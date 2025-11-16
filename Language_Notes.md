Traits
=

You can determine whether a type is explicitly or implicitly copyable by
checking its API documentation to see what _traits_ it conforms to. A Mojo
_trait_ is a set of requirements that a type must implement, usually in the form
of one or more method signatures.

* The `List` type and other Mojo collection types like _Dict_ and _Set_ conform
  to the _Copyable_ trait, which indicates that they are explicitly copyable.
* The `String`, `Int` and other numeric types conform the _ImplicitlyCopyable_
  trait, so you can also use types that conform to the _ImplicitlyCopyable_ trait
  in the same way you can use types that conform to the _Copyable_ trait.

If you define a simple `struct` where all fields are types that conform to the
_ImplicitlyCopyable_ trait—such as `String` and numeric types—you could
indicate that your struct conforms to the _ImplicitlyCopyable_ trait instead
of the _Copyable_ trait. However, our `Grid` struct uses a `List[List[Int]]` field,
which is not implicitly copyable.

Also see the Life of a value section of the Mojo Manual for more information
about the different lifecycle methods and how to implement them.

Kernel Functions
=

A typical kernel (executes in the GPU) function...

```mojo
fn print_threads():
  """Print thread ids."""
  print("Block_index: [",
        block_idx.x,
        block_idx.y,
        block_idx.z,
        "]\t Thread index: [",
        thread_idx.x,
        thread_idx.y,
        thread_idx.z,
        "]")
```

When using `fn` without the `raise` keyword because a kernel function is not
allowed to raise an error condition. In contrast, when you define a Mojo
function with `def`, the compiler always assumes that the function _can_ raise
an error condition.

Kernel Functions inside Apple Silicon
===

`DeviceContext` also includes `enqueue_function()` and `compile_function()`
methods. However, these methods currently don't typecheck the arguments to the
compiled kernel function, which can lead to obscure run-time errors if the
argument ordering, types, or count doesn't match the kernel function's
definition. Additionally, these methods currently have known issues with Apple
silicon GPUs.

For compile-time typechecking, we recommend that you use the
`enqueue_function_checked()` and `compile_function_checked()` methods, which
also work correctly on Apple silicon GPUs.

Note that `enqueue_function_checked()` and `compile_function_checked()` currently
require the kernel function to be provided _twice_ as parameters. This
requirement willbe removed in a future API update, when typechecking will become
the default behavior for both `enqueue_function()` and `compile_function()`.

Warp - how they work
===

Warps are used to efficiently utilize GPU hardware by maximising throughput and
minimizing control overhead. Since GPUs are designed for high-performance
parallel processing, grouping threads into wraps allows for streamlined
instruction scheduling and execution, reducing the complexity of managing
individual threads. Multiple warps from multiple thread blocks can be active
within an SM at any given time, enabling the GPU to keep execution units busy.

For example, if the threads of a particular warp are blocked waiting for data
from memory, the warp scheduler can immediately switch execution to another
warp that's ready to run.

The maximum number of threads per thread block and threads per SM is
GPU-specific. For example, the NVIDIA A100 GPU has a maximujm of 1,024 threads
per thread block and 2,048 threads per SM.
