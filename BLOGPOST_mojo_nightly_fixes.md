# Keeping Up With Mojo: Six Breaking Changes in One Nightly Update

*What happens when a fast-moving language compiler outruns your source code — and how to fix it.*

---

## The Price of Living on the Bleeding Edge

Mojo is moving fast. Deliberately, intentionally, unapologetically fast. The Modular team ships nightly builds that advance the language's type system, memory model, and standard library simultaneously. For an HPC-focused language that needs to get both safety and performance right, this pace is necessary. For developers maintaining a codebase against it, it means the occasional morning where nothing compiles.

This post documents six distinct breaking changes encountered when updating to Mojo nightly `0.26.2.0.dev2026022005`, what each one means, and how to fix it. If you are chasing the same nightly, this is your field guide.

---

## The Landscape

The affected files span the basics and advanced directories of this repository:

```
01_basics/
  01_ctx_mgr.mojo          ← arithmetic type mismatch
  01_types.mojo            ← binary package incompatibility
  01_working_with_traits.mojo  ← trait default body syntax
  01_advanced_traits.mojo  ← pointer origin API + destructor constraints
02_advanced/
  01_parameterization.mojo ← wildcard parameter syntax
  01_pointers.mojo         ← copyinit argument naming
pixi.toml                  ← missing dependency
```

Seven files. Six root causes. Let us go through them one by one.

---

## Fix 1: Trait Default Implementations — `pass` → `...`

**File:** `01_basics/01_working_with_traits.mojo`

**Error:**
```
trait method has results but default implementation returns no value; did you mean '...'?
```

### The Old Code

```mojo
trait Stacklike:
  alias EltType: Copyable & Movable

  fn push(mut self, var item: Self.EltType):
    pass
  fn pop(mut self) -> Self.EltType:
    pass
```

### The Problem

In Python, `pass` is a valid no-op body for any function. In Mojo, `pass` is still syntactically accepted — but for a trait method that declares a non-void return type, the compiler now correctly rejects it. A method that declares `-> Self.EltType` must either return a value or use the explicit "this is intentionally unimplemented" syntax.

Mojo's equivalent of "abstract method body" is `...` (the ellipsis literal), borrowed from Python's stub file convention:

### The Fix

```mojo
trait Stacklike:
  alias EltType: Copyable & Movable

  fn push(mut self, var item: Self.EltType):
    ...
  fn pop(mut self) -> Self.EltType:
    ...
```

The `...` tells the compiler: "this method has no default implementation; any conforming struct must provide one." It is semantically meaningful — unlike `pass`, it cannot be silently compiled into a function that returns garbage.

This is a stricter enforcement of a rule that was always logically correct. The compiler is now catching a class of errors that previously would only surface at runtime.

---

## Fix 2: UnsafePointer's Origin Model Changed

**File:** `01_basics/01_advanced_traits.mojo`

**Error:**
```
'MutOrigin' value has no attribute 'external'
```

### The Old Code

```mojo
struct GenericArray[ElementType: Copyable & Movable]:
  var data: UnsafePointer[Self.ElementType, MutOrigin.external]
```

### The Problem

Mojo's `UnsafePointer` type previously used a two-parameter form where the second argument was an *origin value* — a specific instance of the origin type expressing where this memory came from. `MutOrigin.external` meant "mutable memory from outside the Mojo runtime (e.g., `alloc`)."

The new `UnsafePointer` struct signature is:

```mojo
struct UnsafePointer[
    mut: Bool,   # infer-only — derived from origin
    //,
    type: AnyType,
    origin: Origin[mut=mut],
    *,
    address_space: AddressSpace = AddressSpace.GENERIC,
]
```

Two things changed:
1. `mut` is now an **infer-only parameter** (before the `//` separator) — it is not set directly, it is inferred from the `origin` you provide.
2. `MutOrigin.external` no longer exists as an attribute. It is now a top-level type alias called `MutExternalOrigin`.

You can verify this by looking at what `alloc` returns:

```mojo
fn alloc[type: AnyType, /](count: Int, ...) -> UnsafePointer[type, MutExternalOrigin]:
```

The standard library's own allocation function uses `MutExternalOrigin` — which is the correct origin for heap-allocated, Mojo-owned mutable memory with no tracked lifetime.

### The Fix

```mojo
struct GenericArray[ElementType: Copyable & Movable & ImplicitlyDestructible]:
  var data: UnsafePointer[Self.ElementType, MutExternalOrigin]
```

Note that `ImplicitlyDestructible` was also added to the type constraint — see Fix 3 below for why.

---

## Fix 3: `ImplicitlyDestructible` Is Now Required Explicitly

**File:** `01_basics/01_advanced_traits.mojo`

**Error (after Fix 2):**
```
invalid call to 'destroy_pointee': argument type 'Copyable & Movable'
is not a child trait of 'ImplicitlyDestructible'
```

### The Problem

`GenericArray.__del__` calls `destroy_pointee()` on each element to run its destructor before freeing the backing memory:

```mojo
fn __del__(deinit self):
    for i in range(self.size):
        (self.data + i).destroy_pointee()
    self.data.free()
```

`destroy_pointee()` requires the pointed-to type to implement `ImplicitlyDestructible` — that is, the compiler needs a guarantee that it knows how to destroy a value of that type. With the original constraint `ElementType: Copyable & Movable`, no such guarantee exists. A type could be `Copyable & Movable` without having a destructor that the compiler can call automatically.

In earlier Mojo, `Movable` implied destructibility. That implication has been removed — the relationship is now explicit.

The same issue applies to `Container`:

```mojo
# Before
struct Container[ElementType: Movable]:

# After
struct Container[ElementType: Movable & ImplicitlyDestructible]:
```

### The Fix

Add `ImplicitlyDestructible` to every type parameter constraint on structs that need to destroy their elements:

```mojo
struct GenericArray[ElementType: Copyable & Movable & ImplicitlyDestructible]:
```

This is good discipline regardless — it makes the required contract explicit in the type signature rather than leaving it as an unstated assumption.

---

## Fix 4: Arithmetic on Mixed Integer/Float Types

**File:** `01_basics/01_ctx_mgr.mojo`

**Error:**
```
constraint failed: the SIMD type must be floating point
```

### The Old Code

```mojo
fn __exit__(mut self):
    end_time = time.perf_counter_ns()
    elapsed_time_ms = round(((end_time - UInt(self.start_time)) / 1e6), 3)
```

### The Problem

`time.perf_counter_ns()` returns an integer nanosecond count. `UInt(self.start_time)` is also an integer. The subtraction `end_time - UInt(self.start_time)` produces an integer. Dividing an integer by `1e6` (a `Float64` literal) requires an implicit integer-to-float promotion.

The new Mojo compiler enforces that `round()` only operates on floating-point SIMD types — and the argument reaching `round()` was being classified as integer because the division was not yet widening the type.

The fix is to make the floating-point intent explicit at the subtraction site:

### The Fix

```mojo
fn __exit__(mut self):
    end_time = time.perf_counter_ns()
    elapsed_time_ms = round((Float64(end_time) - Float64(self.start_time)) / 1e6, 3)
```

By wrapping both operands in `Float64(...)` before subtracting, the entire expression is unambiguously floating-point, and `round()` receives a `Float64` as intended. This also fixes a subtle correctness issue: integer subtraction of two `UInt`/`Int` values can silently overflow, whereas `Float64` subtraction handles nanosecond-scale timestamps safely.

---

## Fix 5: Wildcard Parameter Syntax — `*_` → `...`

**File:** `02_advanced/01_parameterization.mojo`

**Error:**
```
'*_' not supported on parameter list, using '...' instead
```

### The Old Code

```mojo
fn eat(f: Fudge[5, *_]):
    print("Ate " + String(f))
```

### The Problem

`Fudge` is a parameterized struct with three parameters: `sugar`, `cream`, and `chocolate`. The function `eat` is only interested in `Fudge` values where `sugar == 5`, but does not care about `cream` or `chocolate`. The `*_` syntax was a wildcard meaning "any values for the remaining parameters."

This syntax has been replaced. The new syntax uses `...` (ellipsis) as the wildcard in type parameter positions:

### The Fix

```mojo
fn eat(f: Fudge[5, ...]):
    print("Ate " + String(f))
```

The `...` reads naturally as "Fudge with sugar=5 and anything else." This is consistent with Mojo's broader use of `...` as the "unspecified/abstract" token, and avoids the visual ambiguity of `*_` (which looks like it could be a variadic argument name).

---

## Fix 6: `__copyinit__` Argument Naming Convention

**File:** `02_advanced/01_pointers.mojo`

**Error:**
```
source argument of '__copyinit__' must be named 'copy'
```

### The Old Code

```mojo
fn __copyinit__(out self, other: Self):
    self.attributes = other.attributes
```

### The Problem

Mojo has standardized the argument names for lifecycle methods. Just as `__init__` uses `out self` (not `inout self` or any other name), `__copyinit__` now requires the source argument to be named `copy`. This is not a style suggestion — it is enforced by the compiler.

The rationale is clarity: when reading a call site, `copy` immediately signals the intent of the argument — it is the value being copied from. `other` is generic and gives no information about the operation.

### The Fix

```mojo
fn __copyinit__(out self, copy: Self):
    self.attributes = copy.attributes
```

Update both the parameter name in the signature and any references to it in the body.

---

## Fix 7: Binary Package Incompatibility — emberjson

**File:** `01_basics/01_types.mojo`

**Error:**
```
emberjson.mojopkg:0:0: error: unexpected trailing bytes after attribute entry
```

### The Problem

This one is fundamentally different from the others — it is not a source code issue. `emberjson` is a pre-compiled Mojo package (`.mojopkg`) distributed via the modular-community conda channel. The `.mojopkg` format encodes internal compiler structures, and when the Mojo compiler version changes significantly, old packages become binary-incompatible with the new compiler.

This is a known pain point of nightly development: third-party packages must be recompiled against each nightly. Until the `emberjson` maintainers release a build compiled against `0.26.2.0.dev2026022005` (or later), the package simply cannot be loaded.

```bash
$ pixi update emberjson
✔ Lock-file was already up-to-date   # no newer build available
```

### The Fix

Comment out the emberjson import and the code that depends on it until a compatible build is published:

```mojo
# emberjson 0.3.0 is binary-incompatible with this Mojo nightly; disabled until updated
# from emberjson import parse, to_string
```

```mojo
def main():
    # emberjson disabled (binary incompatible with current nightly):
    # var data = parse('{ "name": "Alice", ... }')
    # print(to_string[pretty=True](data))

    describeDType[DType.float32]()
    # ... rest of main
```

The rest of the file — type demonstrations, SIMD arithmetic, implicit conversions — compiles and runs fine. Only the JSON parsing section is gated behind the disabled import.

---

## The `pygame` Dependency

**File:** `01_basics/01_helloworld.mojo`, `pixi.toml`

**Error:**
```
Unhandled exception caught during execution: No module named 'pygame'
```

This is the simplest fix: the helloworld demo uses Python interop to drive a pygame window for Conway's Game of Life, but `pygame` was never added to `pixi.toml`. Adding it to the conda dependencies resolves it immediately:

```toml
[dependencies]
# ...
pygame = ">=2.0"
```

Note: installing via `[pypi-dependencies]` fails on Apple Silicon because building pygame from source requires SDL headers. The conda-forge package includes pre-built SDL binaries.

---

## Summary

| File | Root Cause | Fix |
|---|---|---|
| `01_working_with_traits.mojo` | Trait default syntax tightened | `pass` → `...` |
| `01_advanced_traits.mojo` | `UnsafePointer` origin API refactored | `MutOrigin.external` → `MutExternalOrigin` |
| `01_advanced_traits.mojo` | `Movable` no longer implies destructibility | Add `& ImplicitlyDestructible` to constraints |
| `01_ctx_mgr.mojo` | Integer/float arithmetic stricter | Explicit `Float64(...)` cast before division |
| `01_parameterization.mojo` | Wildcard parameter syntax changed | `*_` → `...` |
| `01_pointers.mojo` | `__copyinit__` naming enforced | `other` → `copy` |
| `01_types.mojo` | Pre-compiled package binary-incompatible | Comment out until upstream updates |
| `pixi.toml` | Missing pygame dependency | Add via conda-forge |

---

## Takeaways for Mojo Nightly Users

**1. Trait `pass` bodies are a compilation error for non-void methods.**
Use `...` for abstract/default trait methods. This was always the correct idiom — the compiler now enforces it.

**2. Read the `alloc` return type when you see `UnsafePointer` errors.**
The stdlib's own memory allocation functions tell you exactly what origin type to use. `alloc` returns `UnsafePointer[T, MutExternalOrigin]` — match that type in your struct fields.

**3. `Movable` is not `Destructible`.**
If your struct's destructor calls `destroy_pointee()`, you must require `ImplicitlyDestructible` in the type parameter constraint. Make the contract explicit.

**4. Arithmetic literals carry type information.**
`1e6` is `Float64`. Dividing an integer by `Float64` without an explicit cast is increasingly frowned upon. Be intentional about where widening happens.

**5. Check the modular-community channel before debugging package errors.**
If you see "unexpected trailing bytes" from a `.mojopkg`, it is almost certainly a compiler version mismatch — not a bug in your code. `pixi update <package>` will tell you immediately if a compatible build exists.

**6. Pre-compiled packages lag nightly releases.**
This is an unavoidable consequence of nightly development. Keep emberjson (and any other third-party `.mojopkg` dependencies) guarded with comments so the rest of your code continues to compile.

---

*Part of an ongoing series exploring Mojo for high-performance computing. Source code in this repository. Fixes committed to `main` at `580376d`.*
