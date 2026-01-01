using TestItems
using TestItemRunner
@run_package_tests

@testitem "new indexing" begin
    # https://github.com/mcabbott/AxisKeys.jl/pull/110
    A = KeyedArray([1 2 3; 4 5 6], a=-1:0, b=1:3)
    A(a=0, b=1, :) .= 1000
    @test A(a=0, b=1) == 1000
end

@testitem "structarrays" begin
    using StructArrays
    using StaticArrays

    A = StructArray(a=KeyedArray(1:5; x=11:15), b=KeyedArray(10:10:50; x=11:15))
    @test named_axiskeys(A) === (x=11:15,)
    @test A.a == 1:5
    @test A.x == 11:15
    @test A[2].a == 2
    @test A[x=2].b == 20
    @test A[x=1:2].x == 11:12
    @test A(x=13).a == 3
    @test A(x= >=(13)).b == 30:10:50
    @test A(x= >=(13)).x == 13:15

    A = StructArray(a=KeyedArray([1 2]; x=[:x], y=11:12), b=KeyedArray([10 20]; x=[:x], y=11:12))
    @test named_axiskeys(A) == (x=[:x], y=11:12)
    @test A.a == [1 2]
    @test A.x == [:x]
    @test A[1, 2].a == 2
    @test A[x=1].b == [10, 20]
    @test A[x=1, y=2].b == 20
    @test A[y=1:2].x == [:x]
    @test A(x=:x, y=11).a == 1

    A = StructArray(KeyedArray([SVector(1, 2), SVector(3, 4)]; a=[:a, :b]))
    @test named_axiskeys(A) == (;a=[:a, :b])
    @test A[1] == SVector(1, 2)
    @test A.a == [:a, :b]
    @test A.:1 == [1, 3]
    @test A.x == [1, 3]
    @test A(a=:a) == SVector(1, 2)
end

@testitem "axiskeys grid" begin
    using RectiGrids

    A = KeyedArray([1 2 3; 4 5 6], a=-1:0, b=1:3)
    ak_g = with_axiskeys(grid)(A)
    @test ak_g isa RectiGrid
    @test isconcretetype(eltype(ak_g))
    @test ak_g == [(a=-1, b=1) (a=-1, b=2) (a=-1, b=3); (a=0, b=1) (a=0, b=2) (a=0, b=3)]

    w_ak = with_axiskeys(A)
    @test isconcretetype(eltype(w_ak))
    @test w_ak[2, 3] === ((a=0, b=3) => 6)
    @test w_ak.:1 == ak_g
    @test w_ak.:2 === A
    @test named_axiskeys(w_ak) == (a=-1:0, b=1:3)
    @test w_ak(a=0, b=3) === ((a=0, b=3) => 6)

    fA = filter(p -> p[1].a >= 0, w_ak)
    @test fA.:1 == vec(grid(a=0:0, b=1:3))
    @test fA.:2 == vec(A(a=0:0, b=1:3))

    A = KeyedArray(10:10:50, a=1:5)
    w_ak = with_axiskeys(A)

    fA = filter(p -> p[1].a >= 3, w_ak)
    @test fA.:1 == grid(a=3:5)
    @test fA.:2 == A[a=3:5]
    @test fA.:1 isa RectiGrid
    @test fA.:2 isa KeyedArray

    @test_broken filter!(p -> p[1].a >= 3, w_ak) === w_ak
end

@testitem "with_axiskeys funcs" begin
    arr = KeyedArray([1 2 3; 4 5 6], a=-1:0, b=1:3)

    @test with_axiskeys(argmax)(arr) == (a=0, b=3)
    @test with_axiskeys(findmax)(arr) == (6, (a=0, b=3))
    @test with_axiskeys(argmin)(arr) == (a=-1, b=1)
    @test with_axiskeys(findmin)(arr) == (1, (a=-1, b=1))
end

@testitem "dimensionaldata" begin
    using DimensionalData

    A = reshape(1:8, (4, 2))
    DA = DimArray(A, (a=10:10:40, b=[:x, :y]))
    KA = KeyedArray(DA)
    @test AxisKeys.keyless_unname(KA) === A
    @test named_axiskeys(KA) == (a=10:10:40, b=[:x, :y])
end

@testitem "comradebase" begin
    using ComradeBase, Unitful

    data = rand(128, 128)
    imap = IntensityMap(data, 12.8, 25.6; header=ComradeBase.NoHeader())
    KA = KeyedArray(imap)
    @test AxisKeys.keyless_unname(KA) == data
    @test named_axiskeys(KA).X::AbstractRange ≈ (-6.35:0.1:6.35)u"rad"
    @test named_axiskeys(KA).Y::AbstractRange ≈ (-12.7:0.2:12.7)u"rad"

    imap = IntensityMap(KA)
    @test imap.X ≈ -6.35:0.1:6.35

    KA_d = KeyedArray(AxisKeys.keyless_unname(KA); map(named_axiskeys(KA)) do ak
        ak .|> u"°"
    end...)
    imap = IntensityMap(KA_d)
    @test imap.X ≈ -6.35:0.1:6.35

    KA2 = KeyedArray(imap)
    @test all(axiskeys(KA2) .≈ axiskeys(KA))
    @test AxisKeys.keyless_unname(KA2) == AxisKeys.keyless_unname(KA)
end

@testitem "Interpolations" begin
    using Interpolations
    using StaticArrays

    @testset for (A, it) in Any[
        KeyedArray([1 2 3; 4 5 6], a=-1:0, b=1:3) => BSpline(Linear()),
        KeyedArray([3 2 1; 6 5 4], a=-1:0, b=3:-1:1) => BSpline(Linear()),
        KeyedArray([1 2 3; 4 5 6], a=-1:0, b=1:3) => Gridded(Linear()),
        KeyedArray([3 2 1; 6 5 4], a=-1:0, b=3:-1:1) => Gridded(Linear()),
        KeyedArray([1 2 3; 4 5 6], a=-1:0, b=[1,2,3]) => Gridded(Linear()),
    ]
        @testset for Ai in [interpolate(A, it), linear_interpolation(A)]
            @test issetequal(dimnames(Ai), dimnames(A))
            @test map(sort, named_axiskeys(Ai)) == map(sort, named_axiskeys(A))

            @test Ai(0, 2) == 5.0
            @test Ai((0, 2)) == 5.0
            @test Ai(SVector(0, 2)) == 5.0
            @test Ai(a=0, b=2) == A(a=0, b=2) == 5.0
            @test Ai(a=-0.4, b=2) ≈ 3.8
            @test Ai(a=-0.4, b=2.5) ≈ 4.3
            @test Ai(b=2, a=-0.4) ≈ 3.8
            @test_throws BoundsError Ai(a=0.5, b=2)

            @test Interpolations.gradient(Ai, a=0, b=2) == [3, 1]
            @test_throws ArgumentError Interpolations.gradient(Ai, (b=2, a=0))
        end

        @testset for Aie in [extrapolate(interpolate(A, it), Flat()), linear_interpolation(A; extrapolation_bc=Flat())]
            @test issetequal(dimnames(Aie), dimnames(A))
            @test map(sort, named_axiskeys(Aie)) == map(sort, named_axiskeys(A))

            @test Aie(0, 2) == 5.0
            @test Aie((0, 2)) == 5.0
            @test Aie(SVector(0, 2)) == 5.0
            @test Aie(a=0, b=2) == 5.0
            @test Aie(a=-0.4, b=2) ≈ 3.8
            @test Aie(a=-0.4, b=2.5) ≈ 4.3
            @test Aie(a=0.5, b=2) == 5.0
            @test Aie(b=2, a=-0.4) ≈ 3.8

            @test Interpolations.gradient(Aie, a=0, b=2) == [3, 1]
            @test_throws ArgumentError Interpolations.gradient(Aie, (b=2, a=0))
        end
    end
end

@testitem "_" begin
    import CompatHelperLocal as CHL
    CHL.@check()

    import Aqua
    Aqua.test_ambiguities(AxisKeysExtra; recursive=false)
    Aqua.test_all(AxisKeysExtra; ambiguities=false, piracies=false, undefined_exports=false, persistent_tasks=false)
end
