# Mojo requires you to declare all fields in the struct definition. You cannot
# add fields dynamically at run-time. You must declare the type for each field,
# but you cannot assign a value as part of the field declaration.
from std import random


@fieldwise_init
struct Grid(Copyable, Writable):
    # Indicate that Grid conforms to the Movable and Copyable traits without
    # implementing the corresponding lifecycle methods. In that case, the Mojo
    # compiler automatically generates the missing methods for you.
    var rows: Int
    var cols: Int
    var data: List[List[Int]]

    # Mojo 1.2: `Stringable`/`__str__` were removed; `String(grid)` and
    # `print(grid)` both use `Writable.write_to`.
    def write_to(self, mut writer: Some[Writer]):
        for row in range(self.rows):
            for col in range(self.cols):
                if self[row, col] == 1:
                    writer.write("*")
                else:
                    writer.write(" ")
            if row != self.rows - 1:
                writer.write("\n")

    # Getters retrieve "state"
    def __getitem__(self, row: Int, col: Int) -> Int:
        return self.data[row][col]

    # Setters alter "state" and don't return any values.
    def __setitem__(mut self, row: Int, col: Int, value: Int) -> None:
        self.data[row][col] = value

    # Static methods do not operate on specific instances of the type,
    # so it can be invoked as a utility function. We can decorate in
    # using the @staticmethod decorator.
    @staticmethod
    def random(rows: Int, cols: Int) -> Self:
        # seed the random number generator using the current time.
        random.seed()

        var data: List[List[Int]] = []
        for _ in range(rows):
            var row_data: List[Int] = []
            for _ in range(cols):
                row_data.append(Int(random.random_si64(0, 1)))
            data.append(
                row_data^
            )  # transfer ownership from `row_data` to `data`

        return Self(rows, cols, data^)

    def evolve(self) -> Self:
        var next_generation = List[List[Int]]()

        for row in range(self.rows):
            var row_data = List[Int]()

            # calculate neighboring row indices, handling "Wrap around"
            var row_above = (row - 1) % self.rows
            var row_below = (row + 1) % self.rows

            for col in range(self.cols):
                var col_left = (col - 1) % self.cols
                var col_right = (col + 1) % self.cols

                var num_neighbours = (
                    self[row_above, col_left]
                    + self[row_above, col]
                    + self[row_above, col_right]
                    + self[row, col_left]
                    + self[row, col_right]
                    + self[row_below, col_left]
                    + self[row_below, col]
                    + self[row_below, col_right]
                )

                # Determine the state of the current cell for the next generation
                var new_state = 0
                if self[row, col] == 1 and (
                    num_neighbours == 2 or num_neighbours == 3
                ):
                    new_state = 1
                elif self[row, col] == 0 and num_neighbours == 3:
                    new_state = 1
                row_data.append(new_state)
            next_generation.append(row_data^)

        return Self(self.rows, self.cols, next_generation^)
