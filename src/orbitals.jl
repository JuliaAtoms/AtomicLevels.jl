abstract type AbstractOrbital end

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

# * Non-relativistic orbital

"""
    struct Orbital{N <: AtomicLevels.MQ} <: AbstractOrbital

Label for an atomic orbital with a principal quantum number `n::N` and orbital angular
momentum `ℓ`.

The type parameter `N` has to be such that it can represent a proper principal quantum number
(i.e. a subtype of [`AtomicLevels.MQ`](@ref)).

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
    mℓrange(orbital::Orbital)

Returns the range of valid values of `mℓ` for `orbital`.

# Examples

```jldoctest
julia> mℓrange(o"2p")
-1:1
```
"""
mℓrange(orb::Orbital) = (-orb.ℓ:orb.ℓ)

"""
    struct SpinOrbital{O<:Orbital} <: AbstractOrbital

Spin orbitals are fully characterized orbitals, i.e. the quantum numbers `n`, `ℓ`, `mℓ` and
`ms` are all specified.
"""
struct SpinOrbital{O<:Orbital} <: AbstractOrbital
    orb::O
    mℓ::Int
    spin::Bool
    function SpinOrbital(orb::O, mℓ::Int, spin::Bool) where {O<:Orbital}
        abs(mℓ) ≤ orb.ℓ ||
            throw(ArgumentError("Magnetic quantum number not in valid range -$(orb.ℓ)..$(orb.ℓ)"))
        new{O}(orb, mℓ, spin)
    end
end
function Base.show(io::IO, so::SpinOrbital)
    show(io, so.orb)
    write(io, to_subscript(so.mℓ))
    write(io, so.spin ? "α" : "β")
end

degeneracy(::SpinOrbital) = 1

Base.isless(a::SpinOrbital, b::SpinOrbital) =
    a.orb < b.orb ||
    a.orb == b.orb && a.mℓ < b.mℓ ||
    a.orb == b.orb && a.mℓ == b.mℓ && a.spin > b.spin # We prefer α < β

parity(so::SpinOrbital) = parity(so.orb)
symmetry(so::SpinOrbital) = (symmetry(so.orb), so.mℓ, so.spin)

isbound(so::SpinOrbital) = isbound(so.orb)

Base.promote_type(::Type{SpinOrbital{O}}, ::Type{SpinOrbital}) where O = SpinOrbital
Base.promote_type(::Type{SpinOrbital}, ::Type{SpinOrbital{O}}) where O = SpinOrbital
Base.promote_type(::Type{SpinOrbital{Orbital{I}}}, ::Type{SpinOrbital{Orbital{Symbol}}}) where {I<:Integer} = SpinOrbital
Base.promote_type(::Type{SpinOrbital{Orbital{Symbol}}}, ::Type{SpinOrbital{Orbital{I}}}) where {I<:Integer} = SpinOrbital

"""
    spin_orbitals(orbital)

Generate all permissible spin-orbitals for a given `orbital`, e.g. 2p
-> 2p ⊗ mℓ = {-1,0,1} ⊗ s = {α,β}

# Examples

```jldoctest
julia> spin_orbitals(o"2p")
6-element Array{SpinOrbital{Orbital{Int64}},1}:
 2p₋₁α
 2p₋₁β
 2p₀α
 2p₀β
 2p₁α
 2p₁β
```

"""
function spin_orbitals(orb::O) where {O<:Orbital}
    map([true,false]) do spin
        map(mℓrange(orb)) do mℓ
            SpinOrbital(orb, mℓ, spin)
        end
    end |> so -> vcat(so...) |> sort
end

# * Relativistic orbital

"""
    kappa_to_ℓ(κ::Integer) :: Integer

Calculate the `ℓ` quantum number corresponding to the `κ` quantum number.

Note: `κ` and `ℓ` values are always integers.
"""
function kappa_to_ℓ(kappa::Integer)
    kappa == zero(kappa) && throw(ArgumentError("κ can not be zero"))
    (kappa < 0) ? -(kappa+1) : kappa
end

"""
    kappa_to_j(κ::Integer) :: HalfInteger

Calculate the `j` quantum number corresponding to the `κ` quantum number.

Note: `κ` is always an integer.
"""
function kappa_to_j(kappa::Integer)
    kappa == zero(kappa) && throw(ArgumentError("κ can not be zero"))
    HalfInteger(2*abs(kappa) - 1, 2)
end

"""
    ℓj_to_kappa(ℓ::Integer, j::Real) :: Integer

Converts a valid `(ℓ, j)` pair to the corresponding `κ` value.

**Note:** there is a one-to-one correspondence between valid `(ℓ,j)` pairs and `κ` values
such that for `j = ℓ ± 1/2`, `κ = ∓(j + 1/2)`.
"""
function ℓj_to_kappa(ℓ::Integer, j::Real)
    assert_orbital_ℓj(ℓ, j)
    (j < ℓ) ? ℓ : -(ℓ + 1)
end

function assert_orbital_ℓj(ℓ::Integer, j::Real)
    j = HalfInteger(j)
    s = hi"1/2"
    (ℓ == j + s) || (ℓ == j - s) ||
        throw(ArgumentError("Invalid (ℓ, j) = $(ℓ), $(j) pair, expected j = ℓ ± 1/2."))
    return
end

"""
    struct RelativisticOrbital{N <: AtomicLevels.MQ} <: AbstractOrbital

Label for an atomic orbital with a principal quantum number `n::N` and well-defined total
angular momentum ``j``. The angular component of the orbital is labelled by the ``(\\ell, j)``
pair, conventionally written as ``\\ell_j`` (e.g. ``p_{3/2}``).

The ``\\ell`` and ``j`` can not be arbitrary, but must satisfy ``j = \\ell \\pm 1/2``.
Internally, the ``\\kappa`` quantum number, which is a unique integer corresponding to every
physical ``(\\ell, j)`` pair, is used to label each allowed pair.
When ``j = \\ell \\pm 1/2``, the corresponding ``\\kappa = \\mp(j + 1/2)``.

When printing and parsing `RelativisticOrbital`s, the notation `nℓ` and `nℓ-` is used (e.g.
`2p` and `2p-`), corresponding to the orbitals with ``j = \\ell + 1/2`` and
``j = \\ell - 1/2``, respectively.

The type parameter `N` has to be such that it can represent a proper principal quantum number
(i.e. a subtype of [`AtomicLevels.MQ`](@ref)).

# Constructors

    RelativisticOrbital(n::Integer, κ::Integer)
    RelativisticOrbital(n::Symbol, κ::Integer)
    RelativisticOrbital(n, ℓ::Integer, j::Real)

Construct an orbital label with the quantum numbers `n` and `κ`.
If the principal quantum number `n` is an integer, it has to positive and the orbital angular
momentum must satisfy `0 <= ℓ < n`.
Instead of `κ`, valid `ℓ` and `j` values can also be specified instead.

```jldoctest
julia> RelativisticOrbital(1, 0, 1//2)
1s

julia> RelativisticOrbital(2, -1)
2s

julia> RelativisticOrbital(:K, 2, 3//2)
Kd⁻
```
"""
struct RelativisticOrbital{N<:MQ} <: AbstractOrbital
    n::N
    κ::Int
    function RelativisticOrbital(n::Integer, κ::Integer)
        n ≥ 1 || throw(ArgumentError("Invalid principal quantum number $(n)"))
        κ == zero(κ) && throw(ArgumentError("κ can not be zero"))
        ℓ = kappa_to_ℓ(κ)
        0 ≤ ℓ && ℓ < n || throw(ArgumentError("Angular quantum number has to be ∈ [0,$(n-1)] when n = $(n)"))
        new{Int}(n, κ)
    end
    function RelativisticOrbital(n::Symbol, κ::Integer)
        κ == zero(κ) && throw(ArgumentError("κ can not be zero"))
        new{Symbol}(n, κ)
    end
end
RelativisticOrbital(n::MQ, ℓ::Integer, j::Real) = RelativisticOrbital(n, ℓj_to_kappa(ℓ, j))


function Base.show(io::IO, orb::RelativisticOrbital)
    write(io, "$(orb.n)$(spectroscopic_label(kappa_to_ℓ(orb.κ)))")
    orb.κ > 0 && write(io, "⁻")
end

function flip_j(orb::RelativisticOrbital)
    orb.κ == -1 && return RelativisticOrbital(orb.n, -1) # nothing to flip for s-orbitals
    RelativisticOrbital(orb.n, orb.κ < 0 ? abs(orb.κ) - 1 : -(orb.κ + 1))
end

degeneracy(orb::RelativisticOrbital{N}) where N = 2*abs(orb.κ) # 2j + 1 = 2|κ|

function Base.isless(a::RelativisticOrbital, b::RelativisticOrbital)
    nisless(a.n, b.n) && return true
    aℓ, bℓ = kappa_to_ℓ(a.κ), kappa_to_ℓ(b.κ)
    a.n == b.n && aℓ < bℓ && return true
    a.n == b.n && aℓ == bℓ && abs(a.κ) < abs(b.κ) && return true
    false
end

parity(orb::RelativisticOrbital) = p"odd"^kappa_to_ℓ(orb.κ)
symmetry(orb::RelativisticOrbital) = orb.κ

isbound(::RelativisticOrbital{Int}) = true
isbound(::RelativisticOrbital{Symbol}) = false

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

function orbital_from_string(::Type{O}, orb_str::AbstractString) where {O<:AbstractOrbital}
    m = match(r"^([0-9]+|.)([a-z]|\[[0-9]+\])([-]{0,1})$", orb_str)
    m === nothing && throw(ArgumentError("Invalid orbital string: $(orb_str)"))
    n = parse_orbital_n(m)
    ℓ = parse_orbital_ℓ(m)
    if O == RelativisticOrbital
        j = ℓ + (m[3] == "-" ? -1 : 1)*1//2
        O(n, ℓ, j)
    else
        m[3] == "" || throw(ArgumentError("Non-relativistic orbitals cannot have their spins explicitly specified"))
        O(n, ℓ)
    end
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
    orbital_from_string(Orbital, orb_str)
end

"""
    @ro_str -> RelativisticOrbital

A string macro to construct an [`RelativisticOrbital`](@ref) from the canonical string
representation.

```jldoctest
julia> ro"1s"
1s

julia> ro"2p-"
2p⁻

julia> ro"Kf-"
Kf⁻
```
"""
macro ro_str(orb_str)
    orbital_from_string(RelativisticOrbital, orb_str)
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

```jldoctest
julia> os"5[d] 6[s-p] k[7-10]"
7-element Array{Orbital,1}:
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

"""
    @ros_str -> Vector{RelativisticOrbital}

Can be used to easily construct a list of [`RelativisticOrbital`](@ref)s.

```jldoctest
julia> ros"2[s-p] 3[p] k[0-d]"
10-element Array{RelativisticOrbital,1}:
 2s
 2p⁻
 2p
 3p⁻
 3p
 ks
 kp⁻
 kp
 kd⁻
 kd
```
"""
macro ros_str(orbs_str)
    orbitals_from_string(RelativisticOrbital, orbs_str)
end

function kappa_from_string(κ_str)
    m = match(r"^([a-z]|\[[0-9]+\])([-]{0,1})$", κ_str)
    m === nothing && throw(ArgumentError("Invalid κ string: $(κ_str)"))
    ℓ = parse_orbital_ℓ(m, 1)
    j = ℓ + (m[2] == "-" ? -1 : 1)//2
    ℓj_to_kappa(ℓ, j)
end

"""
    @κ_str -> Int

A string macro to convert the canonical string representation of a ``\\ell_j`` angular label
(i.e. `ℓ-` or `ℓ`) into the corresponding ``\\kappa`` quantum number.

```jldoctest
julia> κ"s", κ"p-", κ"p"
(-1, 1, -2)
```
"""
macro κ_str(κ_str)
    kappa_from_string(κ_str)
end

export Orbital, SpinOrbital, RelativisticOrbital, @o_str, @ro_str, @os_str, @ros_str, degeneracy, symmetry, isbound, mℓrange, spin_orbitals, @κ_str
