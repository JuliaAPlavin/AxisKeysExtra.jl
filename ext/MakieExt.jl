module MakieExt

using AxisKeysExtra
import AxisKeysExtra: _ustrip
using AxisKeysExtra.AxisKeys: keyless_unname
using Makie


_ustrip(x::AbstractArray{<:Union{String,Symbol}}) = Categorical(x)

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


function Makie.expand_dimensions(ct::ImageLike, x::KeyedArray{<:Any,2})
    aks = axiskeys(x)
    edges = map(ak -> _ustrip.(extrema(ak) .+ (-step(ak)/2, step(ak)/2)), aks)
    if step(aks[1]) < zero(step(aks[1]))
        x = reverse(x, dims=1)
    end
    if step(aks[2]) < zero(step(aks[2]))
        x = reverse(x, dims=2)
    end
    (edges..., x |> _ustrip)
end

Makie.Isoband.isobands(xs::AbstractVector, ys::AbstractVector, zs::KeyedArray, lows::AbstractVector, highs::AbstractVector) =
    Makie.Isoband.isobands(xs, ys, keyless_unname(zs), lows, highs)

Makie.expand_dimensions(ct::GridBased, x::KeyedArray{<:Any,2}) = (_ustrip.(axiskeys(x))..., x |> _ustrip)

Makie.convert_arguments(ct::Type{<:Arrows}, x::KeyedArray{<:Any,2}) =
    convert_arguments(ct, Point2f.(_ustrip(axiskeys(x, 1)), _ustrip(axiskeys(x, 2))'), x |> _ustrip)

Makie.plot!(p::Arrows{<:Tuple{AbstractMatrix, KeyedArray}}) = arrows!(p, p.attributes, lift(vec, p[1]), lift(vec, p[2]))

Makie.convert_arguments(ct::Type{<:Union{Volume,VolumeSlices,Voxels}}, x::KeyedArray{<:Any,3}) =
    convert_arguments(ct, _ustrip.(axiskeys(x))..., x |> _ustrip)

Makie._update_voxel(a::KeyedArray, b::KeyedArray, args...) = Makie._update_voxel(keyless_unname(a), keyless_unname(b), args...)

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
	PT = typeof(plot)
	@invoke plot!(ax, plot::supertype(PT))
	Base.fill!(ax, plot)  # pirate Base function for now, so that several packages can avoid depending on each other
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
    A = plot[2] isa Observable{<:KeyedArray} ? plot[2] : plot[3]
    use_dataaspect = @lift allequal(map(eltype, axiskeys($A)))
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

function default_axis_attributes(plot::Union{
        Volume{<:Tuple{Any,Any,Any,KeyedArray}},
        VolumeSlices{<:Tuple{Any,Any,Any,KeyedArray}},
        Voxels{<:Tuple{Any,Any,Any,KeyedArray}},
    })
    A = plot[4]
    use_dataaspect = @lift allequal(map(eltype, axiskeys($A)))
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

# pirate Base function for now, so that several packages can avoid depending on each other
Base.fill!(ax::Makie.AbstractAxis, plot::Plot) =
	for (k, v) in pairs(default_axis_attributes(plot))
		upd_ax_attr!(ax, k, v)
	end

default_axis_attributes(plot) = (;)

upd_ax_attr!(ax::Makie.AbstractAxis, k::Symbol, v) = if should_update_value(ax, k)
	update_value!(ax, k, v)
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

val(::Val{x}) where {x} = x

end
