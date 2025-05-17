function updateAtomsInSystem(ac::Union{AbstractAtomContainer, Observable{<:AbstractAtomContainer}}, 
                            detail::Dict{String, <:Dict{String, <:Any}})
    vac = ac isa Observable ? ac[] : ac
    
    # update ac
    for (idx, fields) in detail
        idx = parse(Int, idx)
        atom = atom_by_idx(vac, idx)
        for (field, value) in fields
            try 
                setproperty!(atom, Symbol(field), value)
            catch e
                @warn "updating ac failed on atom: $idx with error: $e"
            end
        end
    end
    
    # notifys the ac observable
    if ac isa Observable
        ac[] = vac  
    end
    
    return ac
end

