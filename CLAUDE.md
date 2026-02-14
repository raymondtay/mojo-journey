# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

An educational repository exploring Mojo programming for HPC (High-Performance Computing). Covers language fundamentals, GPU programming, SIMD/AVX-512/AMX vectorization, and memory layout optimization (AoS vs SoA vs AoSoA). Licensed under MPL 2.0.

## Build & Run Commands

**Environment manager:** Pixi (conda-based). Must be installed first.

```bash
# Run a Mojo file
pixi run mojo <path/to/file>.mojo

# Compile a Mojo file
pixi run mojo build <path/to/file>.mojo

# Emit assembly (for verifying vectorization/AMX instructions)
pixi run mojo build --emit=asm <path/to/file>.mojo

# AMX assembly generation (requires LLVM/Clang, in 10_hyperscaling_for_Mojo_programmers/)
make amx-asm

# Update dependencies
pixi update
```

No formal test framework or linting/formatting tools are configured.

## Key Dependencies (pixi.toml)

- `mojo >= 0.26.1` (nightly, from modular conda channel)
- `numpy`, `emberjson`, `numba`

## Repository Structure

- `01_basics/` — Language fundamentals: types, traits, lifecycles, error handling, context managers
- `01_gpu_basics/` — GPU kernel examples (vector addition, layouts)
- `01_layouts/` — Memory layout concepts (1D/2D)
- `02_advanced/` — Parameterization, pointers, rebind
- `03_applications/` — HPC applications: AoS/SoA/AoSoA memory layouts with cross-language benchmarks (Mojo, C++, CUDA, Python/Numba)
- `10_hyperscaling_for_Mojo_programmers/` — CPU optimization: SIMD, AVX-512, AMX with assembly verification
- `docs/` — Reference papers on memory hierarchies

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
