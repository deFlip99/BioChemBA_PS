export
    ball_and_stick,
    stick,
    van_der_waals,
    display_model,
    prepare_model


for file in ["prep_atom_info.jl", "system_utils.jl"]
    include("../jl_utils/$file")
end

const VISUALIZE = ES6Module(asset_path("../typescript/dist/biochemicalvisualization.js"))::Asset

sp = Base.source_path()


hex_colors = [hex(RGB((e ./ 255)...)) for e in ELEMENT_COLORS]

element_color(e) = "0x"*lowercase(get(hex_colors, Int(e), hex_colors[end]))

function prepare_model(ac::AbstractAtomContainer; type="BALL_AND_STICK")
	if type == "BALL_AND_STICK"
		return prepare_ball_and_stick_model(ac)
	elseif type == "STICK"
		return prepare_stick_model(ac)
	elseif type == "VAN_DER_WAALS"
		return prepare_van_der_waals_model(ac)
	end

	return nothing
end

#Löst manuell ein Observable aus
function forceRefresh(obs::Observable{<:AbstractAtomContainer})
    obs[] = obs[]
    return obs
end




function display_model(
    ac::Union{AbstractAtomContainer, Observable{<:AbstractAtomContainer}}; 
    type="BALL_AND_STICK", 
    width="100%", 
    height="90%"
)


  function updateObservable(ob::Observable, new_value)
    if ob isa Observable
      ob[] = new_value
    else
      ob = Observable(new_value)
    end
  end
  
  dom = DOM.div(; style="display: flex; width: $width; height: $height; max-height: 600px;")

  #Observable Atom idx
  oidx = Observable{Union{Nothing, Int}}(nothing) 

  #Observable Type
  type = type isa Observable ? type : Observable(type)

  #Observable ac
  ac = ac isa Observable ? ac : Observable(ac)

  #Observable updatevent
  oupdate = Observable{Union{Nothing, Dict}}(nothing)

  #Observable representation 
  or , r = if ac isa Observable
    if type isa Observable
      or = map((a, t) -> prepare_model(a; type=t), ac, type)
      or, or[]
    else
      or = map(a -> prepare_model(a; type=type), ac)
      or, or[]
    end
  else
    nothing, prepare_model(ac; type=type)
  end



	if isnothing(r)
		return
	end

	# compute the center of mass of the geometry

  obs_focus_point, focus_point = if or isa Observable
    obs_focus_point = map(r -> mean(center.(vcat(values(r.primitives)...))), or)
    obs_focus_point, obs_focus_point[]
  else
    nothing, mean(center.(vcat(values(r.primitives)...)))
  end

  

  #Liste der idx in ac
  atoms_idx_vec = if ac isa Observable
    map(a -> [idx for idx in atoms(a).idx], ac)
  else
    [idx for idx in atoms(ac).idx]
  end
  



	App() do session::Session


		Bonito.onload(session, dom, js"""
      function (container){
        $(VISUALIZE).then(VISUALIZE => {
          parent = $dom.parentNode;
          parent.style.height = '600px

          const scene = document.createElement("bv-scene");
          scene.setAttribute("id", "bv-scene-1");
          scene.setAttribute("style", `flex: 0 0 75%; 
                                        height: 100%;
                                        position: relative;`);
        

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

            scene_div = document.getElementById("bv-scene-1-div");

            forwardToScene("set-focus", { focus_point: $focus_point }, scene_div);
            forwardToScene("add-representation", { representation: $r}, scene_div);
            forwardToScene("set-render-mode", { ssao_mode: 2, debug: false }, scene_div);
          });

          $dom.appendChild(scene);
          
          //DASHBOARD CONTAINER
          const dash_div = document.createElement("div");
          dash_div.setAttribute("id", "dash-div-1");
          dash_div.setAttribute("style", `flex: 0 0 25%; 
                                          height: 100%;
                                          padding: 5px; 
                                          overflow: auto;
                                          display: flex;
                                          flex-direction: column;`);

          //Top Container
          const dashTop = document.createElement("div");
          dashTop.setAttribute("id", "dash-top-div");
          dashTop.setAttribute("style", `flex: 1;
                                          overflow:auto;
                                          padding: 5px;`);

          //Header
          const dashHeader = document.createElement("div");
          dashHeader.setAttribute("style", `padding: 4px;
                                            font-size: 28px; 
                                            font-weight: bold; 
                                            color: #000000;`);
          dashHeader.textContent = "Atom data";

          //Idx - Dropdown
          const dropdownContainer = document.createElement("div");
          dropdownContainer.setAttribute("style", `padding: 4px;`);
          const dropdownSelect = document.createElement("select");
          dropdownSelect.setAttribute("id", "atom-idx-select");

          const idxOptions = $(atoms_idx_vec[])
          idxOptions.forEach(function(idx) {
            const option = document.createElement("option");
            option.value = idx;
            option.textContent = idx;
            dropdownSelect.appendChild(option); 
          });


          //Bottom Container
          const dashBottom = document.createElement("div");
          dashBottom.setAttribute("id", "dash-bottom-div");
          dashBottom.setAttribute("style", `flex: 1;
                                            padding: 5px;
                                            overflow: auto;
                                            border: 1px solid #000000;`);


          //Dropdown Eventlistener
          dropdownSelect.addEventListener("change", event => {
            const selectedIdx = parseInt(event.target.value, 10);
            $(oidx).notify(selectedIdx);
          });

          //on atom click change Infobox
          document.addEventListener("atom-clicked", event => {
            const clickedIdx = event.detail.atomIdx;
              dropdownSelect.value = clickedIdx;
              $(oidx).notify(clickedIdx);
          });


          //Atom drag Event
          document.addEventListener('atom-draged', event => {
            console.log("atom-draged event");
            const Idx = String(event.detail.atomIdx);
            const newX = Math.trunc(event.detail.newX * 100) / 100;
            const newY = Math.trunc(event.detail.newY * 100) / 100;
            const newZ = Math.trunc(event.detail.newZ * 100) / 100;
                $(oupdate).notify({ idx:    Idx,
                                    field:  "r",
                                    value:  [newX, newY, newZ]});
          });

          //append to DOM
          dropdownContainer.appendChild(dropdownSelect);
          dashTop.appendChild(dashHeader)
          dashTop.appendChild(dropdownContainer);
          dash_div.appendChild(dashTop);
          dash_div.appendChild(dashBottom);

          $dom.appendChild(dash_div);


          // Context-menu
          const contextMenu = document.createElement("bv-context-menu");
          contextMenu.setAttribute("id", "bv-context-menu-1");
          contextMenu.setAttribute("style", `position: fixed;
                                          display: none;
                                          z-index: 9999;
                                          background-color: white;
                                          border: 1px solid black;
                                          padding: 5px;
          `);

          contextMenu.innerHTML = `
            <div id="BallAndStick"  style="padding:4px; cursor:pointer; color:#000000;">
              Ball and Stick
            </div>
            <div id="VanDerWaal" style="padding:4px; cursor:pointer; color:#000000;">
              Van der Waals
            </div>
            <div id="Stick" style="padding:4px; cursor:pointer; color:#000000;">
              Stick
            </div>
            `;

          contextMenu.addEventListener("click", event => {
            const targetID = event.target.id;
            switch(targetID) {
              case "BallAndStick":
                $(type).notify("BALL_AND_STICK");
                break;
              case "VanDerWaal":
                $(type).notify("VAN_DER_WAALS");
                break;
              case "Stick":
                $(type).notify("STICK");
                break;
              default:
                console.log("Unknown target ID:", targetID);
            }
          })

          document.addEventListener("contextmenu", (event) => {
            event.preventDefault();
            contextMenu.style.display = "block";
            contextMenu.style.left = `${event.clientX}px`;
            contextMenu.style.top = `${event.clientY}px`;
          });
          document.addEventListener("click", (event) => {
            contextMenu.style.display = "none";
          });

          $dom.appendChild(contextMenu);
 
        })

		  }
		""")


    # Aufruf des Observables für die Aktualisierung der Infobox
      on(oidx) do idx
      atom_dict = prepAtomByIdx(ac isa Observable ? ac[] : ac, Int(idx))

      Bonito.evaljs(session, js"""
        const data  = $atom_dict;
        const dashBottom = document.getElementById("dash-bottom-div");
        dashBottom.innerHTML = "";
        for (const [key, value] of Object.entries(data)) {
          const row = document.createElement("div");
          row.textContent = key + ": " + value;
          row.style.padding = "2px";
          dashBottom.appendChild(row);
        }
      """)
      end



    # Aufruf für die Aktualisierung des Models
    on(or) do new_rep
      Bonito.evaljs(session, js"""
        $(VISUALIZE).then(VISUALIZE => {
          console.log("or called");
          const scene_div = document.getElementById("bv-scene-1-div");
          scene_div.dispatchEvent(new CustomEvent("set-focus", { detail: { focus_point: $(obs_focus_point[]) } }));
          scene_div.dispatchEvent(new CustomEvent("add-representation", { detail: { representation: $new_rep} }));
        }
      )""")
    end


    # Aufruf für die Aktualisierung von Atomen
    on(oupdate) do payload
      Bonito.evaljs(session, js"""
      console.log("oupdate called");
        """)
      # detail = Dict()
      # payloads = [x for x in payload]
      # for p in payloads
      #   key = p[0]
      #   for d in p[1] 
      #     field = d[0]
      #     value = d[1]
      #     detail[key] = Dict(field => value)
      #   end
      # end
        idx =   payload["idx"]
        field = payload["field"]
        value = payload["value"]

      updateAtomsInSystem(ac, Dict(idx => Dict(field => value)))
      oidx[] = parse(Int, idx)
    end

		Bonito.record_states(session, dom)
  end
end

"""
    ball_and_stick(::AbstractAtomContainer, kwargs...)

Creates and displays a ball-and-stick representation for the given atom container.
"""
ball_and_stick(ac; kwargs...) = display_model(ac; type="BALL_AND_STICK", kwargs...)

"""
    stick(::AbstractAtomContainer, kwargs...)

Creates and displays a stick representation for the given atom container.
"""
stick(ac; kwargs...)          = display_model(ac; type="STICK", kwargs...)

"""
    van_der_waals(::AbstractAtomContainer, kwargs...)

Creates and displays a van-der-Waals representation for the given atom container.
Sphere radii generally depend on the `radius` field of the corresponding atoms but
are at least 1 Å.
"""
van_der_waals(ac; kwargs...)  = display_model(ac; type="VAN_DER_WAALS", kwargs...)