module LatticeVis

__precompile__(true)

using StaticArrays.FixedSizeArrays
import Base: size, in, ==, +, show, merge

include("UnitCell.jl")
export UnitCell, get_pos, dims, merge
export square, triangle, honeycomb
export sc, bcc, fcc, diamond

include("Neighbors.jl")
export get_neighbors

include("LatticeGraph.jl")
export Lattice
export SimpleSite, SimpleBond, SimpleGraph
export AbstractNode, AbstractEdge, AbstractGraph


using PyPlot
include("Pyplot.jl")
export plot

end # module
