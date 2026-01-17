from math import iota
from sys import exit, has_accelerator

from gpu.host import DeviceContext
from gpu import block_dim, block_idx, thread_idx

comptime num_elements = 20

fn scalar_add(
    vector: UnsafePointer[Float32, MutAnyOrigin],
    size: Int,
    scalar: Float32
    ):
  """
  Kernel function to add a scalar to all elements of a vector.

  This kernel function adds a scalar value to each element of a vector stored
  in GPU memory. The input vector is modified in place.

  Args: 
  vector: Pointer to the input vector
  size: Number of elements in the vector.
  scalar: Scalar to add to the vector, element-wise.
  """

  # Calculate the global thread index within the entire grid. Each thread
  # processes one element of the vector.
  # block_idx.x : the index of the current thread block.
  # block_dim.x : number of threads per block.
  # thread_idx.x : the index of the current thread within its block.
  idx = block_idx.x * block_dim.x + thread_idx.x

  # Bounds checking: ensure we don't access memory beyond the vector size.
  # In other words, we perform the kernel operation within the bounds of the
  # vector w/o triggering a segmentation fault.
  if idx < UInt(size):
    vector[idx] += scalar


def main():
  @parameter
  if not has_accelerator():
    print("No GPUs detected")
    exit(0)
  else:
    # initialize GPU context for device 0 (default GPU device).
    ctx = DeviceContext()

    # Create a buffer in host *CPU* memory to store the input data
    host_buffer = ctx.enqueue_create_host_buffer[DType.float32](num_elements)

    # Wait for buffer creation to complete.
    ctx.synchronize()

    # Fill the host buffer with sequential numbers.
    iota(host_buffer.unsafe_ptr(), num_elements)
    print("Original host buffer:", host_buffer)

    # Create a buffer in device (GPU) memory to store the results of our
    # transformed data.
    device_buffer = ctx.enqueue_create_buffer[DType.float32](num_elements)

    # Copy the data from the CPU memory to the GPU memory.
    ctx.enqueue_copy(src_buf=host_buffer, dst_buf=device_buffer)

    # Compile the function
    scalar_add_kernel = ctx.compile_function[scalar_add, scalar_add]()

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
        num_elements,
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

