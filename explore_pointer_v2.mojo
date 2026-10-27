def main():
    var p = alloc[Int](1)
    p.store(10) # this worked before
    p.unsafe_free()