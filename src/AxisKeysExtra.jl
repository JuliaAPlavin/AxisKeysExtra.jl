module AxisKeysExtra

using Reexport
@reexport using AxisKeys
using StructArrays
using StructArrays: component, components
import DataPipes

export with_axiskeys, dimlabel

include("structarrays.jl")
include("functions.jl")


_ustrip(x) = x

end
