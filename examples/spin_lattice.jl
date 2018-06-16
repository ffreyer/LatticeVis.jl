using LatticeVis

# Generating a matrix of spins using the existing graph
lattice = Lattice(Honeycomb, 5)
spins = rand([-1.0, 1.0], size(lattice.nodes))


################################################################################

# Adding spins by implementing new nodes
using LatticeVis

mutable struct SpinSite{N, T <: AbstractEdge} <: AbstractNode
    neighbors::Vector{Vector{T}}
    uvw::NTuple{N, Int64}
    spin::Float64
end

# Outer constructor
# this has to work with B, neighbors and uvw as arguments
function SpinSite(
        B::Bravais,
        neighbors::Vector{Vector{T}},
        uvw::NTuple{N, Int64}
    ) where {N, T <: AbstractEdge}
    SpinSite(neighbors, uvw, rand([-1.0, 1.0]))
end

# Use custom type with "nodetype = (CustomNode)"
lattice = Lattice(Honeycomb, 5, nodetype = SpinSite)
# The spins can now be read off of each node
spin_matrix = map(n -> n.spin, lattice.nodes)


################################################################################

# Adding spins by implementing a new Graph

using LatticeVis

struct SpinGraph{
        Dimensions,
        T,
        NodeType <: AbstractNode,
        EdgeType <: AbstractEdge
    } <: AbstractGraph

    bravais::Vector{Bravais{Dimensions, T}}
    nodes::Array{NodeType}
    edges::Vector{Vector{EdgeType}}
    spins::Array{Float64}
end

# Outer constructor
# this has to work w/o spins being given
function SpinGraph(
        bravais::Vector{Bravais{D, T}},
        nodes::Array{NodeType},
        edges::Vector{Vector{EdgeType}}
    ) where {
        D,
        T,
        NodeType <: AbstractNode,
        EdgeType <: AbstractEdge
    }

    SpinGraph(
        bravais,
        nodes,
        edges,
        rand([-1.0, 1.0], size(nodes))
    )
end

# Use custom type with "graphtype = (CustomGraph)"
lattice = Lattice(Honeycomb, 5, graphtype = SpinGraph)
# The spins are now available in lattice
lattice.spins
