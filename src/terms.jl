# * Term symbols

"""
    struct Term

Represents a term symbol with specific parity in LS-coupling.

Only the ``L``, ``S`` and parity values of the symbol ``{}^{2S+1}L_{J}`` are specified. To
specify a _level_, the ``J`` value would have to be specified separately. The valid ``J``
values corresponding to given ``L`` and ``S`` fall in the following range:

```math
|L - S| \\leq J \\leq L+S
```

# Constructors

    Term(L::Real, S::Real, parity::Union{Parity,Integer})

Constructs a `Term` object with the given ``L`` and ``S`` quantum numbers and parity. `L`
and `S` both have to be convertible to `HalfInteger`s and `parity` must be of type
[`Parity`](@ref) or `±1`.

See also: [`@T_str`](@ref)

# Properties

To access the quantum number values, you can use the `.L`, `.S` and `.parity` properties to
access the ``L``, ``S`` and parity values (represented with [`Parity`](@ref)), respectively.
E.g.:

```jldoctest
julia> t = Term(2, 1//2, p"odd")
²Dᵒ

julia> t.L, t.S, t.parity
(2, 1/2, odd)
```
"""
struct Term
    L::HalfInt
    S::HalfInt
    parity::Parity
    function Term(L::HalfInteger, S::HalfInteger, parity::Parity)
        L >= 0 || throw(DomainError(L, "Term symbol can not have negative L"))
        S >= 0 || throw(DomainError(S, "Term symbol can not have negative S"))
        new(L, S, parity)
    end
end
Term(L::Real, S::Real, parity::Union{Parity,Integer}) =
    Term(convert(HalfInteger, L), convert(HalfInteger, S), convert(Parity, parity))

"""
    parse(::Type{Term}, ::AbstractString) -> Term

Parses a string into a [`Term`](@ref) object.

```jldoctest
julia> parse(Term, "4Po")
⁴Pᵒ
```

See also: [`@T_str`](@ref)
"""
function Base.parse(::Type{Term}, s::AbstractString)
    m = match(r"([0-9]+)([A-Z]|\[[0-9/]+\])([oe ]{0,1})", s)
    isnothing(m) && throw(ArgumentError("Invalid term string $s"))
    L = lowercase(m[2])
    L = if L[1] == '['
        L = strip(L, ['[',']'])
        if occursin("/", L)
            Ls = split(L, "/")
            length(Ls) == 2 && length(Ls[1]) > 0 && length(Ls[2]) > 0 ||
                throw(ArgumentError("Invalid term string $(s)"))
            Rational(parse(Int, Ls[1]),parse(Int, Ls[2]))
        else
            parse(Int, L)
        end
    else
        findfirst(L, spectroscopic)[1]-1
    end
    denominator(L) ∈ [1,2] || throw(ArgumentError("L must be integer or half-integer"))
    S = (parse(Int, m[1]) - 1)//2
    Term(L, S, m[3] == "o" ? p"odd" : p"even")
end

"""
    @T_str -> Term

Constructs a [`Term`](@ref) object out of its canonical string representation.

```jldoctest
julia> T"1S"
¹S

julia> T"4Po"
⁴Pᵒ

julia> T"2[3/2]o" # jK coupling, common in noble gases
²[3/2]ᵒ
```
"""
macro T_str(s::AbstractString)
    :(parse(Term, $s))
end

Base.zero(::Type{Term}) = T"1S"

multiplicity(t::Term) = convert(Int, 2t.S + 1)
weight(t::Term) = (2t.L + 1) * multiplicity(t)

import Base.==
==(t1::Term, t2::Term) = ((t1.L == t2.L) && (t1.S == t2.S) && (t1.parity == t2.parity))

import Base.<
<(t1::Term, t2::Term) = ((t1.S < t2.S) || (t1.S == t2.S) && (t1.L < t2.L)
                         || (t1.S == t2.S) && (t1.L == t2.L) && (t1.parity < t2.parity))
import Base.isless
isless(t1::Term, t2::Term) = (t1 < t2)

Base.hash(t::Term) = hash((t.L,t.S,t.parity))

include("xu2006.jl")

"""
    xu_terms(ℓ, w, p)

Return all term symbols for the orbital `ℓʷ` and parity `p`; the term
multiplicity is computed using [`AtomicLevels.Xu.X`](@ref).

# Examples

```jldoctest
julia> AtomicLevels.xu_terms(3, 3, parity(c"3d3"))
17-element Array{Term,1}:
 ²P
 ²D
 ²D
 ²F
 ²F
 ²G
 ²G
 ²H
 ²H
 ²I
 ²K
 ²L
 ⁴S
 ⁴D
 ⁴F
 ⁴G
 ⁴I
```
"""
function xu_terms(ℓ::Int, w::Int, p::Parity)
    ts = map(((w//2 - floor(Int, w//2)):w//2)) do S
        S′ = 2S |> Int
        map(L -> repeat([Term(L,S,p)], Xu.X(w, ℓ, S′, L)), 0:w*ℓ)
    end
    vcat(vcat(ts...)...)
end

"""
    terms(orb::Orbital, w::Int=one(Int))

Returns a list of valid LS term symbols for the orbital `orb` with `w`
occupancy.

# Examples

```jldoctest
julia> terms(o"3d", 3)
8-element Array{Term,1}:
 ²P
 ²D
 ²D
 ²F
 ²G
 ²H
 ⁴P
 ⁴F
```
"""
function terms(orb::Orbital, w::Int=one(Int))
    ℓ = orb.ℓ
    g = degeneracy(orb)
    w > g && throw(DomainError(w, "Invalid occupancy $w for $orb with degeneracy $g"))
    # For shells that are more than half-filled, we instead consider
    # the equivalent problem of g-w coupled holes.
    (w > g/2 && w != g) && (w = g - w)

    p = parity(orb)^w
    if w == 1
        [Term(ℓ,1//2,p)] # Single electron
    elseif ℓ == 0 && w == 2 || w == degeneracy(orb) || w == 0
        [Term(0,0,p"even")] # Filled ℓ shell
    else
        xu_terms(ℓ, w, p) # All other cases
    end
end

"""
    terms(config)

Generate all final ``LS`` terms for `config`.

# Examples

```jldoctest
julia> terms(c"1s")
1-element Array{Term,1}:
 ²S

julia> terms(c"1s 2p")
2-element Array{Term,1}:
 ¹Pᵒ
 ³Pᵒ

julia> terms(c"[Ne] 3d3")
7-element Array{Term,1}:
 ²P
 ²D
 ²F
 ²G
 ²H
 ⁴P
 ⁴F
```
"""
function terms(config::Configuration{O}) where {O<:AbstractOrbital}
    ts = map(config) do (orb,occ,state)
        terms(orb,occ)
    end

    final_terms(ts)
end

"""
    count_terms(orbital, occupation, term)

Count how many times `term` occurs among the valid terms of `orbital^occupation`.

```jldoctest
julia> count_terms(o"1s", 2, T"1S")
1

julia> count_terms(ro"6h", 4, 8)
4
```
"""
function count_terms end

function count_terms(orb::Orbital, occ::Int, term::Term)
    ℓ = orb.ℓ
    g = degeneracy(orb)
    occ > g && throw(ArgumentError("Invalid occupancy $occ for $orb with degeneracy $g"))
    (occ > g/2 && occ != g) && (occ = g - occ)

    p = parity(orb)^occ
    if occ == 1
        term == Term(ℓ,1//2,p) ? 1 : 0
    elseif ℓ == 0 && occ == 2 || occ == degeneracy(orb) || occ == 0
        term == Term(0,0,p"even") ? 1 : 0
    else
        S′ = convert(Int, 2term.S)
        Xu.X(occ, orb.ℓ, S′, convert(Int, term.L))
    end
end

function write_L(io::IO, term::Term)
    if isinteger(term.L)
        write(io, uppercase(spectroscopic_label(convert(Int, term.L))))
    else
        write(io, "[$(numerator(term.L))/$(denominator(term.L))]")
    end
end

function Base.show(io::IO, term::Term)
    write(io, to_superscript(multiplicity(term)))
    write_L(io, term)
    write(io, to_superscript(term.parity))
end

export Term, @T_str, multiplicity, weight, terms, count_terms
