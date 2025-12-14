Hybrid Layout (AoSoA / Tiled SoA)
-

Modern HPC uses the `Array-of-Structures-of-Arrays (AoSoA)` aka "Tiled SoA"
approach, the structure looks like:

[!AoSoA](./images/AoSoA.png)

```pre
Tile[0]:
    x[VL], y[VL], z[VL], m[VL]
Tile[1]:
    x[VL], y[VL], z[VL], m[VL]
...
```

Where `VL = SIMD width (4/8/16/32)` and gives the following characteristics:

* Vectorization within each `tile`,
* Good per-object locality,
* Excellent cache behavior

1. Mojo version of AoS vs SoA

*

1.1 AoS in Mojo (conceptual)
--

Going back to the particles _simulation_ earlier used to illustrate the concept, here's how it can be represented in Mojo:

```mojo
struct Particle(Copyable, ImplicitlyCopyable):
    var x: Float32
    var y: Float32
    var z: Float32
    var vx: Float32
    var vy: Float32
    var vz: Float32

# Array-of-Structures: contiguous particles[]
fn update_positions_aos(var particles: List[Particle], dt: Float32):
    var n = len(particles)
    for i in range(n):
        # Load one particle (brings x,y,z,vx,vy,vz into cache)
        var p = particles[i]
        p.x += p.vx * dt
        p.y += p.vy * dt
        p.z += p.vz * dt
        particles[i] = p
```

The takeaways are:

* Memory layout is `[x y z vx vy vz][x y z vx vy vz]...`
* Good when you always work per particle and use most fields.
* Harder for SIMD/GPU because consecutive access to `x` values of particles are _strided in memory_.

1.2 SoA in Mojo
--

Now, we examine how it looks like in SoA form:

```mojo
struct ParticlesSoA(Copyable,ImplicitlyCopyable):
    var x: List[Float32]
    var y: List[Float32]
    var z: List[Float32]
    var vx: List[Float32]
    var vy: List[Float32]
    var vz: List[Float32]

    fn __init__(out self, n: Int):
        self.x = List[Float32](fill=0, length=n)
        self.y = List[Float32](fill=0, length=n)
        self.z = List[Float32](fill=0, length=n)
        self.vx = List[Float32](fill=0, length=n)
        self.vy = List[Float32](fill=0, length=n)
        self.vz = List[Float32](fill=0, length=n)

fn update_positions_soa(mut p: ParticlesSoA, dt: Float32):
    let n = len(p.x)
    for i in range(n):
        p.x[i] += p.vx[i] * dt
        p.y[i] += p.vy[i] * dt
        p.z[i] += p.vz[i] * dt
```

The takeaways are:

* Memory layout is `xxx....yyy....zzz....vxvxvx....vyvy....vzvz...`
* Loops over x / vx can become perfectly vectorizable and GPU-friendly.
* It definitely increases the opportunities to add SIMD primitives or Mojo's vector types.

2. Numba/CUDA: AoS vs SoA and Coalescing
--
Here is a minimal setup that you can paste into a notebook, if you wish. The setup proceeds to encode particles as [x, y, z, mass] in AoS.

```python
import numpy as np
from numba import cuda
import time

N = 100_000_000 # ~ 100 mil elements

# AoS: shape (N, 4)  => [x, y, z, mass]
particles_aos = np.zeros((N, 4), dtype=np.float32)
particles_aos[:, 0] = np.linspace(0, 1, N)  # x
particles_aos[:, 1] = 1.0                   # y
particles_aos[:, 2] = 2.0                   # z
particles_aos[:, 3] = 3.0                   # mass

# SoA: 4 separate arrays
x = particles_aos[:, 0].copy()
y = particles_aos[:, 1].copy()
z = particles_aos[:, 2].copy()
m = particles_aos[:, 3].copy()

# kernel: AoS access (poor Coalescing)
@cuda.jit
def scale_x_aos(particles, factor):
    i = cuda.grid(1)
    if i < particles.shape[0]:
        particles[i, 0] *= factor

# Contiguous x[i] gives fully coalesced loads for a warp
@cuda.jit
def scale_x_soa(x, factor):
    i = cuda.grid(1)
    if i < x.size:
        x[i] *= factor


threads_per_block = 256
blocks = (N + threads_per_block - 1) // threads_per_block

def computation_via_aos():
    d_aos = cuda.to_device(particles_aos)

    start = time.perf_counter()
    scale_x_aos[blocks, threads_per_block](d_aos, 1.1)
    cuda.synchronize()
    t_aos = time.perf_counter() - start
    print("AoS kernel time:", t_aos, "s")
    return t_aos


def computation_via_soa():
    d_x = cuda.to_device(x)

    start = time.perf_counter()
    scale_x_soa[blocks, threads_per_block](d_x, 1.1)
    cuda.synchronize()
    t_soa = time.perf_counter() - start
    print("SoA kernel time:", t_soa, "s")
    return t_soa


if __name__ == "__main__":
    (t_aos, t_soa) = (computation_via_aos(), computation_via_soa())
    print("Speedup (AoS / SoA): ", t_aos / t_soa)

```
