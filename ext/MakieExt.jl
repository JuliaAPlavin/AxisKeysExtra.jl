module MakieExt

using AxisKeysExtra
using AxisKeysExtra: _ustrip
using AxisKeysExtra.AxisKeys: keyless_unname
using Makie
import Makie: convert_arguments


function convert_arguments(ct::ImageLike, x::KeyedArray{<:Any,2})
	aks = axiskeys(x)
	edges = map(ak -> _ustrip.(extrema(ak)), aks)  # XXX: edges "off by one"?
	if step(aks[1]) < zero(step(aks[1]))
		x = reverse(x, dims=1)
	end
	if step(aks[2]) < zero(step(aks[2]))
		x = reverse(x, dims=2)
	end
	convert_arguments(ct, edges..., keyless_unname(x) |> _ustrip)
end

convert_arguments(ct::GridBased, x::KeyedArray{<:Any,2}) =
    convert_arguments(ct, _ustrip.(axiskeys(x))..., keyless_unname(x) |> _ustrip)

convert_arguments(ct::Type{<:Arrows}, x::KeyedArray{<:Any,2}) =
    convert_arguments(ct, Point2f.(_ustrip(axiskeys(x, 1)), _ustrip(axiskeys(x, 2))') |> vec, keyless_unname(x) |> _ustrip |> vec)

for plotf in (:heatmap, :image, :contour, :contourf, :arrows)
    plotf_excl = Symbol(plotf, :!)
    KA_TYPE = KeyedArray{<:Any,2}

	@eval function Makie.$plotf(A::Observable{<:$KA_TYPE}; figure=(;), kwargs...)
		fig = Figure(; figure...)
		ax, plt = $plotf(fig[1,1], A; kwargs...)
		Makie.FigureAxisPlot(fig, ax, plt)
	end

	@eval function Makie.$plotf(pos::Union{GridPosition, GridSubposition}, A::Observable{<:$KA_TYPE}; axis=(;), kwargs...)
		# XXX: all observable changes should be taken into account
		akeys = axiskeys(A[])
		@assert all(ak -> ak isa AbstractRange, akeys)
		ax_kwargs = merge(
			allequal(map(eltype, akeys)) ? (aspect=DataAspect(),) : (;),
			(
				xreversed=step(akeys[1]) < zero(step(akeys[1])),
				yreversed=step(akeys[2]) < zero(step(akeys[2])),
				xlabel=dimlabel(A[], 1),
				ylabel=dimlabel(A[], 2)
			),
			axis
		)
		ax = Axis(pos; ax_kwargs...)
		plt = $plotf_excl(ax, A; kwargs...)
		Makie.AxisPlot(ax, plt)
	end

    @eval Makie.$plotf(pos::Union{GridPosition, GridSubposition}, A::$KA_TYPE; kwargs...) = $plotf(pos, Observable(A); kwargs...)
    @eval Makie.$plotf(A::$KA_TYPE; kwargs...) = $plotf(Observable(A); kwargs...)
end

end
