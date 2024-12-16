with_axiskeys(f::Union{typeof.((argmax, argmin))...}) = A -> ix_to_axiskeys(A, f(A))
with_axiskeys(f::Union{typeof.((findmax, findmin))...}) = A -> let
    (x, ix) = f(A)
    (x, ix_to_axiskeys(A, ix))
end

ix_to_axiskeys(A, ix) = NamedTuple{dimnames(A)}(map((i, vs) -> vs[i], Tuple(ix), axiskeys(A)))


dimlabel(A, i) = _dimlabel(dimnames(A, i), axiskeys(A, i))
_dimlabel(dimname, _) = dimname == :_ ? "" : "$dimname"
