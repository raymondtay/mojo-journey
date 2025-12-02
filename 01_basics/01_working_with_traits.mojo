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

def main():
  make_it_quack(StealthCow())
  make_it_quack(Duck())
  make_it_quack2(StealthCow())
  make_it_quack2(Duck())
  quack_n_go(Duck())
  quack_n_go(StealthCow())
