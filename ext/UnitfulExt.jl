module UnitfulExt

using Unitful
import AxisKeysExtra: _dimlabel, _ustrip

function _dimlabel(dimname, axiskeys::AbstractVector{<:Quantity})
	u = unit(eltype(axiskeys))
	"$dimname ($u)"
end

_ustrip(x::Quantity) = ustrip(x)
_ustrip(x::AbstractArray{<:Quantity}) = ustrip.(x)
_ustrip(x::AbstractRange{<:Quantity}) = ustrip.(x)  # preserves range; separate method from the above just for clarity
_ustrip(x::Array{<:Quantity}) = ustrip(x)  # reinterprets

end
