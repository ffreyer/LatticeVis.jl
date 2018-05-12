"""
    plot(lattice)

Creates a 2D plot of lattice using PyPlot.
"""
function plot(lattice::T) where {T <: AbstractGraph}
    @assert dims(lattice.bravais) == 2 "plot only works for 2D lattices."

    # Recover node positions
    positions = [
        get_pos(
            lattice.bravais[node.uvw[1]],
            node.uvw[2:end]
        ) for node in lattice.nodes
    ]

    # Plot nodes/sites
    PyPlot.plot(
        [p[1] for p in positions[:]],
        [p[2] for p in positions[:]],
        "ko"
    )

    # plot edges/bonds
    for level in lattice.edges
        for edge in level
            PyPlot.plot(
                [positions[edge.node1.uvw...][1], positions[edge.node2.uvw...][1]],
                [positions[edge.node1.uvw...][2], positions[edge.node2.uvw...][2]],
                "k-"
            )
        end
    end

    axis("equal")
    lattice
end
