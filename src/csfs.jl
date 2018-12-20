struct CSF{O<:AbstractOrbital, IT<:Union{IntermediateTerm,HalfInteger}, T<:Union{Term,HalfInteger}}
    config::Configuration{<:O}
    subshell_terms::Vector{IT}
    terms::Vector{T}

    function CSF(config::Configuration{<:Orbital},
                 subshell_terms::Vector{<:IntermediateTerm},
                 terms::Vector{<:Term})
        length(subshell_terms) == length(peel(config)) ||
            throw(ArgumentError("Need to provide $(length(peel(config))) subshell terms for $(config)"))
        length(terms) == length(peel(config)) ||
            throw(ArgumentError("Need to provide $(length(peel(config))) terms for $(config)"))
        new{Orbital,IntermediateTerm,Term}(config, subshell_terms, terms)
    end

    function CSF(config::Configuration{O},
                 subshell_terms::Vector{R},
                 terms::Vector{R}) where {O <: RelativisticOrbital, R <: Real}
        length(subshell_terms) == length(peel(config)) ||
            throw(ArgumentError("Need to provide $(length(peel(config))) subshell terms for $(config)"))
        length(terms) == length(peel(config)) ||
            throw(ArgumentError("Need to provide $(length(peel(config))) terms for $(config)"))
        new{O,HalfInteger,HalfInteger}(config,
                                       convert.(HalfInteger, subshell_terms),
                                       convert.(HalfInteger, terms))
    end
end

Base.:(==)(a::CSF{O,T}, b::CSF{O,T}) where {O,T} =
    (a.config == b.config) && (a.subshell_terms == b.subshell_terms) && (a.terms == b.terms)

# We possibly want to sort on configuration as well
Base.isless(a::CSF, b::CSF) = last(a.terms) < last(b.terms)

function csfs(config::Configuration)
    map(allchoices(intermediate_terms(peel(config)))) do subshell_terms
        map(intermediate_couplings(subshell_terms)) do coupled_terms
            CSF(config, subshell_terms, coupled_terms[2:end])
        end
    end |> c -> vcat(c...) |> sort
end

csfs(configs::Vector{Configuration{O}}) where O = vcat(map(csfs, configs)...)

show_couplings(io::IO, st::IntermediateTerm, t::Term) = write(io, "($(st)|$(t))")
show_couplings(io::IO, st::HalfInteger, t::HalfInteger) = write(io, "($(rs(st))|$(rs(t)))")

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
        show_couplings(io, st, t)
        i != lastindex(p) && write(io, " ")
    end
    print(io, iseven(parity(csf.config)) ? "+" : "-")
end

function Base.show(io::IO, ::MIME"text/plain", csf::CSF{<:RelativisticOrbital,HalfInteger,HalfInteger})
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
    for j in csf.subshell_terms
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

export CSF, csfs
