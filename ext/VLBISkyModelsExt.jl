module VLBISkyModelsExt

using AxisKeysExtra
using VLBISkyModels
using VLBISkyModels.ComradeBase

VLBISkyModels.ContinuousImage(KA::AxisKeys.KeyedArray, pulse) = ContinuousImage(IntensityMap(KA), pulse)

end
