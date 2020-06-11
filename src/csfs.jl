# This is due to the statement "For partially filled f-shells,
# seniority alone is not sufficient to distinguish all possible
# states." on page 24 of
#
# - Froese Fischer, C., Brage, T., & Jönsson, P. (1997). Computational
#   atomic structure : an mchf approach. Bristol, UK Philadelphia, Penn:
#   Institute of Physics Publ.
#
# This is too strict, i.e. there are partially filled (ℓ ≥ f)-shells
# for which seniority /is/ enough, but I don't know which, so better
# play it safe.
assert_unique_classification(orb::Orbital, occ, intermediate_term::IntermediateTerm{Term,<:Integer}) =
    orb.ℓ < 3 || occ == degeneracy(orb)

function assert_unique_classification(orb::RelativisticOrbital, occ, intermediate_term::IntermediateTerm{<:HalfInteger,<:Integer})
    J = intermediate_term.term
    ν = intermediate_term.seniority
    # This is deduced by looking at table A.10 of
    #
    # - Grant, I. P. (2007). Relativistic quantum theory of atoms and
    #   molecules : theory and computation. New York: Springer.
    !((orb.j == half(9) && (occ == 4 || occ == 6) &&
       (J == 4 || J == 6) && ν == 4) ||
      orb.j > half(9)) # Again, too strict.
end

struct CSF{O<:AbstractOrbital, IT<:IntermediateTerm, T<:Union{Term,HalfInteger}}
    config::Configuration{<:O}
    subshell_terms::Vector{IT}
    terms::Vector{T}

    function CSF(config::Configuration{O},
                 subshell_terms::Vector{I},
                 terms::Vector{T}) where {O<:Union{<:Orbital,<:RelativisticOrbital},
                                          I<:IntermediateTerm,
                                          T<:Union{Term,HalfInt}}
        length(subshell_terms) == length(peel(config)) ||
            throw(ArgumentError("Need to provide $(length(peel(config))) subshell terms for $(config)"))
        length(terms) == length(peel(config)) ||
            throw(ArgumentError("Need to provide $(length(peel(config))) terms for $(config)"))

        for (i,(orb,occ,_)) in enumerate(peel(config))
            assert_unique_classification(orb, occ, subshell_terms[i]) ||
                throw(ArgumentError("$(intermediate_term) is not a unique classification of $(orb)$(to_superscript(occ))"))
        end

        new{O,I,T}(config, subshell_terms, terms)
    end

    CSF(config, subshell_terms, terms::Vector{<:Real}) =
        CSF(config, subshell_terms, convert.(HalfInt, terms))
end

const NonRelativisticCSF = CSF{<:Orbital,IntermediateTerm{Term,Int},Term}
const RelativisticCSF = CSF{<:RelativisticOrbital,IntermediateTerm{HalfInt,Int},HalfInt}

Base.:(==)(a::CSF{O,T}, b::CSF{O,T}) where {O,T} =
    (a.config == b.config) && (a.subshell_terms == b.subshell_terms) && (a.terms == b.terms)

# We possibly want to sort on configuration as well
Base.isless(a::CSF, b::CSF) = last(a.terms) < last(b.terms)

num_electrons(csf::CSF) = num_electrons(csf.config)

function csfs(config::Configuration)
    map(allchoices(intermediate_terms(peel(config)))) do subshell_terms
        map(intermediate_couplings(subshell_terms)) do coupled_terms
            CSF(config, subshell_terms, coupled_terms[2:end])
        end
    end |> c -> vcat(c...) |> sort
end

csfs(configs::Vector{Configuration{O}}) where O = vcat(map(csfs, configs)...)

function Base.show(io::IO, csf::CSF)
    c = core(csf.config)
    p = peel(csf.config)
    nc = length(c)
    if nc > 0
        show(io, c)
        write(io, " ")
    end

    for (i,(orb,occ,state)) in enumerate(p)
        show(io, orb)
        occ > 1 && write(io, to_superscript(occ))
        st = csf.subshell_terms[i]
        t = csf.terms[i]
        write(io, "($(st)|$(t))")
        i != lastindex(p) && write(io, " ")
    end
    print(io, iseven(parity(csf.config)) ? "+" : "-")
end

function Base.show(io::IO, ::MIME"text/plain", csf::RelativisticCSF)
    c = core(csf.config)
    nc = length(c)
    cw = length(string(c))

    w = 0
    p = peel(csf.config)
    for (orb,occ,state) in p
        w = max(w, length(string(orb))+length(digits(occ)))
    end

    w += 1

    cfmt = FormatExpr("{1:$(cw)s} ")
    ofmt = FormatExpr("{1:<$(w+1)s}")
    ifmt = FormatExpr("{1:>$(w+1)d}")
    rfmt = FormatExpr("{1:>$(w-1)d}/2")

    nc > 0 && printfmt(io, cfmt, c)
    for (orb,occ,state) in p
        printfmt(io, ofmt, join([string(orb), occ > 1 ? to_superscript(occ) : ""], ""))
    end
    println(io)

    nc > 0 && printfmt(io, cfmt, "")
    for it in csf.subshell_terms
        j = it.term
        if denominator(j) == 1
            printfmt(io, ifmt, numerator(j))
        else
            printfmt(io, rfmt, numerator(j))
        end
    end
    println(io)

    nc > 0 && printfmt(io, cfmt, "")
    print(io, " ")
    for j in csf.terms
        if denominator(j) == 1
            printfmt(io, ifmt, numerator(j))
        else
            printfmt(io, rfmt, numerator(j))
        end
    end
    print(io, iseven(parity(csf.config)) ? "+" : "-")
end

export CSF, NonRelativisticCSF, RelativisticCSF, csfs
