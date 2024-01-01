using AxisKeysExtra
using AxisKeys: keyless_unname, keyless
using StructArrays
using Test


@testset begin
    # https://github.com/mcabbott/AxisKeys.jl/pull/110
    A = KeyedArray([1 2 3; 4 5 6], a=-1:0, b=1:3)
    A(a=0, b=1, :) .= 1000
    @test A(a=0, b=1) == 1000
end

@testset "structarrays" begin
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
end

@testset "axiskeys grid" begin
    A = KeyedArray([1 2 3; 4 5 6], a=-1:0, b=1:3)
    ak_g = axiskeys_grid(A)
    @test ak_g isa AxisKeysExtra.RectiGrid
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
    @test fA.:1 == vec(AxisKeysExtra.grid(a=0:0, b=1:3))
    @test fA.:2 == vec(A(a=0:0, b=1:3))

    A = KeyedArray(10:10:50, a=1:5)
    w_ak = with_axiskeys(A)

    fA = filter(p -> p[1].a >= 3, w_ak)
    @test fA.:1 == AxisKeysExtra.grid(a=3:5)
    @test fA.:2 == A[a=3:5]
    @test fA.:1 isa AxisKeysExtra.RectiGrid
    @test fA.:2 isa KeyedArray

    @test_broken filter!(p -> p[1].a >= 3, w_ak) === w_ak
end

@testset "with_axiskeys funcs" begin
    arr = KeyedArray([1 2 3; 4 5 6], a=-1:0, b=1:3)

    @test with_axiskeys(argmax)(arr) == (a=0, b=3)
    @test with_axiskeys(findmax)(arr) == (6, (a=0, b=3))
    @test with_axiskeys(argmin)(arr) == (a=-1, b=1)
    @test with_axiskeys(findmin)(arr) == (1, (a=-1, b=1))
end


import CompatHelperLocal as CHL
CHL.@check()

import Aqua
Aqua.test_ambiguities(AxisKeysExtra; recursive=false)
Aqua.test_all(AxisKeysExtra; ambiguities=false, piracy=false)
