struct Bravais{D, T <: AbstractFloat}
    tag::Symbol
    pos::Point{D, T}
    dirs::NTuple{D, Vec{D, T}}
end
Bravais(pos::Point, dirs::NTuple) = Bravais(:None, pos, dirs)

# const BravaisComp = Array{Bravais}
# BravaisComp(args...) = [args...]::BravaisComp

Honeycomb() = [
    Bravais(
        Point{2}(0.),
        (
            Vec{2}(0., 2cosd(30.0)),
            2cosd(30.0) * Vec{2}(cosd(30.0), sind(30.0))
        )
    ),
    Bravais(
        Point{2}(1.0, 0.0),
        (
            Vec{2}(0., 2cosd(30.0)),
            2cosd(30.0) * Vec{2}(cosd(30.0), sind(30.0))
        )
    )
]


function get_pos(B::Bravais, uvw)
    B.pos + reduce(+, map((i, v) -> i * v, uvw, B.dirs))
    # mapreduce((i, v) -> i*v, +, uvw, B.dirs)
end


# TODO
# more constructors

# TODO
# center!
