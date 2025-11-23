# `alias` is used to name compile-time values
alias G: Int = 42


struct ImmovableObject(Writable):
    var name: String

    @implicit
    fn __init__(out self, var name: String):
        self.name = name^

    fn write_to(self, mut writer: Some[Writer]):
        writer.write("Immovable Object is: ", self.name)


def create_immovable_object(var name: String, out obj: ImmovableObject):
    obj = ImmovableObject(name^)
    obj.name += "!!!"


def main():
    my_obj = create_immovable_object("Blob")
    print(my_obj)
