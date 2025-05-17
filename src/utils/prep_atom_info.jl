function prepAtomByIdx(ac::AbstractAtomContainer{T}, idx::Int) where T
    atom = atom_by_idx(ac, idx)
    return Dict(
        "Name"           => "$(atom.name)",
        "Element"        => "$(String(Symbol(atom.element)))",
        "idx"            => "$(atom.idx)",
        "Position"       => "$(join(string.(atom.r), ", "))",
        "Velocity"       => "$(join(string.(atom.v), ", "))",
        "Force"          => "$(join(string.(atom.F), ", "))",
        "formal_charge"  => "$(atom.formal_charge)",
        "Charge"         => "$(atom.charge)",
        "Radius"         => "$(atom.radius)",
        "Chain"          => isnothing(atom.chain_idx) ? "N/A" : "$(atom.chain_idx)",
        "Fragment"       => isnothing(atom.fragment_idx) ? "N/A" : "$(atom.fragment_idx)"
    )
end
