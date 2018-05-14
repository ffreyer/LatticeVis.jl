# LatticeVis

[![Build Status](https://travis-ci.org/ffreyer/LatticeVis.jl.svg?branch=master)](https://travis-ci.org/ffreyer/LatticeVis.jl)
[![Coverage Status](https://coveralls.io/repos/ffreyer/LatticeVis.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/ffreyer/LatticeVis.jl?branch=master)
[![codecov.io](http://codecov.io/github/ffreyer/LatticeVis.jl/coverage.svg?branch=master)](http://codecov.io/github/ffreyer/LatticeVis.jl?branch=master)

Install the package with

`Pkg.clone("git://github.com/ffreyer/LatticeVis.jl.git")`

This package offers a way to create lattices from unit cells, that is a combination of basis positions and translation vectors. The dimensionality of the lattice can be choosen freely, as can the number of neighbor orders (i.e. first and second for 2).

A lattice can be created with `Lattice(name_of_lattice, Ls=(Lx, Ly))`, e.g. `Lattice(honeycomb, Ls=(8, 6))`. For this `name_of_lattice` has to be implemented as a `::UnitCell`. Additional unit cells can be implemented fairly easily, see `UnitCell.jl`. They can also be passed by value, e.g. `Lattice(honeycomb(), L=3)`.

A simple 2D plot can be generated with `plot(lattice_object)` where `lattice_object` is the Graph returned from `Lattice`.

    l = Lattice(honeycomb)
    plot(l)

---

Implemented 2D UnitCells:
- `square`
- `triangle`
- `honeycomb`

Implemented 3D UnitCells
- `sc`
- `bcc`
- `fcc`
- `diamond`

Each UnitCell constructor can take the keyword arguments:
- `pos::Point{2, T} = Point{2}(0.)`: Starting position for this lattice.
- `a::T = 1.0`: Scaling along the first lattice vector.
- `b::T = 1.0`: Scaling along the second lattice vector.
- `isa::Symbol = :primitive`: Lattice shape to use (:cubic or :primitive)


`Lattice` has the keyword arguments:
- `L::Int64 = 8`: The size of the lattice
- `Ls::NTuple{D, Int64} = (L, ..., L)`: The size of the lattice in D dimensions.
- `do_periodic::Bool = true`: Generate lattice with periodic bonds.
- `N_neighbors::Int64 = 1`: The number neighbor levels used.
- `nodetype::Type{N} = StandardSite`: Type of Node used to construct the lattice.
- `edgetype::Type{E} = StandardBond`: Type of Edge used to construct the lattice.
- `graphtype::Type{G} = StandardGraph`: Type of Graph used to construct the lattice.

where `nodetype`, `edgetype` and `graphtype` allow for custom nodes, edges and/or graph types to be used in the generation of a lattice. For this, the custom types must inherit from AbstractNode, AbstractEdge and AbstractGraph respectively, and implement fitting constructors. See `LatticeGraph.jl`.
