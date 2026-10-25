from testing import assert_equal, assert_true
from memory import alloc


struct GenericArray[ElementType: Copyable & Movable]:
    var data: UnsafePointer[Self.ElementType, MutOrigin.external]
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
            raise Error(
                "array out-of-bounds, trying to reference index: {}".format(i)
            )

    @staticmethod
    fn splat(count: Int, value: Self.ElementType) -> Self:
        return GenericArray[Self.ElementType](value.copy())


struct MyStack[type: Copyable & Movable]:
    alias EltType = Self.type
    alias list_type = List[Self.EltType]

    var list: Self.list_type

    fn __init__(out self):
        self.list = Self.list_type()

    fn push(mut self, var item: Self.EltType):
        self.list.append(item^)

    fn pop(mut self) -> Self.EltType:
        return self.list.pop()


# --- Tests ---


def test_generic_array_getitem():
    var arr = GenericArray[Int](10, 20, 30, 40, 50)
    assert_equal(arr[0], 10)
    assert_equal(arr[1], 20)
    assert_equal(arr[2], 30)
    assert_equal(arr[3], 40)
    assert_equal(arr[4], 50)


def test_generic_array_size():
    var arr = GenericArray[Int](1, 2, 3)
    assert_equal(arr.size, 3)


def test_generic_array_out_of_bounds():
    var arr = GenericArray[Int](1, 2, 3)
    var caught = False
    try:
        _ = arr[5]
    except:
        caught = True
    assert_true(caught, "Expected out-of-bounds error")


def test_generic_array_float():
    var arr = GenericArray[Float64](1.5, 2.5, 3.5)
    assert_equal(arr[0], 1.5)
    assert_equal(arr[1], 2.5)
    assert_equal(arr[2], 3.5)


def test_generic_array_string():
    var arr = GenericArray[String]("hello", "world")
    assert_equal(arr[0], "hello")
    assert_equal(arr[1], "world")


def test_stack_push_pop_lifo():
    var s = MyStack[Int]()
    s.push(1)
    s.push(2)
    s.push(3)
    assert_equal(s.pop(), 3)
    assert_equal(s.pop(), 2)
    assert_equal(s.pop(), 1)


def test_stack_push_pop_strings():
    var s = MyStack[String]()
    s.push("a")
    s.push("b")
    s.push("c")
    assert_equal(s.pop(), "c")
    assert_equal(s.pop(), "b")
    assert_equal(s.pop(), "a")


def test_stack_single_element():
    var s = MyStack[Int]()
    s.push(42)
    assert_equal(s.pop(), 42)


def test_stack_interleaved_push_pop():
    var s = MyStack[Int]()
    s.push(1)
    s.push(2)
    assert_equal(s.pop(), 2)
    s.push(3)
    assert_equal(s.pop(), 3)
    assert_equal(s.pop(), 1)
