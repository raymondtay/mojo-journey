from testing import assert_equal, assert_true

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


fn update_positions_aos(var particles: List[Particle], dt: Float32):
    var n = len(particles)
    for i in range(n):
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


fn approx_eq(a: Float32, b: Float32, tol: Float32 = 1e-5) -> Bool:
    var diff = a - b
    if diff < 0:
        diff = -diff
    return diff < tol


def test_update_positions_aos():
    var particles = List[Particle]()
    particles.append(Particle(x=1.0, y=2.0, z=3.0, vx=10.0, vy=20.0, vz=30.0))
    particles.append(Particle(x=0.0, y=0.0, z=0.0, vx=1.0, vy=2.0, vz=3.0))

    update_positions_aos(particles, Float32(1.0))

    # Particle 0: x=1+10*1=11, y=2+20*1=22, z=3+30*1=33
    assert_true(approx_eq(particles[0].x, 11.0))
    assert_true(approx_eq(particles[0].y, 22.0))
    assert_true(approx_eq(particles[0].z, 33.0))

    # Particle 1: x=0+1*1=1, y=0+2*1=2, z=0+3*1=3
    assert_true(approx_eq(particles[1].x, 1.0))
    assert_true(approx_eq(particles[1].y, 2.0))
    assert_true(approx_eq(particles[1].z, 3.0))


def test_update_positions_aos_fractional_dt():
    var particles = List[Particle]()
    particles.append(Particle(x=0.0, y=0.0, z=0.0, vx=10.0, vy=20.0, vz=30.0))

    update_positions_aos(particles, Float32(0.5))

    assert_true(approx_eq(particles[0].x, 5.0))
    assert_true(approx_eq(particles[0].y, 10.0))
    assert_true(approx_eq(particles[0].z, 15.0))


def test_update_positions_soa():
    var soa = ParticlesSoA(2)
    soa.x[0] = 1.0; soa.y[0] = 2.0; soa.z[0] = 3.0
    soa.vx[0] = 10.0; soa.vy[0] = 20.0; soa.vz[0] = 30.0
    soa.x[1] = 0.0; soa.y[1] = 0.0; soa.z[1] = 0.0
    soa.vx[1] = 1.0; soa.vy[1] = 2.0; soa.vz[1] = 3.0

    update_positions_soa(soa, Float32(1.0))

    assert_true(approx_eq(soa.x[0], 11.0))
    assert_true(approx_eq(soa.y[0], 22.0))
    assert_true(approx_eq(soa.z[0], 33.0))
    assert_true(approx_eq(soa.x[1], 1.0))
    assert_true(approx_eq(soa.y[1], 2.0))
    assert_true(approx_eq(soa.z[1], 3.0))


def test_update_positions_soa_fractional_dt():
    var soa = ParticlesSoA(1)
    soa.x[0] = 0.0; soa.y[0] = 0.0; soa.z[0] = 0.0
    soa.vx[0] = 10.0; soa.vy[0] = 20.0; soa.vz[0] = 30.0

    update_positions_soa(soa, Float32(0.5))

    assert_true(approx_eq(soa.x[0], 5.0))
    assert_true(approx_eq(soa.y[0], 10.0))
    assert_true(approx_eq(soa.z[0], 15.0))


def test_aos_soa_consistency():
    """Both layouts should produce the same results for identical input."""
    var n = 4
    var dt = Float32(0.1)

    var aos = List[Particle]()
    var soa = ParticlesSoA(n)
    for i in range(n):
        var fi = Float32(i)
        aos.append(Particle(x=fi, y=fi * 2, z=fi * 3, vx=1.0, vy=2.0, vz=3.0))
        soa.x[i] = fi; soa.y[i] = fi * 2; soa.z[i] = fi * 3
        soa.vx[i] = 1.0; soa.vy[i] = 2.0; soa.vz[i] = 3.0

    update_positions_aos(aos, dt)
    update_positions_soa(soa, dt)

    for i in range(n):
        assert_true(approx_eq(aos[i].x, soa.x[i]))
        assert_true(approx_eq(aos[i].y, soa.y[i]))
        assert_true(approx_eq(aos[i].z, soa.z[i]))


def test_update_empty_particles():
    """Updating an empty particle list should not error."""
    var particles = List[Particle]()
    update_positions_aos(particles, Float32(1.0))
    assert_equal(len(particles), 0)

    var soa = ParticlesSoA(0)
    update_positions_soa(soa, Float32(1.0))
    assert_equal(len(soa.x), 0)
