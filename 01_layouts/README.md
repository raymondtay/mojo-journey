Layouts on Tutorials
=

Here is a step-by-step structure to use to learn _layouts_ in Mojo.

Step 0 - Why do Layouts matter?
==

Below we talk about shapes, strides or modes, let's answer this:

```
Why should programmers care about memory layouts at all?
```

Consider a simple **2x4** matirx:

```
+----+----+----+----+
|  a |  b |  c |  d |
+----+----+----+----+
|  e |  f |  g |  h |
+----+----+----+----+
```

In memory, this is really eight numbers in a row. That is `Memory:
[a,b,c,d,e,f,g,h]`. The question is how do we map coordinates `(row, col)` to
this linear buffer? Three (3) most popular access patterns would be:

* Row-major? (most programming languages use this)
* Column-major? (Fortran, MATLAB)
* Tiled? Blocked? Strided?

**Layout encodes that mapping**.

In Mojo, layouts are explicit (i.e., you CAN control your multi-dimensional
tensor stored in memory).

1.Foundation: 1D Layouts
=

Let's begin with a **1D vector of length 8** and in Mojo nomenclature, it can be
expressed as a _mode_ which is `(shape : stride)`. Here's an example `(8 : 1)`
which means that the _shape_ = 8 (elements), with a _stride_ of 1 (i.e., each
element is exactly 1 memory slot away ⇒ contiguous memory access).

To be very explicit, here's what it looks like, conceptually:

```ascii
index:  0 1 2 3 4 5 6 7
mem:   [x x x x x x x x]
          contiguous
```

In Mojo, it's expressed as follows:

```python
from layout import Layout, IntTuple, print_layout
let layout = Layout(IntTuple(8,1))
print("size =", layout.size()) # 8
print_layout(layout)
```

2.2D Layouts: Row-Major vs Column-major
=

Now, let's look at the 2x4 matrix again:

Row-major layout
==

```MATLAB
((2, 4) : (4, 1))
```

in ASCII,

```ascii
row 0 → [ a b c d ]
row 1 → [ e f g h ]

memory → a b c d e f g h
```

The breakdown can be understood as follows:

* 2 rows (outer dimension)
* 4 columns (inner dimension)
* row stride = 4
* column stride = 1

Column-major layout
==

```MATLAB
((2, 4) : (1, 2))
```

in ASCII,

```ascii
col 0 → [ a e ]
col 1 → [ b f ]
col 2 → [ c g ]
col 3 → [ d h ]

memory → a e b f c g d h
```

The breakdown can be understood as follows:

* 2 rows (outer dimension)
* 4 columns (inner dimension)
* row stride = 2
* column stride = 1

Question: If this 2x4 matrix uses row-major layout, what's the linear index of
element at row=1, col=2?
