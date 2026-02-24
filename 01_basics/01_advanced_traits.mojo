#
# To support Mojo's work in AI, Mojo aims to provide powerful, easy-to-use
# metaprogramming with zero runtime cost. This compile-time metaprogramming uses
# the same language as runtime progres, so you don't have to learn a new
# language - just a few new features.
#
# The main new feature is parameters. You can think of a parameter as a
# compile-time variable that becomes a runtime constant. This usage of
# "parameter" is probably different from what you're used to from other
# languages, where "parameter" and "argument" are often used interchangably. In
# Mojo, "parameter" and "parameter expression" refer to compile-time values, and
# "argument" and "expression" refer to runtime values.
#
# def my_sort[
#     # infer-only parameters
#     dtype: DType,
#     width: Int,
#     //,
#     # positional-only parameter
#     values: SIMD[dtype, width],
#     /,
#     # positional-or-keyword parameter
#     compare: fn (Scalar[dtype], Scalar[dtype]) -> Int,
#     *,
#     # keyword-only parameter
#     reverse: Bool = False,
# ]() -> SIMD[dtype, width]:
# Here's a quick overview of the special characters in the parameter list:
# - Double slash (//): parameters declared before the double slash are infer-only
#                      parameters.
#                      
# - Slash (/): parameters declared before a slash are positional-only parameters.
#              Positional-only and keyword-only parameters follow the same rules
#              as positional-only and keyword-only arguments.
#
# - A parameter name prefixed with a star, like *Types identifies a variadic parameter
#   (not shown in the example above). Any parameters following the variadic parameter are keyword-only.
#
# - Star (*): in a parameter list with no variadic parameter, a star by itself indicates
#             that the following parameters are keyword-only parameters.
#
# - An equals sign (=) introduces a default value for an optional parameter.

# 1. Parameterized functions
fn repeat[MsgType: Stringable, //, count : Int](msg: MsgType):
  @parameter
  for _ in range(count):
    print(String(msg))

# 2. Parameterized structs
struct GenericArray[ElementType: Copyable & Movable & ImplicitlyDestructible]:
  var data: UnsafePointer[Self.ElementType, MutExternalOrigin]
  var size: Int
  
  fn __init__(out self, var *elements: Self.ElementType):
    self.size = len(elements)
    self.data = alloc[Self.ElementType](self.size)
    for i in range(self.size):
      (self.data + i).init_pointee_move(elements[i].copy())

  fn __del__(deinit self):
    for i in range(self.size):
      (self.data + i).destroy_pointee()
    self.data.free()

  fn __getitem__(self, i: Int) raises -> ref[self] Self.ElementType:
    if i < self.size:
      return self.data[i]
    else:
      raise Error("array out-of-bounds, trying to reference index: {}".format(i))

  @staticmethod
  fn splat(count: Int, value: Self.ElementType) -> Self:
    return GenericArray[Self.ElementType](value.copy())


@fieldwise_init
struct Container[ElementType: Movable & ImplicitlyDestructible]:
  var element: Self.ElementType

  def __str__[
      StrElementType: Writable & Movable, //
      ](self: Container[StrElementType]) -> String:
    return String("Container[{}]".format(String(self.element)))

# 3. Inference failures - YES It CAN HAPPEN ☺
struct One[tpe: Writable & Copyable & Movable]:
  var value: Self.tpe

  fn __init__(out self, value: Self.tpe):
    self.value = value.copy()

def use_one():
  s1 = One("456")
  s2 = One(123)

struct Two[tpe: Writable & Copyable & Movable]:
  var val1: Self.tpe
  var val2: Self.tpe

  fn __init__(out self, val1: One[Self.tpe], val2: One[Self.tpe]):
    self.val1 = val1.value.copy()
    self.val2 = val2.value.copy()
    print(String(self.val1), String(self.val2))

  @staticmethod
  fn fire(thing1: One[Self.tpe], thing2: One[Self.tpe]):
    print("🔥!!!!", String(thing1.value), String(thing2.value))

def use_two():
  s3 = Two(One("Infer"), One("me"))
  Two.fire(One(1), One(2))
  # Two.fire(One("Mixed"), One(0))


# 4. Dependent Types
# Sometimes you need to declare functions where parameters depend on other
# parameters. Because the signature is processed left-to-right, a parameter can
# only depend on a parameter earlier in the parameter list.

fn dependent_type[dtype: DType, value: Scalar[dtype]]():
  print("Value: " , value)
  print("Value is floating-point: ", dtype.is_floating_point())

fn dependent_type2[dtype: DType, //, value: Scalar[dtype]]():
  print("Value: " , value)
  print("Value is floating-point: ", dtype.is_floating_point())



def main():
  repeat[3]("Hello world!")

  gen_arr = GenericArray[Int](1,2,3,4,5)
  for i in range(gen_arr.size):
    end = ", " if i < gen_arr.size - 1 else "\n"
    print(gen_arr[i], end=end)

  # print(gen_arr[6]) # error!!!

  _ = GenericArray[Float64].splat(8, 0) # i don't know what to do with this yet ...

  float_container = Container(3.142)
  string_container = Container("Hello World")
  print(float_container.__str__())
  print(string_container.__str__())

  # 3. Inference failures demonstrations
  use_one()
  use_two()

  # 4. dependent Type
  dependent_type[DType.float64, Float64(3.142)]()
  # Question: Do you know what needs to be changed to get this -> dependent_type[Float64(3.142)]()
  dependent_type2[Float64(3.142)]()

