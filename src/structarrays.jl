const TupKeyedArray = Union{Tuple{Vararg{KeyedArray}}, NamedTuple{<:Any, <:Tuple{Vararg{KeyedArray}}}}
const StructKeyedArray{T} = StructArray{T, <:Any, <:TupKeyedArray, <:Any}

function AxisKeys.dimnames(A::StructKeyedArray)
    @assert allequal(dimnames(c) for c in components(A))
    return dimnames(component(A, 1))
end

function AxisKeys.axiskeys(A::StructKeyedArray)
    @assert allequal(axiskeys(c) for c in components(A))
    return axiskeys(component(A, 1))
end

Base.getproperty(A::StructKeyedArray, key::Symbol) = component(merge(named_axiskeys(A), components(A)), key)

Base.@propagate_inbounds Base.getindex(x::StructArray{<:Any, <:Any, <:TupKeyedArray, Int64}, I...; K...) = _getindex(x, I...; K...)
Base.@propagate_inbounds Base.getindex(x::StructArray{<:Any, <:Any, <:TupKeyedArray, Int64}, I::Int; K...) = _getindex(x, I...; K...)

function _getindex(A::StructArray{T}, I...; K...) where {T}
    comps = map(v -> getindex(v, I...; K...), components(A))
    is_elts = all(map((C, c) -> c isa eltype(C), components(A), comps))
    is_arr = all(map((C, c) -> !(c isa Number) && eltype(c) <: eltype(C), components(A), comps))
    @assert is_elts != is_arr
    if is_arr
        StructArray{T}(comps)
    else
        StructArrays.createinstance(T, comps...)
    end
end

function (A::StructKeyedArray{T})(I...; K...) where {T}
    comps = map(v -> v(I...; K...), components(A))
    is_elts = all(map((C, c) -> c isa eltype(C), components(A), comps))
    is_arr = all(map((C, c) -> !(c isa Number) && eltype(c) <: eltype(C), components(A), comps))
    @assert is_elts != is_arr
    if is_arr
        StructArray{T}(comps)
    else
        StructArrays.createinstance(T, comps...)
    end
end
