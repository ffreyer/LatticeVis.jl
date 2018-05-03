# TODO find out if one can access the N in something like NTuple{N, T}

"""
    get_neighbors(B, N[, L = N])

This function searches for neighbors in the Bravais lattice B up to order N.
It returns a nested vector of index offsets, which can be added to the indices
of a site to get one of its k-th neighbors.

The vector is indexed as such

    offset = neighbors[sublattice_index][k][running_index]

Optionally L can be set to change the size of the temporary lattice this
function creates. L has to be large enough to include all neighbors up to order
N.
"""
function get_neighbors(
        BC::Vector{<: Bravais},
        N::Int64,
        L::Int64 = N
    )

    @assert mapreduce(
        B -> length(B.pos), ==, BC
    ) "The Bravais lattice composition must have common dimensionality"

    # Get all positions
    # This is a bit awkward due to arbitrary dimensionality
    d = length(BC[1].pos)
    positions = Array{typeof(BC[1].pos)}(length(BC), [2L+1 for _ in 1:d]...)
    pos2d = reshape(positions, Val{2})

    for (i, B) in enumerate(BC)
        pos2d[i, :] = get_array_from_bravais(B, L)[:]
    end

    # T_T
    # neighbor[Bravais_index][neighbor_lvl] = Vector of offsets
    neighbors = [Vector{NTuple{d+1, Int64}}[] for _ in eachindex(BC)]

    for (i, B) in enumerate(BC)
        distances = [norm²(B.pos - x) for x in positions[:]]
        by_dist = sortperm(distances)

        # j = 1 is at 0 distance, skip this
        j = 2
        for lvl in 1:N
            current_distance = distances[by_dist[j]]
            nth_neighbors = NTuple{d+1, Int64}[]
            while distances[by_dist[j]] ≈ current_distance
                # linear index -> d-dimensional index
                index_pos = ind2sub(positions, by_dist[j])
                # we want relative index offsets.
                # the current Bravais is at index i
                # B.pos is at (L+1, L+1, ...) because we start from -L
                push!(
                    nth_neighbors,
                    (
                        index_pos[1] - i,
                        map(x -> x - L - 1, index_pos[2:end])...
                    )
                )
                j += 1
                j > length(by_dist) && throw(ErrorException(
                    "L is (perhaps) too small for the requested number of \
                    neighbor orders N."
                ))
            end
            push!(neighbors[i], nth_neighbors)
        end
    end

    neighbors
end

# less fault tolerant to use norm²
norm²(v::Point) = dot(v, v)


function get_array_from_bravais(B::Bravais{2}, L::Int64)
    [get_pos(B, (u, v)) for u in -L:L, v in -L:L]
end

function get_array_from_bravais(B::Bravais{3}, L::Int64)
    [
        get_pos(B, (u, v, w))
        for u in -L:L, v in -L:L, w in -L:L
    ]
end
