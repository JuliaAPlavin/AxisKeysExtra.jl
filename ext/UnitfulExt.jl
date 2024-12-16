module UnitfulExt

using Unitful
import AxisKeysExtra: _dimlabel, _ustrip

function _dimlabel(dimname, axiskeys::AbstractVector{<:Quantity})
	u = unit(eltype(axiskeys))
	"$(_dimlabel(dimname, nothing)) ($u)"
end

_ustrip(x::Union{Quantity,AbstractArray{<:Quantity}}) = ustrip(x)

end
