import compile

from emberjson import parse, to_string
from utils.numerics import max_finite, min_finite


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
    var data = parse(
        '{ "name": "Alice", "age": 30, "isStudent": false, "courses": ["Math",'
        ' "Science"] }'
    )
    print(to_string[pretty=True](data))

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
