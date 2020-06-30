struct CSF{O<:AbstractOrbital, T<:Union{Term,HalfInteger}, S}
    config::Configuration{<:O}
    subshell_terms::Vector{IntermediateTerm{T,S}}
    terms::Vector{T}

    function CSF(config::Configuration{O},
                 subshell_terms::Vector{IntermediateTerm{T,S}},
                 terms::Vector{T}) where {O<:Union{<:Orbital,<:RelativisticOrbital},
                                          T<:Union{Term,HalfInt}, S}
        length(subshell_terms) == length(peel(config)) ||
            throw(ArgumentError("Need to provide $(length(peel(config))) subshell terms for $(config)"))
        length(terms) == length(peel(config)) ||
            throw(ArgumentError("Need to provide $(length(peel(config))) terms for $(config)"))

        for (i,(orb,occ,_)) in enumerate(peel(config))
            st = subshell_terms[i]
            assert_unique_classification(orb, occ, st) ||
                throw(ArgumentError("$(st) is not a unique classification of $(orb)$(to_superscript(occ))"))
        end

        new{O,T,S}(config, subshell_terms, terms)
    end

    CSF(config, subshell_terms::Vector{<:IntermediateTerm}, terms::Vector{<:Real}) =
        CSF(config, subshell_terms, convert.(HalfInt, terms))
end

const NonRelativisticCSF = CSF{<:Orbital,Term}
const RelativisticCSF = CSF{<:RelativisticOrbital,HalfInt}

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

Base.length(csf::CSF) = length(peel(csf.config))
Base.getindex(csf::CSF, i::Integer) =
    (peel(csf.config)[i],csf.subshell_terms[i],csf.terms[i])

Base.iterate(csf::CSF, (el, i)=(length(csf)>0 ? csf[1] : nothing,1)) =
    i > length(csf) ? nothing : (el, (csf[i==length(csf) ? i : i+1],i+1))

function Base.show(io::IO, csf::CSF)
    c = core(csf.config)
    p = peel(csf.config)
    nc = length(c)
    if nc > 0
        show(io, c)
        write(io, " ")
    end

    for (i,((orb,occ,state),st,t)) in enumerate(csf)
        show(io, orb)
        occ > 1 && write(io, to_superscript(occ))
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
