from testing import assert_equal, assert_true


fn concat[
    dtype: DType, ls_size: Int, rh_size: Int, //
](lhs: SIMD[dtype, ls_size], rhs: SIMD[dtype, rh_size]) -> SIMD[
    dtype, ls_size + rh_size
]:
    var result = SIMD[dtype, ls_size + rh_size]()

    @parameter
    for i in range(ls_size):
        result[i] = lhs[i]

    @parameter
    for j in range(rh_size):
        result[ls_size + j] = rhs[j]

    return result


fn slice[
    dtype: DType, size: Int, //
](x: SIMD[dtype, size], offset: Int) -> SIMD[dtype, size // 2]:
    comptime new_size = size // 2
    var result = SIMD[dtype, new_size]()
    for i in range(new_size):
        result[i] = SIMD[dtype, 1](x[i + offset])
    return result


fn reduce_add(x: SIMD) -> Int:
    @parameter
    if x.size == 1:
        return Int(x[0])
    elif x.size == 2:
        return Int(x[0]) + Int(x[1])

    comptime half_size = x.size // 2
    var lhs = slice(x, 0)
    var rhs = slice(x, half_size)
    return reduce_add(lhs + rhs)


fn interleave(v1: SIMD, v2: type_of(v1)) -> SIMD[v1.dtype, v1.size * 2]:
    var result = SIMD[v1.dtype, v1.size * 2]()
    for i in range(v1.size):
        result[i * 2] = SIMD[v1.dtype, 1](v1[i])
        result[i * 2 + 1] = SIMD[v1.dtype, 1](v2[i])
    return result


@fieldwise_init
struct Sentiment(Equatable, ImplicitlyCopyable):
    var _value: Int
    comptime NEGATIVE = Sentiment(0)
    comptime NEURAL = Sentiment(1)
    comptime POSITIVE = Sentiment(2)

    fn __eq__(self, other: Self) -> Bool:
        return self._value == other._value

    fn __ne__(self, other: Self) -> Bool:
        return not (self == other)


# --- Tests ---


def test_concat_basic():
    var lhs = SIMD[DType.int32, 2](1, 2)
    var rhs = SIMD[DType.int32, 2](3, 4)
    var result = concat(lhs, rhs)
    assert_equal(Int(result[0]), 1)
    assert_equal(Int(result[1]), 2)
    assert_equal(Int(result[2]), 3)
    assert_equal(Int(result[3]), 4)


def test_concat_different_sizes():
    var lhs = SIMD[DType.float32, 4](1.0, 2.0, 3.0, 4.0)
    var rhs = SIMD[DType.float32, 4](1.1, 2.1, 3.1, 4.1)
    var result = concat(lhs, rhs)
    assert_equal(Int(result[0]), 1)
    assert_equal(Int(result[4]), 1)  # truncated to int


def test_concat_float():
    var lhs = SIMD[DType.float32, 2](1.5, 2.5)
    var rhs = SIMD[DType.float32, 2](3.5, 4.5)
    var result = concat(lhs, rhs)
    # Check as floats via comparison
    assert_true(result[0] > 1.4 and result[0] < 1.6)
    assert_true(result[3] > 4.4 and result[3] < 4.6)


def test_slice_first_half():
    var x = SIMD[DType.int32, 4](10, 20, 30, 40)
    var result = slice(x, 0)
    assert_equal(Int(result[0]), 10)
    assert_equal(Int(result[1]), 20)


def test_slice_second_half():
    var x = SIMD[DType.int32, 4](10, 20, 30, 40)
    var result = slice(x, 2)
    assert_equal(Int(result[0]), 30)
    assert_equal(Int(result[1]), 40)


def test_reduce_add_size_1():
    var x = SIMD[DType.int32, 1](7)
    assert_equal(reduce_add(x), 7)


def test_reduce_add_size_2():
    var x = SIMD[DType.int32, 2](3, 5)
    assert_equal(reduce_add(x), 8)


def test_reduce_add_size_4():
    var x = SIMD[DType.int32, 4](1, 2, 3, 4)
    assert_equal(reduce_add(x), 10)


def test_reduce_add_size_8():
    var x = SIMD[DType.int32, 8](1, 1, 1, 1, 1, 1, 1, 1)
    assert_equal(reduce_add(x), 8)


def test_interleave_basic():
    var v1 = SIMD[DType.int16, 4](1, 2, 3, 4)
    var v2 = SIMD[DType.int16, 4](10, 20, 30, 40)
    var result = interleave(v1, v2)
    assert_equal(Int(result[0]), 1)
    assert_equal(Int(result[1]), 10)
    assert_equal(Int(result[2]), 2)
    assert_equal(Int(result[3]), 20)
    assert_equal(Int(result[4]), 3)
    assert_equal(Int(result[5]), 30)
    assert_equal(Int(result[6]), 4)
    assert_equal(Int(result[7]), 40)


def test_interleave_zeros():
    var v1 = SIMD[DType.int16, 4](1, 2, 3, 4)
    var v2 = SIMD[DType.int16, 4](0, 0, 0, 0)
    var result = interleave(v1, v2)
    assert_equal(Int(result[0]), 1)
    assert_equal(Int(result[1]), 0)
    assert_equal(Int(result[2]), 2)
    assert_equal(Int(result[3]), 0)


def test_sentiment_equality():
    assert_true(Sentiment.POSITIVE == Sentiment.POSITIVE)
    assert_true(Sentiment.NEGATIVE == Sentiment.NEGATIVE)
    assert_true(Sentiment.NEURAL == Sentiment.NEURAL)


def test_sentiment_inequality():
    assert_true(Sentiment.POSITIVE != Sentiment.NEGATIVE)
    assert_true(Sentiment.NEGATIVE != Sentiment.NEURAL)
    assert_true(Sentiment.POSITIVE != Sentiment.NEURAL)


def test_sentiment_custom_value():
    var s1 = Sentiment(42)
    var s2 = Sentiment(42)
    var s3 = Sentiment(99)
    assert_true(s1 == s2)
    assert_true(s1 != s3)
