import numpy as np
from numba import cuda, njit
import time

N = 100_000_000  # ~100 mil elements

# AoS: shape (N, 4)  => [x, y, z, mass]
particles_aos = np.zeros((N, 4), dtype=np.float32)
particles_aos[:, 0] = np.linspace(0, 1, N)  # x
particles_aos[:, 1] = 1.0  # y
particles_aos[:, 2] = 2.0  # z
particles_aos[:, 3] = 3.0  # mass

# SoA: 4 separate arrays
x = particles_aos[:, 0].copy()
y = particles_aos[:, 1].copy()
z = particles_aos[:, 2].copy()
m = particles_aos[:, 3].copy()


# Kernel: AoS access (poor Coalescing)
# Each thread reads x from a row (i,0) but the stride is 4 * sizeof(float) between rows.
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
