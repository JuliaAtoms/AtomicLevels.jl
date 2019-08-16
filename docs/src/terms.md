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

## Term multiplicity

For subshells starting with `d³`, the possible terms may occur
more than once (multiplicity higher than one), corresponding to
different physical states. These arise from different sequences of
coupling the ``w`` equivalent electrons of the same ``\ell``, and are
distinguished using a _seniority number_. AtomicLevels.jl uses the
algorithm presented in

- _Alternative mathematical technique to determine LS spectral terms_
  by Xu Renjun and Dai Zhenwen, published in JPhysB, 2006.

  [doi:10.1088/0953-4075/39/16/007](https://dx.doi.org/10.1088/0953-4075/39/16/007)

to compute the multiplicity of individual subshells, beyond the
trivial cases of a single electron or a filled subshell.

In the following, ``S'=2S\in\mathbb{Z}`` and
``M_S'=2M_S\in\mathbb{Z}``, as in the original article.

```@docs
AtomicLevels.xu_terms
AtomicLevels.Xu.X
AtomicLevels.Xu.A
AtomicLevels.Xu.f
```

```@meta
DocTestSetup = nothing
```
