# [Term symbols](@id man-terms)

```@meta
DocTestSetup = :(using AtomicLevels)
```

AtomicLevels provides types and methods to work and determine term symbols. The ["Term
symbol"](https://en.wikipedia.org/wiki/Term_symbol) and ["Angular momentum
coupling"](https://en.wikipedia.org/wiki/Angular_momentum_coupling) Wikipedia articles give
a good basic overview of the terminology.

For term symbols in LS coupling, AtomicLevels provides the [`Term`](@ref) type.

```@docs
Term
```

The [`Term`](@ref) objects can also be constructed with the [`@T_str`](@ref) string macro.

```@docs
@T_str
Base.parse(::Type{Term}, ::AbstractString)
```

The [`terms`](@ref) function can be used to generate all possible term symbols. In the case
of relativistic orbitals, the term symbols are simply the valid ``J`` values, represented
using the [`HalfInteger`](https://github.com/sostock/HalfIntegers.jl) type.

```@docs
terms
count_terms
multiplicity(t::Term)
weight(t::Term)
```

## Term multiplicity and intermediate terms

For subshells starting with `d³`, a term symbol can occur multiple times, each occurrence
corresponding to a different physical state (multiplicity higher than one). This happens
when there are distinct ways of coupling the electrons, but they yield the same total
angular momentum. E.g. a `d³` subshell can be coupled in 8 different ways, two of which are
both described by the `²D` term symbol:

```jldoctest
julia> terms(o"3d", 3)
8-element Vector{Term}:
 ²P
 ²D
 ²D
 ²F
 ²G
 ²H
 ⁴P
 ⁴F

julia> count_terms(o"3d", 3, T"2D")
2
```

The multiplicity can be even higher if more electrons and higher angular momenta are
involved:

```jldoctest
julia> count_terms(o"4f", 5, T"2Do")
5
```

To distinguish these subshells, extra quantum numbers must be specified. In AtomicLevels,
that can be done with the [`IntermediateTerm`](@ref) type. This is primarily used when
specifying the subshell couplings in [CSFs](@ref man-csfs).

```@docs
IntermediateTerm
intermediate_terms
```

### Disambiguating quantum numbers

The [`IntermediateTerm`](@ref) type does not specify how to interpret the disambiguating
quantum number(s) ``ν``, or even what the type of it should be. In AtomicLevels, we use two
different types, depending on the situation:

* **A simple `Integer`.** In this case, the quantum number ``\nu`` must be in the range
  ``1 \leq \nu \leq N_{\rm{terms}}``, where ``N_{\rm{terms}}`` is the multiplicity of the
  term symbol (i.e. the number of times this term symbol appears for this subshell
  ``\ell^w`` or ``\ell_j^w``).

  AtomicLevels does not prescribe any further interpretation for the quantum number.
  It can be used as a simple counter to distinguish the different terms, or the user can
  define their own mapping from the set of integers to physical states.

* **`Seniority`.** In this case the number is interpreted to be _Racah's seniority
  number_. This gives the intermediate term a specific physical interpretation, but only
  works for certain subshells. See the [`Seniority`](@ref) type for more information.

```@docs
Seniority
```

## Term couplings

The angular momentum coupling method is based on the [vector
model](https://en.wikipedia.org/wiki/Vector_model_of_the_atom),
where two angular momenta can be combined via vector addition to form
a total angular momentum:

```math
\vec{J} = \vec{L} + \vec{S},
```

where the length of the resultant momentum ``\vec{J}`` obeys

```math
|L-S| \leq J \leq L+S.
```

Relations such as these are used to couple the term symbols in both
``LS`` and ``jj`` coupling; however, not all values of ``J`` predicted
by the vector model are valid physical states, see
[`couple_terms`](@ref).

To generate the possible [`terms`](@ref) of a configuration, all the
possible terms of the individual subshells, have to be coupled
together to form the final terms; this is done from
left-to-right. When generating all possible [`CSFs`](@ref  man-csfs) from a
configuration, it is also necessary to find the intermediate couplings
of the individual subshells. As an example, if we want to find the
possible terms of `3p² 4s 5p²`, we first find the possible terms of the
individual subshells:

```jldoctest intermediate_term_examples
julia> its = intermediate_terms(c"3p2 4s 5p2")
3-element Vector{Vector{IntermediateTerm{Term, Seniority}}}:
 [₀¹S, ₂¹D, ₂³P]
 [₁²S]
 [₀¹S, ₂¹D, ₂³P]
```

where the seniority numbers are indicated as preceding subscripts. We
then need to couple each intermediate term of the first subshell with
each of the second subshell, and couple each of the resulting terms
with each of the third subshell, and so on. E.g. coupling the `₂³P`
intermediate term with `₁²S` produces two terms:

```jldoctest
julia> couple_terms(T"3P", T"2S")
2-element Vector{Term}:
 ²P
 ⁴P
```

each of which need to be coupled with e.g. `₂¹D`:

```jldoctest
julia> couple_terms(T"2P", T"1D")
3-element Vector{Term}:
 ²P
 ²D
 ²F

julia> couple_terms(T"4P", T"1D")
3-element Vector{Term}:
 ⁴P
 ⁴D
 ⁴F
```

[`terms`](@ref) uses [`couple_terms`](@ref) (through
[`AtomicLevels.final_terms`](@ref)) to produce all possible terms
coupling trees, folding from left-to-right:

```jldoctest
julia> a = couple_terms([T"1S", T"1D", T"3P"], [T"2S"])
4-element Vector{Term}:
 ²S
 ²P
 ²D
 ⁴P

julia> couple_terms(a, [T"1S", T"1D", T"3P"])
12-element Vector{Term}:
 ²S
 ²P
 ²D
 ²F
 ²G
 ⁴S
 ⁴P
 ⁴D
 ⁴F
 ⁶S
 ⁶P
 ⁶D
```

which gives the same result as

```jldoctest
julia> terms(c"3p2 4s 5p2")
12-element Vector{Term}:
 ²S
 ²P
 ²D
 ²F
 ²G
 ⁴S
 ⁴P
 ⁴D
 ⁴F
 ⁶S
 ⁶P
 ⁶D
```

Note that for the generation of final terms, the intermediate terms
need not be kept (and their seniority is not important). However, for
the generation of [`CSFs`](@ref man-csfs), we need to form all possible
combinations of intermediate terms for each subshell, and couple them,
again left-to-right, to form all possible coupling chains (each one
corresponding to a unique physical state). E.g. for the last term of
each subshell of `3p² 4s 5p²`

```jldoctest intermediate_term_examples
julia> last.(its)
3-element Vector{IntermediateTerm{Term, Seniority}}:
 ₂³P
 ₁²S
 ₂³P
```

we find the following chains:

```jldoctest intermediate_term_examples
julia> intermediate_couplings(last.(its))
15-element Vector{Vector{Term}}:
 [¹S, ³P, ²P, ²S]
 [¹S, ³P, ²P, ²P]
 [¹S, ³P, ²P, ²D]
 [¹S, ³P, ²P, ⁴S]
 [¹S, ³P, ²P, ⁴P]
 [¹S, ³P, ²P, ⁴D]
 [¹S, ³P, ⁴P, ²S]
 [¹S, ³P, ⁴P, ²P]
 [¹S, ³P, ⁴P, ²D]
 [¹S, ³P, ⁴P, ⁴S]
 [¹S, ³P, ⁴P, ⁴P]
 [¹S, ³P, ⁴P, ⁴D]
 [¹S, ³P, ⁴P, ⁶S]
 [¹S, ³P, ⁴P, ⁶P]
 [¹S, ³P, ⁴P, ⁶D]
```

```@docs
couple_terms
AtomicLevels.final_terms
intermediate_couplings
```

## Levels & States

Coupling ``L`` and ``S`` to a total ``J``, as discussed under [Term
couplings](@ref) above, yields a [`Level`](@ref); in ``jj`` coupling,
final term of the [`CSF`](@ref) already has its final ``J`` given.  In
both coupling schemes, the same values of final ``J`` will result, but
via different intermediate couplings. As an example, we will consider
the configuration ``1s\;2p``, which in the ``LS`` and ``jj`` coupling
schemes has the following [`CSF`](@ref)s:

```jldoctest levels_and_states
julia> csls = csfs(c"1s 2p")
2-element Vector{NonRelativisticCSF{Orbital{Int64}, Seniority}}:
 1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-
 1s(₁²S|²S) 2p(₁²Pᵒ|³Pᵒ)-

julia> csjj = vcat(csfs(rc"1s 2p"), csfs(rc"1s 2p-"))
4-element Vector{RelativisticCSF{RelativisticOrbital{Int64}, Seniority}}:
 1s(₁1/2|1/2) 2p(₁3/2|1)-
 1s(₁1/2|1/2) 2p(₁3/2|2)-
 1s(₁1/2|1/2) 2p-(₁1/2|0)-
 1s(₁1/2|1/2) 2p-(₁1/2|1)-
```

If we now generate the permissible [`Level`](@ref)s, we find the valid
values of ``J``, i.e. ``0``, ``2\times 1``, and ``2``:

```jldoctest levels_and_states
julia> levels.(csls)
2-element Vector{Vector{Level{Orbital{Int64}, Term, Seniority}}}:
 [|1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-, J = 1⟩]
 [|1s(₁²S|²S) 2p(₁²Pᵒ|³Pᵒ)-, J = 0⟩, |1s(₁²S|²S) 2p(₁²Pᵒ|³Pᵒ)-, J = 1⟩, |1s(₁²S|²S) 2p(₁²Pᵒ|³Pᵒ)-, J = 2⟩]

julia> levels.(csjj)
4-element Vector{Vector{Level{RelativisticOrbital{Int64}, HalfIntegers.Half{Int64}, Seniority}}}:
 [|1s(₁1/2|1/2) 2p(₁3/2|1)-, J = 1⟩]
 [|1s(₁1/2|1/2) 2p(₁3/2|2)-, J = 2⟩]
 [|1s(₁1/2|1/2) 2p-(₁1/2|0)-, J = 0⟩]
 [|1s(₁1/2|1/2) 2p-(₁1/2|1)-, J = 1⟩]
```

```@docs
Level
weight(l::Level)
J_range
levels
```

Similarly, by additionally specifying the projection quantum number
``M_J``, we get a fully quantified [`State`](@ref). In the same way,
the permissible values of ``M_J`` must agree between the coupling
schemes, sorting by ``M_J`` for clarity:

```jldoctest levels_and_states
julia> sort(reduce(vcat, reduce(vcat, states.(csls))), by=s->s.M_J)
12-element Vector{State{Orbital{Int64}, Term, Seniority}}:
 |1s(₁²S|²S) 2p(₁²Pᵒ|³Pᵒ)-, J = 2, M_J = -2⟩
 |1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-, J = 1, M_J = -1⟩
 |1s(₁²S|²S) 2p(₁²Pᵒ|³Pᵒ)-, J = 1, M_J = -1⟩
 |1s(₁²S|²S) 2p(₁²Pᵒ|³Pᵒ)-, J = 2, M_J = -1⟩
 |1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-, J = 1, M_J = 0⟩
 |1s(₁²S|²S) 2p(₁²Pᵒ|³Pᵒ)-, J = 0, M_J = 0⟩
 |1s(₁²S|²S) 2p(₁²Pᵒ|³Pᵒ)-, J = 1, M_J = 0⟩
 |1s(₁²S|²S) 2p(₁²Pᵒ|³Pᵒ)-, J = 2, M_J = 0⟩
 |1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-, J = 1, M_J = 1⟩
 |1s(₁²S|²S) 2p(₁²Pᵒ|³Pᵒ)-, J = 1, M_J = 1⟩
 |1s(₁²S|²S) 2p(₁²Pᵒ|³Pᵒ)-, J = 2, M_J = 1⟩
 |1s(₁²S|²S) 2p(₁²Pᵒ|³Pᵒ)-, J = 2, M_J = 2⟩

julia> sort(reduce(vcat, reduce(vcat, states.(csjj))), by=s->s.M_J)
12-element Vector{State{RelativisticOrbital{Int64}, HalfIntegers.Half{Int64}, Seniority}}:
 |1s(₁1/2|1/2) 2p(₁3/2|2)-, J = 2, M_J = -2⟩
 |1s(₁1/2|1/2) 2p(₁3/2|1)-, J = 1, M_J = -1⟩
 |1s(₁1/2|1/2) 2p(₁3/2|2)-, J = 2, M_J = -1⟩
 |1s(₁1/2|1/2) 2p-(₁1/2|1)-, J = 1, M_J = -1⟩
 |1s(₁1/2|1/2) 2p(₁3/2|1)-, J = 1, M_J = 0⟩
 |1s(₁1/2|1/2) 2p(₁3/2|2)-, J = 2, M_J = 0⟩
 |1s(₁1/2|1/2) 2p-(₁1/2|0)-, J = 0, M_J = 0⟩
 |1s(₁1/2|1/2) 2p-(₁1/2|1)-, J = 1, M_J = 0⟩
 |1s(₁1/2|1/2) 2p(₁3/2|1)-, J = 1, M_J = 1⟩
 |1s(₁1/2|1/2) 2p(₁3/2|2)-, J = 2, M_J = 1⟩
 |1s(₁1/2|1/2) 2p-(₁1/2|1)-, J = 1, M_J = 1⟩
 |1s(₁1/2|1/2) 2p(₁3/2|2)-, J = 2, M_J = 2⟩
```

```@docs
State
states
```


## Index

```@index
Pages = ["terms.md"]
```

```@meta
DocTestSetup = nothing
```
