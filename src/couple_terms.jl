"""
    couple_terms(t1, t2)

Generate all possible coupling terms between `t1` and `t2`.  It is
assumed that t1 and t2 originate from non-equivalent electrons, since
the vector model does not predict correct term couplings for
equivalent electrons; some of the generated terms would violate the
Pauli principle; cf. Cowan p. 108–109.

# Examples

```jldoctest
julia> couple_terms(T"1Po", T"2Se")
1-element Array{Term,1}:
 ²Pᵒ

julia> couple_terms(T"3Po", T"2Se")
2-element Array{Term,1}:
 ²Pᵒ
 ⁴Pᵒ

julia> couple_terms(T"3Po", T"2De")
6-element Array{Term,1}:
 ²Pᵒ
 ²Dᵒ
 ²Fᵒ
 ⁴Pᵒ
 ⁴Dᵒ
 ⁴Fᵒ
```
"""
function couple_terms(t1::Term, t2::Term)
    L1 = t1.L
    L2 = t2.L
    S1 = t1.S
    S2 = t2.S
    p = t1.parity * t2.parity
    sort(vcat([[Term(L, S, p) for S in abs(S1-S2):(S1+S2)]
               for L in abs(L1-L2):(L1+L2)]...))
end

"""
    couple_terms(t1s, t2s)

Generate all coupling between all terms in `t1s` and all terms in
`t2s`.
"""
function couple_terms(t1s::Vector{<:Term}, t2s::Vector{<:Term})
    ts = map(t1s) do t1
        map(t2s) do t2
            couple_terms(t1, t2)
        end
    end
    sort(unique(vcat(vcat(ts...)...)))
end

"""
    final_terms(ts::Vector{<:Vector{<:Union{Term,Real}}})

Generate all possible final terms from the vector of vectors of
individual subshell terms by coupling from left to right.

# Examples

```jldoctest
julia> ts = [[T"1S", T"3S"], [T"2P", T"2D"]]
2-element Array{Array{Term,1},1}:
 [¹S, ³S]
 [²P, ²D]

julia> AtomicLevels.final_terms(ts)
4-element Array{Term,1}:
 ²P
 ²D
 ⁴P
 ⁴D
```
"""
final_terms(ts::Vector{<:Vector{<:T}}) where {T<:Union{Term,Real}} =
    foldl(couple_terms, ts)


couple_terms(J1::T, J2::T) where {T <: Union{Integer,HalfInteger}} =
    collect(abs(J1-J2):(J1+J2))
couple_terms(J1::Real, J2::Real) =
    couple_terms(convert(HalfInteger, J1), convert(HalfInteger, J2))

term_type(::Type{IntermediateTerm}) = Term
term_type(::Type{T}) where {T<:Real} = T

function intermediate_couplings(its::Vector{T}, t₀::T=zero(T)) where {T<:Union{Term,Integer,HalfInteger}}
    ts = Vector{Vector{T}}()
    for t in couple_terms(t₀, its[1])
        if length(its) == 1
            push!(ts, [t₀, t])
        else
            for ts′ in intermediate_couplings(its[2:end], t)
                push!(ts, vcat(t₀, ts′...))
            end
        end
    end
    ts
end

"""
    intermediate_couplings(its::Vector{IntermediateTerm,Integer,HalfInteger}, t₀ = T"1S")

Generate all intermediate coupling trees from the vector of
intermediate terms `its`, starting from the initial term `t₀`.

# Examples

```jldoctest
julia> intermediate_couplings([IntermediateTerm(T"2S", 1), IntermediateTerm(T"2D", 1)])
2-element Array{Array{Term,1},1}:
 [¹S, ²S, ¹D]
 [¹S, ²S, ³D]
```
"""
intermediate_couplings(its::Vector{IntermediateTerm}, t₀::Term=zero(Term)) =
    intermediate_couplings(map(t -> t.term, its), t₀)

"""
    intermediate_couplings(J::Vector{<:Real}, j₀ = 0)

# Examples

```jldoctest
julia> intermediate_couplings([1//2, 3//2])
2-element Array{Array{HalfIntegers.Half{Int64},1},1}:
 [0, 1/2, 1]
 [0, 1/2, 2]
```
"""
intermediate_couplings(J::Vector{IT}, j₀::T=zero(IT)) where {IT <: Real, T <: Real} =
    intermediate_couplings(convert.(HalfInteger, J), convert(HalfInteger, j₀))

export couple_terms, intermediate_couplings
