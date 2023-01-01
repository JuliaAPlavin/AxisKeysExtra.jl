function stack(A::KeyedArray; dims::Colon=:)
    data = Base.@invoke stack(A::AbstractArray; dims)
    if !allequal(named_axiskeys(a) for a in A)
        throw(DimensionMismatch("stack expects uniform axiskeys for all arrays"))
    end
    akeys = (; named_axiskeys(first(A))..., named_axiskeys(A)...)
    KeyedArray(data; akeys...)
end
