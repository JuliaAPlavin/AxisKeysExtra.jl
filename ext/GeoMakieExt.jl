module GeoMakieExt

using GeoMakie
using AxisKeysExtra

const MakieExt = Base.get_extension(AxisKeysExtra, :MakieExt)
using .MakieExt: upd_axplt_attrs!


function Makie.plot!(ax::GeoAxis, plot::Union{
    Image{<:Tuple{Any,Any,KeyedArray}},
    Heatmap{<:Tuple{Any,Any,KeyedArray}},
    Contour{<:Tuple{Any,Any,KeyedArray}},
    Contourf{<:Tuple{Any,Any,KeyedArray}},
})
    PT = typeof(plot)
    @invoke plot!(ax, plot::supertype(PT))
    upd_axplt_attrs!(ax, plot)
end

end
