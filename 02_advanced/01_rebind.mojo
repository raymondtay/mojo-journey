# 
# One of the consequences of Mojo not performing function instantiation in the
# parser like C++ is that Mojo cannot always figure out whether some parameteric
# types are equal and complain about invalid conversions. this typically occurs
# in static dispatch patterns,. For example, the following won't compile:
#
# error: invalid call to 'take_simd8': argument #0 cannot be converted from
# 'SIMD[f32, nelts]' to 'SIMD[f32, 8]'
#         take_simd8(x)
#         ~~~~~~~~~~^~~
# This is because the parser fully type-checks the function without
# instantiation, and the type of `x` is still `SIMD[f32, nelts]` and not
# `SIMD[f32, 8]` despite the static conditional. The remedy is to manually
# `rebind` the type of `x`, using the `rebind` built-in, which inserts a
# compile-time assert that the input and result types resolve to the same type
# after function instantiation.
#
fn take_simd8(x: SIMD[DType.float32, 8]):
    pass

# DOES NOT COMPILE
# fn generic_simd[nelts: Int](x: SIMD[DType.float32, nelts]):
#     @parameter
#     if nelts == 8:
#         take_simd8(x)

fn generic_simd2[nelts: Int](x: SIMD[DType.float32, nelts]):
    @parameter
    if nelts == 8:
        take_simd8(rebind[SIMD[DType.float32, 8]](x)) # rebind !!!

