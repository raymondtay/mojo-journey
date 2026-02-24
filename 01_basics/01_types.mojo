import compile

# emberjson 0.3.0 is binary-incompatible with this Mojo nightly; disabled until updated
# from emberjson import parse, to_string
from utils.numerics import max_finite, min_finite

struct Source:
  var name: String
  fn __init__(out self, n: String):
    self.name = n

struct Target:
  var name: String
  @implicit
  fn __init__(out self, s: Source):
    self.name = s.name

fn r[
    size: Int
](
    va: SIMD[DType.int8, size],
    vb: SIMD[DType.int8, size],
    out vc: SIMD[DType.int8, size],
):
    vc = va * vb


def describeDType[dtype: DType]():
    print(dtype, " is floating point: ", dtype.is_floating_point())
    print(dtype, " is integral: ", dtype.is_integral())
    print("Min/max finite values for: ", dtype)
    print(min_finite[dtype](), max_finite[dtype]())


def main():
    # emberjson disabled (binary incompatible with current nightly):
    # var data = parse('{ "name": "Alice", "age": 30, "isStudent": false, "courses": ["Math", "Science"] }')
    # print(to_string[pretty=True](data))

    describeDType[DType.float32]()

    var vec1 = SIMD[DType.int8, 4](3, 5, 7, 9)
    var vec2 = SIMD[DType.int8, 4](2, 3, 4, 5)
    var vec3: SIMD[DType.int8, 4]
    # Option 1: works by default
    # var product = vec1 * vec2
    # print(product)

    # Option 2: works by construction, as well.
    vec3 = r[4](vec1, vec2)
    print(vec3)

    print("--- Unoptimized LLVM IR ---")
    print(compile.compile_info[r[4], emission_kind="asm"]())

    print("\n--- Optimized LLVM IR ---")
    print(compile.compile_info[r[4], emission_kind="llvm-opt"]())

    var a = Source("source")
    var b: Target = a
    print("b is implicitly converted to `Target`, with name: ",b.name)
