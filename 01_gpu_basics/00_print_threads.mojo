from sys import exit, has_accelerator, has_apple_gpu_accelerator

from gpu.host import DeviceContext
from gpu import block_dim, block_idx, global_idx, grid_dim, thread_idx

fn print_threads():
  """Print thread block and thread indices."""
  print(
      "block_idx: [",
      block_idx.x,
      block_idx.y,
      block_idx.z,
      "]\tthread_idx: [",
      thread_idx.x,
      thread_idx.y,
      thread_idx.z,
      "]\tglobal_idx: [",
      global_idx.x,
      global_idx.y,
      global_idx.z,
      "]\tcalculated global_idx: [",
      block_dim.x * block_idx.x + thread_idx.x,
      block_dim.y * block_idx.y + thread_idx.y,
      block_dim.z * block_idx.z + thread_idx.z,
      "]",
      )

def main():
  @parameter
  if not has_accelerator():
    print("No compatible GPU found")
  elif has_apple_gpu_accelerator():
    print(
        "Printing from a kernel is not currently supported on Apple silicon"
        " GPUs"
        )
  else:
    ctx = DeviceContext()

    ctx.enqueue_function_experimental[print_threads](
        grid_dim=(2, 2, 1),
        block_dim=(4, 4, 2)
    )

  ctx.synchronize()
  print("Done")

