AoS versus SoA
--

This is really advanced stuff in High Performance Computing; but also at the
same time, it's also fundamental. Let's start...

1. Array of Structures (AoS)
--

Definition:

```pre
You store objects in memory contiguously, each object containing all its fields.
Example, list of particles, each with the x, y, z, mass.
```

Example code in `C`:

```C
typedef struct {
  float x;
  float y;
  float z;
  float mass;
} Particle;

Particle particles[N]; // N is number of particles to store in array
```

Memory Layout (AoS)
---

```pre
[x y z mass][x y z mass][x y z mass]...
```

Characteristics
---

| Aspect | Effect |
| -- | -- |
| Cache behavior | Good per particle locality; bad for compose-wise scans |
| SIMD vectorization | Hard (computer struggles due to strided loads) |
| GPU Coalescing | Poor - threads read interleaved data |
| Writes | Good when updating the whole particle |

2. Structure of Arrays (SoA)
--

Definition:

Fields are separated into distinct arrays.

Example code in `C`

```c
typedef struct {
  float x[N];
  float y[N];
  float z[N];
  float mass[N];
} Particles_SOA;
```

Memory Layout (SoA)
---

```pre
xxx....yyy...zzz....massmassmass....
```

Characteristics
---

| Aspect | Effect |
| -- | -- |
| Cache behavior | Excellent for column-wise (per-component) access|
| SIMD vectorization | Easy - contiguous arrays == full vector loads |
| GPU Coalescing | Excellent - threads load adjacent values |
| Writes | Potentially worse if updating all components of 1 particle|

3. Famous Example: Force accumulation of particles
--

This is the most reference textbook HPC example because of the following:

* AoS breaks SIMD
* SoA unlocks auto-vectorization
* GPUs demand coalesced loads
* Compilers emit 4x or 8x wider vector loads on SoA.

Here's what it means, concretely in __code__

AoS version
---

```c
for (int i = 0; i < N; i++) {
  float float_x = 0.0f, float_y = 0.0f, float_z = 0.0f;

  for (int j = 0; j < N; j++) {
    float dx = particles[j].x - particles[i].x;
    float dy = particles[j].y - particles[i].y;
    float dz = particles[j].z - particles[i].z;
    float r2 = dx*dx + dy*dy + dz*dz;

    float inv = 1.0f / sqrtf(r2);
    float_x += dx * inv;
    float_y += dy * inv;
    float_z += dz * inv;
  }
  particles[i].x = float_x;
  particles[i].y = float_y;
  particles[i].z = float_z;
}
```

What went _wrong_ with AoS?
---

* `particles[j].x` ⇒ compiler must load x, y, z, mass but only uses `x`. Nada
* stride = 16 bytes ⇒ vector load break.
* CPU prefetcher fails
* GPU threads read 16-byte stride per lane ⇒ no coalescing ⇒ memory bottleneck.

SoA version
---

Here's an example code, expressed in `C`:

```C
for (int i = 0; i < N; i++) {
    float fx = 0.0f, fy = 0.0f, fz = 0.0f;
    for (int j = 0; j < N; j++) {
        float dx = Particles_SOA.x[j] - Particles_SOA.x[i];
        float dy = Particles_SOA.y[j] - Particles_SOA.y[i];
        float dz = Particles_SOA.z[j] - Particles_SOA.z[i];
        float r2 = dx*dx + dy*dy + dz*dz;
        float inv = 1.0f / sqrtf(r2);
        fx += dx * inv;
        fy += dy * inv;
        fz += dz * inv;
    }
    Particles_SOA.fx[i] = fx;
    Particles_SOA.fy[i] = fy;
    Particles_SOA.fz[i] = fz;
}
```

Why SoA wins?
---

Here are some main points:

* All `x[j]` values are contiguous → single contiguous stream
* Compile can emit `vmovaps ymm registers`
* SIMD can process 8 or 16 values at a time (this is also dependent on the
hardware architecture)
* On GPUs, each thread of a warp reads adjacent 4 bytes → perfect coalescing
* Prefetcher excels on sequential streams

So, what's the performance difference? Typical results from CPU benchmarks
(depending on the amount of computation i.e., `N`, cache layout/details,
Instruction Set Architecture (ISA) of the CPU). Always remember that __coalescing
is King__.

On the flip side, AoS is not bad since it does not work well in these types of
workloads. Use AoS when you encounter the following conditions:

* You always touch all fields of each particle together
* Per-object operations dominate
* You want spatial locality per object (remember the object-oriented processing
dominates)
* You often allocate/free individual objects; when the frequency is too high,
then you could run into situations where entire rows of data are loaded but the
data or operations on the data is no longer valid (e.g., object no longer exists)

CPU prefetcher
----

In AoS layouts, the CPU hardware prefetcher can fail - or be much less effective

* because the memory access pattern becomes irregular and low-signal, even if
the code looks sequential at a high-level (i.e., programming language level).

To understand, here's how CPU prefetchers work...

1. What CPU prefetchers are really good at?

-----
CPUs, in general, don't understand `struct` in the way C programmers do; CPU
detect patterns in physical memory addresses. Typical hardware prefetchers look
for:

1. Unit stride

```c
addr, addr + 64, addr + 128, ...
```

2. Small constant stride

```c
addr, addr + 96, addr + 192, ...
```

3. Single dominant stream per load instruction
4. Few independent streams (constrained by prefetch _slots_)

CPU prefetchers do not track:

* Field semantics
* Pointer chasing
* Conditional access
* Multiple interleaved strides well

2. AOS creates Multiple Interleaved strides

-----
Consider the classic AoS:

```c
struct {
  float x, y, z; // position
  float vx, vy, vz; // velocity
  float mass
} Particle;
Particle particles[N]; // N is number of particles
```

And an processing loop, like this:

```c
float sum = 0.0f;
for (int i = 0; i < N; i++) {
  sum += particles[i].x;
}
```

Memory layout that's simplified

```pre
| x y z vx vy vz m | x y z vx vy vz m | x y z vx vy vz m |
^                  ^                  ^
```

The access pattern for `particle[i].x` , simplistic look, is:

```pre
addr + 0
addr + sizeof(Particle)
addr + 2*sizeof(Particle)
```

The kicker here is that if sizeof(Particle) == 28 or 32 bytes, the stride is not
cache_line aligned.

3. Why the Prefetcher struggles

-----
Prefetchers work best when

```pre
stride == cache_line (64 bytes, typically)
```

but AoS often gives:

```pre
stride = 28, 32, 48, 56 bytes ...
```

This causes major problems:

* Particle cache-line utilization
* Prefetch ambiguity: next address is not a clean _multiple_ of the cache
cache_line
* Prefetcher often under-fetches or mispredicts (waste of memory bandwidth and cpu cycles)

3.2 False sharing of unrelated fields
----

When you load `x`:

```pre
[x y z vx vy vz mass]
```

you also drag in other fields like y, z, ... , mass and this causes __cache
pollution__, bandwidth waste, eviction of useful lines before reuse. To be
clear, the prefetcher (if it had a mind) sees traffic, but __useful work per
line is low__.

"Busy without progress is just wasted effort." -- said by someone wise.

3.3 Multiple streams per iteration
Now, consider the following:

```c
particles[i].x += particles[i].vx * dt;
particles[i].y += particles[i].vy * dt;
particles[i].z += particles[i].vz * dt;
```

Each _load_ instruction does the following:

* Targets a different offset
* Generates a separate memory stream
* All with the same stride, but different base addresses

__Caution__: Most CPUs can track only __~ 4 - 8__ streams effectively. You can
quickly see that AoS __will out run__ that quickly.

4. AoS breaks vectorization

-----
Another common expression is that prefetch loses signals. Easiest way to
understand this is understand memory patterns.
In SoA:

```c
x[i], x[i+1], x[i+2], x[i+3], ... 
```

This becomes:

* A single SIMD load
* One clean stride
* One prefetch stream

In AoS:

```c
particles[i].x, particles[i+1].x,...
```

Becomes:

* Gather or scalar loads
* Harder to predict
* Lower instruction-level regularity

Remember: Prefetchers are __load-instruction driven__. No opportunity for
vectorization implies that the prefetcher performs poorly.

5. TLB presssure:AoS amplifies it.

-----

AoS structures are larger, in other words, the memory footprint is stronger.
That means:

* Fewer elements per page
* More page crossings
* More TLB misses

Prefetchers typically do not cross page boundaries aggressively (for safety),
which results in two (2) outcomes:

* Prefetch stops at the page boundary
* Pipeline stalls, waiting for TLB _refill_

SoA, on the other hand, keeps code packed tighter.

```C
x[] packed tightly
```

Hence, there are _less_ or fewer TLB events. Unexpectedly, there is another
kicker to the entire story, this scenario happens when we have pointer-rich
environments.

6. Pointer rich AoS is even worse

-----
Examine the following code snippet:

```C
struct Node {
  float value;
  Node* next;
};
```

So, what's going on? Well, the assignment of the value of the `next` pointer is
practically random which means when we attempt to run-down the list of nodes, we
have the following access pattern:

```pre
addr ⇒ random ⇒ random ⇒ random ...
```

This defeats all hardware prefetches, destroys predictability. Why? Because we
got (a) no stride, (b) no correlation, (c) No repetition ⇒ reduced opportunities
for spatial and temporal locality.

7. Why SoA fixes all of this?

Examine the following code snippet:

```C
struct Particles {
    float x[N], y[N], z[N];
    float vx[N], vy[N], vz[N];
};
```

At this stage, we have the following advantages as follows:

* one stream per array
* Unit stride
* Perfect cache-line utilization
* Easy SIMD
* TLB-friendly
* Prefetcher hits ~ 100% accuracy, or really close to it.
Hence, this is why high-performance computing, gpus and vector CPUs universally
prefer SoA.

8. Can we compare apples to apples?

-----

AoS vs SoA on CPU prefetch ~= AoS vs SoA on GPU prefetch

So, the main notes around the above claim is to understand the following:

* Prefetcher likes one (1) predictable address stream (unit or constant stride)
* AoS often creates multiple interleaved streams &  wasted cacheline bytes

CUDA (coalescing)

* A _warp_ (32 threads, executing in unison) is happiest when threads access
contiguous addresses so that the hardware can serve them with few memory
transactions.
* AoS often makes each thread read one field out of a bigger struct ⇒ the warp's
  addresses are __strided by sizeof(struct)__ strategy, so the hardware often
needs more transactions, and you pull in lots of unused bytes.
