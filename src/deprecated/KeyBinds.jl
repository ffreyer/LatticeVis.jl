# TODO
#=
Requirements:
- incomplete KSAM, i.e. (KEY_S, ignore scancode, key_down, ignore modifier)
- info message for help screen
- function call on success


=#


struct Key
    skip::NTuple{4, Bool}
    ksam::NTuple{4, Int64}
end


"""
    Key(key[; scancode, action, modifier])

Creates a Key for key bindings. Every argument is optional and won't be checked
if it isn't defined here.
"""
function Key(
        key::Int64 = -10;
        scancode::Int64 = -10,
        action::Int64 = -10,
        modifier::Int64 = -10
    )
    Key(
        (key == -10, scancode == -10, action == -10, modifier == -10),
        (key, scancode, action, modifier)
    )
end


function ==(key::Key, ksam::NTuple{4, Int64})
    (key.skip[1] || (key.ksam[1] == ksam[1])) &&
    (key.skip[2] || (key.ksam[2] == ksam[2])) &&
    (key.skip[3] || (key.ksam[3] == ksam[3])) &&
    (key.skip[4] || (key.ksam[4] == ksam[4]))
end


# This shouldn't be global
struct Hotkeys
    window::GLWindow.Screen
    hotkeys::Dict{Key, Tuple{String, Function}}
    key_listener_signal::Signal
    signals::Vector{Signal}
    destructor_signal::Signal
end

function Hotkeys(window::GLWindow.Screen)
    hotkeys = Dict{Key, Tuple{String, Function}}()
    key_listener_signal = map(window.inputs[:keyboard_buttons]) do ksam
        #!value(window.inputs[:window_open]) && return nothing
        for key in keys(hotkeys)
            if key == ksam
                hotkeys[key][2](ksam)
                break
            end
        end
        nothing
    end
    signals = Signal[]
    destructor_signal = map(window.inputs[:window_open]) do is_open
        if !is_open
            for s in signals[end:-1:1]
                close(s)
            end
            close(key_listener_signal)
            empty!(signals)
            empty!(hotkeys)
            println("Signals closed.")
        end
        nothing
    end
    Hotkeys(window, hotkeys, key_listener_signal, signals, destructor_signal)
end

function push!(h::Hotkeys, key::Key, info::String, action::Function)
    push!(h.hotkeys, Pair(key, (info, action)))
end


"""
    init_screenshots!(Hotkeys[, key = Key(GLFW.KEY_F2)])

Sets *key* as a hotkey for screenshots.
"""
function init_screenshots!(
        h::Hotkeys,
        key::Key=Key(GLFW.KEY_F2, action = GLFW.RELEASE)
    )
    push!(h, key, "Screenshot",
        _ -> begin
            name = string(time_ns())*".png"
            println("Screenshot saved as " * name)
            screenshot(h.window, path=name)
        end
    )
    nothing
end


"""
    init_QWEASD_controls!(Hotkeys, cam[, step::Float32=1°])

Sets up Q, W, E, A, S, D as camera controls keys. A and D perform left and right
rotations, W and S do up and down rotation, Q and E do rolls. *step* can be used
to change the rotational speed.
"""
function init_QWEASD_controls!(
        h::Hotkeys,
        cam::Camera,
        step::Signal{Float32} = Signal(Float32(pi/180))
    )

    pre() = begin
        eyepos = value(cam.eyeposition)
        lookat = value(cam.lookat)
        up = value(cam.up)
        dir = eyepos - lookat
        distance = norm(dir)
        dir_norm = normalize(dir)
        right = normalize(cross(dir, up))
        # lookat, up, dir, dir_norm, right
        return dir_norm, right, up, lookat, dir
    end

    post(rot, lookat, up, dir) = begin
        push!(cam.eyeposition, lookat + rot * dir)
        push!(cam.up, normalize(rot * up))
        return nothing
    end

    push!(h, Key(GLFW.KEY_Q), "Anticlockwise roll", ksam -> begin
        if (ksam[3] == GLFW.PRESS) || (ksam[3] == GLFW.REPEAT)
            dir_norm, right, up, lookat, dir = pre()
            rot = Mat3f0(Quaternions.qrotation(dir_norm, -value(step)))
            post(rot, lookat, up, dir)
            nothing
        end
    end)

    push!(h, Key(GLFW.KEY_E), "Clockwise roll", ksam -> begin
        if (ksam[3] == GLFW.PRESS) || (ksam[3] == GLFW.REPEAT)
            dir_norm, right, up, lookat, dir = pre()
            rot = Mat3f0(Quaternions.qrotation(dir_norm, value(step)))
            post(rot, lookat, up, dir)
            nothing
        end
    end)

    push!(h, Key(GLFW.KEY_W), "Upwards tilt", ksam -> begin
        if (ksam[3] == GLFW.PRESS) || (ksam[3] == GLFW.REPEAT)
            dir_norm, right, up, lookat, dir = pre()
            rot = Mat3f0(Quaternions.qrotation(right, -value(step)))
            post(rot, lookat, up, dir)
            nothing
        end
    end)

    push!(h, Key(GLFW.KEY_S), "Downwards tilt", ksam -> begin
        if (ksam[3] == GLFW.PRESS) || (ksam[3] == GLFW.REPEAT)
            dir_norm, right, up, lookat, dir = pre()
            rot = Mat3f0(Quaternions.qrotation(right, value(step)))
            post(rot, lookat, up, dir)
            nothing
        end
    end)

    push!(h, Key(GLFW.KEY_A), "Left rotation", ksam -> begin
        if (ksam[3] == GLFW.PRESS) || (ksam[3] == GLFW.REPEAT)
            dir_norm, right, up, lookat, dir = pre()
            rot = Mat3f0(Quaternions.qrotation(up, value(step)))
            post(rot, lookat, up, dir)
            nothing
        end
    end)

    push!(h, Key(GLFW.KEY_D), "Right rotation", ksam -> begin
        if (ksam[3] == GLFW.PRESS) || (ksam[3] == GLFW.REPEAT)
            dir_norm, right, up, lookat, dir = pre()
            rot = Mat3f0(Quaternions.qrotation(up, -value(step)))
            post(rot, lookat, up, dir)
            nothing
        end
    end)
    nothing
end


function init_angles(h::Hotkeys)
    step_signal = Signal(Float32(pi/180))
    push!(h.signals, step_signal)

    push!(
        h,
        Key(GLFW.KEY_1, action = GLFW.PRESS),
        "Set angle step to 1°.",
        _ -> push!(step_signal, Float32(pi/180))
    )

    for i in 2:9
        push!(
            h,
            Key(48+i, action = GLFW.PRESS),
            "Set angle step to 1°.",
            _ -> push!(step_signal, Float32(2pi/i))
        )
    end

    step_signal
end
