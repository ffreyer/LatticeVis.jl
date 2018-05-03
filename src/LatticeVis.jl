module LatticeVis

using StaticArrays.FixedSizeArrays
import Base: size
#
# include("deprecated/LatticeVis.jl")

include("Bravais.jl")
export Honeycomb

include("Neighbors.jl")
export get_neighbors


end # module
