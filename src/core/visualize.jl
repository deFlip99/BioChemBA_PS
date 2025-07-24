export
    ball_and_stick,
    stick,
    van_der_waals,
    display_model,
    prepare_model


for file in ["prep_atom_info.jl", "system_utils.jl", "representation_utils.jl"]
    include("../jl_utils/$file")
end


const VISUALIZE = ES6Module(asset_path("../typescript/dist/biochemicalvisualization.js"))::Asset

const COMPONENTS = ES6Module(asset_path("../src/interface/components.js"))::Asset

sp = Base.source_path()


hex_colors = [hex(RGB((e ./ 255)...)) for e in ELEMENT_COLORS]

element_color(e) = "0x"*lowercase(get(hex_colors, Int(e), hex_colors[end]))

function prepare_model(ac::AbstractAtomContainer; type="BALL_AND_STICK", acID::Int=0)
	if type == "BALL_AND_STICK"
		return prepare_ball_and_stick_model(ac, acID=acID)
	elseif type == "STICK"
		return prepare_stick_model(ac, acID=acID)
	elseif type == "VAN_DER_WAALS"
		return prepare_van_der_waals_model(ac, acID)
	end

	return nothing
end

function display_model(ac::Union{AbstractAtomContainer, 
              Observable{<:AbstractAtomContainer},
              Vector{<:AbstractAtomContainer},
              Observable{<:Vector{<:AbstractAtomContainer}},
              Vector{Observable{<:AbstractAtomContainer}},           
              Observable{<:Vector{Observable{<:AbstractAtomContainer}}}
              }; 
    type="BALL_AND_STICK", 
    width="100%", 
    height="100%",
    app_mode=false,
    notebook_mode=false
)
 
  if notebook_mode
    width = "200px"
    height = "200px"
    Page(exportable=true, offline=false)
  end


  #wandelt jeden input um in Observable{Vector{Observable{<:AbstractAtomContainer}}}
  ac_obs_vec_obs = 
  if ac isa Observable
    if ac[] isa Vector{Observable{<:AbstractAtomContainer}}
      ac
    elseif ac[] isa Vector{<:AbstractAtomContainer}
      Observable([Observable(system) for system in ac[]])
    elseif ac[] isa AbstractAtomContainer
      Observable([ac])
    else
      error("Unsupported input: $(typeof(ac[]))")
    end
  elseif ac isa Vector{Observable{<:AbstractAtomContainer}}
    Observable(ac)
  elseif ac isa Vector{<:AbstractAtomContainer}
    Observable([Observable(system) for system in ac])
  elseif ac isa AbstractAtomContainer
    Observable([Observable(ac)])
  else
    error("Unsupported input: $(typeof(ac))")
  end

  for inner_obs in ac_obs_vec_obs[]
    on(inner_obs) do changed_ac
      println("Observable changed: ", changed_ac)
      ac_obs_vec_obs[] = ac_obs_vec_obs[]
    end
  end

  #Vertor for the AmberFF systems
  vec_amberff_obs = []



  #Observable Atom idx
  oidx = Observable{Union{Nothing, Dict}}(nothing) 

  #Observable Type
  type = type isa Observable ? type : Observable(type)

  singleType = Observable(type[])

  #Observable updatevent
  oupdate = Observable{Union{Nothing, Dict}}(nothing)

  #Observable reconstruction event
  o_optimize = Observable{Bool}(false) 

  #Observable AC count
  ac_count = Observable(length(ac_obs_vec_obs[]))

  #Observable selected systems
  selected_systems = Observable{Vector}(collect(1:length(ac_obs_vec_obs[])))


# Erzeugt ein Objekt der Form Observable{Vector{Observable{<:Representation}}}
repr_obs_vec_obs = map(ac_obs_vec_obs, type) do systems, current_type
    [map((a, t, id) -> prepare_model(a; type=t, acID=id), sys, Observable(current_type), i) for (i, sys) in enumerate(systems)]
end

#observable representation
or = map((systems) -> concat_representations(systems), repr_obs_vec_obs)
#representation
r = or[]


	if isnothing(r)
		return
	end

	# compute the center of mass of the geometry

  obs_focus_point, focus_point = if or isa Observable
    obs_focus_point = map(r -> mean(center.(vcat(values(r.primitives)...))), or)
    obs_focus_point, obs_focus_point[]
  else
    @show "or no obs"
    nothing, mean(center.(vcat(values(r.primitives)...)))
  end


  if app_mode
    Bonito.use_electron_display(devtools = true)
  end

  dom = DOM.div(; style="display: flex; width: $width; height: $height;")

    App() do session::Session

      Bonito.onload(session, dom, js"""
      function (container){
        Promise.all([$(VISUALIZE), $(COMPONENTS)]).then(([VISUALIZE, COMPONENTS]) => {
          
          // FPS Counter Setup
          const fpsCounter = document.createElement('div');
          fpsCounter.id = 'fps-counter';
          fpsCounter.style.cssText = `
            position: absolute;
            top: 10px;
            right: 10px;
            background: rgba(0, 0, 0, 0.7);
            color: white;
            padding: 5px 10px;
            border-radius: 3px;
            font-family: monospace;
            font-size: 14px;
            z-index: 1000;
            pointer-events: none;
          `;
          fpsCounter.textContent = 'FPS: --';
          
          // FPS Calculation
          let frames = 0;
          let lastTime = performance.now();
          let fps = 0;
          
          function updateFPS() {
            frames++;
            const currentTime = performance.now();
            const deltaTime = currentTime - lastTime;
            
            if (deltaTime >= 1000) { // Update every second
              fps = Math.round((frames * 1000) / deltaTime);
              fpsCounter.textContent = `FPS: ${fps}`;
              frames = 0;
              lastTime = currentTime;
            }
            
            requestAnimationFrame(updateFPS);
          }
          
          //Layout 
          const mainLayout = COMPONENTS.getBaseLayout();
          const secondaryLayout = COMPONENTS.getSecondaryLayout();
          const controlsContainer = COMPONENTS.getControlsContainer();
          
          // Add FPS counter to main layout
          mainLayout.style.position = 'relative';
          mainLayout.appendChild(fpsCounter);
          
          // Start FPS monitoring
          updateFPS();
          
          const contentLayout = mainLayout.querySelector("#main-content");
          contentLayout.appendChild(secondaryLayout.left);
          contentLayout.appendChild(secondaryLayout.right);

          // Controls Container 
          secondaryLayout.right.appendChild(controlsContainer);

          
          const additionalContainer1 = COMPONENTS.getAdditionalContainer1();
          const systemContainer = COMPONENTS.getSystemContainer($(selected_systems[]));


          secondaryLayout.right.appendChild(additionalContainer1);
          secondaryLayout.right.appendChild(systemContainer);

          //Scene 
          const scene = document.createElement("bv-scene");
          scene.setAttribute("id", "bv-scene-1");
          scene.setAttribute("style", "width: 100%; height: 100%;");

          secondaryLayout.left.appendChild(scene);

          document.addEventListener('bv-scene-mounted', () => {
            console.log('component mounted');

            function forwardToScene(eventName, data, component) {
              if (component) {
                  const event = new CustomEvent(eventName, { detail: data });
                  component.dispatchEvent(event);
              } else {
                  console.warn("React Web Component not found!");
              }
            }

            const scene_div = document.getElementById("bv-scene-1-div");

            forwardToScene("set-focus", { focus_point: $focus_point }, scene_div);
            forwardToScene("add-representation", { representation: $r}, scene_div);
            forwardToScene("set-render-mode", { ssao_mode: 2, debug: false }, scene_div);
          });

          

          //Representation Type Context Menu
          const contextMenuReprType = COMPONENTS.getReprTypeContextMenu();

          const menuItems = contextMenuReprType.querySelectorAll('.context-menu-item');
          menuItems.forEach(item => {
            item.addEventListener('click', (event) => {
              console.log("Menu item clicked:", event.target.getAttribute("data-value"));
              
              const targetValue = event.target.getAttribute("data-value");
              if (targetValue) {
                $(type).notify(targetValue);
              }
              contextMenuReprType.style.display = 'none';
              event.stopPropagation();
            });
          });

          $dom.appendChild(mainLayout);
          $dom.appendChild(contextMenuReprType);

          //CONTROLS CONTAINER CONTENT

          //Dropdowns and Buttons from JS module
          const reprTypeDropdown = COMPONENTS.getReprTypeDropdown();
          const backgroundDropdown = COMPONENTS.getBackgroundDropdown();
          const reflectionDropdown = COMPONENTS.getReflectionDropdown();
          const changeButton = COMPONENTS.getChangeButton();


          const dropdownsSection = controlsContainer.querySelector("#controls-container-dropdowns");
          dropdownsSection.appendChild(reprTypeDropdown);
          dropdownsSection.appendChild(backgroundDropdown);
          dropdownsSection.appendChild(reflectionDropdown);

          const buttonSection = controlsContainer.querySelector("#controls-container-buttons");
          buttonSection.appendChild(changeButton);

          document.addEventListener("change-event", () => {
            console.log("Change button clicked!");
            
            const reprVal = reprTypeDropdown.querySelector("select");
            const bgVal = backgroundDropdown.querySelector("select");
            const reflVal = reflectionDropdown.querySelector("select");
            const scene_div = document.getElementById("bv-scene-1-div");
            
            if (reprVal && reprVal.value) {
              const selectedType = reprVal.value;
              $(singleType).notify(selectedType);
            }
            
            if (bgVal && bgVal.value) {
              let colorData;
              
              switch(bgVal.value) {
                case "black":
                  colorData = { r: 0.0, g: 0.0, b: 0.0, a: 1.0 };
                  break;
                case "white":
                  colorData = { r: 1.0, g: 1.0, b: 1.0, a: 1.0 };
                  break;
                case "gray":
                  colorData = { r: 0.3, g: 0.3, b: 0.3, a: 1.0 };
                  break;
                case "lightgray":
                  colorData = { r: 0.7, g: 0.7, b: 0.7, a: 1.0 };
                  break;
                default:
                  colorData = { r: 0.0, g: 0.0, b: 0.0, a: 1.0 };
              }
              
              console.log("Changing background to:", colorData);
              
              scene_div.dispatchEvent(new CustomEvent("change-background", { 
                detail: colorData 
              }));
            }
            
            if (reflVal && reflVal.value) {
              const intensity = parseFloat(reflVal.value);
              console.log("Changing reflection to:", intensity);
            
              scene_div.dispatchEvent(new CustomEvent("set-reflection", { 
                detail: { intensity: intensity }
              }));
            }
          });


          //   GLOBAL EVENTS
          
          const checkboxes = document.querySelectorAll('[id^="system-checkbox-"]');
          checkboxes.forEach(checkbox => {
            checkbox.addEventListener('change', (event) => {

              const newSelection = [];
              
              const allCheckboxes = document.querySelectorAll('[id^="system-checkbox-"]');
              allCheckboxes.forEach(cb => {
                if (cb.checked) {
                  const value = String(cb.value);
                  newSelection.push(value);
                }
              });

              console.log(newSelection);
              $(selected_systems).notify(newSelection);
            });
          });
          

          //optimize structure event
          document.addEventListener("optimize-structure", () => {
            console.log("Optimize structure event triggered");
            $(o_optimize).notify(true);
          });

          //Atom click Event
          document.addEventListener('atom-clicked', event => {
            console.log("atom-clicked event");
            const Idx = String(event.detail.atomIdx);
            const acID = String(event.detail.acId);
            console.log(acID);
            $(oidx).notify({"idx": Idx, "acID": acID});
          });

          //Atom drag Event
          document.addEventListener('atom-dragged', event => {
            console.log("atom-dragged event");
            const Idx = String(event.detail.atomIdx);
            const acID = String(event.detail.acID);
            const newX = Math.trunc(event.detail.newX * 100) / 100;
            const newY = Math.trunc(event.detail.newY * 100) / 100;
            const newZ = Math.trunc(event.detail.newZ * 100) / 100;
            console.log(acID);
            $(oupdate).notify({"idx": Idx,
                                "acID": acID,
                                "field": "r", 
                                "value": [newX, newY, newZ]
                              });
          });

          //handle contextmenu click behavior
          document.addEventListener("contextmenu", event => {
            event.preventDefault();
            contextMenuReprType.style.display = "block";
            contextMenuReprType.style.left = event.clientX + "px";
            contextMenuReprType.style.top = event.clientY + "px";
          });

          document.addEventListener("click", event => {
            if (!contextMenuReprType.contains(event.target)) {
              contextMenuReprType.style.display = "none";
            }
          });

        })
      }
      """)
      # Aufruf des Observables für die Aktualisierung der Infobox
    on(oidx) do payload
      idx = parse(Int, payload["idx"])
      acID = parse(Int, payload["acID"])
      atom_dict = prepAtomByIdx(ac_obs_vec_obs[][acID][], idx)

      Bonito.evaljs(session, js"""
        const data  = $atom_dict;
        const dashBottom = document.getElementById("additional-container-1");
        dashBottom.innerHTML = "";
        for (const [key, value] of Object.entries(data)) {
          const row = document.createElement("div");
          row.textContent = key + ": " + value;
          row.style.padding = "2px";
          dashBottom.appendChild(row);
        }
      """)
    end




    on(singleType) do t 
      for i in selected_systems[]
        i = i isa String ? parse(Int, i) : i
        repr_obs_vec_obs[][i][] = prepare_model(ac_obs_vec_obs[][i][], type=t, acID=i)
      end
      or[] = concat_representations(repr_obs_vec_obs[])
    end


    on(o_optimize) do state
      for ac_obs in ac_obs_vec_obs[]
        push!(vec_amberff_obs, Observable(AmberFF(ac_obs[])))
      end
      for amber in vec_amberff_obs
        optimize_structure!(amber)
      end
      ac_obs_vec_obs[] = [Observable(sys[].system) for sys in vec_amberff_obs]
    end

    # Aufruf für die Aktualisierung des Models
    on(or) do new_rep
      Bonito.evaljs(session, js"""
        $(VISUALIZE).then(VISUALIZE => {
          console.log("or called");
          const scene_div = document.getElementById("bv-scene-1-div");
          scene_div.dispatchEvent(new CustomEvent("set-focus", { detail: { focus_point: $(obs_focus_point[]) } }));
          scene_div.dispatchEvent(new CustomEvent("add-representation", { detail: { representation: $new_rep} }));
        })
      """)
    end


    # Aufruf für die Aktualisierung von Atomen
    on(oupdate) do payload
      println("oupdate called")
      idx = payload["idx"]
      acID = parse(Int, payload["acID"])
      field = payload["field"]
      value = payload["value"]

      updateAtomsInSystem(ac_obs_vec_obs[][acID], Dict(idx => Dict(field => value)))
    end
		Bonito.record_states(session, dom)
  end
end

"""
    ball_and_stick(::AbstractAtomContainer, kwargs...)

Creates and displays a ball-and-stick representation for the given atom container.
"""
ball_and_stick(ac; app_mode=false, kwargs...) = display_model(ac; type="BALL_AND_STICK", app_mode=app_mode, kwargs...)

"""
    stick(::AbstractAtomContainer, kwargs...)

Creates and displays a stick representation for the given atom container.
"""
stick(ac; app_mode=false, kwargs...)          = display_model(ac; type="STICK", app_mode=app_mode, kwargs...)

"""
    van_der_waals(::AbstractAtomContainer, kwargs...)

Creates and displays a van-der-Waals representation for the given atom container.
Sphere radii generally depend on the `radius` field of the corresponding atoms but
are at least 1 Å.
"""
van_der_waals(ac; app_mode=false, kwargs...)  = display_model(ac; type="VAN_DER_WAALS", app_mode=app_mode, kwargs...)