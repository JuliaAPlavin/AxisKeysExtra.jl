module RectiGridsExt

using AxisKeysExtra
using AxisKeysExtra.StructArrays
using RectiGrids

AxisKeysExtra.with_axiskeys(::typeof(grid)) = A -> grid(; named_axiskeys(A)...)

function AxisKeysExtra.with_axiskeys(A)
    G = with_axiskeys(grid)(A)
    StructArray{Pair{eltype(G), eltype(A)}}((G, A))
end

end
