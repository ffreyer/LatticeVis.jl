

function glsphere(;pos=Point3f0(0f0), r=0.1f0, quality=24)
    GLNormalMesh(HyperSphere(pos, r), quality)
end


draw(cubic::CubicBasis; kwargs...) = draw([cubic], kwargs...)

function draw(
        cubics::Vector{CubicBasis};

        rot_v::Signal{Float32} = Signal(0.05f0),
        trans_v::Signal{Float32} = Signal(4f0),
        cam_position::Vec3f0 = Vec3f0(2),
        lookat::Vec3f0 = Vec3f0(0),
        up::Vec3f0=Vec3f0(0., 0., 1.),

        color::RGBA{Float32} = RGBA{Float32}(0.2, 0.4, 0.8, 1.0),
        primitive::AbstractMesh = glsphere()
    )

    window = init_window()
    cam = camera(
        window,
        rot_v = rot_v,
        trans_v = trans_v,
        position = cam_position,
        lookat = lookat,
        up = up
    )

    hotkeys = Hotkeys(window)
    init_screenshots!(hotkeys)
    angles = init_angles(hotkeys)
    init_QWEASD_controls!(hotkeys, cam, angles)

    for c in cubics
        draw(
            window,
            expand(c),
            cam = cam,
            color = RGBA{Float32}(rand(3)..., 1.0)
        )
    end

    window, cam, hotkeys
end

function draw(
        window::GLWindow.Screen,
        pos::Vector{Point3f0};
        cam = :perspective,
        color::RGBA{Float32} = RGBA{Float32}(0.2, 0.4, 0.8, 1.0),
        primitive::AbstractMesh = glsphere()
    )

    _view(visualize(
        (primitive, pos),
        color = color
    ), window, camera = cam)
end
