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

from std.memory import MutPointer
from std.sys import align_of
from std.compile import compile_info

# Mojo 1.2: `UnsafePointer` is deprecated in favour of `Pointer`
# (`MutPointer` = mutable `Pointer`), whose unsafe operations are spelled
# `unsafe_offset` / `unsafe_load` / `unsafe_store`. `SIMD` is in the prelude.
def saxpy16(
    y: MutPointer[Scalar[DType.float32], MutAnyOrigin],
    x: MutPointer[Scalar[DType.float32], MutAnyOrigin],
    n: Int,
    a: Float32,
):
    comptime W = 16
    var va = SIMD[DType.float32, W](a)

    # Alignment for vector load/store (safe choice for 16x f32)
    comptime ALIGN = align_of[SIMD[DType.float32, W]]()

    var i: Int = 0
    while i + W <= n:
      var vx = x.unsafe_offset(i).unsafe_load[width=W, alignment=ALIGN]()
      var vy = y.unsafe_offset(i).unsafe_load[width=W, alignment=ALIGN]()
      y.unsafe_store[width=W, alignment=ALIGN](i, va * vx + vy)
      i += W

    # Scalar tail
    while i < n:
      var xi = x.unsafe_offset(i).unsafe_load[width=1]()
      var yi = y.unsafe_offset(i).unsafe_load[width=1]()
      y.unsafe_store[width=1](i, a * xi + yi)
      i += 1

def main():
    var info = compile_info[saxpy16]()
    print(info)

# In cell-4, let's run it:
# !pixi run --manifest-path mojo_project/ mojo mojo_project/loop_lowering.mojo

