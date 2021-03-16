# Atomic orbitals

```@meta
DocTestSetup = quote
    using AtomicLevels
end
```

Atomic orbitals, i.e. single particle states with well-defined orbital or total angular
momentum, are usually the basic building blocks of atomic states. AtomicLevels provides
various types and methods to conveniently label the orbitals.

## Orbital types

AtomicLevels provides two basic types for labelling atomic orbitals: [`Orbital`](@ref) and
[`RelativisticOrbital`](@ref). Stricly speaking, these types do not label orbitals, but
groups of orbitals with the same angular symmetry and radial behaviour (i.e. a
[subshell](https://en.wikipedia.org/wiki/Electron_shell#Subshells)).

All orbitals are subtypes of [`AbstractOrbital`](@ref). Types and methods that work on
generic orbitals can dispatch on that.

```@docs
Orbital
RelativisticOrbital
AbstractOrbital
```

The [`SpinOrbital`](@ref) type can be used to fully qualify all the quantum numbers (that
is, also ``m_\ell`` and ``m_s``) of an [`Orbital`](@ref). It represent a since, distinct
orbital.

```@docs
SpinOrbital
```

The string macros [`@o_str`](@ref) and [`@ro_str`](@ref) can be used
to conveniently construct orbitals, while [`@os_str`](@ref),
[`@sos_str`](@ref), [`@ros_str`](@ref), and [`@rsos_str`](@ref) can be
used to construct whole lists of them very easily.

```@docs
@o_str
@so_str
@ro_str
@rso_str
@os_str
@sos_str
@ros_str
@rsos_str
```

## Methods

```@docs
isless
degeneracy
parity(::Orbital)
symmetry
isbound
angular_momenta
angular_momentum_ranges
spin_orbitals
@κ_str
nonrelorbital
```

```@meta
DocTestSetup = nothing
```
