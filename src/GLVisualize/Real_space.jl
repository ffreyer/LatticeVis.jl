# GLVisualize throws a lot of information in your face. I don't want that, so
# here's a Container with a show() to supress that.
mutable struct Plot3DContainer
    window::GLWindow.Screen
    cam::Camera
    hotkeys::Hotkeys
end
function show(io::IO, c::Plot3DContainer)
    print(io, "Plot3DContainer with\n")
    print(io, "\twindow\n")
    print(io, "\tcam\n")
    print(io, "\thotkeys\n")
end

function glsphere(;pos=Point3f0(0f0), r=0.1f0, quality=24)
    GLNormalMesh(HyperSphere(pos, r), quality)
end

function plot3D(
        lattice::LatticeType,
        args...;
        # Window setup
        window::GLWindow.Screen = init_window(),
        # Camera setup
        rot_v::Signal{Float32} = Signal(0.05f0),
        trans_v::Signal{Float32} = Signal(4f0),
        cam_position::Vec3f0 = Vec3f0(2),
        lookat::Vec3f0 = Vec3f0(0),
        up::Vec3f0 = Vec3f0(0., 0., 1.),
        cam::Camera = camera(
            window,
            rot_v = rot_v,
            trans_v = trans_v,
            position = cam_position,
            lookat = lookat,
            up = up
        ),
        # Visualization setup
        primitive::AbstractMesh = glsphere(),
        site_color::RGBA{Float32} = RGBA{Float32}(0.2, 0.4, 0.8, 1.0),
        bond_color::RGBA{Float32} = RGBA{Float32}(0.2, 0.2, 0.2, 1.0),
        bond_thickness::Float32 = 5f0,
        kwargs...
    ) where {LatticeType <: AbstractGraph}

    @assert dims(lattice.unitcell) == 3 "plot3D only works for 3D lattices."

    # Controls
    hotkeys = Hotkeys(window)
    init_screenshots!(hotkeys)
    angles = init_angles(hotkeys)
    init_QWEASD_controls!(hotkeys, cam, angles)

    # Recover node positions
    positions = [
        GeometryTypes.Point3f0(get_pos(
            lattice.unitcell,
            node.uvw[1],
            node.uvw[2:end]
        )) for node in lattice.nodes
    ]

    # Gather edges/bonds
    edge_positions = GeometryTypes.Point3f0[]
    for level in lattice.edges
        for edge in level
            push!(
                edge_positions,
                GeometryTypes.Point3f0(positions[edge.node1.uvw...])
            )
            push!(
                edge_positions,
                GeometryTypes.Point3f0(positions[edge.node2.uvw...])
            )
        end
    end

    # Render sites
    _view(
        visualize(
            (primitive, positions[:]),
            color = site_color
        ),
        window,
        camera = cam
    )

    # Render bonds
    _view(
        visualize(
            edge_positions,
            :linesegment,
            color = bond_color,
            thickness = bond_thickness
        ),
        window,
        camera = cam
    )

    center!(window, :custom)

    Plot3DContainer(window, cam, hotkeys)
end
