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


@testset "eachslice" begin
    arr = KeyedArray([1 2 3; 4 5 6], a=-1:0, b=1:3)

    # Base method for regular array
    @test collect(eachslice(keyless_unname(arr); dims=1)) == [[1, 2, 3], [4, 5, 6]]

    @testset "nameddims" begin
        S = eachslice(keyless(arr); dims=1)::NamedDimsArray
        @test S == [[1, 2, 3], [4, 5, 6]] 
        @test dimnames(S) == (:a,)
        @test dimnames(S[1]::NamedDimsArray) == (:b,)

        S = eachslice(keyless(arr); dims=:a)::NamedDimsArray
        @test S == [[1, 2, 3], [4, 5, 6]] 
        @test dimnames(S) == (:a,)
        @test dimnames(S[1]::NamedDimsArray) == (:b,)
    end

    @testset "keyedarray" begin
        S = eachslice(arr; dims=1)
        @test S == [[1, 2, 3], [4, 5, 6]]
        @test S isa KeyedArray
        @test S |> named_axiskeys == (a=-1:0,)
        @test S[1] == [1, 2, 3]
        @test S[1] isa KeyedArray
        @test S[1] |> named_axiskeys == (b=1:3,)

        S = eachslice(arr; dims=:a)
        @test S == [[1, 2, 3], [4, 5, 6]]
        @test S isa KeyedArray
        @test S |> named_axiskeys == (a=-1:0,)
        @test S[1] == [1, 2, 3]
        @test S[1] isa KeyedArray
        @test S[1] |> named_axiskeys == (b=1:3,)

        @test eachslice(arr; dims=(:a, :b)) == fill.([1 2 3; 4 5 6])  # array of 0d arrays
        @test eachslice(arr; dims=(:a, :b)) |> named_axiskeys == (a=-1:0, b=1:3)
        @test eachslice(arr; dims=(:b, :a)) == fill.([1 4; 2 5; 3 6])  # array of 0d arrays
        @test eachslice(arr; dims=(:b, :a)) |> named_axiskeys == (b=1:3, a=-1:0)
        @test eachslice(arr; dims=(:b, 1)) == fill.([1 4; 2 5; 3 6])  # array of 0d arrays
        @test eachslice(arr; dims=(:b, 1)) |> named_axiskeys == (b=1:3, a=-1:0)

        @test_throws Exception eachslice(arr; dims=3)
        @test_throws Exception eachslice(arr; dims=:c)
        @test_throws Exception eachslice(arr; dims=(:c,))
        @test_throws Exception eachslice(arr; dims=(:a, :c,))
    end
end

@testset "stack" begin
    arr = KeyedArray([
        KeyedArray([1, 2], a=[:x, :y]),
        KeyedArray([3, 4], a=[:x, :y]),
        KeyedArray([5, 6], a=[:x, :y]),
    ], b=10:12)

    @test stack(keyless_unname(arr)) == [1 3 5; 2 4 6]
    
    sk = stack(arr)::KeyedArray
    @test sk == [1 3 5; 2 4 6]
    @test named_axiskeys(sk) == (a=[:x, :y], b=10:12)
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
