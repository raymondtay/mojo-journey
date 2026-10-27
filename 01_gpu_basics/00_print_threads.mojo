# Mojo 1.2: `has_apple_gpu_accelerator()` was removed from `std.sys`; ask the
# accelerator target instead via `default_accelerator().is_apple_gpu()`.
# GPU APIs moved from `gpu` to `max.gpu` (shipped with the `max` package).
from std.sys import exit, has_accelerator, default_accelerator

from max.gpu.host import DeviceContext
from max.gpu import block_dim, block_idx, global_idx, grid_dim, thread_idx

def print_threads():
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

def main() raises:
  comptime if not has_accelerator():
    print("No compatible GPU found")
  elif default_accelerator().is_apple_gpu():
    print(
        "Printing from a kernel is not currently supported on Apple silicon"
        " GPUs"
        )
  else:
    var ctx = DeviceContext()

    ctx.enqueue_function[print_threads](
        grid_dim=(2, 2, 1),
        block_dim=(4, 4, 2)
    )
    ctx.synchronize()

  print("Done")

