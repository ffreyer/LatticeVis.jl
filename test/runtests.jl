using LatticeVis
using Base.Test

# write your own tests here

using LatticeVis
window, cam, hotkeys = draw([
    sc(),
    sc(Point3f0(0.5, 0.5, 0.0)),
    sc(Point3f0(0.5, 0.0, 0.5)),
    sc(Point3f0(0.0, 0.5, 0.5))
])
