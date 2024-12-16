@testitem "1d point" begin
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
            xlabel = eltype(axiskeys(KA1d)[1]) <: Quantity ? "x (km)" : "x"
            plotf(KA1d)
            @test current_axis().xlabel[] == xlabel
            plotf(fig[1,end+1], KA1d)
            @test current_axis().xlabel[] == xlabel
            plotf_excl(KA1d)
            @test current_axis().xlabel[] == xlabel

            plotf(Observable(KA1d))
            @test current_axis().xlabel[] == xlabel
            plotf(fig[1,end+1], Observable(KA1d))
            @test current_axis().xlabel[] == xlabel
            plotf_excl(Observable(KA1d))
            @test current_axis().xlabel[] == xlabel
        end
    end
end

@testitem "1d interval" begin
    using Makie
    using Makie.IntervalSets
    using Unitful

    fig = Figure()
    KA1d = KeyedArray(Interval.([1, 5, 2, 1], [1, 5, 2, 1] .+ 1), x=[1, 5, 10, 20]u"km")
    @testset for plotf in (band, rangebars)
        xlabel = "x (km)"
        plotf_excl = @eval $(Symbol(nameof(plotf), :!))

        plotf(KA1d)
        @test current_axis().xlabel[] == xlabel
        plotf(fig[1,end+1], KA1d)
        @test current_axis().xlabel[] == xlabel
        plotf_excl(KA1d)
        @test current_axis().xlabel[] == xlabel

        plotf(Observable(KA1d))
        @test current_axis().xlabel[] == xlabel
        plotf(fig[1,end+1], Observable(KA1d))
        @test current_axis().xlabel[] == xlabel
        plotf_excl(Observable(KA1d))
        @test current_axis().xlabel[] == xlabel
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

@testitem "2d basic" begin
    using Makie
    using Unitful

    KA2s = [
        KeyedArray([1 2 3; 4 5 6], a=-10:10:0, b=1:3),
        KeyedArray([1 2 3; 4 5 6]u"m", a=(-10:10:0)u"s", b=(1:3)u"W"),
    ]
    KA_2d = tuple.(KA2s[1], KA2s[1])
    KA_nonunif = KeyedArray([1 2 3; 4 5 6], a=-10:10:0, b=[1, 3, 10])

    fig = Figure()
    @testset for plotf in (heatmap, image, contour, contourf) #, contour3d, surface)
         # wireframe  # does it work?
        plotf_excl = @eval $(Symbol(nameof(plotf), :!))

        @testset for KA in KA2s
            xlabel, ylabel = eltype(axiskeys(KA)[1]) <: Quantity ? ("a (s)", "b (W)") : ("a", "b")

            plotf(KA)
            @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel
            plotf(fig[1,end+1], KA)
            @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel
            plotf_excl(KA)
            @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel

            plotf(Observable(KA))
            @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel
            plotf(fig[1,end+1], Observable(KA))
            @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel
            plotf_excl(Observable(KA))
            @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel
        end
    end

    @testset for plotf in (heatmap, contour, contourf) #, contour3d, surface)  # wireframe
        xlabel, ylabel = ("a", "b")
        plotf_excl = @eval $(Symbol(nameof(plotf), :!))

        plotf(KA_nonunif)
        @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel
        plotf(fig[1,end+1], KA_nonunif)
        @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel
        plotf_excl(KA_nonunif)
        @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel
    end
end

@testitem "2d arrows" begin
    using Makie

    KA2 = KeyedArray([1 2 3; 4 5 6], a=-10:10:0, b=1:3)
    KA_2d = tuple.(KA2, KA2)

    fig = Figure()
    @testset for plotf in (arrows,)
        xlabel, ylabel = ("a", "b")
        plotf_excl = @eval $(Symbol(nameof(plotf), :!))

        plotf(KA_2d)
        @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel
        plotf(fig[1,end+1], KA_2d)
        @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel
        plotf_excl(KA_2d)
        @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel

        plotf(Observable(KA_2d))
        @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel
        plotf(fig[1,end+1], Observable(KA_2d))
        @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel
        plotf_excl(Observable(KA_2d))
        @test current_axis().xlabel[] == xlabel && current_axis().ylabel[] == ylabel
    end
end

@testitem "2d 3d" begin
    using Makie
    using Unitful

    KA2s = [
        KeyedArray([1 2 3; 4 5 6], a=-10:10:0, b=1:3),
        KeyedArray([1 2 3; 4 5 6]u"m", a=(-10:10:0)u"s", b=(1:3)u"W"),
    ]
    fig = Figure()
    @testset for plotf in (contour3d, surface) # wireframe  # does it work?
       plotf_excl = @eval $(Symbol(nameof(plotf), :!))

       @testset for KA in KA2s
           xlabel, ylabel = eltype(axiskeys(KA)[1]) <: Quantity ? ("a (s)", "b (W)") : ("a", "b")

           ax = Axis3(fig[1,end+1])
           plotf_excl(Observable(KA))
           @test ax.xlabel[] == xlabel && ax.ylabel[] == ylabel && ax.zlabel[] == "z"
       end
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

@testitem "2d geomakie" begin
    using GeoMakie

    X = KeyedArray([1 2 3; 4 5 6], lon=-10:10:0, lat=1:3)
    fig = Figure()
    ga = GeoAxis(fig[1,1]; dest="+proj=moll", xreversed=true)
    heatmap!(ga, X)
    image!(ga, X)
    contour!(ga, X)
end

@testitem "3d" begin
    using Makie
    using Unitful

    KA3ds = [
        KeyedArray(reshape(1:12, (2, 3, 2)) |> collect, a=-10:10:0, b=1:3, c=[5, 7]u"km"),
        KeyedArray(reshape(1:12, (2, 3, 2)) |> collect, a=-10:10:0, b=1:3, c=[5, 7]),
    ]
    @testset for plotf in (volume, volumeslices)
        fig = Figure()
    
        plotf_excl = @eval $(Symbol(nameof(plotf), :!))

        @testset for KA3d in KA3ds
            # # plotf(KA3d)
            # plotf(fig[1,end+1], KA3d)
            # plotf_excl(KA3d)

            # # plotf(Observable(KA3d))
            # plotf(fig[1,end+1], Observable(KA3d))
            # plotf_excl(Observable(KA3d))

            ax = Axis3(fig[1,end+1])
            plotf_excl(KA3d)
            @test ax.xlabel[] == "a"# && ax.ylabel[] == "b" && ax.zlabel[] ∈ ("c", "c (km)")
        end
    end
end
