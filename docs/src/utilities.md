# Other utilities

```@meta
DocTestSetup = :(using AtomicLevels)
```

## Parity

AtomicLevels defines the [`Parity`](@ref) type, which is used to represent the parity of
atomic states etc.

```@docs
Parity
@p_str
```

The parity values also define an algebra and an ordering:

```jldoctest
julia> p"odd" < p"even"
true

julia> p"even" * p"odd"
odd

julia> (p"odd")^3
odd

julia> -p"odd"
even
```

The exported [`parity`](@ref) function is overloaded for many of the types in AtomicLevels,
defining a uniform API to determine the parity of an object.

```@docs
parity
```

## JJ to LSJ

```@docs
jj2ℓsj
```

## Index

```@index
Pages = ["utilities.md"]
```

```@meta
DocTestSetup = nothing
```
