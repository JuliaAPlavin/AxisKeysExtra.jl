module GeoMakieExt

using GeoMakie
using AxisKeysExtra


function Makie.plot!(ax::GeoAxis, plot::Union{
    Image{<:Tuple{Any,Any,KeyedArray}},
    Heatmap{<:Tuple{Any,Any,KeyedArray}},
    Contour{<:Tuple{Any,Any,KeyedArray}},
    Contourf{<:Tuple{Any,Any,KeyedArray}},
})
    PT = typeof(plot)
    @invoke plot!(ax, plot::supertype(PT))
    Base.fill!(ax, plot)  # pirate Base function for now, so that several packages can avoid depending on each other
end

end
