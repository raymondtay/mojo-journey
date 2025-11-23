import compile


fn r[
    size: Int
](
    va: SIMD[DType.int8, size],
    vb: SIMD[DType.int8, size],
    out vc: SIMD[DType.int8, size],
):
    vc = va * vb


def main():
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
