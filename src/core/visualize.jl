export
    ball_and_stick,
    stick,
    van_der_waals,
    display_model

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

function display_model(
    ac::Union{AbstractAtomContainer, Observable{<:AbstractAtomContainer}}; 
    type="BALL_AND_STICK", 
    width="80%", 
    height="60%"
)
  dom = DOM.div(;style="width: $width; height: $height;")

  obs_type = Observable(type)
	# or, r = if ac isa Observable
	# 	or = map(a -> prepare_model(a; type=type), ac)
	# 	or, or.val
	# else
	# 	nothing, prepare_model(ac; type=type)
	# end

  obs_model = map(t -> prepare_model(ac; type=t), obs_type)
  r = obs_model[]

	if isnothing(r)
		return
	end

	# compute the center of mass of the geometry
	focus_point = mean(center.(vcat(values(r.primitives)...)))

	App() do session::Session

		Bonito.onload(session, dom, js"""
      function (container){
        $(VISUALIZE).then(VISUALIZE => {
          parent = $dom.parentNode;
          parent.style.height = '100vh';

          const scene = document.createElement("bv-scene");
          scene.setAttribute("id", "bv-scene-1");
          scene.setAttribute("width", $width);
          scene.setAttribute("height", $height);
        

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

          // Context-menu
          const contextMenu = document.createElement("bv-context-menu");
          contextMenu.setAttribute("id", "bv-context-menu-1");
          contextMenu.style.position = "fixed";
          contextMenu.style.display = "none";
          contextMenu.style.zIndex = "9999";
          contextMenu.style.backgroundColor = "white";
          contextMenu.style.border = "1px solid black";
          contextMenu.style.padding = "5px";
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
                $(obs_type).notify("BALL_AND_STICK")
              break;
              case "VanDerWaal":
                $(obs_type).notify("VAN_DER_WAALS")
              break;
              case "Stick":
                $(obs_type).notify("STICK")
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


    on(obs_type) do new_type
      new_model = prepare_model(ac isa Observable ? ac[] : ac; type=new_type)
      Bonito.evaljs(session, js"""
        $(VISUALIZE).then(VISUALIZE => {
          const scene_div = document.getElementById("bv-scene-1-div");
          scene_div.dispatchEvent(new CustomEvent("add-representation", { detail: { representation: $new_model, replace: true } }));
          VISUALIZE.render()
        }
      )""")
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
