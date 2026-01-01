module GeoMakieExt

using GeoMakie
using AxisKeysExtra

const MakieExt = Base.get_extension(AxisKeysExtra, :MakieExt)
using .MakieExt: default_axis_attributes, default_plot_attributes


function Makie.plot!(ax::GeoAxis, plot::Union{
    Image{<:Tuple{Any,Any,KeyedArray}},
    Heatmap{<:Tuple{Any,Any,KeyedArray}},
    Contour{<:Tuple{Any,Any,KeyedArray}},
    Contourf{<:Tuple{Any,Any,KeyedArray}},
})
    attrs = (axis=default_axis_attributes(plot), plot=default_plot_attributes(plot))
    PT = typeof(plot)
    @invoke plot!(ax, plot::supertype(PT))
    Base.fill!(ax, plot, attrs)  # pirate Base function for now, so that several packages can avoid depending on each other
end

end
