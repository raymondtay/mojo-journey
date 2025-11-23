from layout import Layout, IntTuple, print_layout


fn single_dim_layout():
    var layout = Layout(IntTuple(8, 1))
    print("size =", layout.size())
    print_layout(layout)


fn two_dim_layout():
    """
    It's instructive to examine for coherency of the (shape:stride) format.
    Take some time to understand and trace through the shape and stride.
    size = 16
    ((8, 2):(1, 8))
           0    1
        +----+----+
     0  |  0 |  8 |
        +----+----+
     1  |  1 |  9 |
        +----+----+
     2  |  2 | 10 |
        +----+----+
     3  |  3 | 11 |
        +----+----+
     4  |  4 | 12 |
        +----+----+
     5  |  5 | 13 |
        +----+----+
     6  |  6 | 14 |
        +----+----+
     7  |  7 | 15 |
        +----+----+
    """
    var layout = Layout(IntTuple(8, 2))
    print("size =", layout.size())
    print_layout(layout)


def main():
    single_dim_layout()
    two_dim_layout()
