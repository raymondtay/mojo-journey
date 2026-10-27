from std.testing import assert_equal, assert_true

# Grid struct copied from 01_basics/gridv1.mojo for testing.
@fieldwise_init
struct Grid(Copyable, Movable, Stringable):
    var rows: Int
    var cols: Int
    var data: List[List[Int]]

    def __str__(self) -> String:
        str = String()
        for row in range(self.rows):
            for col in range(self.cols):
                if self[row, col] == 1:
                    str += "*"
                else:
                    str += " "
            if row != self.rows - 1:
                str += "\n"
        return str

    def __getitem__(self, row: Int, col: Int) -> Int:
        return self.data[row][col]

    def __setitem__(mut self, row: Int, col: Int, value: Int) -> None:
        self.data[row][col] = value

    def evolve(self) -> Self:
        next_generation = List[List[Int]]()
        for row in range(self.rows):
            row_data = List[Int]()
            row_above = (row - 1) % self.rows
            row_below = (row + 1) % self.rows
            for col in range(self.cols):
                col_left = (col - 1) % self.cols
                col_right = (col + 1) % self.cols
                num_neighbours = (
                    self[row_above, col_left]
                    + self[row_above, col]
                    + self[row_above, col_right]
                    + self[row, col_left]
                    + self[row, col_right]
                    + self[row_below, col_left]
                    + self[row_below, col]
                    + self[row_below, col_right]
                )
                new_state = 0
                if self[row, col] == 1 and (
                    num_neighbours == 2 or num_neighbours == 3
                ):
                    new_state = 1
                elif self[row, col] == 0 and num_neighbours == 3:
                    new_state = 1
                row_data.append(new_state)
            next_generation.append(row_data^)
        return Self(self.rows, self.cols, next_generation^)


def make_grid(rows: Int, cols: Int) -> Grid:
    """Create an empty grid (all zeros)."""
    var data = List[List[Int]]()
    for _ in range(rows):
        var row_data = List[Int]()
        for _ in range(cols):
            row_data.append(0)
        data.append(row_data^)
    return Grid(rows, cols, data^)


def test_getitem_setitem() raises:
    var g = make_grid(3, 3)
    assert_equal(g[0, 0], 0)
    g[1, 2] = 1
    assert_equal(g[1, 2], 1)
    # Other cells unchanged
    assert_equal(g[0, 0], 0)
    assert_equal(g[2, 2], 0)


def test_str_empty_grid() raises:
    var g = make_grid(2, 3)
    # Empty 2x3 grid: 3 spaces, newline, 3 spaces
    assert_equal(String(g), "   \n   ")


def test_str_with_live_cells() raises:
    var g = make_grid(2, 2)
    g[0, 0] = 1
    g[1, 1] = 1
    assert_equal(String(g), "* \n *")


def test_evolve_block() raises:
    """A 2x2 block is a still life - it should not change after evolving.
    We use a 4x4 grid to avoid wrap-around interference."""
    var g = make_grid(4, 4)
    g[1, 1] = 1
    g[1, 2] = 1
    g[2, 1] = 1
    g[2, 2] = 1
    var next_g = g.evolve()
    assert_equal(next_g[1, 1], 1)
    assert_equal(next_g[1, 2], 1)
    assert_equal(next_g[2, 1], 1)
    assert_equal(next_g[2, 2], 1)
    # Corners should remain dead
    assert_equal(next_g[0, 0], 0)
    assert_equal(next_g[3, 3], 0)


def test_evolve_blinker() raises:
    """A blinker oscillates between horizontal and vertical with period 2.
    Horizontal: row 2 cols 1,2,3 in a 5x5 grid.
    After one step it becomes vertical: rows 1,2,3 col 2."""
    var g = make_grid(5, 5)
    # Horizontal blinker
    g[2, 1] = 1
    g[2, 2] = 1
    g[2, 3] = 1
    var gen1 = g.evolve()
    # Should become vertical
    assert_equal(gen1[1, 2], 1)
    assert_equal(gen1[2, 2], 1)
    assert_equal(gen1[3, 2], 1)
    # Horizontal cells (except center) should be dead
    assert_equal(gen1[2, 1], 0)
    assert_equal(gen1[2, 3], 0)
    # Evolve again - should return to horizontal
    var gen2 = gen1.evolve()
    assert_equal(gen2[2, 1], 1)
    assert_equal(gen2[2, 2], 1)
    assert_equal(gen2[2, 3], 1)
    assert_equal(gen2[1, 2], 0)
    assert_equal(gen2[3, 2], 0)


def test_evolve_all_dead() raises:
    """An empty grid stays empty."""
    var g = make_grid(3, 3)
    var next_g = g.evolve()
    for r in range(3):
        for c in range(3):
            assert_equal(next_g[r, c], 0)


def test_evolve_underpopulation() raises:
    """A single live cell with no neighbours dies."""
    var g = make_grid(5, 5)
    g[2, 2] = 1
    var next_g = g.evolve()
    assert_equal(next_g[2, 2], 0)
