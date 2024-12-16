# smoke tests only
@testitem "1d" begin
    using Makie
    using Makie.IntervalSets
    using Unitful

    fig = Figure()

    KA1ds = [
        KeyedArray([1, 5, 2, 1]u"W", x=[1, 5, 10, 20]u"km"),
        KeyedArray([1, 5, 2, 1], x=[1, 5, 10, 20]u"km"),
        KeyedArray([1, 5, 2, 1], x=[1, 5, 10, 20]),
    ]
    @testset for plotf in (:scatter, :lines, :scatterlines, :stairs, :stem, :barplot)
        plotf_excl = Symbol(plotf, :!)

        @testset for KA1d in KA1ds
            @eval $plotf($KA1d)
            @eval $plotf(fig[1,end+1], $KA1d)
            @eval $plotf_excl($KA1d)

            @eval $plotf(Observable($KA1d))
            @eval $plotf(fig[1,end+1], Observable($KA1d))
            @eval $plotf_excl(Observable($KA1d))
        end
    end

    KA1d = KeyedArray(Interval.([1, 5, 2, 1], [1, 5, 2, 1] .+ 1), x=[1, 5, 10, 20]u"km")
    @testset for plotf in (:band, :rangebars)
        plotf_excl = Symbol(plotf, :!)

        @eval $plotf(KA1d)
        @eval $plotf(fig[1,end+1], KA1d)
        @eval $plotf_excl(KA1d)

        @eval $plotf(Observable(KA1d))
        @eval $plotf(fig[1,end+1], Observable(KA1d))
        @eval $plotf_excl(Observable(KA1d))
    end
end

@testitem "2d" begin
    using Makie
    using Unitful

    KA2s = [
        KeyedArray([1 2 3; 4 5 6], a=-10:10:0, b=1:3),
        KeyedArray([1 2 3; 4 5 6]u"m", a=(-10:10:0)u"s", b=(1:3)u"W"),
    ]
    KA_2d = tuple.(KA2s[1], KA2s[1])
    KA_nonunif = KeyedArray([1 2 3; 4 5 6], a=-10:10:0, b=[1, 3, 10])

    fig = Figure()
    @testset for plotf in (:heatmap, :image, :contour, :contourf, :contour3d, :surface)
         # :wireframe  # does it work?
        plotf_excl = Symbol(plotf, :!)

        @testset for KA in KA2s
            @eval $plotf($KA)
            @eval $plotf(fig[1,end+1], $KA)
            @eval $plotf_excl($KA)

            @eval $plotf(Observable($KA))
            @eval $plotf(fig[1,end+1], Observable($KA))
            @eval $plotf_excl(Observable($KA))
        end
    end

    @testset for plotf in (:heatmap, :contour, :contourf, :contour3d, :surface)  # :wireframe
        plotf_excl = Symbol(plotf, :!)

        @eval $plotf(KA_nonunif)
        @eval $plotf(fig[1,end+1], KA_nonunif)
        @eval $plotf_excl(KA_nonunif)
    end

    @testset for plotf in (:arrows,)
        plotf_excl = Symbol(plotf, :!)

        @eval $plotf(KA_2d)
        @eval $plotf(fig[1,end+1], KA_2d)
        @eval $plotf_excl(KA_2d)

        @eval $plotf(Observable(KA_2d))
        @eval $plotf(fig[1,end+1], Observable(KA_2d))
        @eval $plotf_excl(Observable(KA_2d))
    end
end

@testitem "3d" begin
    using Makie
    using Unitful

    KA3ds = [
        KeyedArray(reshape(1:12, (2, 3, 2)), a=-10:10:0, b=1:3, c=[5, 7]u"km"),
        KeyedArray(reshape(1:12, (2, 3, 2)), a=-10:10:0, b=1:3, c=[5, 7]),
    ]
    @testset for plotf in (:volume, :volumeslices)
        fig = Figure()
    
        plotf_excl = Symbol(plotf, :!)

        @testset for KA3d in KA3ds
            @eval $plotf($KA3d)
            @eval $plotf($fig[1,end+1], $KA3d)
            @eval $plotf_excl($KA3d)

            @eval $plotf(Observable($KA3d))
            @eval $plotf($fig[1,end+1], Observable($KA3d))
            @eval $plotf_excl(Observable($KA3d))
        end
    end
end
