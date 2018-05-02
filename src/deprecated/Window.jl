"""
    init_window(;[
        name="Simulation", res=(1280, 720), color=RGBA(1., 1., 1., 1.),
        fullscreen=false
    ])

Creates a window (screen) and starts the renderloop asynchronously. Returns the
window (screen).
"""
function init_window(;
        name::String = "Lattice Visualization",
        res = (1280, 720),
        color = RGBA(1., 1., 1., 1.),
        fullscreen = false
    )
    screen = glscreen(name, resolution=res, color=color, fullscreen=fullscreen)
    @async renderloop(screen)
    screen
end



"""
    _camera(window[,
        rot_v=Signal(0.01f0), trans_v=Signal(4f0), position=Vec3f0(4.),
        lookat=Vec3f0(0.), up=Vec3f0(0., 0., 1.)
    ])

Sets up and returns a custom perspective camera. Mostly used for more sane
control speed defaults and easier manipulation of those.
"""
function camera(
        window::GLWindow.Screen;
        rot_v::Signal{Float32}=Signal(0.01f0),
        trans_v::Signal{Float32}=Signal(4f0),
        position::Vec3f0 = Vec3f0(4),
        lookat::Vec3f0 = Vec3f0(0),
        up::Vec3f0=Vec3f0(0., 0., 1.)
    )

    keep = map((a, b) -> !a && b, window.hidden, window.inputs[:mouseinside])
    theta, trans = default_camera_control(
        window.inputs, rot_v, trans_v, keep
    )

    lookat, eyepos, up = Signal(lookat), Signal(position), Signal(up)
    farclip = map(eyepos, lookat) do a,b
        max(norm(b-a) * 5f0, 30f0)
    end
    minclip = map(eyepos, lookat) do a,b
        norm(b-a) * 0.007f0
    end

    PerspectiveCamera(
        theta,
        trans,
        lookat,
        eyepos,
        up,
        window.inputs[:window_area],
        Signal(41f0), # Field of View
        Signal(0.001f0),  # Min distance (clip distance)
        farclip # Max distance (clip distance)
    )
end
