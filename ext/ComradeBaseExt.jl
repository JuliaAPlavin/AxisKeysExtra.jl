module ComradeBaseExt

using AxisKeysExtra
using AxisKeysExtra.DataPipes
using ComradeBase
import ComradeBase.DimensionalData
using Unitful

AxisKeys.KeyedArray(im::ComradeBase.IntensityMap) = @p let
	@invoke KeyedArray(im::DimensionalData.AbstractDimArray)
	KeyedArray(AxisKeys.keyless_unname(__); map(named_axiskeys(__)) do ak
		(ak.data * u"rad")::AbstractRange
	end...)
	reverse(dims=1)
end

ComradeBase.IntensityMap(img::KeyedArray) =
	ComradeBase.IntensityMap(AxisKeys.keyless_unname(img), ComradeBase.RectiGrid(img))

ComradeBase.RectiGrid(a::KeyedArray) = @p let
	axiskeys(a)
	map() do ak
		ustrip(ak .|> u"rad")::AbstractRange
	end
	ComradeBase.RectiGrid(NamedTuple{(:X, :Y)}(__))
end

end
