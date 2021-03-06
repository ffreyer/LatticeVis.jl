"""
    get_neighbors(uc, N[, L = N])

This function searches for neighbors in the UnitCell uc up to order N.
It returns a nested vector of index offsets, which can be added to the indices
of a site to get one of its k-th neighbors.

The vector is indexed as such

    offset = neighbors[sublattice_index][k][running_index]

Optionally L can be set to change the size of the temporary lattice this
function creates. L has to be large enough to include all neighbors up to order
N.
"""
function get_neighbors(
        uc::UnitCell{D, T},
        N::Int64,
        L::Int64 = N
    ) where {D, T}

    # Get all positions
    # This is a bit awkward due to arbitrary dimensionality
    pos2d = Array{typeof(uc.basis[1])}(length(uc.basis), (2L+1)^D)
    for i in eachindex(uc.basis)
        pos2d[i, :] = get_array_from_UnitCell(uc, i, L)[:]
    end
    positions = reshape(pos2d, (length(uc.basis), [2L+1 for _ in 1:D]...))

    # neighbor[basis_index][neighbor_lvl] = Vector of offsets
    neighbors = [Vector{NTuple{D+1, Int64}}[] for _ in eachindex(uc.basis)]

    # Search for neighbors
    for i in eachindex(uc.basis)
        distances = [norm²(uc.basis[i] - p) for p in positions[:]]
        by_dist = sortperm(distances)

        # j = 1 is at 0 distance, skip this
        j = 2
        for lvl in 1:N
            level_distance = distances[by_dist[j]]
            nth_neighbors = NTuple{D+1, Int64}[]

            while distances[by_dist[j]] ≈ level_distance
                # linear index -> d-dimensional index
                index_pos = ind2sub(positions, by_dist[j])
                # we want relative index offsets.
                # the current pos is at index (i, L+1, ..., L+1)
                # because the lattice spans from (-L, L)
                push!(
                    nth_neighbors,
                    (
                        index_pos[1] - i,
                        map(x -> x - L - 1, index_pos[2:end])...
                    )
                )
                j += 1

                # If j > length(by_dist) we have checked all distances, but
                # haven't found enough neighbors. This (always?) means that the
                # temporary lattice is too small.
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

# shift every element of t by 'by'
shift(t::NTuple, by::Int64) = ([x + by for x in t]...)


function get_array_from_UnitCell(
        uc::UnitCell{D, T},
        alpha::Int64,
        L::Int64
    ) where {D,T}
    range = [2L+1 for _ in 1:D]
    reshape(
        [get_pos(
            uc,
            alpha,
            shift(ind2sub((range...), i), -L-1)
            # index -> D-dimensional index, shift range from (1, 2L+1) -> (-L, L)
        ) for i in 1:(2L+1)^D],
        range...
    )
end
