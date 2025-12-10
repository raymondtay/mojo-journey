
# Before we jump into the pointer types, here are a few terms you'll run across.
# Some of them may already be familiar to you.
#
# Safe pointers: are designed to prevent memory errors. Unless you use one of the
#                APIs that are specially designated as unsafe, you can use these
#                pointers without worrying about memory issues like double-free or
#                use-after-free.
# Nullable pointers: can point to an invalid memory location (typically 0, or a
#                   “null pointer”). Safe pointers aren't nullable.
# Smart pointers: own their pointees, which means that the value they point to
#                 may be deallocated when the pointer itself is destroyed.
#                 Non-owning pointers may point to values owned elsewhere,
#                 or may require some manual management of the value lifecycle.
# Memory allocation: some pointer types can allocate memory to store their pointees,
#                    while other pointers can only point to pre-existing values.
#                    Memory allocation can either be implicit (that is, performed
#                    automatically when initializing a pointer with a value) or explicit.
# Uninitialized memory: refers to memory locations that haven't been initialized with a value,
#                       which may therefore contain random data. Newly-allocated memory is
#                       uninitialized. The safe pointer types don't allow users to access memory
#                       that's uninitialized. Unsafe pointers can allocate a block of
#                       uninitialized memory locations and then initialize them one at a time.
#                       Being able to access uninitialized memory is unsafe by definition.
# Copyable types: can be copied implicitly (for example, by assigning a value to a variable).
#                 Also called implicitly copyable types.
#                 ```mojo
#                 copied_ptr = ptr
#                 ```
#                 Explicitly copyable types require the user to request a copy,
#                 using a constructor with a keyword argument:
#                 ```mojo
#                 copied_owned_ptr = OwnedPointer(other=owned_ptr)
#                 ```
# Pointer types
# The mojo standard library includes several pointer types with different
# characteristics:
# * Pointer is a safe pointer that points to a single value that it does not
#           own.
# * OwnedPointer is a smart pointer that points to a single value, and maintains
#                exclusive ownership potentially shared with other instances of ArcPointer.
# * ArcPointer is a reference-counted smart pointer that points to an owned
#              value with ownership potentially shared with other instances of ArcPointer.
# * UnsafePointer points to one or more consecutive memory locations, and refer to
#                unitialized memory.
#
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

fn alloc_float_values():
  var float_ptr = alloc[Float64](6)
  for offset in range(6): # generates values 0 .. 5
    (float_ptr+offset).init_pointee_copy(0.0)

  float_ptr[2] = 3.0
  for offset in range(6):
    print(float_ptr[offset], end=", ")

def main():
  var ptr: OwnedPointer[Int] = OwnedPointer(100)
  ptr[] += 10 # update an initialized value
  print(ptr[]) # access an initialized value

  # Demonstrating SharedDict
  thing1 = SharedDict()
  thing2 = thing1
  thing1["Flip"] = "Flop"
  print(thing2["Flip"])

  # Demonstrating alloc_float_values
  alloc_float_values()
