
from gpu.host import DeviceContext
from gpu import block_dim, block_idx, thread_idx
from sys import has_accelerator, has_apple_gpu_accelerator
from layout import Layout, LayoutTensor
from math import ceildiv

alias block_size = 256
alias num_blocks = ceildiv(vector_size, block_size)

fn vector_addition(
    lhs_tensor: LayoutTensor[float_dtype, layout, MutAnyOrigin],
    rhs_tensor: LayoutTensor[float_dtype, layout, MutAnyOrigin],
    out_tensor: LayoutTensor[float_dtype, layout, MutAnyOrigin],
    ):
  """Calculate the element-wise sum of 2 vectors on the GPU."""

  # Calculate the index of the vector element
  # the block_dim tells you the values in (x, y, z) and hence you can think of
  # them as the "striding factor" or stride as its commonly known as.
  # hence block_idx.x = 0 then 0th-block contains 0-255, 
  # and when block_idx.x = 1 then 0th-block contains 256-511,  etc
  var tid = block_idx.x * block_dim.x + thread_idx.x

  # Compute for in-bounded elements
  if tid < vector_size:
    out_tensor[tid] = lhs_tensor[tid] + rhs_tensor[tid]


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

# Mojo requires a compatible GPU development environment to compile kernel
# functions, otherwise it raises a compile time error. In the code, i'm using
# the @parameter decorator to evluate the has_accelerator() function at compile
# time and compile only the corresponding branch of the if-statement. As a
# result, it you don't have a compatibleGPU development environment, you'll
# likely see the following message when you run program:
# ```pre
# No compatible GPU found!
# ```
# In that case, you will need to find a system that has a supported GPU to
# continue with this tutorial.
#
# In my scenaior, the GPU is "Apple M1 Max"


# Vector data type and size
alias float_dtype = DType.float32
alias vector_size = 100000
alias layout = Layout.row_major(vector_size)

def create_host_memory_device_memory_n_execute(ctx: DeviceContext):
  '''A sample run on Apple Silicon GPUs.

  > pixi run mojo vector_addition.mojo
  Printing from a kernel is not currently support on Apple Silicon GPUs
  LHS host buffer:  HostBuffer([0.0, 1.0, 2.0, ..., 997.0, 998.0, 999.0])
  RHS host buffer:  HostBuffer([0.0, 0.5, 1.0, ..., 498.5, 499.0, 499.5])

  Note: There is no need to release/clean neither the device/host buffers
  as it would cleaned up by Mojo.
  '''
  
  lhs_host_buffer = ctx.enqueue_create_host_buffer[float_dtype](vector_size)
  rhs_host_buffer = ctx.enqueue_create_host_buffer[float_dtype](vector_size)
  ctx.synchronize()
  weight_factor = 0.5 # For demonstration purposes only.

  # initialize the input vectors
  for i in range(vector_size):
    lhs_host_buffer[i] = Float32(i)
    rhs_host_buffer[i] = Float32(i*weight_factor)
  print("LHS host buffer: ", lhs_host_buffer)
  print("RHS host buffer: ", rhs_host_buffer)

  lhs_device_buffer = ctx.enqueue_create_buffer[float_dtype](vector_size)
  rhs_device_buffer = ctx.enqueue_create_buffer[float_dtype](vector_size)

  ctx.enqueue_copy(dst_buf=lhs_device_buffer, src_buf=lhs_host_buffer)
  ctx.enqueue_copy(dst_buf=rhs_device_buffer, src_buf=rhs_host_buffer)
  result_device_buffer = ctx.enqueue_create_buffer[float_dtype](vector_size)
  print("LHS device buffer: ", lhs_device_buffer)
  print("RHS device buffer: ", rhs_device_buffer)

  # Wrap the DeviceBuffers in LayoutTensors
  lhs_tensor = LayoutTensor[float_dtype, layout](lhs_device_buffer)
  rhs_tensor = LayoutTensor[float_dtype, layout](rhs_device_buffer)
  result_tensor = LayoutTensor[float_dtype, layout](result_device_buffer)

  # Compile and enqueue the kernel
  ctx.enqueue_function_checked[vector_addition, vector_addition](
      lhs_tensor,
      rhs_tensor,
      result_tensor,
      grid_dim=num_blocks,
      block_dim=block_size,
      )
  # Create a HostBuffer for the result vector
  result_host_buffer = ctx.enqueue_create_host_buffer[float_dtype](vector_size)
  # Copy the result vector from the DeviceBuffer to the HostBuffer
  ctx.enqueue_copy(dst_buf=result_host_buffer, src_buf=result_device_buffer)
  # finally, synchronize the DeviceContext to run all enqueued operations
  ctx.synchronize()
  print("Result vector: ", result_host_buffer)

def main():
  @parameter
  if not has_accelerator():
    print("No compatible GPU found!")
  elif has_apple_gpu_accelerator():
    print(
        "Printing from a kernel is not currently support on Apple Silicon GPUs"
        )
    ctx = DeviceContext()
    create_host_memory_device_memory_n_execute(ctx)
  else:
    ctx = DeviceContext()
    # Invoking the compiled kernel function with grid_dim=2 and block_dim=64
    # which means that we are using a grid of 2 thread blocks with 64 threads
    # each per block, totalling 128 threads in the grid
    ctx.enqueue_function_checked[print_threads, print_threads](
        grid_dim=(2, 2, 1), block_dim=(16, 4, 2)
        )
    ctx.synchronize()
    print("Program finished")
    print("Found GPU: ", ctx.name())

# Typical CPU-GPU interactions are asynchronous, allowing the GPU to process
# tasks while the CPU is busy with other work. Each `DeviceContext` has an
# associated stream of queued operations to execute on the GPU. Operations with
# a stream execute in the order they are issued.
#

