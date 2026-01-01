module InterpolationsExt

using Interpolations
using AxisKeysExtra


struct KeyedInterpolation{DNs, TI}
    interpolation::TI
end

KeyedInterpolation(dimnames, interpolation) = KeyedInterpolation{dimnames}(interpolation)
KeyedInterpolation{dimnames}(interpolation) where {dimnames} = KeyedInterpolation{dimnames, typeof(interpolation)}(interpolation)

Interpolations.interpolate(A::KeyedArray, it::Interpolations.DimSpec{BSpline}) = KeyedInterpolation(dimnames(A), scale(interpolate(parent(A), it), axiskeys(A)...))
Interpolations.extrapolate(A::KeyedInterpolation, et) = KeyedInterpolation(dimnames(A), extrapolate(A.interpolation, et))
Interpolations.linear_interpolation(A::KeyedArray; extrapolation_bc=Throw()) = extrapolate(interpolate(A, BSpline(Linear())), extrapolation_bc)

(ki::KeyedInterpolation)(args::Vararg{Number}) = ki.interpolation(args...)
(ki::KeyedInterpolation)(args::NTuple{<:Any, Number}) = ki.interpolation(args...)
(ki::KeyedInterpolation)(args::NamedTuple) = ki.interpolation(args[dimnames(ki)]...)
(ki::KeyedInterpolation)(;args...) = ki(NamedTuple(args))

Interpolations.gradient(ki::KeyedInterpolation, args::Vararg{Number}) = Interpolations.gradient(ki.interpolation, args...)
Interpolations.gradient(ki::KeyedInterpolation, args::NTuple{<:Any, Number}) = Interpolations.gradient(ki.interpolation, args...)
function Interpolations.gradient(ki::KeyedInterpolation, args::NamedTuple)  
    keys(args) == dimnames(ki) || throw(ArgumentError("KeyedInterpolation gradient requires keys $(dimnames(ki)) but got $(keys(args))"))
    Interpolations.gradient(ki.interpolation, args...)
end
Interpolations.gradient(ki::KeyedInterpolation; args...) = Interpolations.gradient(ki.interpolation, args[dimnames(ki)]...)

AxisKeys.axiskeys(ki::KeyedInterpolation) = Interpolations.getknots(ki.interpolation)
AxisKeys.named_axiskeys(ki::KeyedInterpolation) = NamedTuple{dimnames(ki)}(axiskeys(ki))
AxisKeys.dimnames(::KeyedInterpolation{DNs}) where {DNs} = DNs

Interpolations.bounds(ki::KeyedInterpolation) = bounds(ki.interpolation)

end
