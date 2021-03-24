# Internals

!!! note
    The functions, methods and types documented here are _not_ part of the public API.

```@meta
CurrentModule = AtomicLevels
DocTestSetup = quote
    using AtomicLevels
end
```

```@autodocs
Modules = [AtomicLevels]
Public = false
Filter = fn -> !in(fn, [Base.parse, Base.fill, Base.fill!]) &&
    fn != AtomicLevels.xu_terms
```

## Internal implementation of term multiplicity calculation

AtomicLevels.jl uses the algorithm presented in

- _Alternative mathematical technique to determine LS spectral terms_
  by Xu Renjun and Dai Zhenwen, published in JPhysB, 2006.
  [doi:10.1088/0953-4075/39/16/007](https://dx.doi.org/10.1088/0953-4075/39/16/007)

to compute the multiplicity of individual subshells in ``LS``-coupling, beyond the
trivial cases of a single electron or a filled subshell. These
routines need not be used directly, instead use [`terms`](@ref) and
[`count_terms`](@ref).

In the following, ``S'=2S\in\mathbb{Z}`` and
``M_S'=2M_S\in\mathbb{Z}``, as in the original article.

```@docs
AtomicLevels.Xu.X
AtomicLevels.Xu.A
AtomicLevels.Xu.f
AtomicLevels.xu_terms
```

```@meta
CurrentModule = nothing
DocTestSetup = nothing
```
