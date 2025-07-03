function concat_representations(representations::Vector{Representation{T}}) where {T <: Real}
    if isempty(representations)
        return Representation{T}()
    end

    if length(representations) == 1
        return representations[1]
    end
    
    combined_primitives = Dict{String, Vector{GeometryPrimitive{3, T}}}()
    combined_meta_data = Vector{Vector{Union{String, Int}}}()
    combined_colors = Dict{String, Vector{String}}()
    
    for (repr_id, repr) in enumerate(representations)
        for (primitive_type, primitives) in repr.primitives
            if !haskey(combined_primitives, primitive_type)
                combined_primitives[primitive_type] = Vector{GeometryPrimitive{3, T}}()
            end
            append!(combined_primitives[primitive_type], primitives)
        end
        
        for meta_entry in repr.meta_data
            extended_meta = vcat(meta_entry, repr_id)
            push!(combined_meta_data, extended_meta)
        end
    
        for (color_type, colors) in repr.colors
            if !haskey(combined_colors, color_type)
                combined_colors[color_type] = Vector{String}()
            end
            append!(combined_colors[color_type], colors)
        end
    end
    
    return Representation{T}(
        primitives=combined_primitives,
        meta_data=combined_meta_data,
        colors=combined_colors
    )
end

function concat_representations(representations::Representation{T}...) where {T <: Real}
    collected = collect(representations)
    
    if length(collected) == 1
        return collected[1]
    end
    
    return concat_representations(collected)
end

function concat_representations(representations::Observable{Vector{Representation{T}}}) where {T <: Real}
    repr_vec = representations[]
    if length(repr_vec) == 1
        return repr_vec[1]
    end
    return concat_representations(repr_vec)
end

function concat_representations(representations::Vector{Observable{Representation{T}}}) where {T <: Real}
    if isempty(representations)
        return Representation{T}()
    end

    if length(representations) == 1
        return representations[1][]
    end
    
    repr_values = [obs[] for obs in representations]
    return concat_representations(repr_values)
end

function concat_representations(representations::Observable{<:Vector{Observable{Representation{T}}}}) where {T <: Real}
    obs_repr_vec = representations[]
    if isempty(obs_repr_vec)
        return Representation{T}()
    end
    
    if length(obs_repr_vec) == 1
        return obs_repr_vec[1][]
    end

    return concat_representations(obs_repr_vec)
end