
def incr(n: Int) raises -> Int:
  if n == Int.MAX:
    raise "inc: integer overflow"
  else:
    return n + 1

# This function cannot compile because it handles possible error
# def unhandled_error(n: Int):
#   print(n, " + 1 = ", incr(n))

def handled_error(n: Int):
  try:
    print(n, " + 1 = ", incr(n))
  except e:
    print("Handler error: ", e)

# Mojo 1.2: `fn` was removed and `def` no longer implies `raises`.
# A function that can raise must say so explicitly, just like `incr` above.
def incr2(n: Int) raises -> Int:
  if n == Int.MAX:
    raise "inc: integer overflow"
  else:
    return n + 1

def main():
  for value in [0, 1, Int.MAX]:
    var result: String
    try:
      print()
      print("try    => ", value)
      if value == 1:
        continue
      result = "{} incremented is {}".format(value, incr2(value))
    except e:
      print("except  => ", e)
    else:
      print("else    => ", result)
    finally:
      print("finally => ===================")
  handled_error(44)
