# Term symbols

```@meta
DocTestSetup = quote
    using AtomicLevels
end
```

AtomicLevels provides types and methods to work and determine term symbols. The ["Term
symbol"](https://en.wikipedia.org/wiki/Term_symbol) and ["Angular momentum
coupling"](https://en.wikipedia.org/wiki/Angular_momentum_coupling) Wikipedia articles give a good basic
overview of the terminology.

For term symbols in LS coupling, AtomicLevels provides the [`Term`](@ref) type.

```@docs
Term
```

The [`Term`](@ref) objects can also be constructed with the [`@T_str`](@ref) string macro.

```@docs
@T_str
```

The [`terms`](@ref) function can be used to generate all possible term symbols. In the case
of relativistic orbitals, the term symbols are simply the valid ``J`` values, represented
with the `HalfInteger` type.

```@docs
terms
count_terms
```

The `L` and `S` quantum numbers are not, in general, sufficient to uniquely identify a term.
The [`IntermediateTerm`](@ref) type allows one to specify an additional quantum number which
would uniquely identify the term.

```@docs
IntermediateTerm
intermediate_terms
```

```@meta
DocTestSetup = nothing
```
