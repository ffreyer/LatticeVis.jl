struct UnitCell{Dimensions, T <: AbstractFloat}
    tag::Symbol # currently unused
    # could be used to speed up neighbor search
    basis::Vector{Point{Dimensions, T}}
    dirs::NTuple{Dimensions, Vec{Dimensions, T}}
end

function UnitCell(
        pos::Point{D, T},
        dirs::NTuple{D, Vec{D, T}}
    ) where {D, T <: AbstractFloat}
    UnitCell([pos], dirs)
end

function UnitCell(
        basis::Vector{Point{D, T}},
        dirs::NTuple{D, Vec{D, T}}
    ) where {D, T <: AbstractFloat}
    UnitCell(:None, basis, dirs)
end

"""
    get_pos(uc, a, u)

Returns R = Rₐ + ∑ᵢ uᵢaᵢ for a UnitCell uc.
"""
function get_pos(
        uc::UnitCell{D, T},
        alpha::Int64,
        uvw::NTuple{D, Int64}
    ) where {D, T}
    uc.basis[alpha] + reduce(+, map((i, v) -> i*v, uvw, uc.dirs))
    # B.pos + reduce(+, map((i, v) -> i * v, uvw, B.dirs))
end

# Returns the dimensionality of a UnitCell
dims(uc::UnitCell{D, T}) where {D, T} = D

function merge(ucs::UnitCell{D, T}...) where {D, T}
    @assert all(
        uc -> all(
            v -> v in ucs[1].dirs,
            uc.dirs
        ),
        ucs
    ) "Lattice vectors must match!"

    UnitCell(
        ucs[1].tag,
        [p for uc in ucs for p in uc.basis],
        ucs[1].dirs
    )
end


# TODO
# center! for more safety in get_neighbors


# Literally just constructors from here on out

################################################################################
### 2D Lattices
################################################################################


"""
    square()

Returns a UnitCell representing a square lattice.

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
    UnitCell(:cubic, pos, (a * Vec(1., 0.), b * Vec(0., 1.)))
end


"""
    triangle()

Returns a UnitCell representing a triangular lattice.

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
        return UnitCell(
            :cubic,
            [pos, pos + Point(a*sind(30.), b*cosd(30.))],
            (a * Vec(1., 0.), b * Vec(0., 1.))
        )
    else
        return UnitCell(
            :primitive,
            pos,
            (a*Vec(0., 1.), b*Vec(cosd(30.0), sind(30.0)))
        )
    end
end


"""
    honeycomb()

Returns a UnitCell representing a honeycomb lattice.

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
        return UnitCell(
            :cubic,
            [pos, pos + Point(0.0, b)],
            (2a * cosd(30) * Vec(1., 0.), 2b * cosd(30) * Vec(0., 1.))
        )
    else
        return UnitCell(
            :primitive,
            [pos, pos + Point(a, 0.)],
            (
                2a * cosd(30) * Vec(0., 1.),
                2b * cosd(30) * Vec(cosd(30.0), sind(30.0))
            )
        )
    end
end


################################################################################
### 3D Lattices
################################################################################


"""
    sc()

Returns a UnitCell representing a simple cubic lattice.

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
        c::T = 1.0,
        isa::Symbol = :cubic
    ) where T <: AbstractFloat
    UnitCell(
        :cubic,
        [pos],
        (
            a * Vec(1., 0., 0.),
            b * Vec(0., 1., 0.),
            c * Vec(0., 0., 1.)
        )
    )
end


"""
    bcc()

Returns a UnitCell representing a body centered cubic lattice.

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
        c::T = 1.0,
        isa::Symbol = :primitive
    ) where T <: AbstractFloat

    if isa == :cubic
        return UnitCell(
            :cubic,
            [pos, pos + Point{3}(0.5)],
            (
                a * Vec(1., 0., 0.),
                b * Vec(0., 1., 0.),
                c * Vec(0., 0., 1.)
            )
        )
    else
        return UnitCell(
            :primitive,
            [pos],
            (
                a * 0.5 * Vec(1., 1., -1.),
                b * 0.5 * Vec(1., -1., 1.),
                c * 0.5 * Vec(-1., 1., 1.)
            )
        )
    end
end


"""
    fcc()

Returns a UnitCell representing a face centered cubic lattice.

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
        c::T = 1.0,
        isa::Symbol = :primitive
    ) where T <: AbstractFloat

    if isa == :cubic
        return UnitCell(
            :cubic,
            [
                pos,
                pos + Point(0.5, 0.5, 0.0),
                pos + Point(0.5, 0.0, 0.5),
                pos + Point(0.0, 0.5, 0.5)
            ],
            (
                a * Vec(1., 0., 0.),
                b * Vec(0., 1., 0.),
                c * Vec(0., 0., 1.)
            )
        )
    else
        return UnitCell(
            :primitive,
            [pos],
            (
                a * 0.5 * Vec(1., 1., 0.),
                b * 0.5 * Vec(1., 0., 1.),
                c * 0.5 * Vec(0., 1., 1.)
            )
        )
    end
end


"""
    diamond()

Returns a UnitCell representing a diamond lattice.

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
        c::T = 1.0,
        isa::Symbol = :primitive
    ) where T <: AbstractFloat

    merge(
        fcc(pos = pos, a=a, b=b, c=c, isa=isa),
        fcc(pos = pos + Point{3}(0.25), a=a, b=b, c=c, isa=isa)
    )
end
