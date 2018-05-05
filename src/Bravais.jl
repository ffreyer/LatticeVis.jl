struct Bravais{Dimensions, T <: AbstractFloat}
    tag::Symbol
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

# TODO
# more constructors

# TODO
# center! for more safety in get_neighbors


Honeycomb(pos = Point{2}(0.)) = [
    Bravais(
        :primitive,
        pos + Point{2}(0.),
        (
            Vec{2}(0., 2cosd(30.0)),
            2cosd(30.0) * Vec{2}(cosd(30.0), sind(30.0))
        )
    ),
    Bravais(
        :primitive,
        pos + Point{2}(1.0, 0.0),
        (
            Vec{2}(0., 2cosd(30.0)),
            2cosd(30.0) * Vec{2}(cosd(30.0), sind(30.0))
        )
    )
]

fcc(pos = Point{3}(0.)) = Bravais(
    :primitive,
    pos,
    (
        Vec{3}(0.5, 0.5, 0.0),
        Vec{3}(0.5, 0.0, 0.5),
        Vec{3}(0.0, 0.5, 0.5)
    )
)

diamond(pos = Point{3}(0.)) = [fcc(pos), fcc(pos + Point{3}(0.25))]
