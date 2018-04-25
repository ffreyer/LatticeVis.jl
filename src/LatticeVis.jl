module LatticeVis

using Quaternions, GeometryTypes, Reactive, Colors
using GLFW, GLWindow, GLAbstraction, GLVisualize

export RGBA, Signal
export Point3f0

import Base: merge, expand, push!, ==
import GLAbstraction: center!

include("Lattice.jl")
export sc, bcc, fcc, diamond
export merge, expand, center!

include("Window.jl")
export init_window, camera

include("KeyBinds.jl")
export Key, HotKeys, push!
export init_screenshots!, init_QWEASD_controls!, init_angles

include("Visualize.jl")
export glsphere, draw

end # module
