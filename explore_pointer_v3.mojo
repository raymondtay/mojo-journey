struct S(ImplicitlyCopyable):
    var x: Int
def main():
    var p = alloc[S](1)
    p[0] = S(x=10)
    p.free()