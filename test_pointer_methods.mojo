def main():
    var p = alloc[Int](1)
    # Try different names for init/destroy
    try:
        p.init_pointee(10)
    except:
        print("init_pointee failed")
    try:
        p.store((10)
    except:
        print("init_pointee_copy failed")
    try:
        p.store((10)
    except:
        print("init_pointee_move failed")
    try:
        p
    except:
        print("destroy_pointee failed")
    try:
        p.unsafe_destroy_pointee()
    except:
        print("unsafe_destroy_pointee failed")
    p.free()