Traits
=

You can determine whether a type is explicitly or implicitly copyable by
checking its API documentation to see what _traits_ it conforms to. A Mojo
_trait_ is a set of requirements that a type must implement, usually in the form
of one or more method signatures.

* The `List` type and other Mojo collection types like _Dict_ and _Set_ conform
  to the _Copyable_ trait, which indicates that they are explicitly copyable.
* The `String`, `Int` and other numeric types conform the _ImplicitlyCopyable_
  trait, so you can also use types that conform to the _ImplicitlyCopyable_ trait
  in the same way you can use types that conform to the _Copyable_ trait.

If you define a simple `struct` where all fields are types that conform to the
_ImplicitlyCopyable_ trait—such as `String` and numeric types—you could
indicate that your struct conforms to the _ImplicitlyCopyable_ trait instead
of the _Copyable_ trait. However, our `Grid` struct uses a `List[List[Int]]` field,
which is not implicitly copyable.

Also see the Life of a value section of the Mojo Manual for more information
about the different lifecycle methods and how to implement them.

