axiskeys_grid(A) = grid(; named_axiskeys(A)...)
function with_axiskeys(A)
    G = axiskeys_grid(A)
    StructArray{Pair{eltype(G), eltype(A)}}((G, A))
end

with_axiskeys(f::Union{typeof.((argmax, argmin))...}) = A -> ix_to_axiskeys(A, f(A))
with_axiskeys(f::Union{typeof.((findmax, findmin))...}) = A -> let
    (x, ix) = f(A)
    (x, ix_to_axiskeys(A, ix))
end

ix_to_axiskeys(A, ix) = NamedTuple{dimnames(A)}(map((i, vs) -> vs[i], Tuple(ix), axiskeys(A)))
