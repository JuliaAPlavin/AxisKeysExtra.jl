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
    @testset for plotf in (scatter, lines, scatterlines, stairs, stem, barplot)
        plotf_excl = @eval $(Symbol(nameof(plotf), :!))

        @testset for KA1d in KA1ds
            plotf(KA1d)
            plotf(fig[1,end+1], KA1d)
            plotf_excl(KA1d)

            plotf(Observable(KA1d))
            plotf(fig[1,end+1], Observable(KA1d))
            plotf_excl(Observable(KA1d))
        end
    end

    KA1d = KeyedArray(Interval.([1, 5, 2, 1], [1, 5, 2, 1] .+ 1), x=[1, 5, 10, 20]u"km")
    @testset for plotf in (band, rangebars)
        plotf_excl = @eval $(Symbol(nameof(plotf), :!))

        plotf(KA1d)
        plotf(fig[1,end+1], KA1d)
        plotf_excl(KA1d)

        plotf(Observable(KA1d))
        plotf(fig[1,end+1], Observable(KA1d))
        plotf_excl(Observable(KA1d))
    end
end

@testitem "1d categorical" begin
    using Makie
    using Unitful

    fig = Figure()
    
    KA1ds = [
        KeyedArray(["a", "b", "c", "d"], x=[1, 5, 10, 20]),
        KeyedArray(["a", "b", "c", "d"], x=[1, 5, 10, 20]u"km"),
        KeyedArray([1, 5, 10, 20], x=["a", "b", "c", "d"]),
        KeyedArray([1, 5, 10, 20]u"km", x=["a", "b", "c", "d"]),
    ]
    @testset for plotf in (scatter, lines, scatterlines, stairs, stem, barplot)
        plotf_excl = @eval $(Symbol(nameof(plotf), :!))

        @testset for KA1d in KA1ds
            plotf(KA1d)
            plotf(fig[1,end+1], KA1d)
            plotf_excl(KA1d)

            plotf(Observable(KA1d))
            plotf(fig[1,end+1], Observable(KA1d))
            plotf_excl(Observable(KA1d))
        end
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
    @testset for plotf in (heatmap, image, contour, contourf, contour3d, surface)
         # wireframe  # does it work?
        plotf_excl = @eval $(Symbol(nameof(plotf), :!))

        @testset for KA in KA2s
            plotf(KA)
            plotf(fig[1,end+1], KA)
            plotf_excl(KA)

            plotf(Observable(KA))
            plotf(fig[1,end+1], Observable(KA))
            plotf_excl(Observable(KA))
        end
    end

    @testset for plotf in (heatmap, contour, contourf, contour3d, surface)  # wireframe
        plotf_excl = @eval $(Symbol(nameof(plotf), :!))

        plotf(KA_nonunif)
        plotf(fig[1,end+1], KA_nonunif)
        plotf_excl(KA_nonunif)
    end

    @testset for plotf in (arrows,)
        plotf_excl = @eval $(Symbol(nameof(plotf), :!))

        plotf(KA_2d)
        plotf(fig[1,end+1], KA_2d)
        plotf_excl(KA_2d)

        plotf(Observable(KA_2d))
        plotf(fig[1,end+1], Observable(KA_2d))
        plotf_excl(Observable(KA_2d))
    end
end

@testitem "2d categorical" begin
    using Makie
    using Unitful

    fig = Figure()

    KA2s = [
        KeyedArray([1 2 3; 4 5 6], a=["a", "b"], b=1:3),
        KeyedArray([1 2 3; 4 5 6], a=["a", "b"], b=["c", "d", "e"]),
        KeyedArray([1 2 3; 4 5 6]u"m", a=["a", "b"], b=["c", "d", "e"]),
        KeyedArray([1 2 3; 4 5 6]u"m", a=(1:2)u"km", b=["c", "d", "e"]),
    ]
    @testset for plotf in (heatmap,)# image, contour, contourf, contour3d, surface)
        plotf_excl = @eval $(Symbol(nameof(plotf), :!))

        @testset for KA in KA2s
            plotf(KA)
            plotf(fig[1,end+1], KA)
            plotf_excl(KA)

            plotf(Observable(KA))
            plotf(fig[1,end+1], Observable(KA))
            plotf_excl(Observable(KA))
        end
    end
end

@testitem "3d" begin
    using Makie
    using Unitful

    KA3ds = [
        KeyedArray(reshape(1:12, (2, 3, 2)), a=-10:10:0, b=1:3, c=[5, 7]u"km"),
        KeyedArray(reshape(1:12, (2, 3, 2)), a=-10:10:0, b=1:3, c=[5, 7]),
    ]
    @testset for plotf in (volume, volumeslices)
        fig = Figure()
    
        plotf_excl = @eval $(Symbol(nameof(plotf), :!))

        @testset for KA3d in KA3ds
            plotf(KA3d)
            plotf(fig[1,end+1], KA3d)
            plotf_excl(KA3d)

            plotf(Observable(KA3d))
            plotf(fig[1,end+1], Observable(KA3d))
            plotf_excl(Observable(KA3d))
        end
    end
end
