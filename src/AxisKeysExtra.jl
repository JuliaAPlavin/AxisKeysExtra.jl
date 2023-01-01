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

end
