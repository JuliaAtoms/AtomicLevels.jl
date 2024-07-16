"""
    abstract type AbstractOrbital

Abstract supertype of all orbital types.

!!! note "Broadcasting"

    When broadcasting, orbital objects behave like scalars.
"""
abstract type AbstractOrbital end
Base.Broadcast.broadcastable(x::AbstractOrbital) = Ref(x)

"""
    const MQ = Union{Int,Symbol}

Defines the possible types that may represent the main quantum number. It can either be an
non-negative integer or a `Symbol` value (generally used to label continuum electrons).
"""
const MQ = Union{Int,Symbol}

nisless(an::T, bn::T) where T = an < bn
# Our convention is that symbolic main quantum numbers are always
# greater than numeric ones, such that ks appears after 2p, etc.
nisless(an::I, bn::Symbol) where {I<:Integer} = true
nisless(an::Symbol, bn::I) where {I<:Integer} = false

function Base.ascii(o::AbstractOrbital)
    io = IOBuffer()
    ctx = IOContext(io, :ascii=>true)
    show(ctx, o)
    String(take!(io))
end

# * Non-relativistic orbital

"""
    struct Orbital{N <: AtomicLevels.MQ} <: AbstractOrbital

Label for an atomic orbital with a principal quantum number `n::N` and orbital angular
momentum `ℓ`.

The type parameter `N` has to be such that it can represent a proper principal quantum number
(i.e. a subtype of [`AtomicLevels.MQ`](@ref)).

# Properties

The following properties are part of the public API:

* `.n :: N` -- principal quantum number ``n``
* `.ℓ :: Int` -- the orbital angular momentum ``\\ell``

# Constructors

    Orbital(n::Int, ℓ::Int)
    Orbital(n::Symbol, ℓ::Int)

Construct an orbital label with principal quantum number `n` and orbital angular momentum `ℓ`.
If the principal quantum number `n` is an integer, it has to positive and the angular momentum
must satisfy `0 <= ℓ < n`.

```jldoctest
julia> Orbital(1, 0)
1s

julia> Orbital(:K, 2)
Kd
```
"""
struct Orbital{N<:MQ} <: AbstractOrbital
    n::N
    ℓ::Int
    function Orbital(n::Int, ℓ::Int)
        n ≥ 1 || throw(ArgumentError("Invalid principal quantum number $(n)"))
        0 ≤ ℓ && ℓ < n || throw(ArgumentError("Angular quantum number has to be ∈ [0,$(n-1)] when n = $(n)"))
        new{Int}(n, ℓ)
    end
    function Orbital(n::Symbol, ℓ::Int)
        new{Symbol}(n, ℓ)
    end
end

Orbital{N}(n::N, ℓ::Int) where {N<:MQ} = Orbital(n, ℓ)

Base.:(==)(a::Orbital, b::Orbital) =
    a.n == b.n && a.ℓ == b.ℓ

Base.hash(o::Orbital, h::UInt) = hash(o.n, hash(o.ℓ, h))

"""
    mqtype(::Orbital{MQ}) = MQ

Returns the main quantum number type of an [`Orbital`](@ref).
"""
mqtype(::Orbital{MQ}) where MQ = MQ

Base.show(io::IO, orb::Orbital{N}) where N =
    write(io, "$(orb.n)$(spectroscopic_label(orb.ℓ))")

"""
    degeneracy(orbital::Orbital)

Returns the degeneracy of `orbital` which is `2(2ℓ+1)`

# Examples

```jldoctest
julia> degeneracy(o"1s")
2

julia> degeneracy(o"2p")
6
```
"""
degeneracy(orb::Orbital) = 2*(2orb.ℓ + 1)

"""
    isless(a::Orbital, b::Orbital)

Compares the orbitals `a` and `b` to decide which one comes before the
other in a configuration.

# Examples

```jldoctest
julia> o"1s" < o"2s"
true

julia> o"1s" < o"2p"
true

julia> o"ks" < o"2p"
false
```
"""
function Base.isless(a::Orbital, b::Orbital)
    nisless(a.n, b.n) && return true
    a.n == b.n && a.ℓ < b.ℓ && return true
    false
end

"""
    parity(orbital::Orbital)

Returns the parity of `orbital`, defined as `(-1)^ℓ`.

# Examples

```jldoctest
julia> parity(o"1s")
even

julia> parity(o"2p")
odd
```

"""
parity(orb::Orbital) = p"odd"^orb.ℓ

"""
    symmetry(orbital::Orbital)

Returns the symmetry for `orbital` which is simply `ℓ`.
"""
symmetry(orb::Orbital) = orb.ℓ

"""
    isbound(::Orbital)

Returns `true` is the main quantum number is an integer, `false`
otherwise.

```jldoctest
julia> isbound(o"1s")
true

julia> isbound(o"ks")
false
```
"""
function isbound end
isbound(::Orbital{Int}) = true
isbound(::Orbital{Symbol}) = false

"""
    angular_momenta(orbital)

Returns the angular momentum quantum numbers of `orbital`.

# Examples
```jldoctest
julia> angular_momenta(o"2s")
(0, 1/2)

julia> angular_momenta(o"3d")
(2, 1/2)
```
"""
angular_momenta(orbital::Orbital) = (orbital.ℓ,half(1))
angular_momentum_labels(::Orbital) = ("ℓ","s")

"""
    angular_momentum_ranges(orbital)

Return the valid ranges within which projections of each of the
angular momentum quantum numbers of `orbital` must fall.

# Examples
```jldoctest
julia> angular_momentum_ranges(o"2s")
(0:0, -1/2:1/2)

julia> angular_momentum_ranges(o"4f")
(-3:3, -1/2:1/2)
```
"""
angular_momentum_ranges(orbital::AbstractOrbital) =
    map(j -> -j:j, angular_momenta(orbital))

# ** Saving/loading

Base.write(io::IO, o::Orbital{Int}) = write(io, 'i', o.n, o.ℓ)
Base.write(io::IO, o::Orbital{Symbol}) = write(io, 's', sizeof(o.n), o.n, o.ℓ)

function Base.read(io::IO, ::Type{Orbital})
    kind = read(io, Char)
    n = if kind == 'i'
        read(io, Int)
    elseif kind == 's'
        b = Vector{UInt8}(undef, read(io, Int))
        readbytes!(io, b)
        Symbol(b)
    else
        error("Unknown Orbital type $(kind)")
    end
    ℓ = read(io, Int)
    Orbital(n, ℓ)
end

# * Orbital construction from strings

parse_orbital_n(m::RegexMatch,i=1) =
    isnumeric(m[i][1]) ? parse(Int, m[i]) : Symbol(m[i])

function parse_orbital_ℓ(m::RegexMatch,i=2)
    ℓs = strip(m[i], ['[',']'])
    if isnumeric(ℓs[1])
        parse(Int, ℓs)
    else
        ℓi = findfirst(ℓs, spectroscopic)
        isnothing(ℓi) && throw(ArgumentError("Invalid spectroscopic label: $(m[i])"))
        first(ℓi) - 1
    end
end

function Base.parse(::Type{<:Orbital}, orb_str)
    m = match(r"^([0-9]+|.|\[.+\])([a-z]|\[[0-9]+\])$", orb_str)
    isnothing(m) && throw(ArgumentError("Invalid orbital string: $(orb_str)"))
    n = parse_orbital_n(m)
    ℓ = parse_orbital_ℓ(m)
    Orbital(n, ℓ)
end

"""
    @o_str -> Orbital

A string macro to construct an [`Orbital`](@ref) from the canonical string representation.

```jldoctest
julia> o"1s"
1s

julia> o"Fd"
Fd
```
"""
macro o_str(orb_str)
    parse(Orbital, orb_str)
end

function orbitals_from_string(::Type{O}, orbs_str::AbstractString) where {O<:AbstractOrbital}
    map(split(orbs_str)) do orb_str
        m = match(r"^([0-9]+|.)\[([a-z]|[0-9]+)(-([a-z]|[0-9]+)){0,1}\]$", strip(orb_str))
        m === nothing && throw(ArgumentError("Invalid orbitals string: $(orb_str)"))
        n = parse_orbital_n(m)
        ℓs = map(filter(i -> !isnothing(m[i]), [2,4])) do i
            parse_orbital_ℓ(m, i)
        end
        orbs = if O == RelativisticOrbital
            orbs = map(ℓ -> O(n, ℓ, ℓ-1//2), max(first(ℓs),1):last(ℓs))
            append!(orbs, map(ℓ -> O(n, ℓ, ℓ+1//2), first(ℓs):last(ℓs)))
        else
            map(ℓ -> O(n, ℓ), first(ℓs):last(ℓs))
        end
        sort(orbs)
    end |> o -> vcat(o...) |> sort
end

"""
    @os_str -> Vector{Orbital}

Can be used to easily construct a list of [`Orbital`](@ref)s.

# Examples

```jldoctest
julia> os"5[d] 6[s-p] k[7-10]"
7-element Vector{Orbital}:
 5d
 6s
 6p
 kk
 kl
 km
 kn
```
"""
macro os_str(orbs_str)
    orbitals_from_string(Orbital, orbs_str)
end

export AbstractOrbital, Orbital,
    @o_str, @os_str,
    degeneracy, symmetry, isbound, angular_momenta, angular_momentum_ranges
