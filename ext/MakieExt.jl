module MakieExt

using AxisKeysExtra
import AxisKeysExtra: _ustrip
using AxisKeysExtra.AxisKeys: keyless_unname
using Makie


_ustrip(x::AbstractArray{<:Union{AbstractString,Symbol,AbstractChar}}) = Categorical(x)

# hack: otherwise need a more involved overload of Makie.numbers_to_colors
Base.convert(::Type{<:Union{T,Array{T,N}}}, X::KeyedArray{T,N}) where {T<:Makie.Colorant,N} = AxisKeys.keyless_unname(X)::Array{T,N}


for T in (PointBased, Type{<:Errorbars}, Type{<:Rangebars}, Type{<:Band})
    @eval Makie.expand_dimensions(::$T, x::KeyedArray) = (_ustrip(only(axiskeys(x))), x |> _ustrip)
    @eval Makie.expand_dimensions(::$T, x::KeyedArray{<:Point}) = (x,)
    @eval Makie.expand_dimensions(::$T, x::KeyedArray{<:Tuple{Point,Point}}) = (x,)
end

for T in (Type{<:Errorbars}, Type{<:Rangebars}, Type{<:Band})
    @eval Makie.convert_arguments(ct::$T, x::KeyedArray{<:Any,1}) =
        convert_arguments(ct, _ustrip(only(axiskeys(x))), x |> _ustrip)
end

# two functions that are basically the same
# for some reason, ImageLike requires expand_dimensions, while Volume requires convert_arguments
function Makie.expand_dimensions(ct::ImageLike, x::KeyedArray{<:Any,2})
    aks = axiskeys(x)
    edges = map(aks) do ak
        _ustrip.((first(ak), last(ak)) .+ (-step(ak)/2, +step(ak)/2))
    end
    (edges..., x |> _ustrip)
end

function Makie.convert_arguments(ct::Type{<:Union{Volume,VolumeSlices,Voxels}}, x::KeyedArray{<:Any,3})
    aks = axiskeys(x)
    edges = map(aks) do ak
        _ustrip.((first(ak), last(ak)) .+ (-step(ak)/2, +step(ak)/2))
    end
    convert_arguments(ct, edges..., x |> _ustrip)
end

Makie.Isoband.isobands(xs::AbstractVector, ys::AbstractVector, zs::KeyedArray, lows::AbstractVector, highs::AbstractVector) =
    Makie.Isoband.isobands(xs, ys, keyless_unname(zs), lows, highs)

Makie.expand_dimensions(ct::GridBased, x::KeyedArray{<:Any,2}) = (_ustrip.(axiskeys(x))..., x |> _ustrip)
# https://github.com/MakieOrg/Makie.jl/issues/4204:
Makie.expand_dimensions(ct::Union{VertexGrid,CellGrid}, x::KeyedArray{<:Any,2}) = (_ustrip.(axiskeys(x))..., x |> _ustrip)

Makie.convert_arguments(ct::Type{<:Arrows}, x::KeyedArray{<:Any,2}) =
    Point2f.(_ustrip(axiskeys(x, 1)), _ustrip(axiskeys(x, 2))'), x |> _ustrip

Makie.plot!(p::Arrows{<:Tuple{AbstractMatrix, KeyedArray}}) = arrows2d!(p, p.attributes, lift(vec, p[1]), lift(vec, p[2]))

if isdefined(Makie, :_is_3d_arrows)
    # Makie 0.24
    Makie._is_3d_arrows(::Union{KeyedArray{<:Any,2}, Observable{<:KeyedArray{<:Any,2}}}) = false
    Makie._is_3d_arrows(::Union{KeyedArray{<:Any,3}, Observable{<:KeyedArray{<:Any,3}}}) = true
end

function Makie.plot!(ax::Makie.AbstractAxis, plot::Union{
        Scatter{<:Tuple{KeyedArray}},
        Lines{<:Tuple{KeyedArray}},
        ScatterLines{<:Tuple{KeyedArray}},
        Stairs{<:Tuple{KeyedArray}},
        Stem{<:Tuple{KeyedArray}},
        BarPlot{<:Tuple{KeyedArray}},
        Rangebars{<:Tuple{KeyedArray}},
        Band{<:Tuple{KeyedArray,KeyedArray}},

        Image{<:Tuple{Any,Any,KeyedArray}},
        Heatmap{<:Tuple{Any,Any,KeyedArray}},
        Contour{<:Tuple{Any,Any,KeyedArray}},
        Contourf{<:Tuple{Any,Any,KeyedArray}},

        Contour3d{<:Tuple{Any,Any,KeyedArray}},
        Surface{<:Tuple{Any,Any,KeyedArray}},

        Arrows{<:Tuple{AbstractMatrix, KeyedArray}},

        Volume{<:Tuple{Any,Any,Any,KeyedArray}},
        VolumeSlices{<:Tuple{Any,Any,Any,KeyedArray}},
        Voxels{<:Tuple{Any,Any,Any,KeyedArray}},
    })
    attrs = (axis=default_axis_attributes(plot), plot=default_plot_attributes(plot))
	PT = typeof(plot)
	@invoke plot!(ax, plot::supertype(PT))
	upd_axplt_attrs!(ax, plot, attrs)
end


function default_axis_attributes(plot::Union{
        Scatter{<:Tuple{KeyedArray}},
        Lines{<:Tuple{KeyedArray}},
        ScatterLines{<:Tuple{KeyedArray}},
        Stairs{<:Tuple{KeyedArray}},
        Stem{<:Tuple{KeyedArray}},
        BarPlot{<:Tuple{KeyedArray}},
        Rangebars{<:Tuple{KeyedArray}},
        Band{<:Tuple{KeyedArray,KeyedArray}},
    })
    A = plot[1]
    (xlabel=(@lift dimlabel($A, 1)),)
end

function default_axis_attributes(plot::Union{
        Image{<:Tuple{Any,Any,KeyedArray}},
        Heatmap{<:Tuple{Any,Any,KeyedArray}},
        Contour{<:Tuple{Any,Any,KeyedArray}},
        Contourf{<:Tuple{Any,Any,KeyedArray}},
        Contour3d{<:Tuple{Any,Any,KeyedArray}},
        Surface{<:Tuple{Any,Any,KeyedArray}},
        Arrows{<:Tuple{AbstractMatrix, KeyedArray}},
    })
    A = plot isa Arrows ? plot[2] : plot[3]
    use_dataaspect = @lift have_same_units(axiskeys($A))
    merge(
        use_dataaspect[] ? (;aspect=DataAspect()) : (;),
        (
            xlabel=(@lift dimlabel($A, 1)),
            ylabel=(@lift dimlabel($A, 2)),
            xreversed=(@lift is_revrange(axiskeys($A, 1))),
            yreversed=(@lift is_revrange(axiskeys($A, 2))),
        ),
    )
end

function default_plot_attributes(plot::Union{
        Image{<:Tuple{Any,Any,KeyedArray}},
        Heatmap{<:Tuple{Any,Any,KeyedArray}},
    })
    A_obs = plot[3]
    (;inspector_label=function(plot, index, position)
        A = A_obs[]
		index_int = round.(Int, index)  # XXX: interpolate if non-integer?
		ak_strs = map(dimnames(A), axiskeys(A), index_int) do n, aks, i
			Makie.@sprintf "%s=%.2g" n aks[i]
		end
		"A($(join(ak_strs, ", "))) = $(Makie.color2text(A[index_int...]))"
		# XXX: default Makie tooltip shows different names for heatmap/image
	end)
end

function default_axis_attributes(plot::Union{
        Volume{<:Tuple{Any,Any,Any,KeyedArray}},
        VolumeSlices{<:Tuple{Any,Any,Any,KeyedArray}},
        Voxels{<:Tuple{Any,Any,Any,KeyedArray}},
    })
    A = plot[4]
    use_dataaspect = @lift have_same_units(axiskeys($A))
#     dataaspect = N == 3 || T ∈ (Surface, Wireframe) ? :data : DataAspect()
    merge(
        use_dataaspect[] ? (;aspect=DataAspect()) : (;),
        (
            xlabel=(@lift dimlabel($A, 1)),
            ylabel=(@lift dimlabel($A, 2)),
            zlabel=(@lift dimlabel($A, 3)),
            xreversed=(@lift is_revrange(axiskeys($A, 1))),
            yreversed=(@lift is_revrange(axiskeys($A, 2))),
            zreversed=(@lift is_revrange(axiskeys($A, 3))),
        ),
    )
end

is_revrange(x::AbstractVector) = false
is_revrange(x::AbstractRange) = step(x) < zero(step(x))

function upd_axplt_attrs!(ax::Makie.AbstractAxis, plot::Plot, attrs::NamedTuple)
	for (k, v) in pairs(attrs.axis)
		upd_axplt_attr!(ax, k, v)
	end
	for (k, v) in pairs(attrs.plot)
		upd_axplt_attr!(plot, k, v)
	end
end

default_axis_attributes(plot) = (;)
default_plot_attributes(plot) = (;)

upd_axplt_attr!(axplt, k::Symbol, v) = if should_update_value(axplt, k)
	update_value!(axplt, k, v)
end

update_value!(ax, k::Symbol, v::Observable) = map!(identity, getproperty(ax, k), v)
update_value!(ax, k::Symbol, v) = getproperty(ax, k)[] = v

should_update_value(ax, k::Symbol) = hasproperty(ax, k) && should_update_value(ax, Val(k))
should_update_value(ax, ::Val{:aspect}) = isnothing(ax.aspect[])
should_update_value(ax, ::Union{Val{:xreversed}, Val{:yreversed}, Val{:zreversed}}) = true
should_update_value(ax, k::Union{Val{:xlabel}, Val{:ylabel}, Val{:zlabel}}) = isempty(getproperty(ax, val(k))[] |> String)
should_update_value(ax::Axis3, k::Val{:xlabel}) = String(getproperty(ax, val(k))[]) ∈ ("", "x")
should_update_value(ax::Axis3, k::Val{:ylabel}) = String(getproperty(ax, val(k))[]) ∈ ("", "y")
should_update_value(ax::Axis3, k::Val{:zlabel}) = String(getproperty(ax, val(k))[]) ∈ ("", "z")

# XXX, see https://github.com/MakieOrg/Makie.jl/issues/5229
should_update_value(plt, ::Val{:inspector_label}) = true # plt.inspector_label[] == Makie.Automatic()

val(::Val{x}) where {x} = x

have_same_units(aks) = 
    all(ak -> eltype(ak) <: Real, aks) ? false :  # Real => not Unitful
    allequal(map(eltype, aks))  # Unitful or other non-Real - assume Unitful; Makie only directly supports Real, so if anything else gets passed it will error anyway

end
