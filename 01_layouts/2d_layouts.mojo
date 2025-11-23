from layout import Layout, IntTuple, print_layout


fn col_major():
    """Column-major representation.
     ((2, 4):(1, 2))
           0   1   2   3
       +---+---+---+---+
    0  | 0 | 2 | 4 | 6 |
       +---+---+---+---+
    1  | 1 | 3 | 5 | 7 |
       +---+---+---+---+
    """

    var dlayout = Layout.col_major(2, 4)

    for i in range(0, 2):
        for j in range(0, 4):
            var idx = dlayout(IntTuple(i, j))
            print("(", i, ",", j, ") ⇒", idx)

    print_layout(dlayout)


fn row_major():
    """Row-major representation.
     ((2, 4):(4, 1))
         0   1   2   3
       +---+---+---+---+
    0  | 0 | 1 | 2 | 3 |
       +---+---+---+---+
    1  | 4 | 5 | 6 | 7 |
       +---+---+---+---+
    """

    var dlayout = Layout.row_major(2, 4)

    for i in range(0, 2):
        for j in range(0, 4):
            var idx = dlayout(IntTuple(i, j))
            print("(", i, ",", j, ") ⇒", idx)

    print_layout(dlayout)


def main():
    row_major()
    col_major()
