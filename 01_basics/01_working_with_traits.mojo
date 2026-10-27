trait Flyable:
  def fly(self):
    pass

trait Quackable:
  def quack(self):
    pass

@fieldwise_init
struct Duck(Copyable, Quackable, Movable, Flyable):
  def quack(self):
    print("Quack!")
  def fly(self):
    print("Wee! Daffy duck is flying!")

@fieldwise_init
struct StealthCow(Copyable, Quackable, Movable, Flyable):
  def quack(self):
    print("Moo!")
  def fly(self):
    print("Wee! Cows are flying!")

def make_it_quack[DuckType : Quackable](some_duck: DuckType) :
  some_duck.quack()

def make_it_quack2(some_duck: Some[Quackable]) :
  some_duck.quack()

def quack_n_go[tpe: Quackable & Flyable](object: tpe):
  object.quack()
  object.fly()

trait Stacklike:
  comptime EltType: Copyable & Deinitable

  def push(mut self, var item: Self.EltType):
    ...
  def pop(mut self) -> Self.EltType:
    ...


struct MyStack[type: Copyable & Deinitable](Stacklike):
  comptime EltType = Self.type
  comptime list_type = List[Self.EltType]

  var list : Self.list_type

  def __init__(out self):
    self.list = Self.list_type()

  def push(mut self, var item: Self.EltType):
    self.list.append(item^)

  def pop(mut self) -> Self.EltType:
    return self.list.pop()
  
  # Mojo 1.2: `self` can't be re-typed as `MyStack[WritableEltType]`; use a
  # `where` clause to make `dump` available only when elements are Writable.
  def dump(self) where conforms_to(Self.type, Writable):
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

  var mystack = MyStack[Int]()
  mystack.push(1)
  mystack.push(2)
  mystack.push(3)
  mystack.dump()
  for _ in range(3):
    _ = mystack.pop()
    print("dumped 1 element from the stack.")
  mystack.dump()

