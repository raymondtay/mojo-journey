# Mojo requires you to declare all fields in the struct definition. You cannot
# add fields dynamically at run-time. You must declare the type for each field,
# but you cannot assign a value as part of the field declaration.
import random

@fieldwise_init
struct Grid(Stringable, Copyable, Movable):
  # Indicate that Grid conforms to the Movable and Copyable traits without
  # implementing the corresponding lifecycle methods. In that case, the Mojo
  # compiler automatically generates the missing methods for you.
  var rows: Int
  var cols: Int
  var data: List[List[Int]]

  fn __str__(self) -> String:
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

  # Getters retrieve "state"
  fn __getitem__(self, row: Int, col: Int) -> Int:
    return self.data[row][col];

  # Setters alter "state" and don't return any values.
  fn __setitem__(mut self, row: Int, col: Int, value: Int) -> None:
    self.data[row][col] = value;

  # Static methods do not operate on specific instances of the type, 
  # so it can be invoked as a utility function. We can decorate in
  # using the @staticmethod decorator.
  @staticmethod
  fn random(rows: Int, cols: Int) -> Self:
    # seed the random number generator using the current time.
    random.seed()

    var data: List[List[Int]] = []
    for _ in range(rows):
      var row_data : List[Int] = []
      for _ in range(cols):
        row_data.append(Int(random.random_si64(0, 1)))
      data.append(row_data^) # transfer ownership from `row_data` to `data`

    return Self(rows, cols, data^)

  fn evolve(self) -> Self:
    next_generation = List[List[Int]]()

    for row in range(self.rows):
      row_data = List[Int]()

      # calculate neighboring row indices, handling "Wrap around"
      row_above = (row - 1) % self.rows
      row_below = (row + 1) % self.rows

      for col in range(self.cols):
        col_left = (col - 1) % self.cols
        col_right = (col + 1) % self.cols

        num_neighbours = (
            self[row_above, col_left] + 
            self[row_above, col] +
            self[row_above, col_right] +
            self[row, col_left] +
            self[row, col_right] +
            self[row_below, col_left] +
            self[row_below, col] +
            self[row_below, col_right]
            )

        # Determine the state of the current cell for the next generation
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


