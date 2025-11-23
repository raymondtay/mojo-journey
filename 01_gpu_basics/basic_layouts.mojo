from layout import IntTuple, Layout, print_layout

# What is a Mode?
#
# In Mojo layouts, a mode is a shape:stride pair that describes a single dimension of data.
# - Shape: How many elements are in that dimension.
# - Stride: How many steps in memory to skip to get to the next element in that dimension.
# For example, a simple 1D vector layout (8:1) has one mode: 8 elements with a stride of 1.
#
# What are Nested Modes?
#
# Nested modes (or hierarchical modes) allow you to break down a single logical dimension
# into multiple sub-levels of organization. This is primarily used to represent complex
# memory patterns like tiling or blocking, where data is grouped into chunks rather
# than being purely linear.
#
# In a nested mode, a single dimension's shape and stride are defined by IntTuples
# (tuples of integers) rather than single integers.
#
# Structure: Inner vs. Outer
#
# A nested mode generally follows the structure (inner, outer).
# - Inner Mode (First element): Defines a "group" or a "tile" of data.
# - Outer Mode (Second element): Defines how that group is repeated.
#
# Example 1: The Hierarchical Vector
#  Consider the layout: (((4, 2):(1, 4)))
#  Shape: (4, 2) → Inner size 4, Outer size 2.
#  Stride: (1, 4) → Inner stride 1, Outer stride 4.
#
# How it works step-by-step:
#  Inner Mode (4:1): Create a contiguous group of 4 elements with a stride of 1 (indices 0, 1, 2, 3).
#  Outer Mode (2:4): Repeat this group 2 times, stepping 4 indices to find the start of the next group.
#  Visually, this covers the same indices as a flat (8:1) vector (0-7), but the
#  layout captures the structure that it is "two groups of four".
#
# ==============
# | IMPORTANT |
# ==============
# In nested modes, there is NO notion of row and column. The key insight here is
# to understand that the first mode as the "inner mode" (defining a group) and
# the next mode as an "outer mode" (defining a repeat of the group).
#


fn row_and_column_major():
    print("row major and column major")
    var l2x4row_major = Layout.row_major(2, 4)
    print_layout(l2x4row_major)
    print()
    var l6x6col_major = Layout.col_major(6, 6)
    print_layout(l6x6col_major)
    print()


fn coords_to_index():
    print("coordinates to index")
    var l3x4row_major = Layout.row_major(3, 4)
    print_layout(l3x4row_major)

    var coords: IntTuple = [1, 1]
    var idx = l3x4row_major(coords)
    print("index at (1, 1): ", idx)
    print("coordinates at index 7:", l3x4row_major.idx2crd(7))
    print()


fn nested_modes():
    print("nested modes")
    var layout_a = Layout([4, 4], [4, 1])
    print_layout(layout_a)
    print()
    var layout_b = Layout(
        [[2, 2], [2, 2]],
        [[1, 4], [2, 8]],
    )
    print_layout(layout_b)
    var layout_c = Layout(IntTuple(4, 2), IntTuple(1, 4))
    print_layout(layout_c)
    print()


fn tiled_layout():
    var tiled_layout = Layout(
        IntTuple(IntTuple(3, 2), IntTuple(2, 5)),  # shape
        IntTuple(IntTuple(1, 6), IntTuple(3, 12)),  # strides
    )
    print_layout(tiled_layout)


def main():
    # row_and_column_major()
    # coords_to_index()
    # nested_modes()
    tiled_layout()
