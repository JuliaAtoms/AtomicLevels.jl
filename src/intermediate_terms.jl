# * Seniority

"""
    Seniority(ν)

Seniority is an extra quantum number introduced by Giulio Racah (1943)
to disambiguate between terms belonging to a subshell with a specific
occupancy, that are assigned the same term symbols. For partially
filled f-shells (in ``LS`` coupling) or partially filled ``9/2``
shells (in ``jj`` coupling), seniority alone is not enough to
disambiguate all the arising terms.

The seniority number is defined as the minimum occupancy number `ν ∈
n:-2:0` for which the term first appears, e.g. the ²D term first
occurs in the d¹ configuration, then twice in the d³ configuration
(which will then have the terms ₁²D and ₃²D).
"""
struct Seniority
    ν::Int
end

Base.isless(a::Seniority, b::Seniority) = a.ν < b.ν
Base.iseven(s::Seniority) = iseven(s.ν)
Base.isodd(s::Seniority) = isodd(s.ν)

# This is the notation by Giulio Racah, p.377:
# - Racah, G. (1943). Theory of complex spectra. III. Physical Review,
#   63(9-10), 367–382. http://dx.doi.org/10.1103/physrev.63.367
Base.show(io::IO, s::Seniority) = write(io, to_subscript(s.ν))

istermvalid(term, s::Seniority) =
    iseven(multiplicity(term)) ⊻ iseven(s)

# This is due to the statement "For partially filled f-shells,
# seniority alone is not sufficient to distinguish all possible
# states." on page 24 of
#
# - Froese Fischer, C., Brage, T., & Jönsson, P. (1997). Computational
#   Atomic Structure : An Mchf Approach. Bristol, UK Philadelphia, Penn:
#   Institute of Physics Publ.
#
# This is too strict, i.e. there are partially filled (ℓ ≥ f)-shells
# for which seniority /is/ enough, but I don't know which, so better
# play it safe.
assert_unique_classification(orb::Orbital, occupation, term::Term, s::Seniority) =
    istermvalid(term, s) &&
    (orb.ℓ < 3 || occupation == degeneracy(orb))

function assert_unique_classification(orb::RelativisticOrbital, occupation, J::HalfInteger, s::Seniority)
    ν = s.ν
    # This is deduced by looking at Table A.10 of
    #
    # - Grant, I. P. (2007). Relativistic Quantum Theory of Atoms and
    #   Molecules : Theory and Computation. New York: Springer.
    istermvalid(J, s) &&
        !((orb.j == half(9) && (occupation == 4 || occupation == 6) &&
           (J == 4 || J == 6) && ν == 4) ||
          orb.j > half(9)) # Again, too strict.
end


# * Intermediate terms, seniority
"""
    struct IntermediateTerm{T,S}

Represents a term together with its extra disambiguating quantum number(s), labelled by `ν`.

The term symbol (`::T`) can either be a [`Term`](@ref) (for ``LS``-coupling) or a
`HalfInteger` (for ``jj``-coupling).

The disambiguating quantum number(s) (`::S`) can be anything as long as they are sortable
(i.e. implementing `isless`). It is up to the user to pick a scheme that is suitable for
their application. See "[Disambiguating quantum numbers](@ref)" in the manual for discussion
on how it is used in AtomicLevels.

See also: [`Term`](@ref), [`Seniority`](@ref)

# Constructors

    IntermediateTerm(term, ν)

Constructs an intermediate term with the term symbol `term` and disambiguating quantum
number(s) `ν`.

# Properties

To access the term symbol and the disambiguating quantum number(s), you can use the
`.term :: T` and `.ν :: S` (or `.nu :: S`) properties, respectively. E.g.:

```jldoctest
julia> it = IntermediateTerm(T"2D", 2)
₍₂₎²D

julia> it.term, it.ν
(²D, 2)

julia> it = IntermediateTerm(5//2, Seniority(2))
₂5/2

julia> it.term, it.nu
(5/2, ₂)
```
"""
struct IntermediateTerm{T,S}
    term::T
    ν::S
    IntermediateTerm(term::T, ν::S) where {T<:Union{Term,<:HalfInteger}, S} =
        new{T,S}(term, ν)
    IntermediateTerm(term::Real, ν) =
        IntermediateTerm(convert(HalfInt, term), ν)
end

Base.getproperty(it::IntermediateTerm, s::Symbol) = s == :nu ? getfield(it, :ν) : getfield(it, s)
Base.propertynames(::IntermediateTerm, private=false) = (:term, :ν, :nu)

function Base.show(io::IO, iterm::IntermediateTerm{<:Any,<:Integer})
    write(io, "₍")
    write(io, to_subscript(iterm.ν))
    write(io, "₎")
    show(io, iterm.term)
end

function Base.show(io::IO, iterm::IntermediateTerm)
    show(io, iterm.ν)
    show(io, iterm.term)
end

Base.isless(a::IntermediateTerm, b::IntermediateTerm) =
    a.ν < b.ν ||
    a.ν == b.ν && a.term < b.term

"""
    intermediate_terms(orb::Orbital, w::Int=one(Int))

Generates all [`IntermediateTerm`](@ref) for a given non-relativstic
orbital `orb` and occupation `w`.

# Examples

```jldoctest
julia> intermediate_terms(o"2p", 2)
3-element Array{IntermediateTerm{Term,Seniority},1}:
 ₀¹S
 ₂¹D
 ₂³P
```

The preceding subscript is the seniority number, which indicates at
which occupancy a certain term is first seen, cf.

```jldoctest
julia> intermediate_terms(o"3d", 1)
1-element Array{IntermediateTerm{Term,Seniority},1}:
 ₁²D

julia> intermediate_terms(o"3d", 3)
8-element Array{IntermediateTerm{Term,Seniority},1}:
 ₁²D
 ₃²P
 ₃²D
 ₃²F
 ₃²G
 ₃²H
 ₃⁴P
 ₃⁴F
```

In the second case, we see both `₁²D` and `₃²D`, since there are two
ways of coupling 3 `d` electrons to a `²D` symmetry.
"""
function intermediate_terms(orb::Union{<:Orbital,<:RelativisticOrbital}, w::Int=one(Int))
    g = degeneracy(orb)
    w > g÷2 && (w = g - w)
    ts = terms(orb, w)
    its = map(unique(ts)) do t
        its = IntermediateTerm{typeof(t),Seniority}[]
        previously_seen = 0

        # We have to loop in reverse, since odd occupation numbers
        # should go from 1 and even from 0.
        for ν ∈ reverse(w:-2:0)
            nn = count_terms(orb, ν, t) - previously_seen
            previously_seen += nn
            append!(its, repeat([IntermediateTerm(t, Seniority(ν))], nn))
        end
        its
    end
    sort(vcat(its...))
end

"""
    intermediate_terms(config)

Generate the intermediate terms for each subshell of `config`.

# Examples

```jldoctest
julia> intermediate_terms(c"1s 2p3")
2-element Array{Array{IntermediateTerm{Term,Seniority},1},1}:
 [₁²S]
 [₁²Pᵒ, ₃²Dᵒ, ₃⁴Sᵒ]

julia> intermediate_terms(rc"3d2 5g3")
2-element Array{Array{IntermediateTerm{HalfIntegers.Half{Int64},Seniority},1},1}:
 [₀0, ₂2, ₂4]
 [₁9/2, ₃3/2, ₃5/2, ₃7/2, ₃9/2, ₃11/2, ₃13/2, ₃15/2, ₃17/2, ₃21/2]
```
"""
function intermediate_terms(config::Configuration)
    map(config) do (orb,occupation,state)
        intermediate_terms(orb,occupation)
    end
end

assert_unique_classification(orb, occupation, it::IntermediateTerm) =
    assert_unique_classification(orb, occupation, it.term, it.ν)

export IntermediateTerm, intermediate_terms, Seniority
