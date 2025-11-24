#
# Write a custom context manager
# ==============================
#
# Writing a custom context manager is a matter of defining a struct that
# implements two special dunder methods (double underscore methods): __enter__()
# and __exit__()
# * __enter__() is called by the `with` statement to enter the runtime contex.t
#   The __enter__() method should initialize any state necessary for the context
#   and return the context manager.
# * __exit__() is called when the `with` code block completes execution, even if
#   the `with` code block terminates with a call to `continue`, `break`, or
#   `return`. The __exit__() method should release any resources associated with
#   the context. After the __exit__() method returns, the context manager is
#   destroyed.

import sys
import time

@fieldwise_init
struct Timer(ImplicitlyCopyable, Movable):
  var start_time : Int

  fn __init__(out self):
    self.start_time = 0

  fn __enter__(mut self) -> Self:
    self.start_time = Int(time.perf_counter_ns())
    return self

  fn __exit__(mut self):
    end_time = time.perf_counter_ns()
    elapsed_time_ms = round(((end_time - UInt(self.start_time)) / 1e6), 3)
    print("Elapsed time: ", elapsed_time_ms, " milliseconds")

@fieldwise_init
struct ConditionalTimer(ImplicitlyCopyable, Movable):
  var start_time : Int

  fn __init__(out self):
    self.start_time = 0

  fn __enter__(mut self) -> Self:
    self.start_time = Int(time.perf_counter_ns())
    return self

  fn __exit__(mut self):
    end_time = time.perf_counter_ns()
    elapsed_time_ms = round(((end_time - UInt(self.start_time)) / 1e6), 3)
    print("Elapsed time: ", elapsed_time_ms, " milliseconds")

  fn __exit__(mut self, e : Error) raises -> Bool:
    if String(e) == "just a warning":
      print("Suppressing error: " , e)
      self.__exit__()
      return True
    else:
      print("Propagating error")
      self.__exit__()
      return False

def flaky_identity(n : Int) -> Int:
  if (n % 4) == 0:
    raise "really bad"
  elif (n % 2) == 0:
    raise "just a warning"
  else:
    return n

def main():
  for i in range(1, 9):
    with ConditionalTimer():
      print("\nBeginning Execution")
      print("i = ", i)
      time.sleep(0.1)

      if i == 3:
        print("continue executed")
        continue

      j = flaky_identity(i)
      print("j = ", j)
      print("Ending execution")

  with Timer():
    print("Beginning execution")
    time.sleep(1.0)
    if len(sys.argv())> 1:
      raise "simulated error"
    time.sleep(1.0)
    print("Ending execution")
