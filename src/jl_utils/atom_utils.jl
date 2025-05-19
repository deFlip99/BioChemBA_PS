
# function updateAtom(atom::Atom{T}, fields::Dict{String, Any}) where T
#     for (key, value) in fields
#         if haskey(Atom, key)
#             set_property!(atom, key, value)
#         else
#             @warn "Key $key not found in Atom properties"
#         end
#     end
#     return atom
# end