module AxisKeysExtra

using Reexport
@reexport using AxisKeys
using AxisKeys: keyless
using RectiGrids
using StructArrays
import Base: eachslice

export axiskeys_grid, with_axiskeys

if VERSION > v"1.9-DEV"
    import Base: stack
else
    import Compat: stack
    export stack
end

if VERSION > v"1.9-DEV"
    # fix for AxisKeys
    Base.uncolon(inds, I) = Base.uncolon(inds)
end

@static if VERSION > v"1.9-DEV"
    # AxisKeys defines their own eachslice method, so here we explicitly call the base AbstractArray one
    _base_eachslice(A; dims) = @invoke eachslice(A::AbstractArray; dims)
else
    using SplitApplyCombine
    _base_eachslice(A; dims) = splitdimsview(A, dims)
end


function stack(A::KeyedArray; dims::Colon=:)
    data = Base.@invoke stack(A::AbstractArray; dims)
    if !allequal(named_axiskeys(a) for a in A)
        throw(DimensionMismatch("stack expects uniform axiskeys for all arrays"))
    end
    akeys = (; named_axiskeys(first(A))..., named_axiskeys(A)...)
    KeyedArray(data; akeys...)
end

function eachslice(A::KeyedArray; dims)
    dims_ix = AxisKeys.dim(A, dims) |> Tuple
    data = _base_eachslice(A::AbstractArray; dims=dims_ix)
    return KeyedArray(NamedDimsArray(data, map(d -> dimnames(A, d), dims_ix)), map(d -> axiskeys(A, d), dims_ix))
end

function eachslice(A::NamedDimsArray; dims)
    dims_ix = AxisKeys.dim(A, dims) |> Tuple
    data = _base_eachslice(A::AbstractArray; dims=dims_ix)
    return NamedDimsArray(data, map(d -> dimnames(A, d), dims_ix))
end


axiskeys_grid(A) = grid(; named_axiskeys(A)...)
function with_axiskeys(A)
    G = axiskeys_grid(A)
    StructArray{Pair{eltype(G), eltype(A)}}((G, A))
end

with_axiskeys(f::Union{typeof.((argmax, argmin))...}) = A -> ix_to_axiskeys(A, f(A))
with_axiskeys(f::Union{typeof.((findmax, findmin))...}) = A -> let
    (x, ix) = f(A)
    (x, ix_to_axiskeys(A, ix))
end

ix_to_axiskeys(A, ix) = NamedTuple{dimnames(A)}(map((i, vs) -> vs[i], Tuple(ix), axiskeys(A)))

end
