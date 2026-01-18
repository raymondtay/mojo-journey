# This tiled algorithm leverages the GPU's memory hierachy for better
# performance. Shared memory is an on-chip cache that's much faster than global
# memory, but its limited in size - a typical block might have only 48kb
# available. We break the computation into stages: threads cooperatively load
# small tiles from global memory into this fast shared memory, perform
# computation on those tiles, then repeat for the next set of tiles.
#
# Each thread loads one element per tile, creating coalesced memory accesses
# that maximizes bandwidth. Once a tile sits in shared memory, all threads in
# the block can access it repeatedly without triggering expensive global memory
# reads.
# 
# The first barrier() call appears immediately after the cooperative tile
# loading phase. This synchronization point is critical: it ensures that all
# threads in the block finish writing their elements to shared memory before any
# thread begins reading from it to compute results. Without this barrier, you
# would have a classic read-before-write race condition. In other words, fast
# threads could race ahead and start reading from shared memory locaitons that
# slow threads have not populated yet, leading to incorrect results from
# uninitialized data. Even worse, the bug would be non-deterministics -
# soemtimes the code would work (if threads happened to execute in a favourable
# order), and somtimes it would fail, making debugging extremely difficult. The
# barrier eliminates this unpredictability by establishing a clear
# "happens-before" relationship: all writes complete before any reads begin.
#
# The second barrier() call appears at the end of the computation phase, right
# before the loop continues to load the next tiles. This barrier solves the
# opposite problem: it prevents write-during-read races. Without it, fast
# threads could finish their computations and start loading new tile data into
# shared memory while slow threads are still reading the old data for their
# calculations. This would corrupt the shared memory with partially overwritten
# values, again producing incorrect results.
#
# The pattern is symmetric, that is the first barrier protects readers from
# seeing incomplete writes, while the second barrier protects readers from
# concurrent overwrites. Together, this 2 barriers implement a safe
# producer-consumer cycle: load ⇒ barrier ⇒ compute ⇒ barrier ⇒ repeat. Removing
# either barrier would break this algorithm's correctness.
#
from math import ceildiv
from sys import exit, has_accelerator

from gpu.sync import barrier
from gpu.host import DeviceContext
from gpu import thread_idx, block_idx
from gpu.memory import AddressSpace

# Layout tensort support from open source layout package
from layout import Layout, LayoutTensor

# Data type selection: float32 provides a good balance of precision and
# performance
comptime float_dtype = DType.float32

# matrix dimensions: chosen to be small enough for the purpose of understanding.
comptime MATRIX_SIZE = 64 # 64 x 64 matrices
comptime MATRIX_M = MATRIX_SIZE
comptime MATRIX_N = MATRIX_SIZE
comptime MATRIX_K = MATRIX_SIZE

# tile dimentions
comptime TILE_SIZE = 16
comptime TILE_M = TILE_SIZE
comptime TILE_N = TILE_SIZE
comptime TILE_K = TILE_SIZE

# Derived constants
comptime NUM_TILES_PER_STRIDE = MATRIX_SIZE // TILE_SIZE # number of tiles per matrix side, i.e., 4
comptime THREADS_PER_TILE = TILE_SIZE * TILE_SIZE # threads per tile (256)
comptime TOTAL_TILES_TO_PROCESS = NUM_TILES_PER_STRIDE # tiles to process in K dimension

# LayoutTensor provides type-safe multi-dimensional data access with automatic
# memory layout. Layout definitions using example matrix dimensions
comptime matrix_a_layout = Layout.row_major(MATRIX_M, MATRIX_K) # A: M x K
comptime matrix_b_layout = Layout.row_major(MATRIX_K, MATRIX_N) # A: K x N
comptime matrix_c_layout = Layout.row_major(MATRIX_M, MATRIX_N) # A: M x N

comptime tile_a_layout = Layout.row_major(TILE_M, TILE_K)
comptime tile_b_layout = Layout.row_major(TILE_K, TILE_N)

fn tiled_matmul_kernel(
    matrix_a: LayoutTensor[float_dtype, matrix_a_layout, MutAnyOrigin],
    matrix_b: LayoutTensor[float_dtype, matrix_b_layout, MutAnyOrigin],
    matrix_c: LayoutTensor[float_dtype, matrix_c_layout, MutAnyOrigin],
    ):

  var thread_x = thread_idx.x
  var thread_y = thread_idx.y
  var block_x = block_idx.x
  var block_y = block_idx.y

  # global matrix coordinates
  var global_row = block_y * TILE_M + thread_y
  var global_col = block_x * TILE_N + thread_x

  # Allocate shared memory tiles for fast on-chip access
  var tile_a_shared = LayoutTensor[
      float_dtype,
      tile_a_layout,
      MutAnyOrigin,
      address_space = AddressSpace.SHARED,
  ].stack_allocation()

  var tile_b_shared = LayoutTensor[
      float_dtype,
      tile_b_layout,
      MutAnyOrigin,
      address_space = AddressSpace.SHARED,
  ].stack_allocation()

  # initialize accumulator and start tiling loop
  var accumulator : matrix_c.element_type = 0.0

  # Iterate through tiles along K dimension; use @parameter to unroll the loop
  # at compile time.
  @parameter
  for k_tile in range(0, MATRIX_K, TILE_K):
    var a_global_row = tile_row_start + thread_y
    var a_global_col = UInt(k_tile) + thread_x
    var b_global_row = UInt(k_tile) + thread_y
    var b_global_col = tile_col_start + thread_x

    # Bounds checking
    var load_a_valid = (a_global_row < MATRIX_M) and (
        a_global_col < MATRIX_K)
    var load_b_valid = (b_global_row < MATRIX_K) and (
        b_global_col < MATRIX_N)

    # Load tiles into shared memory with bounds checking
    if load_a_valid:
      tile_a_shared[thread_y, thread_x] = matrix_a[a_global_row, a_global_col]
    else:
      tile_a_shared[thread_y, thread_x] = 0.0

    if load_b_valid:
      tile_b_shared[thread_y, thread_x] = matrix_b[b_global_row, b_global_col]
    else:
      tile_b_shared[thread_y, thread_x] = 0.0

    # Ensure all threads finish loading files before any thread starts computing
    barrier()

    @parameter
    for k in range(TILE_K):
      var element_from_a = tile_a_shared[thread_y, k]
      var element_from_b = tile_b_shared[k, thread_x]
      accumulator += a_element * b_element

    # Ensure all threads finish computing in tile before any thread loads next
    # tiles
    barrier()

  # Write final results to global memory with bounds checking
  if (global_row < MATRIX_M) and (global_col < MATRIX_N):
    matrix_c[global_row, global_col] = accumulator
