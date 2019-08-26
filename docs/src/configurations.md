# Atomic configurations

```@meta
DocTestSetup = quote
    using AtomicLevels
end
```

We define a configuration to be a set of orbitals with their
associated occupation (i.e. the number of electron on that
orbital). We can represent a particular configuration with an instance
of the [`Configuration`](@ref) type. The orbitals of a configuration
can be unsorted (default) or sorted according to the canonical
ordering (first by ``n``, then by ``\ell``, &c). It is important to
allow for arbitrary order, since permutation of the orbitals in a
configuration, in general incurs a phase shift of matrix elements, &c.

```@docs
Configuration
```

The [`@c_str`](@ref) and [`@rc_str`](@ref) string macros can be used to conveniently
construct configurations:

```@docs
@c_str
@rc_str
```

## Interface

For example, it is possible to index into a configuration, including with a range of
indices, returning a sub-configuration consisting of only those orbitals. With an integer
index, an `(orbital, occupancy, state)` tuple is returned.

```jldoctest confexamples
julia> config = c"1s2c 2si 2p3"
[He]ᶜ 2sⁱ 2p³

julia> config[2]
(2s, 1, :inactive)

julia> config[1:2]
[He]ᶜ 2sⁱ

julia> config[[3,1]]
[He]ᶜ 2p³
```

The configuration can also be iterated over. Each item is a `(orbital, occupancy, state)`
tuple.

```jldoctest confexamples
julia> for (o, nelec, s) in config
           @show o, nelec, s
       end
(o, nelec, s) = (1s, 2, :closed)
(o, nelec, s) = (2s, 1, :inactive)
(o, nelec, s) = (2p, 3, :open)
```

Various other methods exist to manipulate or transform configurations or to query them for
information.

```@docs
issimilar
Base.:(==)(a::Configuration{<:O}, b::Configuration{<:O}) where {O<:AbstractOrbital}
num_electrons(::Configuration)
num_electrons(::Configuration, ::AtomicLevels.AbstractOrbital)
Base.delete!
Base.:(+)
Base.:(-)
Base.close
close!
Base.fill
Base.fill!
Base.in
Base.filter
Base.count
Base.replace
core
peel
active
inactive
bound
continuum
parity(::Configuration)
nonrelconfiguration
```

## Generating configuration lists

The [`⊗`](@ref) operator can be used to easily generate lists of configurations from existing
pieces. E.g. to create all the valence configurations on top of an closed core, you only
need to write

```jldoctest
julia> c"[Ne]" ⊗ [c"3s2", c"3s 3p", c"3p2"]
3-element Array{Configuration{Orbital{Int64}},1}:
 [Ne]ᶜ 3s²
 [Ne]ᶜ 3s 3p
 [Ne]ᶜ 3p²
```

That can be combined with the [`@rcs_str`](@ref) string macro to easily generate all possible
relativistic configurations from a non-relativistic definition:

```jldoctest
julia> rc"[Ne] 3s2" ⊗ rcs"3p2"
3-element Array{Configuration{RelativisticOrbital{Int64}},1}:
 [Ne]ᶜ 3s² 3p⁻²
 [Ne]ᶜ 3s² 3p⁻ 3p
 [Ne]ᶜ 3s² 3p²
```

```@docs
⊗
@rcs_str
```

## Spin configurations

```@docs
spin_configurations
substitutions
@scs_str
```

```@meta
DocTestSetup = nothing
```
