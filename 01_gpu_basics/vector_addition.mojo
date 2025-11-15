
from gpu.host import DeviceContext
from gpu import block_idx, thread_idx
from sys import has_accelerator, has_apple_gpu_accelerator

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
def main():
  @parameter
  if not has_accelerator():
    print("No compatible GPU found!")
  elif has_apple_gpu_accelerator():
    print(
        "Printing from a kernel is not currently support on Apple Silicon GPUs"
        )
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

