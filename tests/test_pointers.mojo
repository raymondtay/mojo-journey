from std.testing import assert_equal, assert_true
from std.memory import *


struct SharedDict(Movable, ImplicitlyCopyable):
    var attributes: ArcPointer[Dict[String, String]]

    def __init__(out self):
        attributesDict: Dict[String, String] = {}
        self.attributes = ArcPointer(attributesDict.copy())

    def __copyinit__(out self, copy: Self):
        self.attributes = copy.attributes

    def __setitem__(mut self, key: String, value: String):
        self.attributes[][key] = value

    def __getitem__(self, key: String) -> String:
        return self.attributes[].get(key, default="")


# --- Tests ---


def test_shared_dict_set_get() raises:
    var d = SharedDict()
    d["name"] = "Alice"
    assert_equal(d["name"], "Alice")


def test_shared_dict_multiple_keys() raises:
    var d = SharedDict()
    d["a"] = "1"
    d["b"] = "2"
    d["c"] = "3"
    assert_equal(d["a"], "1")
    assert_equal(d["b"], "2")
    assert_equal(d["c"], "3")


def test_shared_dict_missing_key() raises:
    var d = SharedDict()
    assert_equal(d["nonexistent"], "")


def test_shared_dict_overwrite() raises:
    var d = SharedDict()
    d["key"] = "old"
    d["key"] = "new"
    assert_equal(d["key"], "new")


def test_shared_dict_shared_state() raises:
    """Two copies of SharedDict should share state via ArcPointer."""
    var d1 = SharedDict()
    var d2 = d1  # copies the ArcPointer (shared)
    d1["shared"] = "value"
    assert_equal(d2["shared"], "value")


def test_alloc_float_values() raises:
    """Test UnsafePointer allocation and initialization."""
    var float_ptr = alloc[Float64](6)
    for offset in range(6):
         float_ptr .unsafe_offset(offset).init_pointee_copy(0.0)

    float_ptr[2] = 3.0

    assert_equal(float_ptr[0], 0.0)
    assert_equal(float_ptr[1], 0.0)
    assert_equal(float_ptr[2], 3.0)
    assert_equal(float_ptr[3], 0.0)
    assert_equal(float_ptr[4], 0.0)
    assert_equal(float_ptr[5], 0.0)

    for offset in range(6):
         float_ptr .unsafe_offset(offset).destroy_pointee()
    float_ptr.unsafe_free()
