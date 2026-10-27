from std.python import Python


# This basically says that whatever implements `AddOne` would add the value of
# `1` to whatever the structure.
trait AddOne:
    def add_one(mut self, x: Int):
        ...


@fieldwise_init
struct MyPair(AddOne, Copyable, Intable):
    var first: Int
    var second: Int

    def add_one(mut self, x: Int = 1):
        self.first = self.first + x
        self.second = self.second + x

    def __int__(self) -> Int:
        return self.first

    def dump(self):
        print(self.first, self.second)


# `add_four` basically says that it would accept an argument `x` of
# type T which implements `AddOne`. The body of this function would add
# four (4).
def add_four[T: AddOne](mut x: T):
    x.add_one(4)


# Parameterization in Mojo means a parameter is a compile-time variable that
# becomes a runtime constant, and it's declared in square brackets on a function
# or struct.
# Parameters allow for compile-time metaprogramming, which means we/you can
# generate or modify code at compile
def repeat[count: Int](msg: String):
    comptime for i in range(count):  # evaluate the following for-loop at compile time.
        print(msg)


# Variadic function that does not raise exceptions or errors to its invoker.
# This function says that the argument types can be converted to Int (hence the word Int-able)
# what is interesting is that we can convert user-defined types to Int
def count_many_things[*ArgTypes: Intable](*args: *ArgTypes) -> Int:
    var total = 0

    comptime for i in range(args.__len__()):
        total += Int(args[i])
    return total


def main() raises:
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
    # demonstrating the integration to Python ecosystem
    var np = Python.import_module("numpy")
    var arr = np.arange(15).reshape(3, 5)

    print(count_many_things(1, 2.2, 4.4, 12, MyPair(1, 2)))
