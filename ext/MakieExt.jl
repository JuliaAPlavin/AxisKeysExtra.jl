module MakieExt

using AxisKeysExtra
using AxisKeysExtra: _ustrip
using AxisKeysExtra.AxisKeys: keyless_unname
using Makie
import Makie: convert_arguments


for T in (PointBased, Type{<:Errorbars}, Type{<:Rangebars}, Type{<:Band})
    @eval convert_arguments(ct::$T, x::KeyedArray{<:Any,1}) =
        convert_arguments(ct, _ustrip(only(axiskeys(x))), keyless_unname(x) |> _ustrip)
end

function convert_arguments(ct::ImageLike, x::KeyedArray{<:Any,2})
    aks = axiskeys(x)
    edges = map(ak -> _ustrip.(extrema(ak) .+ (-step(ak)/2, step(ak)/2)), aks)
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

convert_arguments(ct::Type{<:Union{Volume,VolumeSlices}}, x::KeyedArray{<:Any,3}) =
    convert_arguments(ct, _ustrip.(axiskeys(x))..., keyless_unname(x) |> _ustrip)

# also make sense for irregular: tricontourf, wireframe
plotfs_1d = (:scatter, :lines, :scatterlines, :band, :errorbars, :rangebars, :stairs, :stem, :barplot)
plotfs_2d = (:heatmap, :image, :contour, :contourf, :contour3d, :surface, :wireframe, :arrows)
plotfs_3d = (:volume, :volumeslices)
for plotf in (plotfs_1d..., plotfs_2d..., plotfs_3d...)
    plotf_excl = Symbol(plotf, :!)
    KA_TYPE = KeyedArray{<:Any, plotf in plotfs_3d ? 3 : plotf in plotfs_2d ? 2 : plotf in plotfs_1d ? 1 : error()}
    AxisT = plotf in (plotfs_3d..., :surface, :wireframe) ? Axis3 : Axis

    @eval function Makie.$plotf(A::Observable{<:$KA_TYPE}; figure=(;), kwargs...)
        fig = Figure(; figure...)
        ax, plt = $plotf(fig[1,1], A; kwargs...)
        Makie.FigureAxisPlot(fig, ax, plt)
    end

    @eval function Makie.$plotf(pos::Union{GridPosition, GridSubposition}, A::Observable{<:$KA_TYPE}; axis=(;), kwargs...)
        # XXX: all observable changes should be taken into account
        akeys = axiskeys(A[])
        signs = map(akeys) do ak
            d = diff(ak)
            if all(≥(zero(eltype(d))), d)
                1
            elseif all(≤(zero(eltype(d))), d)
                -1
            else
                error("Axis keys must be monotonically increasing or decreasing; got $ak.")
            end
        end
        use_dataaspect = ndims(A[]) > 1 && allequal(map(eltype, akeys))
        ax_kwargs = merge(
            use_dataaspect ? (aspect=$(AxisT == Axis3 ? QuoteNode(:data) : DataAspect()),) : (;),
            (
                xreversed=signs[1] < 0,
                xlabel=dimlabel(A[], 1),
            ),
            ndims(A[]) ≥ 2 ? (
                yreversed=signs[2] < 0,
                ylabel=dimlabel(A[], 2),
            ) : (;),
            ndims(A[]) ≥ 3 ? (
                zreversed=signs[3] < 0,
                zlabel=dimlabel(A[], 3),
            ) : (;),
            axis,
        )
        ax = $AxisT(pos; ax_kwargs...)
        plt = $plotf_excl(ax, A; kwargs...)
        Makie.AxisPlot(ax, plt)
    end

    @eval Makie.$plotf(pos::Union{GridPosition, GridSubposition}, A::$KA_TYPE; kwargs...) = $plotf(pos, Observable(A); kwargs...)
    @eval Makie.$plotf(A::$KA_TYPE; kwargs...) = $plotf(Observable(A); kwargs...)
end

end
