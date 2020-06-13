using AtomicLevels: CSF, orbital_from_string

p_suffix(p::Parity) = isodd(p) ? "o" : ""
p_suffix(cfg::Configuration) = p_suffix(parity(cfg))

function parse_csf(filename)
    # It is assumed that all term symbols are on the form ML (and MLS
    # for intermediate terms) where M is multiplicity, and S is
    # seniority number.
    ref_csfs = NonRelativisticCSF[]
    open(filename) do file
        readline(file)
        core_cfg = close(fill(parse(Configuration{Orbital}, join(split(readline(file)), " "))))
        while true
            peel_cfg = readline(file)
            peel_cfg[1] == '*' && break
            peel_cfg = parse(Configuration{Orbital},
                             join(split(replace(replace(replace(peel_cfg, "( "=>""), "("=>""), ")"=>"")), " "))
            cfg = core_cfg + peel_cfg
            ts = split(readline(file))
            np = length(peel_cfg)
            its = map(enumerate(ts[1:np])) do (i,t)
                ip = p_suffix(parity(Configuration(peel_cfg[i]...)))
                IntermediateTerm(parse(Term, "$(t[1:2])$(ip)"), Seniority(parse(Int, t[end])))
            end
            coupled_terms = map(enumerate(ts[vcat(1,np+1:end)])) do (i,t)
                parse(Term, "$(t[1:2])$(p_suffix(peel_cfg[1:i]))")
            end
            push!(ref_csfs, CSF(cfg, its, coupled_terms))
        end
    end
    ref_csfs
end
