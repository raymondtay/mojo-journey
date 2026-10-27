from std.testing import assert_equal, assert_true, TestSuite


# --- MyPair and helpers from 01_basics/01_proglang.mojo ---

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


def add_four[T: AddOne](mut x: T):
    x.add_one(4)


def count_many_things[*ArgTypes: Intable](*args: *ArgTypes) -> Int:
    var total = 0

    comptime for i in range(args.__len__()):
        total += Int(args[i])
    return total


# --- incr from 01_basics/01_error_handling.mojo ---

def incr(n: Int) raises -> Int:
    if n == Int.MAX:
        raise "inc: integer overflow"
    else:
        return n + 1


def incr2(n: Int) raises -> Int:
    if n == Int.MAX:
        raise "inc: integer overflow"
    else:
        return n + 1


# --- flaky_identity from 01_basics/01_ctx_mgr.mojo ---

def flaky_identity(n: Int) raises -> Int:
    if (n % 4) == 0:
        raise "really bad"
    elif (n % 2) == 0:
        raise "just a warning"
    else:
        return n


# --- create_immovable_object from 01_basics/01_namedresults.mojo ---

struct ImmovableObject(Writable):
    var name: String

    @implicit
    def __init__(out self, var name: String):
        self.name = name^

    def write_to(self, mut writer: Some[Writer]):
        writer.write("Immovable Object is: ", self.name)


def create_immovable_object(var name: String, out obj: ImmovableObject):
    obj = ImmovableObject(name^)
    obj.name += "!!!"


# --- Tests ---


def test_mypair_add_one_default() raises:
    var pair = MyPair(10, 20)
    pair.add_one()
    assert_equal(pair.first, 11)
    assert_equal(pair.second, 21)


def test_mypair_add_one_custom() raises:
    var pair = MyPair(5, 10)
    pair.add_one(3)
    assert_equal(pair.first, 8)
    assert_equal(pair.second, 13)


def test_mypair_int_conversion() raises:
    var pair = MyPair(42, 99)
    assert_equal(Int(pair), 42)


def test_add_four() raises:
    var pair = MyPair(1, 2)
    add_four(pair)
    assert_equal(pair.first, 5)
    assert_equal(pair.second, 6)


def test_count_many_things_ints() raises:
    var result = count_many_things(1, 2, 3, 4)
    assert_equal(result, 10)


def test_count_many_things_with_pair() raises:
    # MyPair is Intable, __int__ returns first
    var result = count_many_things(1, 2, MyPair(10, 20))
    assert_equal(result, 13)


def test_count_many_things_single() raises:
    var result = count_many_things(42)
    assert_equal(result, 42)


def test_incr_normal() raises:
    assert_equal(incr(0), 1)
    assert_equal(incr(5), 6)
    assert_equal(incr(99), 100)


def test_incr_overflow() raises:
    var caught = False
    try:
        _ = incr(Int.MAX)
    except:
        caught = True
    assert_true(caught, "Expected overflow error")


def test_incr2_normal() raises:
    assert_equal(incr2(0), 1)
    assert_equal(incr2(10), 11)


def test_incr2_overflow() raises:
    var caught = False
    try:
        _ = incr2(Int.MAX)
    except:
        caught = True
    assert_true(caught, "Expected overflow error")


def test_flaky_identity_odd() raises:
    # Odd numbers should return the value
    assert_equal(flaky_identity(1), 1)
    assert_equal(flaky_identity(3), 3)
    assert_equal(flaky_identity(7), 7)


def test_flaky_identity_divisible_by_4() raises:
    var caught = False
    var msg = String("")
    try:
        _ = flaky_identity(4)
    except e:
        caught = True
        msg = String(e)
    assert_true(caught)
    assert_true("really bad" in msg)


def test_flaky_identity_even_not_div4() raises:
    var caught = False
    var msg = String("")
    try:
        _ = flaky_identity(2)
    except e:
        caught = True
        msg = String(e)
    assert_true(caught)
    assert_true("just a warning" in msg)


def test_create_immovable_object() raises:
    var obj = create_immovable_object("Blob")
    assert_equal(obj.name, "Blob!!!")


def test_create_immovable_object_empty() raises:
    var obj = create_immovable_object("")
    assert_equal(obj.name, "!!!")


def test_immovable_object_write() raises:
    var obj = ImmovableObject("Test")
    var s = String(obj)
    assert_equal(s, "Immovable Object is: Test")


# Mojo 1.2: test files are plain programs; discover and run every `test_*`.
def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
