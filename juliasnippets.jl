  #Liste der idx in ac
  # atoms_idx_vec = if ac_obs_vec_obs isa Observable
  #   map(ac_vec_obs) do systems_vec
  #     systems_array = systems_vec isa Vector ? systems_vec : [systems_vec]
  #     first_system = systems_array isa Observable ? systems_array[][1] : systems_array[1]
  #     if first_system isa Observable
  #       first_system = first_system[]
  #     end
  #     @show first_system
  #     [idx for idx in atoms(first_system).idx]
  #   end
  # else
  #   systems_array = ac_vec_obs isa Vector ? ac_vec_obs : [ac_vec_obs]
  #   first_system = systems_array isa Observable ? systems_array[][1] : systems_array[1]
  #   if first_system isa Observable
  #     first_system = first_system[]
  #   end
  #   @show first_system
  #   [idx for idx in atoms(first_system).idx]
  # end


    # ac_vec = if ac isa Vector || (ac isa Observable && ac[] isa Vector)
  #   ac
  # else
  #   [ac]
  # end

  # ac_vec_obs = ac_vec isa Observable ? ac_vec : Observable(ac_vec)

  # systems_repr = map(ac_vec_obs, type) do systems_vec, current_type
  #   systems_array = systems_vec isa Vector ? systems_vec : [systems_vec]
  #   Dict(i => prepare_model(sys isa Observable ? sys[] : sys; type=current_type, acID=i) for (i, sys) in enumerate(systems_array))
  # end

  # systems_repr_vec = map(systems_repr) do repr_dict
  #   [repr for (_, repr) in sort(collect(repr_dict), by=first)]
  # end

  # or = map(systems_repr_vec) do repr_vec
  #   concat_representations(repr_vec)
  # end

  # r = or[]

  #Observable representation 
  # or , r = if ac isa Observable
  #   if type isa Observable
  #     or = map((a, t) -> prepare_model(a; type=t), ac, type)
  #     or, or[]
  #   else
  #     or = map(a -> prepare_model(a; type=type), ac)
  #     or, or[]
  #   end
  # else
  #   nothing, prepare_model(ac; type=type)
  # end





#     //on atom click change Infobox
#   document.addEventListener("atom-clicked", event => {
#     const clickedIdx = event.detail.atomIdx;
#     const clickedAcID = String(event.detail.acID);
#       dropdownSelectId.value = clickedIdx;
#       $(oidx).notify({idx: clickedIdx,
#                       acID: clickedAcID});
#   });

      on(oidx) do payload
        idx = payload["idx"]
        acID = parse(Int, payload["acID"])
        @show("oidx acID: ", acID)
        atom_dict = prepAtomByIdx(ac_obs_vec_obs[][Int(acID)][], Int(idx))

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