# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

An educational repository exploring Mojo programming for HPC (High-Performance Computing). Covers language fundamentals, GPU programming, SIMD/AVX-512/AMX vectorization, and memory layout optimization (AoS vs SoA vs AoSoA). Licensed under MPL 2.0.

## Build & Run Commands

**Environment manager:** Pixi (conda-based). Must be installed first.

```bash
# Run a Mojo file
pixi run mojo <path/to/file>.mojo

# Run a test
pixi run mojo tests/<test_file>.mojo

# Compile a Mojo file
pixi run mojo build <path/to/file>.mojo

# Emit assembly (for verifying vectorization/AMX instructions)
pixi run mojo build --emit=asm <path/to/file>.mojo

# AMX assembly generation (requires LLVM/Clang, in 10_hyperscaling_for_Mojo_programmers/)
make amx-asm

# Update dependencies
pixi update
```

No formal test framework is configured; tests are run as standalone Mojo files in the `tests/` directory.

## Key Dependencies (pixi.toml)

- `mojo` 1.2.x and `max` 26.7.x (stable `https://conda.modular.com/max` channel). `max` is required for GPU code (`max.gpu`) and `layout`.

## Mojo 1.2 conventions used in this repo

- `def` only (`fn` was removed); `def` does **not** imply `raises`, so declare `raises` explicitly.
- Stdlib imports use the `std.` prefix (`from std.time import ...`, `from std import random`); GPU imports use `max.gpu` (`from max.gpu.host import DeviceContext`); `layout` is imported as `layout`.
- `comptime` replaces `alias`; `comptime for` / `comptime if` replace `@parameter for/if`.
- Every new variable needs `var` (implicit declarations are errors).
- `Writable.write_to` replaces `Stringable`/`__str__`; `Deinitable` replaces `ImplicitlyDestructible`; `__init__(out self, *, copy: Self)` replaces `__copyinit__`; `__deinit__` replaces `__del__`.
- `Pointer` replaces `UnsafePointer` (`unsafe_offset`, `unsafe_write`, `unsafe_load`, `ptr[unsafe_offset=i]`); heap memory via `alloc(Layout[T](count=n))` -> `Allocation`, released with `dealloc(a^)` (or `.into_managed()`).
- SIMD widths inferred from arguments are `SIMDLength`; use `.length` (not `.size`).
- GPU kernels take fixed-width ints (`Int32`), not `Int`; launch with `ctx.enqueue_function[kernel](args..., grid_dim=..., block_dim=...)`; detect Apple GPUs with `default_accelerator().is_apple_gpu()`.
- Tests end with `def main() raises: TestSuite.discover_tests[__functions_in_module()]().run()`.
- `numpy`, `emberjson`, `numba`, `pygame`

## Repository Structure

- `01_basics/` — Language fundamentals: types, traits, lifecycles, error handling, context managers
- `01_gpu_basics/` — GPU kernel examples (vector addition, layouts)
- `01_layouts/` — Memory layout concepts (1D/2D)
- `02_advanced/` — Parameterization, pointers, rebind
- `03_applications/` — HPC applications: AoS/SoA/AoSoA memory layouts with cross-language benchmarks (Mojo, C++, CUDA, Python/Numba)
- `10_hyperscaling_for_Mojo_programmers/` — CPU optimization: SIMD, AVX-512, AMX with assembly verification
- `docs/` — Reference papers on memory hierarchies
- `tests/` — Standalone test files for verifying language and performance features

## Architecture Notes

**Memory layout patterns** are the central theme of the applications:
- **AoS** (Array-of-Structures): per-object locality, poor for SIMD/GPU
- **SoA** (Structure-of-Arrays): vectorization-friendly, uses separate `List` arrays per field
- **AoSoA** (Tiled SoA): hybrid with tile width matching SIMD lane count (e.g., `W=16` for AVX-512)

**SIMD pattern** used throughout HPC examples:
```mojo
comptime W = 16  # SIMD width
va = SIMD[DType.float32, W](a)
vx = (ptr + i).load[width=W, alignment=ALIGN]()
```

**Assembly verification** is used to confirm the compiler emits expected vector instructions (e.g., `vfmadd213ps` for AVX-512, `tileloadd`/`tdpbssd` for AMX).
