# AtomicLevels.jl

AtomicLevels provides a collections of types and methods to facilitate working with atomic states (or, more generally, states with spherical symmetry), both in the relativistic (eigenstates of ``J = L + S``) and non-relativistic (eigenstates on ``L`` and ``S`` separately) frameworks.

* [Orbitals and orbital subshells](@ref man-orbitals)
* [Configurations](@ref man-configurations)
* [Configuration state functions (CSFs)](@ref man-csfs)
* [Term symbols](@ref man-terms)

The aim is to make sure that the types used to label and store information about atomic states are both efficient and user-friendly at the same time.
In addition, it also provides various utility methods, such as generation of a list CSFs corresponding to a given configuration, serialization of orbitals and configurations, methods for introspecting physical quantities etc.

## Usage examples

### Orbitals

```@setup orbitals
using AtomicLevels
```

A single orbital can be constructed using string macros

```@repl orbitals
orbitals = o"2s", ro"5f-"
```

Various methods are provided to look up the properties of the orbitals

```@repl orbitals
for o in orbitals
    @info "Orbital: $o :: $(typeof(o))" parity(o) degeneracy(o) angular_momenta(o)
end
```

You can also create a range of orbitals quickly using the [`@os_str`](@ref) (or [`@ros_str`](@ref)) string macros

```@repl orbitals
os"5[d] 6[s-p] k[7-10]"
```

### Configurations

```@setup configurations
using AtomicLevels
```

The ground state of hydrogen and helium.

```@repl configurations
c"1s",(c"1s2",c"[He]")
```

The ground state configuration of xenon, in relativistic notation.

```@repl configurations
Xe = rc"[Kr] 5s2 5p6"
```

As we see above, by default, the krypton core is declared “closed”. This is useful for calculations when the core should be frozen. We can “open” it by affixing `*`.

```@repl configurations
Xe = c"[Kr]* 5s2 5p6"
```

Note that the `5p` shell was broken up into 2 `5p-` electrons and 4 `5p` electrons. If we are not filling the shell, occupancy of the spin-up and spin-down electrons has to be given separately.

```@repl configurations
Xe⁺ = rc"[Kr] 5s2 5p-2 5p3"
```

It is also possible to work with “continuum orbitals”, where the main quantum number is replaced by a `Symbol`.

```@repl configurations
Xe⁺e = rc"[Kr] 5s2 5p-2 5p3 ks"
```

### Excitations

```@setup excitations
using AtomicLevels
```

We can easily generate all possible excitations from a reference configuration. If no extra orbitals are specified, only those that are “open” within the reference set will be considered.

```@repl excitations
excited_configurations(rc"[Kr] 5s2 5p-2 5p3")
```

By appending virtual orbitals, we can generate excitations to configurations beyond those spanned by the reference set.

```@repl excitations
excited_configurations(rc"[Kr] 5s2 5p-2 5p3", ros"5[d] 6[s-p]"...)
```

Again, using the “continuum orbitals”, it is possible to generate the state space accessible via one-photon transitions from the ground state.

```@repl excitations
Xe⁺e = excited_configurations(rc"[Kr] 5s2 5p6", ros"k[s-d]"...,
                              max_excitations=:singles,
                              keep_parity=false)
```

We can then query for the bound and continuum orbitals thus.

```@repl excitations
map(Xe⁺e) do c
    b = bound(c)
    num_electrons(b) => b
end
map(Xe⁺e) do c
    b = continuum(c)
    num_electrons(b) => b
end
```

### Term symbol calculation

```@setup termsymbols
using AtomicLevels
```

[Overview of angular momentum coupling on Wikipedia.](https://en.wikipedia.org/wiki/Angular_momentum_coupling)

**``LS``-coupling.**
This is done purely non-relativistic, i.e. `2p-` is considered equivalent to `2p`.

```@repl termsymbols
terms(c"1s")
terms(c"[Kr] 5s2 5p5")
terms(c"[Kr] 5s2 5p4 6s 7g")
```

**``jj``-coupling**.
``jj``-coupling is implemented slightly differently, it calculates the possible ``J`` values resulting from coupling `n` equivalent electrons in all combinations allowed by the Pauli principle.

```@repl termsymbols
intermediate_terms(ro"1s", 1)
intermediate_terms(ro"5p", 2)
intermediate_terms(ro"7g", 3)
```

### Configuration state functions

```@setup csfs
using AtomicLevels
```

CSFs are formed from electronic configurations and their possible term couplings (along with intermediate terms, resulting from unfilled subshells).

```@repl csfs
sort(vcat(csfs(rc"3s 3p2")..., csfs(rc"3s 3p- 3p")...))
```
