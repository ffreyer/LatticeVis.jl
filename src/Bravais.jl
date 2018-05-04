struct Bravais{D, T <: AbstractFloat}
    tag::Symbol
    pos::Point{D, T}
    dirs::NTuple{D, Vec{D, T}}
end
Bravais(pos::Point, dirs::NTuple) = Bravais(:None, pos, dirs)

# const BravaisComp = Array{Bravais}
# BravaisComp(args...) = [args...]::BravaisComp

Honeycomb(pos = Point{2}(0.)) = [
    Bravais(
        pos + Point{2}(0.),
        (
            Vec{2}(0., 2cosd(30.0)),
            2cosd(30.0) * Vec{2}(cosd(30.0), sind(30.0))
        )
    ),
    Bravais(
        pos + Point{2}(1.0, 0.0),
        (
            Vec{2}(0., 2cosd(30.0)),
            2cosd(30.0) * Vec{2}(cosd(30.0), sind(30.0))
        )
    )
]

fcc(pos = Point{3}(0.)) = Bravais(
    pos,
    (
        Vec{3}(0.5, 0.5, 0.0),
        Vec{3}(0.5, 0.0, 0.5),
        Vec{3}(0.0, 0.5, 0.5)
    )
)

diamond(pos = Point{3}(0.)) = [fcc(pos), fcc(pos + Point{3}(0.25))]


function get_pos(B::Bravais, uvw)
    B.pos + reduce(+, map((i, v) -> i * v, uvw, B.dirs))
    # mapreduce((i, v) -> i*v, +, uvw, B.dirs)
end


# TODO
# more constructors

# TODO
# center! for more safety in get_neighbors
