# Mojo's origin values are mostly created by the compiler, so you can't just
# create your own origin value — you usually need to derive an origin from
# an existing value.
# Among other things, Mojo uses __origins__ to extend the lifetimes of referenced
# values, so values aren't destroyed prematurely.
#

struct NameList:
  var names: List[String]

  def __init__(out self, *names: String):
    self.names = []
    for name in names:
      self.names.append(name)

  def __getitem__(ref self, index: Int) -> ref [self.names] String:
    '''classical object[index].
    Additional advantage of `ref` return arguments is the ability to support
    parameter mutability. In this context, the method signature is instructive
    and the explanation of the -> ref [self.names] String : is that since the
    `origin` of the return value is tied to the origin of `self`, the returned
    reference will be mutable if the method was called using a mutable
    reference.

    without parameter mutability, you would need to write two versions of
    __getitem__(), one that accepts an immutable self and another that accepts a
    mutable self.
    '''
    if (index >= 0 and index < len(self.names)):
      return self.names[index]
    else:
      raise Error("index out of bounds")

fn pass_immutable_list(list: NameList) raises:
  print(list[2])

def main():
  list = NameList("Thor", "Athena", "Zeus", "Dana", "Vrinda")
  ref name = list[2]
  print(name)
  name += "?"
  print(list[2])
  pass_immutable_list(list)
