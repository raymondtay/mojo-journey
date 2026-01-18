The current implementations of `compile_function()` and `enqueue_function()`
don't typecheck the arguments to the compiled kernel function, which can lead to
obscure runtime errors if the argument ordering, types, or count does not match
the kernel function's definition. Additionally, these methods currently have
known issues with Apple silicon GPUs.

For compile-time typechecking, we recommend that you use the
`compile_function()` and `enqueue_function()` methods, which also work correctly
on Apple silicon GPUs.

Note that `compile_function()` requires the kernel function to be provided
_twice_ as parameters to enable compile-time typechecking of kernel arguments.

The advantage of compiling the kernel as a separate step is that you can execute
the same compiled kernel on the same device multiple times. This avoids the
overhead of compiling the kernel each time it's executed.
