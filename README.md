# LatticeVis

[![Build Status](https://travis-ci.org/ffreyer/LatticeVis.jl.svg?branch=master)](https://travis-ci.org/ffreyer/LatticeVis.jl)
[![Coverage Status](https://coveralls.io/repos/ffreyer/LatticeVis.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/ffreyer/LatticeVis.jl?branch=master)
[![codecov.io](http://codecov.io/github/ffreyer/LatticeVis.jl/coverage.svg?branch=master)](http://codecov.io/github/ffreyer/LatticeVis.jl?branch=master)

Install the package with

    Pkg.clone("git://github.com/ffreyer/LatticeVis.jl.git")

A lattice can be created with `Lattice(name_of_lattice, size)`, e.g. `Lattice(Honeycomb, 3)`. For this `name_of_lattice` has to be implemented as a
`::Bravais`. Additional Bravais lattices can be implemented fairly easily, see
`Bravais.jl`. They can also be passed by value, e.g. `Lattice(Honeycomb(), 3)`.

A simple plot can be generated with `plot(lattice_object)` where `lattice_object` is the Graph returned from `Lattice`.
