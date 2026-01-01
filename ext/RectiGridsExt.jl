module RectiGridsExt

using AxisKeysExtra
using AxisKeysExtra.StructArrays
using RectiGrids

AxisKeysExtra.with_axiskeys(::typeof(grid)) = _grid_with_axiskeys
_grid_with_axiskeys(A) = grid(; named_axiskeys(A)...)
_grid_with_axiskeys(T, A) = grid(T; named_axiskeys(A)...)

function AxisKeysExtra.with_axiskeys(A)
    G = with_axiskeys(grid)(A)
    StructArray{Pair{eltype(G), eltype(A)}}((G, A))
end

end
