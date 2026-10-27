from std.testing import assert_equal, assert_true, TestSuite
from std.memory import ArcPointer, Layout, alloc


struct SharedDict(Movable, ImplicitlyCopyable):
    var attributes: ArcPointer[Dict[String, String]]

    def __init__(out self):
        var attributesDict: Dict[String, String] = {}
        self.attributes = ArcPointer(attributesDict.copy())

    def __init__(out self, *, copy: Self):
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
    """Test Layout-based allocation and initialization (Mojo 1.2)."""
    # `assert_equal` can raise, and the compiler rejects an `Allocation` that
    # could be abandoned on that error path. `into_managed()` (fine for trivially
    # destructible types like Float64) frees the storage automatically instead.
    var allocation = alloc(Layout[Float64](count=6)).into_managed()
    var float_ptr = allocation.unsafe_ptr()
    for offset in range(6):
        float_ptr.unsafe_offset(offset).unsafe_write(0.0)

    float_ptr[unsafe_offset=2] = 3.0

    assert_equal(float_ptr[unsafe_offset=0], 0.0)
    assert_equal(float_ptr[unsafe_offset=1], 0.0)
    assert_equal(float_ptr[unsafe_offset=2], 3.0)
    assert_equal(float_ptr[unsafe_offset=3], 0.0)
    assert_equal(float_ptr[unsafe_offset=4], 0.0)
    assert_equal(float_ptr[unsafe_offset=5], 0.0)




# Mojo 1.2: test files are plain programs; discover and run every `test_*`.
def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
