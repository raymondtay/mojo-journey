from std.testing import assert_true, assert_equal, TestSuite
from std.memory import (
    Alignment,
    Layout,
    MutPointer,
    ThinAllocation,
    alloc,
    dealloc,
)
from std.sys import align_of

comptime FPtr = MutPointer[Scalar[DType.float32], MutUntrackedOrigin]
# saxpy16 issues 64-byte aligned vector loads, so allocate with that alignment.
comptime SIMD_ALIGN = Alignment.of[SIMD[DType.float32, 16]]()


def saxpy16(
    y: FPtr,
    x: FPtr,
    n: Int,
    a: Float32,
):
    comptime W = 16
    var va = SIMD[DType.float32, W](a)
    comptime ALIGN = align_of[SIMD[DType.float32, W]]()

    var i: Int = 0
    while i + W <= n:
        var vx = x.unsafe_offset(i).unsafe_load[width=W, alignment=ALIGN]()
        var vy = y.unsafe_offset(i).unsafe_load[width=W, alignment=ALIGN]()
        y.unsafe_store[width=W, alignment=ALIGN](i, va * vx + vy)
        i += W

    # Scalar tail
    while i < n:
        var xi = x.unsafe_offset(i).unsafe_load[width=1]()
        var yi = y.unsafe_offset(i).unsafe_load[width=1]()
        y.unsafe_store[width=1](i, a * xi + yi)
        i += 1


def approx_eq(a: Float32, b: Float32, tol: Float32 = 1e-4) -> Bool:
    var diff = a - b
    if diff < 0:
        diff = -diff
    return diff < tol


# Mojo 1.2: `alloc(Layout)` returns an `Allocation`; `unsafe_leak()` hands back
# the raw pointer, and `free_ptr` re-pairs it with the same `Layout` to free it.
def alloc_and_fill(n: Int, value: Float32) -> FPtr:
    var ptr = alloc(
        Layout[Float32, alignment=SIMD_ALIGN](count=n)
    ).unsafe_leak()
    for i in range(n):
        ptr.unsafe_offset(i).unsafe_write(value)
    return ptr


def alloc_iota(n: Int) -> FPtr:
    """Allocate and fill with 0, 1, 2, ..., n-1."""
    var ptr = alloc(
        Layout[Float32, alignment=SIMD_ALIGN](count=n)
    ).unsafe_leak()
    for i in range(n):
        ptr.unsafe_offset(i).unsafe_write(Float32(i))
    return ptr


def free_ptr(ptr: FPtr, n: Int):
    # Float32 is trivially destructible: no per-element deinit needed.
    dealloc(
        ThinAllocation(unsafe_owned_ptr=ptr).unsafe_with_layout(
            Layout[Float32, alignment=SIMD_ALIGN](count=n)
        )
    )


def test_saxpy_aligned_32() raises:
    """Test with n=32 (exactly 2 SIMD iterations, no scalar tail)."""
    var n = 32
    var a = Float32(2.0)
    var x = alloc_and_fill(n, Float32(3.0))  # all 3s
    var y = alloc_and_fill(n, Float32(1.0))  # all 1s

    saxpy16(y, x, n, a)

    # y = 2.0 * 3.0 + 1.0 = 7.0
    for i in range(n):
        assert_true(approx_eq(y[unsafe_offset=i], 7.0), "expected 7.0 at index " + String(i))

    free_ptr(x, n)
    free_ptr(y, n)


def test_saxpy_aligned_16() raises:
    """Test with n=16 (exactly 1 SIMD iteration)."""
    var n = 16
    var a = Float32(0.5)
    var x = alloc_and_fill(n, Float32(4.0))
    var y = alloc_and_fill(n, Float32(2.0))

    saxpy16(y, x, n, a)

    # y = 0.5 * 4.0 + 2.0 = 4.0
    for i in range(n):
        assert_true(approx_eq(y[unsafe_offset=i], 4.0), "expected 4.0 at index " + String(i))

    free_ptr(x, n)
    free_ptr(y, n)


def test_saxpy_unaligned_17() raises:
    """Test with n=17 (1 SIMD iteration + 1 scalar tail element)."""
    var n = 17
    var a = Float32(2.0)
    var x = alloc_and_fill(n, Float32(3.0))
    var y = alloc_and_fill(n, Float32(1.0))

    saxpy16(y, x, n, a)

    for i in range(n):
        assert_true(approx_eq(y[unsafe_offset=i], 7.0), "expected 7.0 at index " + String(i))

    free_ptr(x, n)
    free_ptr(y, n)


def test_saxpy_unaligned_15() raises:
    """Test with n=15 (pure scalar tail, no SIMD iteration)."""
    var n = 15
    var a = Float32(3.0)
    var x = alloc_and_fill(n, Float32(2.0))
    var y = alloc_and_fill(n, Float32(5.0))

    saxpy16(y, x, n, a)

    # y = 3.0 * 2.0 + 5.0 = 11.0
    for i in range(n):
        assert_true(approx_eq(y[unsafe_offset=i], 11.0), "expected 11.0 at index " + String(i))

    free_ptr(x, n)
    free_ptr(y, n)


def test_saxpy_single_element() raises:
    """Test with n=1."""
    var n = 1
    var a = Float32(5.0)
    var x = alloc_and_fill(n, Float32(2.0))
    var y = alloc_and_fill(n, Float32(3.0))

    saxpy16(y, x, n, a)

    # y = 5.0 * 2.0 + 3.0 = 13.0
    assert_true(approx_eq(y[unsafe_offset=0], 13.0))

    free_ptr(x, n)
    free_ptr(y, n)


def test_saxpy_zero_length() raises:
    """Test with n=0 - should be a no-op."""
    var n = 0
    var x = alloc_and_fill(1, Float32(99.0))
    var y = alloc_and_fill(1, Float32(99.0))

    saxpy16(y, x, n, Float32(2.0))

    # y should be untouched since n=0
    assert_true(approx_eq(y[unsafe_offset=0], 99.0))

    free_ptr(x, 1)
    free_ptr(y, 1)


def test_saxpy_with_iota() raises:
    """Test with varying x values (0, 1, 2, ...) and a=1, y=0."""
    var n = 20
    var a = Float32(1.0)
    var x = alloc_iota(n)
    var y = alloc_and_fill(n, Float32(0.0))

    saxpy16(y, x, n, a)

    # y = 1.0 * i + 0.0 = i
    for i in range(n):
        assert_true(approx_eq(y[unsafe_offset=i], Float32(i)), "expected " + String(i) + " at index " + String(i))

    free_ptr(x, n)
    free_ptr(y, n)


def test_saxpy_zero_scalar() raises:
    """Test with a=0 — y should remain unchanged."""
    var n = 20
    var a = Float32(0.0)
    var x = alloc_and_fill(n, Float32(999.0))
    var y = alloc_and_fill(n, Float32(42.0))

    saxpy16(y, x, n, a)

    # y = 0 * 999 + 42 = 42
    for i in range(n):
        assert_true(approx_eq(y[unsafe_offset=i], 42.0))

    free_ptr(x, n)
    free_ptr(y, n)


# Mojo 1.2: test files are plain programs; discover and run every `test_*`.
def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
