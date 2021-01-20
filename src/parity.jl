"""
    struct Parity

Represents the parity of a quantum system, taking two possible values: `even` or `odd`.

The integer values that correspond to `even` and `odd` parity are `+1` and `-1`, respectively.
`Base.convert` can be used to convert integers into `Parity` values.

```jldoctest
julia> convert(Parity, 1)
even

julia> convert(Parity, -1)
odd
```
"""
struct Parity
    p::Bool
end

"""
    @p_str

A string macro to easily construct [`Parity`](@ref) values.

```jldoctest
julia> p"even"
even

julia> p"odd"
odd
```
"""
macro p_str(ps)
    if ps == "even"
        Parity(true)
    elseif ps == "odd"
        Parity(false)
    else
        throw(ArgumentError("Invalid parity string $(ps)"))
    end
end

function Base.convert(::Type{Parity}, i::I) where {I<:Integer}
    i == 1 && return p"even"
    i == -1 && return p"odd"
    throw(ArgumentError("Don't know how to convert $(i) to parity"))
end

Base.convert(::Type{I}, p::Parity) where {I<:Integer} = I(p.p ? 1 : -1)

Base.iseven(p::Parity) = p.p
Base.isodd(p::Parity) = !p.p
Base.isless(a::Parity, b::Parity) = isodd(a) && iseven(b)

Base.:*(a::Parity, b::Parity) = Parity(a == b)
Base.:^(p::Parity, i::I) where {I<:Integer} =
    p.p || iseven(i) ? Parity(true) : Parity(false)
Base.:-(p::Parity) = Parity(!p.p)

Base.show(io::IO, p::Parity) =
    write(io, iseven(p) ? "even" : "odd")

UnicodeFun.to_superscript(p::Parity) = iseven(p) ? "" : "ᵒ"

"""
    parity(object) -> Parity

Returns the parity of `object`.
"""
function parity end

export Parity, @p_str, parity
