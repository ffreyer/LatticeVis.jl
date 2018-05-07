using LatticeVis

lattice = Lattice(Honeycomb, 10)
plot(lattice)



using PyPlot

lattice = Lattice(Honeycomb, 10, do_periodic = false)

figure(figsize=(10, 10))
plot(lattice)
xlim(-5, 21)
ylim(1, 27)
