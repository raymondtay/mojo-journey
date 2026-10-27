struct S(ImplicitlyCopyable):
    var x: Int
    def __init__(out self, x: Int):
        self.x = x
def main():
    var p = alloc[S](1)
    p[0] = S(x=10)
    p.free()