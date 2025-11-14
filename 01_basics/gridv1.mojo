# Mojo requires you to declare all fields in the struct definition. You cannot
# add fields dynamically at run-time. You must declare the type for each field,
# but you cannot assign a value as part of the field declaration.

@fieldwise_init
struct Grid(Copyable, Movable):
  # Indicate that Grid conforms to the Movable and Copyable traits without
  # implementing the corresponding lifecycle methods. In that case, the Mojo
  # compiler automatically generates the missing methods for you.
  var rows: Int
  var cols: Int
  var data: List[List[Int]]

  fn grid_str(self) -> String:
    str = String()
  
    for row in range(self.rows):
      for col in range(self.cols):
        if self.data[row][col] == 1:
          str += "*"
        else:
          str += " "
      if row != self.rows - 1:
        str += "\n"
    return str


