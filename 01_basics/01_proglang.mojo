
# This basically says that whatever implements `AddOne` would add the value of
# `1` to whatever the structure.
trait AddOne:
  fn add_one(mut self, x: Int) : ...

@fieldwise_init
struct MyPair(Copyable, AddOne):
  var first: Int
  var second: Int

  fn add_one(mut self, x: Int = 1):
    self.first = self.first + x
    self.second = self.second + x

  def dump(self):
    print(self.first, self.second)

# `add_four` basically says that it would accept an argument `x` of
# type T which implements `AddOne`. The body of this function would add
# four (4).
fn add_four[T : AddOne](mut x: T):
  x.add_one(4)

# Parameterization in Mojo means a parameter is a compile-time variable that
# becomes a runtime constant, and it's declared in square brackets on a function
# or struct.
# Parameters allow for compile-time metaprogramming, which means we/you can
# generate or modify code at compile
def repeat[count : Int](msg: String): 
  @parameter # evaluate the following for-loop at compile time.
  for i in range(count):
    print(msg)

def main(): 
  var pair = MyPair(1, 2)
  print("Before adding one (ie 1): ")
  pair.dump()
  pair.add_one()
  print("After adding one (ie 1): ")
  pair.dump()
  print("After adding four (ie 4): ")
  add_four(pair)
  pair.dump()

  repeat[3]("Hello!")
