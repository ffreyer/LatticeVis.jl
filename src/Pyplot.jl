# position nodes

struct PosSite{N, D, T <: AbstractEdge} <: AbstractNode
    neighbors::Vector{Vector{T}}
    pos::Point{D}
    uvw::NTuple{N, Int64}
end
function PosSite(
        B::Bravais,
        neighbors::Vector{Vector{ET}},
        uvw::NTuple{N, Int64}
    ) where {N, ET <: AbstractEdge}
    PosSite(neighbors, get_pos(B, (uvw[2:end]...)), uvw)
end


function plot(_lattice::T) where {T <: AbstractGraph}
    @assert length(_lattice.bravais[1].pos) == 2 "plot only works for 2D \
    lattices."
    if typeof(_lattice.nodes[1]) == PosSite
        lattice = _lattice
    else
        g = _lattice

        nodes = reshape(map(eachindex(g.nodes)) do i
            PosSite(
                g.bravais[ind2sub(g.nodes, i)[1]],
                [SimpleBond[] for _ in g.nodes[i].neighbors],
                g.nodes[i].uvw
            )
        end, size(g.nodes))

        edges = [SimpleBond[] for _ in eachindex(g.edges)]
        for lvl in eachindex(g.edges)
            for old_edge in g.edges[lvl]
                new_edge = SimpleBond(
                    nodes[old_edge.node1.uvw...],
                    nodes[old_edge.node2.uvw...]
                )
                push!(edges[lvl], new_edge)
                push!(nodes[old_edge.node1.uvw...].neighbors[lvl], new_edge)
                push!(nodes[old_edge.node2.uvw...].neighbors[lvl], new_edge)
            end
        end

        lattice = SimpleGraph(g.bravais, nodes, edges)
    end


    PyPlot.plot(
        [n.pos[1] for n in lattice.nodes[:]],
        [n.pos[2] for n in lattice.nodes[:]],
        "ko"
    )
    for level in lattice.edges
        for edge in level
            PyPlot.plot(
                [edge.node1.pos[1], edge.node2.pos[1]],
                [edge.node1.pos[2], edge.node2.pos[2]],
                "k-"
            )
        end
    end

    lattice
end
