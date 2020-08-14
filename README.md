# OCaml.jl

<a href="https://jonathan-laurent.github.io/OCaml.jl/dev" alt="Dev">
  <img src="https://img.shields.io/badge/docs-dev-blue.svg"/>
</a>
<a href="https://travis-ci.com/jonathan-laurent/OCaml.jl" alt="Build Status">
  <img src="https://travis-ci.com/jonathan-laurent/OCaml.jl.svg?branch=master"/>
</a>

This package enables you to generate Julia bindings for OCaml libraries without
writing a single line of boilerplate.

## How to build the example

To build and run the example, type the following at the root of this repo:

```
make testjl
```

## How this works

In `examples/libocaml/api.mli`, we find the following function declaration:

```ocaml
val evaluate: expr -> int
```

From this signature, the following C wrapper is generated automatically:

```c
value* evaluate(value *x0) {
  static const value *_f = NULL;
  if (_f == NULL) _f = caml_named_value("evaluate");
  value *_r = malloc(sizeof(value));
  *_r = caml_callback_exn(*_f, *x0);
  if (Is_exception_result(*_r)) {
    caml_last_exception = Extract_exception(*_r);
    caml_register_generational_global_root(&caml_last_exception);
    free(_r);
    return NULL;
  }
  else {
    caml_register_generational_global_root(_r);
    return _r;
  }
}
```

Also, the following Julia stub is generated:

```julia
@caml evaluate(::Caml{:expr}) :: Caml{:int}
```

where the `@caml` macro expands to:

```julia
function evaluate(e)
  e = convert(Caml{:expr}, e)
  GC.@preserve e begin
    ptr = ccall((:evaluate, OCAML_LIB), Ptr{Cvoid}, (Ptr{Cvoid},), e.ptr)
    return tojulia(Caml{:int}(ptr))
  end
end
```