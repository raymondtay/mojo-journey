trait Flyable:
  fn fly(self):
    pass

trait Quackable:
  fn quack(self):
    pass

@fieldwise_init
struct Duck(Copyable, Quackable, Movable, Flyable):
  fn quack(self):
    print("Quack!")
  fn fly(self):
    print("Wee! Daffy duck is flying!")

@fieldwise_init
struct StealthCow(Copyable, Quackable, Movable, Flyable):
  fn quack(self):
    print("Moo!")
  fn fly(self):
    print("Wee! Cows are flying!")

fn make_it_quack[DuckType : Quackable](some_duck: DuckType) :
  some_duck.quack()

fn make_it_quack2(some_duck: Some[Quackable]) :
  some_duck.quack()

fn quack_n_go[tpe: Quackable & Flyable](object: tpe):
  object.quack()
  object.fly()

trait Stacklike:
  alias EltType: Copyable & Movable

  fn push(mut self, var item: Self.EltType):
    ...
  fn pop(mut self) -> Self.EltType:
    ...


struct MyStack[type: Copyable & Movable](Stacklike):
  alias EltType = Self.type
  alias list_type = List[Self.EltType]

  var list : Self.list_type

  fn __init__(out self):
    self.list = Self.list_type()

  fn push(mut self, var item: Self.EltType):
    self.list.append(item^)

  fn pop(mut self) -> Self.EltType:
    return self.list.pop()
  
  fn dump[
      WritableEltType: Writable & Copyable & Movable
      ](self: MyStack[WritableEltType]) :
    print("[", end="")
    for item in self.list:
      print(item, end=", ")

    print("]", end="\n")

def main():
  make_it_quack(StealthCow())
  make_it_quack(Duck())
  make_it_quack2(StealthCow())
  make_it_quack2(Duck())
  quack_n_go(Duck())
  quack_n_go(StealthCow())

  mystack = MyStack[Int]()
  mystack.push(1)
  mystack.push(2)
  mystack.push(3)
  mystack.dump()
  for _ in range(3):
    _ = mystack.pop()
    print("dumped 1 element from the stack.")
  mystack.dump()

