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
# center! for more safety in get_neighbors


# Literally just constructors from here on out

################################################################################
### 2D Lattices
################################################################################


"""
    square()

Returns a composition of Bravais lattices to represent a square lattice.

Keyword arguments include
- `pos::Point{2, T} = Point{2}(0.)`: Starting position for this lattice.
- `a::T = 1.0`: Scaling along the first lattice vector.
- `b::T = 1.0`: Scaling along the second lattice vector.
- `isa::Symbol = :cubic`: Lattice shape to use (:cubic or :primitive)
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
    triangle()

Returns a composition of Bravais lattices to represent a triangular lattice.

Keyword arguments include
- `pos::Point{2, T} = Point{2}(0.)`: Starting position for this lattice.
- `a::T = 1.0`: Scaling along the first lattice vector.
- `b::T = 1.0`: Scaling along the second lattice vector.
- `isa::Symbol = :primitive`: Lattice shape to use (:cubic or :primitive)
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
    honeycomb()

Returns a composition of Bravais lattices to represent a honeycomb lattice.

Keyword arguments include
- `pos::Point{2, T} = Point{2}(0.)`: Starting position for this lattice.
- `a::T = 1.0`: Scaling along the first lattice vector.
- `b::T = 1.0`: Scaling along the second lattice vector.
- `isa::Symbol = :primitive`: Lattice shape to use (:cubic or :primitive)
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
    sc()

Returns a composition of Bravais lattices to represent a simple cubic lattice.

Keyword arguments include
- `pos::Point{3, T} = Point{3}(0.)`: Starting position for this lattice.
- `a::T = 1.0`: Scaling along the first lattice vector.
- `b::T = 1.0`: Scaling along the second lattice vector.
- `c::T = 1.0`: Scaling along the third lattice vector.
- `isa::Symbol = :cubic`: Lattice shape to use (:cubic or :primitive)
"""
function sc(;
        pos::Point{3, T} = Point{3}(0.),
        a::T = 1.0,
        b::T = 1.0,
        c::T = 1.0
        isa::Symbol = :cubic
    ) where T <: AbstractFloat
    [Bravais(
        :cubic,
        pos,
        (
            a * Vec(1., 0., 0.),
            b * Vec(0., 1., 0.),
            b * Vec(0., 0., 1.)
        )
    )]
end


"""
    bcc()

Returns a composition of Bravais lattices to represent a body centered cubic
lattice.

Keyword arguments include
- `pos::Point{3, T} = Point{3}(0.)`: Starting position for this lattice.
- `a::T = 1.0`: Scaling along the first lattice vector.
- `b::T = 1.0`: Scaling along the second lattice vector.
- `c::T = 1.0`: Scaling along the third lattice vector.
- `isa::Symbol = :primitive`: Lattice shape to use (:cubic or :primitive)
"""
function bcc(;
        pos::Point{3, T} = Point{3}(0.),
        a::T = 1.0,
        b::T = 1.0,
        c::T = 1.0
        isa::Symbol = :primitive
    ) where T <: AbstractFloat

    if isa == :cubic
        return merge(
            sc(pos = pos, a=a, b=b, c=c, isa = :cubic),
            sc(pos = pos + Point{3}(0.5), a=a, b=b, c=c, isa = :cubic)
        )
    else
        return [Bravais(
            :primitive,
            pos,
            (
                a * 0.5 * Vec(1., 1., -1.),
                b * 0.5 * Vec(1., -1., 1.),
                b * 0.5 * Vec(-1., 1., 1.)
            )
        )]
    end
end


"""
    fcc()

Returns a composition of Bravais lattices to represent a face centered cubic
lattice.

Keyword arguments include
- `pos::Point{3, T} = Point{3}(0.)`: Starting position for this lattice.
- `a::T = 1.0`: Scaling along the first lattice vector.
- `b::T = 1.0`: Scaling along the second lattice vector.
- `c::T = 1.0`: Scaling along the third lattice vector.
- `isa::Symbol = :primitive`: Lattice shape to use (:cubic or :primitive)
"""
function fcc(;
        pos::Point{3, T} = Point{3}(0.),
        a::T = 1.0,
        b::T = 1.0,
        c::T = 1.0
        isa::Symbol = :primitive
    ) where T <: AbstractFloat

    if isa == :cubic
        return merge(
            sc(pos = pos, a=a, b=b, c=c, isa = :cubic),
            sc(pos = pos + Point(0.5, 0.5, 0.0), a=a, b=b, c=c, isa = :cubic),
            sc(pos = pos + Point(0.5, 0.0, 0.5), a=a, b=b, c=c, isa = :cubic),
            sc(pos = pos + Point(0.0, 0.5, 0.5), a=a, b=b, c=c, isa = :cubic)
        )
    else
        return [Bravais(
            :primitive,
            pos,
            (
                a * 0.5 * Vec(1., 1., 0.),
                b * 0.5 * Vec(1., 0., 1.),
                b * 0.5 * Vec(0., 1., 1.)
            )
        )]
    end
end


"""
    diamond()

Returns a composition of Bravais lattices to represent a diamond lattice.

Keyword arguments include
- `pos::Point{3, T} = Point{3}(0.)`: Starting position for this lattice.
- `a::T = 1.0`: Scaling along the first lattice vector.
- `b::T = 1.0`: Scaling along the second lattice vector.
- `c::T = 1.0`: Scaling along the third lattice vector.
- `isa::Symbol = :primitive`: Lattice shape to use (:cubic or :primitive)
"""
function diamond(;
        pos::Point{3, T} = Point{3}(0.),
        a::T = 1.0,
        b::T = 1.0,
        c::T = 1.0
        isa::Symbol = :primitive
    ) where T <: AbstractFloat

    merge(
        fcc(pos = pos, a=a, b=b, c=c, isa=isa),
        fcc(pos = pos + Point{3}(0.25), a=a, b=b, c=c, isa=isa)
    )
end
