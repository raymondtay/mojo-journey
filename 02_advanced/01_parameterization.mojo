# Mojo supports variadic parameters, similar to Variadic arguments:
# - variadic parameters must be homogenous - that is, all the values must be on the same type.
# - the parameter type must be register-passable.
# - the parameter values are not automatically projected into a `VariadicList`,
# so you need to construct the list explicitly (see below)
# ```python
# def sum_params[*values: Int]() -> Int:
#   comptime list = VariadicList(values)
#   var sum = 0
#   for v in list:
#     sum += v
#   return sum
# ```
#

# 1. Parameter Expressions 
# Mojo 1.2: a SIMD width inferred from an argument is a `SIMDLength`, not an
# `Int`, and the `SIMD.size` alias was removed in favour of `SIMD.length`.

def concat[
    dtype: DType, ls_size: SIMDLength, rh_size: SIMDLength, //
    ](lhs: SIMD[dtype, ls_size], rhs: SIMD[dtype, rh_size]) -> SIMD[dtype,
                                                                    ls_size +
                                                                    rh_size]:
      var result = SIMD[dtype, ls_size + rh_size]()

      comptime for i in range(ls_size):
        result[i] = lhs[i]

      comptime for j in range(rh_size):
        result[ls_size+j] = rhs[j]

      return result

def slice[
    dtype: DType, size: SIMDLength, //
    ](x: SIMD[dtype, size], offset: Int) -> SIMD[dtype, size // 2]:
  comptime new_size = size // 2
  var result = SIMD[dtype, new_size]()

  for i in range(new_size):
    result[i] = SIMD[dtype, 1](x[i + offset])

  return result

def reduce_add(x : SIMD) -> Int:
  # Decorator to create a parametric if condition, which is a if-statement that
  # runs at compile-time. It requires that its condition be a valid parameter
  # expression, and ensures that only the live branch of the if-statement is
  # compiled into the program.
  comptime if x.length == 1: return Int(x[0])
  elif x.length == 2:
    return Int(x[0]) + Int(x[1])

  comptime half_size = x.length // 2
  var lhs = slice(x, 0)
  var rhs = slice(x, half_size)
  return reduce_add(lhs + rhs)

@fieldwise_init
struct Sentiment(Equatable, ImplicitlyCopyable):
  var _value: Int
  comptime NEGATIVE = Sentiment(0)
  comptime NEURAL   = Sentiment(1)
  comptime POSITIVE = Sentiment(2)

  def __eq__(self, other: Self) -> Bool:
    return self._value == other._value

  def __ne__(self, other: Self) -> Bool:
    return not (self == other)

def is_happy(s: Sentiment):
  if s == Sentiment.POSITIVE:
    print("Yes. ☺")
  else:
    print("No. ☽")


# 2. Automatica parameterization through such creative ways.
def interleave(v1: SIMD, v2: type_of(v1)) -> SIMD[v1.dtype, v1.length*2]:
  var result = SIMD[v1.dtype, v1.length*2]()
  for i in range(v1.length):
    result[i*2] = SIMD[v1.dtype, 1](v1[i])
    result[i*2+1] = SIMD[v1.dtype, 1](v2[i])
  return result

# 3. Automatic parameterization with partially-bound types
@fieldwise_init
struct Fudge[sugar: Int, cream: Int, chocolate: Int = 7](Writable):
  # Mojo 1.2: `Stringable`/`__str__` are gone; `String(f)` uses `write_to`.
  def write_to(self, mut writer: Some[Writer]):
    writer.write(
        "Fudge (", Self.sugar, ", ", Self.cream, ", ", Self.chocolate, ")"
        )
# 3. the unbound 'cream' and 'chocolate' parameters become implicit parameters
#    on the 'eat' function. In practice, this is roughly equivalent to writing:
#    def eat[cr: Int, ch: Int](f: Fudge[5, cr, ch]):
#       print("Ate " + String(f))
def eat(f: Fudge[5, ...]):
  print("Ate " + String(f))

def main():
  var lhs = SIMD[DType.float32, 4](1.0, 2.0, 3.0, 4.0)
  var rhs = SIMD[DType.float32, 4](1.1, 2.1, 3.1, 4.1)
  var combo = concat(lhs, rhs)
  print(combo)
  var reduced_value = reduce_add(combo)
  print(reduced_value)

  # 2. interleaving
  var a = SIMD[DType.int16, 4](1,2,3,4)
  var b = SIMD[DType.int16, 4](0, 0, 0, 0)
  var c = interleave(a, b)
  print(c)

  # 3. Partially-bound types
  eat(Fudge[5,6,7]())
  eat(Fudge[5,8,9]())



