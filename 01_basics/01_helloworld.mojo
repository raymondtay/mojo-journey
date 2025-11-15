# My first mojo program !
# Run: 
# ------
# 1) pixi run mojo 01_helloworld.mojo
# 2) mojo 01_helloworld.mojo
#
# Build: 
# ------
# 1) mojo build 01_helloworld.mojo
#    ./01_helloworld
from gridv1 import Grid
from python import Python

def main():
  # var name : String = input("Enter your name: ")
  # var greeting : String = name + ", Hi!"
  # print(greeting)

  num_rows = 8
  num_cols = 8
  glider = [
      [0, 1, 0, 0, 0, 0, 0, 0],
      [0, 0, 1, 0, 0, 0, 0, 0],
      [1, 1, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
  ]
  result = grid_str(num_rows, num_cols, glider)
  result2 = Grid(num_rows, num_cols, glider^)
  print(result)
  # print(result2.grid_str())
  print(String(result2))

  print(String(Grid.random(8, 16)))
  grid = Grid.random(8, 16)
  run_display(grid^)
  run_pygame()

fn grid_str(rows: Int, cols: Int, grid: List[List[Int]]) -> String:
  str = String() # create empty String

  for row in range(rows):
    for col in range(cols):
      if grid[row][col] == 1:
        str += "*"
      else:
        str += " "
    if row != rows - 1:
      str += "\n"
  return str

def run_display(var grid: Grid) -> None:
  while True:
    print(String(grid))
    print()
    if input("Enter 'q' to quit or press <Enter> to continue: ") == "q":
      break
    grid = grid.evolve()

