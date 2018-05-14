#=
Lattice is implemented in a generic way, such that it should work with any
Nodes, Edges and Graphs as long as they fulfill a few requirements:

- They must inherit from AbstractNode, AbstractEdge or AbstractGraph
  respectively
- They must contain the fields SimpleSite, SimpleBond and SimpleGraph contain
- They must have a constructor which only requires these fields.

SimpleSite, SimpleBond and SimpleGraph are also generic in the sense that they
should work with any type inheriting from AbstractNode, AbstractEdge or
AbstractGraph.

E.g. the following works to add positions:

struct PosSite{D, T <: AbstractEdge} <: AbstractNode
    neighbors::Vector{Vector{T}}
    pos::Point{D}
    uvw::NTuple{D+1, Int64}
end
function PosSite(
        uc::UnitCell{D, T},
        neighbors::Vector{Vector{ET}},
        iuvw::NTuple
    ) where {D, T <: AbstractFloat, ET <: AbstractEdge}
    PosSite(neighbors, get_pos(B, iuvw[1], uvw[2:end]))
end
=#

abstract type AbstractNode end
abstract type AbstractEdge end
abstract type AbstractGraph end

struct SimpleSite{N, T <: AbstractEdge} <: AbstractNode
    neighbors::Vector{Vector{T}}
    uvw::NTuple{N, Int64}
end

function SimpleSite(
        uc::UnitCell,
        neighbors::Vector{Vector{T}},
        uvw::NTuple{N, Int64}
    ) where {N, T <: AbstractEdge}
    SimpleSite(neighbors, uvw)
end

struct SimpleBond{T <: AbstractNode} <: AbstractEdge
    node1::T
    node2::T
end

struct SimpleGraph{
        Dimensions,
        T,
        NodeType <: AbstractNode,
        EdgeType <: AbstractEdge
    } <: AbstractGraph

    unitcell::UnitCell{Dimensions, T}
    nodes::Array{NodeType}
    edges::Vector{Vector{EdgeType}}
end


"""
    Lattice(uc[; kwargs...])

Generates a lattice of size L^d based on a UnitCell uc, which can be given
as a ::Function, a ::UnitCell.

Additional keyword arguments (kwargs) include
- `L::Int64 = 8`: The size of the lattice
- `Ls::NTuple{D, Int64} = (L, ..., L)`: The size of the lattice in D dimensions.
- `do_periodic::Bool = true`: Generate lattice with periodic bonds.
- `N_neighbors::Int64 = 1`: The number neighbor levels used.
- `nodetype::Type{N} = SimpleSite`: Type of Node used to construct the lattice.
- `edgetype::Type{E} = SimpleBond`: Type of Edge used to construct the lattice.
- `graphtype::Type{G} = SimpleGraph`: Type of Graph used to construct the lattice.
"""
function Lattice(
        uc::UnitCell{D, T};
        L::Int64 = 8,
        Ls::NTuple{D, Int64} = ([L for _ in 1:D]...),
        do_periodic::Bool = true,
        N_neighbors::Int64 = 1,
        nodetype::Type{N} = SimpleSite,
        edgetype::Type{E} = SimpleBond,
        graphtype::Type{G} = SimpleGraph
    ) where {D, T, N <: AbstractNode, E <: AbstractEdge, G <: AbstractGraph}

    dimsize = reduce(*, Ls)

    # Search for neighbors
    relative_offsets = get_neighbors(uc, N_neighbors)

    # Generate Nodes/Sites without edges
    # shape: (#number of Bravais lattices, L₁, ..., Lₙ) with n dimensions
    nodes = reshape([
        nodetype(
            uc,
            [edgetype[] for _ in relative_offsets[i]],
            (i, ind2sub(Ls, j)...)
        ) for i in eachindex(uc.basis), j in 1:dimsize
    ], length(uc.basis), Ls...)


    # Generate and connect edges
    edges = [edgetype[] for _ in 1:N_neighbors]

    for i in eachindex(nodes)
        from = ind2sub(nodes, i)

        for (lvl, lvl_offsets) in enumerate(relative_offsets[from[1]])
            for (j, offset) in enumerate(lvl_offsets)
                accept, to = move(from, offset, do_periodic, Ls)
                !accept && continue

                e = edgetype(nodes[from...], nodes[to...])
                if !(e in nodes[from...].neighbors[lvl])
                    push!(nodes[from...].neighbors[lvl], e)
                    push!(nodes[to...].neighbors[lvl], e)
                    push!(edges[lvl], e)
                end
            end
        end
    end

    graphtype(uc, nodes, edges)
end

# Extra methods
function Lattice(uc_func::Function, args...; kwargs...)
    Lattice(uc_func(), args...; kwargs...)
end


################################################################################

# Required for in
# Checks whether if e1 == e2, ignoring the direction of e1 and e2
function ==(e1::T, e2::T) where {T <: AbstractEdge}
    ((e1.node1 == e2.node1) && (e1.node2 == e2.node2)) ||
    ((e1.node1 == e2.node2) && (e1.node2 == e2.node1))
end

# Checks if edge is in edgelist
function in(edge::T, edgelist::Vector{T}) where {T <: AbstractEdge}
    for e in edgelist
        if edge == e
            return true
        end
    end
    false
end


# This calculates to = from + by with or without periodic boundaries.
# If the result is within the boundaries, it'll return true, to.
function move(
        from::NTuple{N, T},     # starting indices
        by::NTuple{N, T},       # offset indices
        do_periodic::Bool,      # use periodic boundaries
        Ls::NTuple{D, Int64}       # maximum index value
    ) where {D, N, T}

    to = [from[i] + by[i] for i in 1:N]

    if do_periodic
        for i in 2:length(to)
            (to[i] < 1) && (to[i] += Ls[i-1])
            (to[i] > Ls[i-1]) && (to[i] -= Ls[i-1])
        end
        return true, (to...)
    else
        return all((x, L) -> 1 <= x <= L, to[2:end], Ls), (to...)
    end
end



# Pretty printing to avoid printing circular references
function show(io::IO, g::T) where {T <: AbstractGraph}
    D = dims(g.unitcell)
    print(io, "$D-dimensional lattice graph with ")
    print(io, length(g.nodes))
    print(io, " sites and ")
    print(io, mapreduce(length, +, g.edges))
    print(io, " bonds.")
end

# Pretty printing to avoid printing circular references
function show(io::IO, n::T) where {T <: AbstractNode}
    print(io, "Node $(n.uvw) with ")
    print(io, "$(map(length, n.neighbors)) edges.")
end
# Pretty printing to avoid printing circular references
function show(io::IO, e::T) where {T <: AbstractEdge}
    print(io, "Edge connecting Node $(e.node1.uvw) and $(e.node2.uvw)")
end
