module AxisKeysExtra

using Reexport
@reexport using AxisKeys
using AxisKeys: keyless
using RectiGrids
using StructArrays
using StructArrays: component, components
import Base: eachslice

export axiskeys_grid, with_axiskeys

if VERSION > v"1.9-DEV"
    import Base: stack
else
    import Compat: stack
    export stack
end

include("structarrays.jl")
include("eachslice.jl")
include("stack.jl")
include("functions.jl")


if VERSION > v"1.9-DEV"
    # fix for AxisKeys
    Base.uncolon(inds, I) = Base.uncolon(inds)
end


# https://github.com/mcabbott/AxisKeys.jl/pull/110
NdaKa{L,T,N} = NamedDimsArray{L,T,N,<:KeyedArray{T,N}}
KaNda{L,T,N} = KeyedArray{T,N,<:NamedDimsArray{L,T,N}}
Base.@propagate_inbounds (A::KaNda)(c=nothing; kw...) = AxisKeys.getkey(A, c; kw...)
Base.@propagate_inbounds (A::NdaKa)(c=nothing; kw...) = AxisKeys.getkey(A, c; kw...)
Base.@propagate_inbounds function AxisKeys.getkey(A, c::Union{Nothing, Colon}; kw...)
    list = dimnames(A)
    issubset(keys(kw), list) || error("some keywords not in list of names!")
    args = map(s -> Base.sym_in(s, keys(kw)) ? getfield(values(kw), s) : Colon(), list)
    isnothing(c) ? A(args...) : A(args..., c)
end

end
