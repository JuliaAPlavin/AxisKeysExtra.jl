using SplitApplyCombine
_base_eachslice(A; dims) = splitdimsview(A, dims)

function eachslice(A::KeyedArray; dims)
    dims_ix = AxisKeys.dim(A, dims) |> Tuple
    data = _base_eachslice(A::AbstractArray; dims=dims_ix)
    return KeyedArray(NamedDimsArray(data, map(d -> dimnames(A, d), dims_ix)), map(d -> axiskeys(A, d), dims_ix))
end

function eachslice(A::NamedDimsArray; dims)
    dims_ix = AxisKeys.dim(A, dims) |> Tuple
    data = _base_eachslice(A::AbstractArray; dims=dims_ix)
    return NamedDimsArray(data, map(d -> dimnames(A, d), dims_ix))
end
