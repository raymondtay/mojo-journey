
fn incr(n: Int) raises -> Int:
  if n == Int.MAX:
    raise "inc: integer overflow"
  else:
    return n + 1

# This function cannot compile because it handles possible error
# fn unhandled_error(n: Int):
#   print(n, " + 1 = ", incr(n))

fn handled_error(n: Int):
  try:
    print(n, " + 1 = ", incr(n))
  except e:
    print("Handler error: ", e)

# 'def' always means that it's possible to raise exceptions
def incr2(n: Int) -> Int:
  if n == Int.MAX:
    raise "inc: integer overflow"
  else:
    return n + 1

def main():
  for value in [0, 1, Int.MAX]:
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
