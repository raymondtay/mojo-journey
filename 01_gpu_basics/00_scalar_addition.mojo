from std.math import iota
from std.sys import exit, has_accelerator

from std.memory import MutPointer

from max.gpu.host import DeviceContext
from max.gpu import block_dim, block_idx, thread_idx

comptime num_elements = 20

def scalar_add(
    vector: MutPointer[Float32, MutAnyOrigin],
    size_dev: Int32,
    scalar: Float32
    ):
  """
  Kernel function to add a scalar to all elements of a vector.

  This kernel function adds a scalar value to each element of a vector stored
  in GPU memory. The input vector is modified in place.

  Args: 
  vector: Pointer to the input vector
  size_dev: Number of elements in the vector (Mojo 1.2: `Int` is not
    `DevicePassable`, so kernel arguments use fixed-width integers).
  scalar: Scalar to add to the vector, element-wise.
  """

  # Calculate the global thread index within the entire grid. Each thread
  # processes one element of the vector.
  # block_idx.x : the index of the current thread block.
  # block_dim.x : number of threads per block.
  # thread_idx.x : the index of the current thread within its block.
  var idx = block_idx.x * block_dim.x + thread_idx.x

  # Bounds checking: ensure we don't access memory beyond the vector size.
  # In other words, we perform the kernel operation within the bounds of the
  # vector w/o triggering a segmentation fault.
  # Mojo 1.2: the index builtins are `Int`, and pointer indexing is spelled
  # `ptr[unsafe_offset=i]` (positional `ptr[i]` is deprecated).
  var size = Int(size_dev)
  if idx < size:
    vector[unsafe_offset=idx] += scalar


def main() raises:
  comptime if not has_accelerator():
    print("No GPUs detected")
    exit(0)
  else:
    # initialize GPU context for device 0 (default GPU device).
    var ctx = DeviceContext()

    # Create a buffer in host *CPU* memory to store the input data
    var host_buffer = ctx.enqueue_create_host_buffer[DType.float32](num_elements)

    # Wait for buffer creation to complete.
    ctx.synchronize()

    # Fill the host buffer with sequential numbers.
    iota(host_buffer.unsafe_ptr(), num_elements)
    print("Original host buffer:", host_buffer)

    # Create a buffer in device (GPU) memory to store the results of our
    # transformed data.
    var device_buffer = ctx.enqueue_create_buffer[DType.float32](num_elements)

    # Copy the data from the CPU memory to the GPU memory.
    ctx.enqueue_copy(src_buf=host_buffer, dst_buf=device_buffer)

    # Compile the function
    # Mojo 1.2: the kernel is passed once (the old `[kernel, kernel]` form of the
    # type-checked API is gone).
    var scalar_add_kernel = ctx.compile_function[scalar_add]()

    # Launched the compiled kernel function with the following arguments:
    # - device_buffer: gpu memory containing our payload
    # - num_elements: number of elements in the vector
    # - Float32(3.142): the scalar value to be added into the vector,
    # element-wise
    # - grid_dim=1 use 1 thread block
    # - block_dim = num_elements: use exactly `num_elements` threads in the
    # block
    #
    ctx.enqueue_function(
        scalar_add_kernel,
        device_buffer,
        Int32(num_elements),
        Float32(3.142),
        grid_dim=1,
        block_dim=num_elements
    )

    # Copy the computed results back from device memory to host memory.
    ctx.enqueue_copy(src_buf=device_buffer, dst_buf=host_buffer)
    # Wait for all GPU operations to cease.
    ctx.synchronize()
    # Display the final results after GPU computation
    print("Modified host buffer: ", host_buffer)

