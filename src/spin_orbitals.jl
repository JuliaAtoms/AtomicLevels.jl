parse_projection(m::Number) = m
function parse_projection(m::AbstractString)
    n = tryparse(Float64, m)
    isnothing(n) || return n
    if m == "α"
        half(1)
    elseif m == "β"
        -half(1)
    elseif occursin('/', m)
        n,d = split(m, "/")
        parse(Int,n)//parse(Int,d)
    else
        throw(ArgumentError("Don't know how to parse projection quantum number $(m)"))
    end
end

"""
    struct SpinOrbital{O<:Orbital} <: AbstractOrbital

Spin orbitals are fully characterized orbitals, i.e. the projections
of all angular momenta are specified.
"""
struct SpinOrbital{O<:AbstractOrbital,M<:Tuple} <: AbstractOrbital
    orb::O
    m::M
    function SpinOrbital(orb::O, m::Tuple) where O
        O <: SpinOrbital &&
            throw(ArgumentError("Cannot create SpinOrbital from $O"))

        am = angular_momentum_ranges(orb)
        aml = angular_momentum_labels(orb)
        nam = length(am)
        nm = length(m)
        nm == nam ||
            throw(ArgumentError("$(nam) projection quantum numbers required, got $(nm)"))
        newm = ()
        for (mi,ar,l) in zip(m,am,aml)
            mm = parse_projection(mi)
            mm ∈ ar ||
                throw(ArgumentError("Projection $mi of quantum number $l not in valid set $ar"))
            newm = (newm..., convert(eltype(ar), mm))
        end

        new{O,typeof(newm)}(orb, newm)
    end
end
SpinOrbital(orb, m...) = SpinOrbital(orb, m)

Base.:(==)(a::SpinOrbital, b::SpinOrbital) =
    a.orb == b.orb && a.m == b.m

Base.hash(o::SpinOrbital, h::UInt) = hash(o.orb, hash(o.m, h))

function Base.show(io::IO, so::SpinOrbital)
    show(io, so.orb)
    projections = map(((l,m),) -> "m_$l = $m", zip(angular_momentum_labels(so.orb),so.m))
    write(io, "(", join(projections, ", "), ")")
end

function Base.show(io::IO, so::SpinOrbital{<:Orbital})
    show(io, so.orb)
    mℓ,ms = so.m
    write(io, to_subscript(mℓ))
    write(io, ms == half(1) ? "α" : "β")
end

function Base.show(io::IO, so::SpinOrbital{<:RelativisticOrbital})
    show(io, so.orb)
    write(io, "($(so.m[1]))")
end

degeneracy(::SpinOrbital) = 1

# We cannot order spin-orbitals of differing orbital types
Base.isless(a::SpinOrbital{O,M}, b::SpinOrbital{O,N}) where {O<:AbstractOrbital,M,N} = false

function Base.isless(a::SpinOrbital{<:O,M}, b::SpinOrbital{<:O,M}) where {O,M}
    a.orb < b.orb && return true
    a.orb > b.orb && return false

    for (ma,mb) in zip(a.m,b.m)
        ma < mb && return true
        ma > mb && return false
    end
    # All projections were equal
    return false
end

function Base.isless(a::SpinOrbital{<:Orbital}, b::SpinOrbital{<:Orbital})
    a.orb < b.orb && return true
    a.orb > b.orb && return false

    a.m[1] < b.m[1] ||
        a.m[1] == b.m[1] && a.m[2] > b.m[2] # We prefer α to appear before β
end

parity(so::SpinOrbital) = parity(so.orb)
symmetry(so::SpinOrbital) = (symmetry(so.orb), so.m...)

isbound(so::SpinOrbital) = isbound(so.orb)

Base.promote_type(::Type{SO}, ::Type{SO}) where {SO<:SpinOrbital} = SO

Base.promote_type(::Type{SpinOrbital{O}}, ::Type{SpinOrbital}) where O = SpinOrbital
Base.promote_type(::Type{SpinOrbital}, ::Type{SpinOrbital{O}}) where O = SpinOrbital

Base.promote_type(::Type{SpinOrbital{A,M}}, ::Type{SpinOrbital{B,M}}) where {A,B,M} =
    SpinOrbital{<:promote_type(A,B),M}

# ** Saving/loading

Base.write(io::IO, o::SpinOrbital{<:Orbital}) = write(io, 'n', o.orb, o.m[1], o.m[2].twice)
Base.write(io::IO, o::SpinOrbital{<:RelativisticOrbital}) = write(io, 'r', o.orb, o.m[1].twice)

function Base.read(io::IO, ::Type{SpinOrbital})
    kind = read(io, Char)
    if kind == 'n'
        orb = read(io, Orbital)
        mℓ = read(io, Int)
        ms = half(read(io, Int))
        SpinOrbital(orb, (mℓ, ms))
    elseif kind == 'r'
        orb = read(io, RelativisticOrbital)
        mj = half(read(io, Int))
        SpinOrbital(orb, mj)
    else
        error("Unknown SpinOrbital type $(kind)")
    end
end

# * Orbital construction from strings

function Base.parse(::Type{O}, orb_str) where {OO<:AbstractOrbital,O<:SpinOrbital{OO}}
    m = match(r"^(.*)\((.*)\)$", orb_str)
    # For non-relativistic spin-orbitals, we also support specifying
    # the m_ℓ quantum number using Unicode subscripts and the spin
    # label using α/β
    m2 = match(r"^(.*?)([₋]{0,1}[₁₂₃₄₅₆₇₈₉₀]+)([αβ])$", orb_str)
    if !isnothing(m)
        o = parse(OO, m[1])
        SpinOrbital(o, (split(m[2], ",")...,))
    elseif !isnothing(m2) && OO <: Orbital
        o = parse(OO, m2[1])
        SpinOrbital(o, from_subscript(m2[2]), m2[3])
    else
        throw(ArgumentError("Invalid spin-orbital string: $(orb_str)"))
    end
end

"""
    @so_str -> SpinOrbital{<:Orbital}

String macro to quickly construct a non-relativistic spin-orbital; it
is similar to [`@o_str`](@ref), with the added specification of
the magnetic quantum numbers ``m_ℓ`` and ``m_s``.

# Examples

```jldoctest
julia> so"1s(0,α)"
1s₀α

julia> so"kd(2,β)"
kd₂β

julia> so"2p(1,0.5)"
2p₁α

julia> so"2p(1,-1/2)"
2p₁β
```
"""
macro so_str(orb_str)
    parse(SpinOrbital{Orbital}, orb_str)
end

"""
    @rso_str -> SpinOrbital{<:RelativisticOrbital}

String macro to quickly construct a relativistic spin-orbital; it
is similar to [`@o_str`](@ref), with the added specification of
the magnetic quantum number ``m_j``.

# Examples

```jldoctest
julia> rso"2p-(1/2)"
2p-(1/2)

julia> rso"2p(-3/2)"
2p(-3/2)

julia> rso"3d(2.5)"
3d(5/2)
```
"""
macro rso_str(orb_str)
    parse(SpinOrbital{RelativisticOrbital}, orb_str)
end

"""
    spin_orbitals(orbital)

Generate all permissible spin-orbitals for a given `orbital`, e.g. 2p
-> 2p ⊗ mℓ = {-1,0,1} ⊗ ms = {α,β}

# Examples

```jldoctest
julia> spin_orbitals(o"2p")
6-element Vector{SpinOrbital{Orbital{Int64}, Tuple{Int64, HalfIntegers.Half{Int64}}}}:
 2p₋₁α
 2p₋₁β
 2p₀α
 2p₀β
 2p₁α
 2p₁β

julia> spin_orbitals(ro"2p-")
2-element Vector{SpinOrbital{RelativisticOrbital{Int64}, Tuple{HalfIntegers.Half{Int64}}}}:
 2p-(-1/2)
 2p-(1/2)

julia> spin_orbitals(ro"2p")
4-element Vector{SpinOrbital{RelativisticOrbital{Int64}, Tuple{HalfIntegers.Half{Int64}}}}:
 2p(-3/2)
 2p(-1/2)
 2p(1/2)
 2p(3/2)
```

"""
function spin_orbitals(orb::O) where {O<:AbstractOrbital}
    map(reduce(vcat, Iterators.product(angular_momentum_ranges(orb)...))) do m
        SpinOrbital(orb, m...)
    end |> sort
end

"""
    @sos_str -> Vector{<:SpinOrbital{<:Orbital}}

Can be used to easily construct a list of [`SpinOrbital`](@ref)s.

# Examples

```jldoctest
julia> sos"3[s-p]"
8-element Vector{SpinOrbital{Orbital{Int64}, Tuple{Int64, HalfIntegers.Half{Int64}}}}:
 3s₀α
 3s₀β
 3p₋₁α
 3p₋₁β
 3p₀α
 3p₀β
 3p₁α
 3p₁β
```
"""
macro sos_str(orbs_str)
    reduce(vcat, map(spin_orbitals, orbitals_from_string(Orbital, orbs_str)))
end

"""
    @rsos_str -> Vector{<:SpinOrbital{<:RelativisticOrbital}}

Can be used to easily construct a list of [`SpinOrbital`](@ref)s.

# Examples

```jldoctest
julia> rsos"3[s-p]"
8-element Vector{SpinOrbital{RelativisticOrbital{Int64}, Tuple{HalfIntegers.Half{Int64}}}}:
 3s(-1/2)
 3s(1/2)
 3p-(-1/2)
 3p-(1/2)
 3p(-3/2)
 3p(-1/2)
 3p(1/2)
 3p(3/2)
```
"""
macro rsos_str(orbs_str)
    reduce(vcat, map(spin_orbitals, orbitals_from_string(RelativisticOrbital, orbs_str)))
end

export SpinOrbital, spin_orbitals, @so_str, @rso_str, @sos_str, @rsos_str
