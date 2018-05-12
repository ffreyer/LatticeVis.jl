struct Bravais{Dimensions, T <: AbstractFloat}
    tag::Symbol # currently unused
    pos::Point{Dimensions, T}
    dirs::NTuple{Dimensions, Vec{Dimensions, T}}
end
Bravais(pos::Point, dirs::NTuple) = Bravais(:None, pos, dirs)

"""
    get_pos(Bravais, u)

Returns R = R₀ + ∑ᵢ uᵢaᵢ for a Bravais B
"""
function get_pos(B::Bravais, uvw)
    B.pos + reduce(+, map((i, v) -> i * v, uvw, B.dirs))
end

# Returns the dimensionality of Bravais
dims(B::Bravais{D, T}) where {D, T} = D
dims(Bs::Vector{Bravais{D, T}}) where {D, T} = D

function merge(bvs::Vector{Bravais{D, T}}...) where {D, T}
    [b for bv in bvs for b in bv]
end

# TODO
# more constructors

# TODO
# center! for more safety in get_neighbors

################################################################################
### 2D Lattices
################################################################################


"""
    square([; pos])
"""
function square(;
        pos::Point{2, T} = Point{2}(0.),
        a::T = 1.0,
        b::T = 1.0,
        isa::Symbol = :cubic
    ) where T <: AbstractFloat
    [Bravais(
        :cubic,
        pos,
        (
            a * Vec(1., 0.),
            b * Vec(0., 1.)
        )
    )]
end


"""
    triangle([, pos])
"""
function triangle(;
        pos::Point{2, T} = Point{2}(0.),
        a::T = 1.0,
        b::T = 1.0,
        isa::Symbol = :primitive
    ) where T <: AbstractFloat

    if isa == :cubic
        return merge(
            square(
                pos = pos,
                a = a,
                b = 2b * cosd(30)
            ),
            square(
                pos = pos + Point(a*sind(30.), b*cosd(30.)),
                a = a,
                b = 2b * cosd(30)
            )
        )
    else
        return [Bravais(
            :primitive,
            pos,
            (a*Vec(0., 1.), b*Vec(cosd(30.0), sind(30.0)))
        )]
    end
end


"""
    honeycomb([, pos])
"""
function honeycomb(;
        pos::Point{2, T} = Point{2}(0.),
        a::T = 1.0,
        b::T = 1.0,
        isa::Symbol = :primitive
    ) where T <: AbstractFloat

    if isa == :cubic
        return merge(
            triangle(
                pos = pos,
                a = 2a * cosd(30),
                b = 2b * cosd(30),
                isa = :cubic
            ),
            triangle(
                pos = pos + Point(0.0, b),
                a = 2a * cosd(30),
                b = 2b * cosd(30),
                isa = :cubic
            )
        )
    else
        return merge(
            triangle(
                pos = pos,
                a = 2a * cosd(30),
                b = 2b * cosd(30)
            ),
            triangle(
                pos = pos + Point(a, 0.),
                a = 2a * cosd(30),
                b = 2b * cosd(30)
            )
        )
    end
end


################################################################################
### 3D Lattices
################################################################################


"""
    fcc([, pos])
"""
fcc(pos = Point{3}(0.)) = Bravais(
    :primitive,
    pos,
    (
        Vec{3}(0.5, 0.5, 0.0),
        Vec{3}(0.5, 0.0, 0.5),
        Vec{3}(0.0, 0.5, 0.5)
    )
)

"""
    diamond([, pos])
"""
diamond(pos = Point{3}(0.)) = [fcc(pos), fcc(pos + Point{3}(0.25))]
