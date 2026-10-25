from testing import assert_equal, assert_true


# --- MyPair and helpers from 01_basics/01_proglang.mojo ---

trait AddOne:
    fn add_one(mut self, x: Int):
        ...


@fieldwise_init
struct MyPair(AddOne, Copyable, Intable):
    var first: Int
    var second: Int

    fn add_one(mut self, x: Int = 1):
        self.first = self.first + x
        self.second = self.second + x

    fn __int__(self) -> Int:
        return self.first


fn add_four[T: AddOne](mut x: T):
    x.add_one(4)


fn count_many_things[*ArgTypes: Intable](*args: *ArgTypes) -> Int:
    var total = 0

    @parameter
    for i in range(args.__len__()):
        total += Int(args[i])
    return total


# --- incr from 01_basics/01_error_handling.mojo ---

fn incr(n: Int) raises -> Int:
    if n == Int.MAX:
        raise "inc: integer overflow"
    else:
        return n + 1


def incr2(n: Int) -> Int:
    if n == Int.MAX:
        raise "inc: integer overflow"
    else:
        return n + 1


# --- flaky_identity from 01_basics/01_ctx_mgr.mojo ---

def flaky_identity(n: Int) -> Int:
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
    fn __init__(out self, var name: String):
        self.name = name^

    fn write_to(self, mut writer: Some[Writer]):
        writer.write("Immovable Object is: ", self.name)


def create_immovable_object(var name: String, out obj: ImmovableObject):
    obj = ImmovableObject(name^)
    obj.name += "!!!"


# --- Tests ---


def test_mypair_add_one_default():
    var pair = MyPair(10, 20)
    pair.add_one()
    assert_equal(pair.first, 11)
    assert_equal(pair.second, 21)


def test_mypair_add_one_custom():
    var pair = MyPair(5, 10)
    pair.add_one(3)
    assert_equal(pair.first, 8)
    assert_equal(pair.second, 13)


def test_mypair_int_conversion():
    var pair = MyPair(42, 99)
    assert_equal(Int(pair), 42)


def test_add_four():
    var pair = MyPair(1, 2)
    add_four(pair)
    assert_equal(pair.first, 5)
    assert_equal(pair.second, 6)


def test_count_many_things_ints():
    var result = count_many_things(1, 2, 3, 4)
    assert_equal(result, 10)


def test_count_many_things_with_pair():
    # MyPair is Intable, __int__ returns first
    var result = count_many_things(1, 2, MyPair(10, 20))
    assert_equal(result, 13)


def test_count_many_things_single():
    var result = count_many_things(42)
    assert_equal(result, 42)


def test_incr_normal():
    assert_equal(incr(0), 1)
    assert_equal(incr(5), 6)
    assert_equal(incr(99), 100)


def test_incr_overflow():
    var caught = False
    try:
        _ = incr(Int.MAX)
    except:
        caught = True
    assert_true(caught, "Expected overflow error")


def test_incr2_normal():
    assert_equal(incr2(0), 1)
    assert_equal(incr2(10), 11)


def test_incr2_overflow():
    var caught = False
    try:
        _ = incr2(Int.MAX)
    except:
        caught = True
    assert_true(caught, "Expected overflow error")


def test_flaky_identity_odd():
    # Odd numbers should return the value
    assert_equal(flaky_identity(1), 1)
    assert_equal(flaky_identity(3), 3)
    assert_equal(flaky_identity(7), 7)


def test_flaky_identity_divisible_by_4():
    var caught = False
    var msg = String("")
    try:
        _ = flaky_identity(4)
    except e:
        caught = True
        msg = String(e)
    assert_true(caught)
    assert_true("really bad" in msg)


def test_flaky_identity_even_not_div4():
    var caught = False
    var msg = String("")
    try:
        _ = flaky_identity(2)
    except e:
        caught = True
        msg = String(e)
    assert_true(caught)
    assert_true("just a warning" in msg)


def test_create_immovable_object():
    var obj = create_immovable_object("Blob")
    assert_equal(obj.name, "Blob!!!")


def test_create_immovable_object_empty():
    var obj = create_immovable_object("")
    assert_equal(obj.name, "!!!")


def test_immovable_object_write():
    var obj = ImmovableObject("Test")
    var s = String(obj)
    assert_equal(s, "Immovable Object is: Test")
