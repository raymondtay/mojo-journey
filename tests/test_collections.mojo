from std.testing import assert_equal, assert_true, TestSuite
from std.memory import alloc, dealloc, Allocation, Layout, unsafe_destroy_n


struct GenericArray[ElementType: Copyable & Deinitable]:
    var data: Allocation[Self.ElementType]
    var size: Int

    def __init__(out self, var *elements: Self.ElementType):
        self.size = len(elements)
        self.data = alloc(Layout[Self.ElementType](count=self.size))
        var ptr = self.data.unsafe_ptr()
        for i in range(self.size):
            ptr.unsafe_offset(i).unsafe_write(copy=elements[i])

    def __deinit__(deinit self):
        unsafe_destroy_n(self.data.unsafe_ptr(), self.size)
        dealloc(self.data^)

    def __getitem__(
        self, i: Int
    ) raises -> ref[self.data._alloc] Self.ElementType:
        if i < self.size:
            return self.data.unsafe_ptr()[unsafe_offset=i]
        else:
            raise Error(
                "array out-of-bounds, trying to reference index: {}".format(i)
            )

    @staticmethod
    def splat(count: Int, value: Self.ElementType) -> Self:
        return GenericArray[Self.ElementType](value.copy())


struct MyStack[type: Copyable & Deinitable]:
    comptime EltType = Self.type
    comptime list_type = List[Self.EltType]

    var list: Self.list_type

    def __init__(out self):
        self.list = Self.list_type()

    def push(mut self, var item: Self.EltType):
        self.list.append(item^)

    def pop(mut self) -> Self.EltType:
        return self.list.pop()


# --- Tests ---


def test_generic_array_getitem() raises:
    var arr = GenericArray[Int](10, 20, 30, 40, 50)
    assert_equal(arr[0], 10)
    assert_equal(arr[1], 20)
    assert_equal(arr[2], 30)
    assert_equal(arr[3], 40)
    assert_equal(arr[4], 50)


def test_generic_array_size() raises:
    var arr = GenericArray[Int](1, 2, 3)
    assert_equal(arr.size, 3)


def test_generic_array_out_of_bounds() raises:
    var arr = GenericArray[Int](1, 2, 3)
    var caught = False
    try:
        _ = arr[5]
    except:
        caught = True
    assert_true(caught, "Expected out-of-bounds error")


def test_generic_array_float() raises:
    var arr = GenericArray[Float64](1.5, 2.5, 3.5)
    assert_equal(arr[0], 1.5)
    assert_equal(arr[1], 2.5)
    assert_equal(arr[2], 3.5)


def test_generic_array_string() raises:
    var arr = GenericArray[String]("hello", "world")
    assert_equal(arr[0], "hello")
    assert_equal(arr[1], "world")


def test_stack_push_pop_lifo() raises:
    var s = MyStack[Int]()
    s.push(1)
    s.push(2)
    s.push(3)
    assert_equal(s.pop(), 3)
    assert_equal(s.pop(), 2)
    assert_equal(s.pop(), 1)


def test_stack_push_pop_strings() raises:
    var s = MyStack[String]()
    s.push("a")
    s.push("b")
    s.push("c")
    assert_equal(s.pop(), "c")
    assert_equal(s.pop(), "b")
    assert_equal(s.pop(), "a")


def test_stack_single_element() raises:
    var s = MyStack[Int]()
    s.push(42)
    assert_equal(s.pop(), 42)


def test_stack_interleaved_push_pop() raises:
    var s = MyStack[Int]()
    s.push(1)
    s.push(2)
    assert_equal(s.pop(), 2)
    s.push(3)
    assert_equal(s.pop(), 3)
    assert_equal(s.pop(), 1)


# Mojo 1.2: test files are plain programs; discover and run every `test_*`.
def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
