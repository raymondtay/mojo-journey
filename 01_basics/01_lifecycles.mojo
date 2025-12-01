# As soon as a value/object is no longer used, Mojo destroys it.
# Mojo does not wait until the end of a code block - or even until the end of an
# expression - to destroy an unused value. It destroys values using an "as soon
# as possible" (ASAP) destruction policy that runs after every sub-expression.
# Even within an expression like `a+b+c+d`, Mojo destroys the intermediate
# values as soon as they're no longer needed.
#
# Field lifetimes
# ==============
#
# In addition to tracking the lifetimes of all objects in a program, Mojo also
# tracks each field of a structure independently. That is, Mojo keep  track of
# whether a "whole object" is fully or partially initialized/destroyed, and it
# destroys each field independently within its ASAP destruction policy.

@fieldwise_init
struct Balloon(Writable):
  var color: String

  fn write_to(self, mut writer : Some[Writer]):
    writer.write(String("a ", self.color, " balloon"))

  fn __del__(deinit self):
    print("Destroyed", String(self))

def main():
  var a = Balloon("red")
  var b = Balloon("blue")
  print(a)
  # a.__del__() runs here for "red" balloon

  a = Balloon("green")
  print(a.color)
  # a.__del__() runs immediately because "green" balloon is never used

  print(b)
  # b.__del__() runs here for "blue" balloon

