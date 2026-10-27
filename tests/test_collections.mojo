from std.testing import assert_equal, assert_true
from std.memory import alloc


struct GenericArray[ElementType: Copyable & Movable & ImplicitlyDestructible]:
    var data: Pointer[Self.ElementType, MutUntrackedOrigin]
    var size: Int

    def __init__(out self, var *elements: Self.ElementType):
        self.size = len(elements)
        self.data = alloc[Self.ElementType](self.size)
        for i in range(self.size):
             self.data .unsafe_offset(i).init_pointee_move(elements[i].copy())

    def __deinit__(deinit self):
        for i in range(self.size):
             self.data .unsafe_offset(i).destroy_pointee()
        self.data.unsafe_free()

    def __getitem__(self, i: Int) raises -> ref[self] Self.ElementType:
        if i < self.size:
            return self.data[i]
        else:
            raise Error(
                "array out-of-bounds, trying to reference index: {}".format(i)
            )

    @staticmethod
    def splat(count: Int, value: Self.ElementType) -> Self:
        return GenericArray[Self.ElementType](value.copy())


struct MyStack[type: Copyable & Movable & Deinitable & ImplicitlyDestructible]:
    var list: List[Self.type]

    def __init__(out self):
        self.list = List[Self.type]()

    def push(mut self, var item: Self.type):
        self.list.append(item^)

    def pop(mut self) -> Self.type:
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
