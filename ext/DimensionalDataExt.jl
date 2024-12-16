module DimensionalDataExt

using AxisKeys
import DimensionalData

function AxisKeys.KeyedArray(DA::DimensionalData.AbstractDimArray)
    dims = DimensionalData.dims(DA)
    dnames = DimensionalData.label.(dims)
    dvals = DimensionalData.val.(dims)
    return KeyedArray(parent(DA); NamedTuple{Symbol.(dnames)}(dvals)...)
end

end
