# AxisKeysExtra.jl

The [AxisKeys.jl](https://github.com/mcabbott/AxisKeys.jl) package provides a nice lightweight `KeyedArray` structure: arrays with keyed/labelled axes, similar to `xarray` in Python. \
It is being maintained, but for stability reasons new features are added very cautiously. That's the reason for this package, `AxisKeysExtra.jl`: it extends `AxisKeys` with new convenience functions, conversions, Makie plotting recipes. Some of them may be upstreamed to `AxisKeys` at some point.

The intended usage is to just do `using AxisKeysExtra`: it reexports `AxisKeys`, so one can use both regular `AxisKeys` functionality and functions defined in this package.\
See [the Pluto notebook](https://aplavin.github.io/AxisKeysExtra.jl/test/notebook.html) for details and examples.
