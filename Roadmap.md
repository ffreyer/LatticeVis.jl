

# General structure


---

### Bravais lattice representation

represent lattice w/ initial pos + translation vectors

Problems:
- primitive unit vectors makes it awkward to compute neighbors
- primitive unit vectors are hard to combine
- cubic unit vectors may fail for some lattices (e.g. triangular?)

keep things variable:

    struct Bravais{N}
        pos::Point3f0
        dirs::NTuple{N, Point3f0}
    end

- should implement some `center!()` function to guarantee that different `Bravais` are close
- implement general `*(::Bravais, lattice_indices)`


---

### Neighbors

need to find neighbors for each `Bravais.pos`

- calculate `R = Bravais.pos + ∑i ∑j Bravais.dirs[i] * j` for each Bravais, where -N <= j <= N (should be enough, can possibly be less, depends on vectors though)
- for each `p = Bravais.pos`, calculate `d = |p - R|²` and save the corresponding index difference (j, Bravais) `uvw`
- sort `d`, permute `uvw`
- every `d` of approximately the same value (because Floats are Floats) belongs to the same level of neighbors.
- save the `uvw` for each requested level


---

### Create Lattice

- spawn lattice by indices (i.e. `Array{d+1, Type}`)
- connect neighbors using the relative `uvw` from above
- get positions from `Bravais`

using Graphs (minimal)

    struct Node
        edges::Vector{Vector{Edge}}
    end

    struct Edge
        from::Node
        to::Node
    end

    struct Graph{N}
        nodes::Array{N, Node}
        edges::Vector{Vector{Edge}}
    end

Problems:

###### Generating an `Edge` for each Node will create duplicates

Could implement `==(::Edge, ::Edge)` and/or `in(::Edge, ::Vector{Edge})` and explicitly check if an Edge exists yet. Searching through the edges in Node `to` is much cheaper (O(N) rather than O(N²)). For this add each new Edge to both `edge.from` and `edge.to`.

###### Type Node requires type Edge, type Edge requires type Node

Add `abstract type AbstractNode end` and reference those.

###### Edge requires nodes to be present

Here we can create nodes with empty Vectors first and add edges later. In general you may need to use `Union{Void, Type}` or `Nullable{Type}`

###### Generalized data

- let nodes (and edges) carry indices
- let nodes (and edges) carry dictionaries (this may be somewhat inefficient due to memory fragmentation)


---

### Visualization

###### Compose (2D)

Create SVG's or PDF's for lattices.
- use `circle(x, y, r)` to draw sites
- use `line([(x, y), (x, y)])` to draw edges

save as

    composition = compose(
        context(),
        lines...,
        circles...
    )
    draw(SVG(filename, width, height), composition)


###### PyPlot (2D)

Create whatever for lattices.
- use markers to draw nodes?
- use normal `plot` to draw edges

###### GLVisualize (3D)

Create interactive real-time lattices. Save as png.

nodes as balls:

    sphere = GeometryTypes.GLNormalMesh(
        GeometryTypes.HyperSphere(pos, radius),
        quality
    )

edges as linesegments:

    lines = Point3f0[]
    for e in edges
        push!(lines, R(e.from))
        push!(lines, R(e.to))
    end

window creation and actually drawing stuff:

    window = GLVisualize.glscreen()
    @async renderloop(window)
    _view(
        visualize(
            (sphere, positions)
        ),
        window
    )
    _view(
        visualize(
            lines,
            :linesegment
        ),
        window
    )

Finish by crying when you want to change anything because nothing is documented
