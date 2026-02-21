from time import perf_counter_ns

@fieldwise_init
struct Particle(Copyable, ImplicitlyCopyable):
    var x: Float32
    var y: Float32
    var z: Float32
    var vx: Float32
    var vy: Float32
    var vz: Float32

    fn __copyinit__(out self, existing: Self):
      self.x = existing.x.copy()
      self.y = existing.y.copy()
      self.z = existing.z.copy()
      self.vx = existing.vx.copy()
      self.vy = existing.vy.copy()
      self.vz = existing.vz.copy()


struct ParticlesSoA(Copyable, ImplicitlyCopyable):
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

    fn __copyinit__(out self, existing: Self):
      self.x = existing.x.copy()
      self.y = existing.y.copy()
      self.z = existing.z.copy()
      self.vx = existing.vx.copy()
      self.vy = existing.vy.copy()
      self.vz = existing.vz.copy()

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

fn update_positions_soa(mut p: ParticlesSoA, dt: Float32):
    var n = len(p.x)
    for i in range(n):
        p.x[i] += p.vx[i] * dt
        p.y[i] += p.vy[i] * dt
        p.z[i] += p.vz[i] * dt

fn bench_aos(particles: List[Particle], dt: Float32, iters: Int = 5) -> Float64:
  var best_time = 1e9
  for _ in range(iters):
    var start = perf_counter_ns()
    update_positions_aos(particles.copy(), dt)
    var end = perf_counter_ns()
    var elapsed = Float64(end - start) / 1_000_000.0
    if elapsed < best_time:
      best_time = elapsed
  return best_time

fn bench_soa(mut p: ParticlesSoA, dt: Float32, iters: Int = 5) -> Float64:
  var best_time = 1e9
  for _ in range(iters):
    var start = perf_counter_ns()
    update_positions_soa(p, dt)
    var end = perf_counter_ns()
    var elapsed = Float64(end - start) / 1_000_000.0
    if elapsed < best_time:
      best_time = elapsed
  return best_time


fn benchmark(n: Int = 10_000_000):
    var aos = List[Particle]()
    aos.reserve(n)
    for i in range(n):
        aos.append(Particle(
            x = Float32(i),
            y = 1.0, z = 2.0,
            vx = 0.1, vy = 0.2, vz = 0.3
        ))

    var soa = ParticlesSoA(n)
    for i in range(n):
        soa.x[i]  = Float32(i)
        soa.y[i]  = 1.0
        soa.z[i]  = 2.0
        soa.vx[i] = 0.1
        soa.vy[i] = 0.2
        soa.vz[i] = 0.3

    var dt: Float32 = 0.01

    var t_aos = bench_aos(aos^, dt)
    var t_soa = bench_soa(soa, dt)

    print("AoS: ", t_aos, " ms")
    print("SoA: ", t_soa, " ms")
    print("Speedup SoA/AoS: ", t_aos / t_soa)

def main():
    benchmark()
