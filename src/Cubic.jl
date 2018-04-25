abstract type Basis end

# Assumes Unit vectors
struct CubicBasis <: Basis
    positions::Vector{Point3f0}
end
 
"""
    sc(pos = Point3f0(0.))
"""
sc(pos::Point3f0 = Point3f0(0.)) = CubicBasis([pos])

"""
    bcc(pos = Point3f0(0.))
"""
bcc(pos::Point3f0 = Point3f0(0.)) = CubicBasis([pos, pos + Point3f0(0.5)])

"""
    fcc(pos = Point3f0(0.))
"""
function fcc(pos::Point3f0 = Point3f0(0.))
    CubicBasis([
        pos,
        pos + Point3f0(0.5, 0.5, 0.0),
        pos + Point3f0(0.0, 0.5, 0.5),
        pos + Point3f0(0.5, 0.0, 0.5)
    ])
end

"""
    diamond(pos = Point3f0(0.))
"""
function diamond(pos::Point3f0 = Point3f0(0.))
    CubicBasis([
        pos,
        pos + Point3f0(0.5, 0.5, 0.0),
        pos + Point3f0(0.0, 0.5, 0.5),
        pos + Point3f0(0.5, 0.0, 0.5),
        pos + Point3f0(0.25, 0.25, 0.25),
        pos + Point3f0(0.75, 0.75, 0.25),
        pos + Point3f0(0.25, 0.75, 0.75),
        pos + Point3f0(0.75, 0.25, 0.75)
    ])
end

"""
    merge(cubics::CubicBasis...)
"""
function merge(cubics::CubicBasis...)
    positions = Point3f0[]
    for c in cubics
        for p in c.positions
            if !(p in positions)
                push!(positions, p)
            end
        end
    end

    Cubic(positions)
end


function center!(cubic::CubicBasis; epsilon::Float32 = 1f-10)
    es = [Point3f0(1, 0, 0), Point3f0(0, 1, 0), Point3f0(0, 0, 1)]
    for i in eachindex(cubic.positions)
        for j in eachindex(cubic.positions[i])
            while cubic.positions[i][j] > 0.5f0 + epsilon
                cubic.positions[i] = cubic.positions[i] - es[j]
            end
            while cubic.positions[i][j] < -0.5f0 - epsilon
                cubic.positions[i] = cubic.positions[i] + es[j]
            end
        end
    end
    nothing
end



function expand(
        cubic::CubicBasis;
        min::Point3f0 = Point3f0(-1.0),
        max::Point3f0 = Point3f0(1.0),
        epsilon::Float32 = 1f-10
    )

    center!(cubic)
    xrange = floor(Int64, min[1]):ceil(Int64, max[1])
    yrange = floor(Int64, min[2]):ceil(Int64, max[2])
    zrange = floor(Int64, min[3]):ceil(Int64, max[3])

    positions = Point3f0[]
    for x in xrange, y in yrange, z in zrange
        r = Point3f0(x, y, z)
        for p in cubic.positions
            v = p + r
            if all(map((a, x, b) -> a-epsilon <= x <= b+epsilon, min, v, max))
                push!(positions, p + r)
            end
        end
    end

    positions
end
