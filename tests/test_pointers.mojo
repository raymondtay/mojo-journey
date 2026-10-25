from testing import assert_equal, assert_true
from memory import *


struct SharedDict(Movable, ImplicitlyCopyable):
    var attributes: ArcPointer[Dict[String, String]]

    fn __init__(out self):
        attributesDict: Dict[String, String] = {}
        self.attributes = ArcPointer(attributesDict.copy())

    fn __copyinit__(out self, other: Self):
        self.attributes = other.attributes

    def __setitem__(mut self, key: String, value: String):
        self.attributes[][key] = value

    def __getitem__(self, key: String) -> String:
        return self.attributes[].get(key, default="")


# --- Tests ---


def test_shared_dict_set_get():
    var d = SharedDict()
    d["name"] = "Alice"
    assert_equal(d["name"], "Alice")


def test_shared_dict_multiple_keys():
    var d = SharedDict()
    d["a"] = "1"
    d["b"] = "2"
    d["c"] = "3"
    assert_equal(d["a"], "1")
    assert_equal(d["b"], "2")
    assert_equal(d["c"], "3")


def test_shared_dict_missing_key():
    var d = SharedDict()
    assert_equal(d["nonexistent"], "")


def test_shared_dict_overwrite():
    var d = SharedDict()
    d["key"] = "old"
    d["key"] = "new"
    assert_equal(d["key"], "new")


def test_shared_dict_shared_state():
    """Two copies of SharedDict should share state via ArcPointer."""
    var d1 = SharedDict()
    var d2 = d1  # copies the ArcPointer (shared)
    d1["shared"] = "value"
    assert_equal(d2["shared"], "value")


def test_alloc_float_values():
    """Test UnsafePointer allocation and initialization."""
    var float_ptr = alloc[Float64](6)
    for offset in range(6):
        (float_ptr + offset).init_pointee_copy(0.0)

    float_ptr[2] = 3.0

    assert_equal(float_ptr[0], 0.0)
    assert_equal(float_ptr[1], 0.0)
    assert_equal(float_ptr[2], 3.0)
    assert_equal(float_ptr[3], 0.0)
    assert_equal(float_ptr[4], 0.0)
    assert_equal(float_ptr[5], 0.0)

    for offset in range(6):
        (float_ptr + offset).destroy_pointee()
    float_ptr.free()
