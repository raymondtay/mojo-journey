# In cell-0, i'm using pixi so here's how to install it:
#
# !curl -fsSL https://pixi.sh/install.sh | sh
# Add the pixi bin directory to the PATH for the current session
# import os
# os.environ['PATH'] = f"{os.environ['HOME']}/.pixi/bin:{os.environ['PATH']}"
# !source /root/.bashrc
#
# In cell-1, prepare the mojo environment using following:
#
# !pixi init mojo_project -c https://conda.modular.com/max-nightly/ -c conda-forge  && cd mojo_project
# 
# In cell-2, add mojo into our project directory
# !pixi add --manifest-path mojo_project/ mojo
#
# In cell-3, write the file into our project directory
# %%writefile mojo_project/loop_lowering.mojo

from memory import UnsafePointer
from sys import align_of
from builtin.simd import SIMD
from compile import compile_info

fn saxpy16(
    y: UnsafePointer[mut=True, Scalar[DType.float32]],
    x: UnsafePointer[mut=True, Scalar[DType.float32]],
    n: Int,
    a: Float32,
):
    comptime W = 16
    va = SIMD[DType.float32, W](a)

    # Alignment for vector load/store (safe choice for 16x f32)
    comptime ALIGN = align_of[SIMD[DType.float32, W]]()

    var i: Int = 0
    while i + W <= n:
      vx = (x + i).load[width=W, alignment=ALIGN]()
      vy = (y + i).load[width=W, alignment=ALIGN]()
      (y + i).store[width=W, alignment=ALIGN](va * vx + vy)
      i += W

    # Scalar tail
    while i < n:
      xi = (x + i).load[width=1]()
      yi = (y + i).load[width=1]()
      (y + i).store[width=1](a * xi + yi)
      i += 1

fn main():
    info = compile_info[saxpy16]()
    print(info)

# In cell-4, let's run it:
# !pixi run --manifest-path mojo_project/ mojo mojo_project/loop_lowering.mojo

