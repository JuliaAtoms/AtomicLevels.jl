# * Intermediate terms, seniority
"""
    IntermediateTerm(term, seniority)

Represents a term together with its seniority quantum number.
"""
struct IntermediateTerm{T,S}
    term::T
    seniority::S # This could allow multiple seniority numbers for
                 # higher sub-shells.
    function IntermediateTerm(term::T, seniority::Int) where {T<:Union{Term,<:HalfInteger}}
        iseven(multiplicity(term)) ⊻ iseven(seniority) ||
            throw(ArgumentError("Invalid seniority $(seniority) for term $(term)"))
        new{T,Int}(term, seniority)
    end
    IntermediateTerm(term::Real, seniority) =
        IntermediateTerm(convert(HalfInt, term), seniority)
end

function Base.show(io::IO, iterm::IntermediateTerm)
    # This is the notation by Giulio Racah, p.377:
    # - Racah, G. (1943). Theory of complex spectra. III. Physical Review,
    #   63(9-10), 367–382. http://dx.doi.org/10.1103/physrev.63.367
    write(io, to_subscript(iterm.seniority))
    show(io, iterm.term)
end

Base.isless(a::IntermediateTerm, b::IntermediateTerm) =
    a.seniority < b.seniority ||
    a.seniority == b.seniority && a.term < b.term

"""
    intermediate_terms(orb::Orbital, w::Int=one(Int))

Generates all [`IntermediateTerm`](@ref) for a given non-relativstic
orbital `orb` and occupation `w`.

# Examples

```jldoctest
julia> intermediate_terms(o"2p", 2)
3-element Array{IntermediateTerm,1}:
 ₀¹S
 ₂¹D
 ₂³P
```

The preceding subscript is the seniority number, which indicates at
which occupancy a certain term is first seen, cf.

```jldoctest
julia> intermediate_terms(o"3d", 1)
1-element Array{IntermediateTerm,1}:
 ₁²D

julia> intermediate_terms(o"3d", 3)
8-element Array{IntermediateTerm,1}:
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
        its = IntermediateTerm{typeof(t),Int}[]
        previously_seen = 0
        # The seniority number is defined as the minimum occupancy
        # number ν ∈ n:-2:0 for which the term first appears, e.g. the
        # ²D term first occurs in the d¹ configuration, then twice in
        # the d³ configuration (which will then have the terms ₁²D and
        # ₃²D).
        #
        # We have to loop in reverse, since odd occupation numbers
        # should go from 1 and even from 0.
        for ν ∈ reverse(w:-2:0)
            nn = count_terms(orb, ν, t) - previously_seen
            previously_seen += nn
            append!(its, repeat([IntermediateTerm(t, ν)], nn))
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
2-element Array{Array{IntermediateTerm,1},1}:
 [₁²S]
 [₁²Pᵒ, ₃²Dᵒ, ₃⁴Sᵒ]

julia> intermediate_terms(rc"3d2 5g3")
2-element Array{Array{HalfIntegers.Half{Int64},1},1}:
 [0, 2, 4]
 [3/2, 5/2, 7/2, 9/2, 9/2, 11/2, 13/2, 15/2, 17/2, 21/2]
```
"""
function intermediate_terms(config::Configuration)
    map(config) do (orb,occ,state)
        intermediate_terms(orb,occ)
    end
end

export IntermediateTerm, intermediate_terms
