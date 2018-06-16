"""
    plot(lattice)

Creates a 2D plot of lattice using PyPlot.
"""
function plot(lattice::T, args...; kwargs...) where {T <: AbstractGraph}
    D = dims(lattice.unitcell)
    if D == 2
        plot2D(lattice, args...; kwargs...)
    elseif D == 3
        plot3D(lattice, args...; kwargs...)
    else
        error("No method available to plot $D-dimensional lattice.")
    end
end


function plot2D(lattice::T) where {T <: AbstractGraph}
    @assert dims(lattice.unitcell) == 2 "plot2D only works for 2D lattices."

    # Recover node positions
    positions = [
        get_pos(
            lattice.unitcell,
            node.uvw[1],
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

    PyPlot.axis("equal")
    lattice
end
