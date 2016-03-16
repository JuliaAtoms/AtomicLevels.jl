using SuperSub

type Term
    L::Integer
    S::Rational
    parity::Integer
end

multiplicity(t::Term) = round(Int, 2t.S + 1)
weight(t::Term) = (2t.L + 1) * multiplicity(t)

import Base.==
==(t1::Term, t2::Term) = ((t1.L == t2.L) && (t1.S == t2.S) && (t1.parity == t2.parity))

import Base.<
<(t1::Term, t2::Term) = ((t1.S < t2.S) || (t1.S == t2.S) && (t1.L < t2.L)
                         || (t1.S == t2.S) && (t1.L == t2.L) && (t1.parity < t2.parity))
import Base.isless
isless(t1::Term, t2::Term) = (t1 < t2)

import Base.hash
hash(t::Term) = hash((t.L,t.S,t.parity))

function couple_terms(t1::Term, t2::Term)
    L1 = t1.L
    L2 = t2.L
    S1 = t1.S
    S2 = t2.S
    p = t1.parity * t2.parity
    sort(vcat([[Term(L, S, p) for S in abs(S1-S2):(S1+S2)]
               for L in abs(L1-L2):(L1+L2)]...))
end

function couple_terms(t1s::Vector{Term}, t2s::Vector{Term})
    ts = map(t1s) do t1
        map(t2s) do t2
            couple_terms(t1, t2)
        end
    end
    sort(unique(vcat(vcat(ts...)...)))
end

couple_terms(ts::Vector{Vector{Term}}) = reduce(couple_terms, ts)

function couple_terms(ts::Vector{Void})
    [nothing]
end

include("xu2006.jl")

# This function calculates the term symbol for a given orbital ℓʷ
function xu_terms(ell::Integer, w::Integer, p::Integer)
    candidates = map(((w//2 - floor(Int, w//2)):w//2)) do S
        map(-S:S) do M_S
            S_p = round(Int,2S)
            M_Sp = round(Int, 2M_S)

            a = (w-M_Sp) >> 1
            b = (w+M_Sp) >> 1
            fa = Xu.f(a-1,ell)
            fb = Xu.f(b-1,ell)

            map(0:(fa+fb)) do L
                x = Xu.X(w,ell, S_p, L)
                t = Term(L,S,p)
                x != 0 ? t : nothing
            end
        end
    end
    candidates = vcat(vcat(candidates...)...)
    ts = Vector{Term}(sort(unique(filter(c -> c != nothing, candidates))))
    ts
end

function terms(orb::Orbital)
    ell = orb[2]
    w = orb[3]
    g = degeneracy(orb)
    (w > g/2) && (w = g - w)

    p = parity(orb)

    if w == 1
        return [Term(ell,1//2,p)]
    end

    xu_terms(ell, w, p)
end

function terms(config::Config)
    config = filter(o -> o[3]<degeneracy(o), config)

    # All subshells are filled, total angular momentum = 0, total spin = 0
    if length(config) == 0
        return [Term(0, 0, 1)]
    end

    ts = map(config) do orb
        terms(orb)
    end

    couple_terms(ts)
end
terms(config::AbstractString) = terms(ref_set_list(config))

import Base.print, Base.show, Base.writemime, Base.string

function ELL(L::Integer)
    if L<length(ells)
        uppercase(ells[L+1])
    else
        string(L)
    end
end

function print(io::IO, t::Term)
    print(io, superscript(multiplicity(t)))
    print(io, ELL(t.L))
    t.parity == -1  && print(io, "ᵒ")
end
show(io::IO, t::Term) = print(io, t)

function writemime(io::IO, ::MIME"text/latex", t::Term, wrap = true)
    wrap && print(io, "\$")
    p = t.parity == -1 ? "^{\\mathrm{o}}" : ""
    print(io, "^{$(multiplicity(t))}\\mathrm{$(ELL(t.L))}$p")
    wrap && print(io, "\$")
end

string(t::Term) = "$(2t.S+1)$(ELL(t.L))$(t.parity == -1 ? '-' : "")"

export Term, multiplicity, weight, ==, <, isless, hash, couple_terms, terms, print, show, string
