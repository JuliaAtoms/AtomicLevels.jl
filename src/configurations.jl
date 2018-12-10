using UnicodeFun

struct Configuration{I<:Integer,R<:Rational{I}}
    orbitals::Vector{Orbital{I,R}}
    occupancy::Vector{I}
    states::Vector{Symbol}
    function Configuration(
        orbitals::Vector{Orbital{I,R}},
        occupancy::Vector{I},
        states::Vector{Symbol}=[:open for o in orbitals]) where {I<:Integer,R<:Rational{I}}
        length(orbitals) == length(occupancy) || throw(ArgumentError("Need to specify occupation numbers for all orbitals"))
        length(states) ≤ length(orbitals) || throw(ArgumentError("Cannot provide more states than orbitals"))

        length(orbitals) == length(unique(orbitals)) || throw(ArgumentError("Not all orbitals are unique"))

        if length(states) < length(orbitals)
            append!(states, repeat([:open], length(orbitals) - length(states)))
        end
        sd = setdiff(states, [:open, :closed, :inactive])
        isempty(sd) || throw(ArgumentError("Unknown orbital states $(sd)"))

        for i in eachindex(orbitals)
            occ = occupancy[i]
            occ < 1 && throw(ArgumentError("Invalid occupancy $(occ)"))
            orb = orbitals[i]
            degen_orb = degeneracy(orb)
            if occ > degen_orb
                orb_conj = flip_j(orb)
                degen_orb_conj = degeneracy(orb_conj)
                if occ == degen_orb + degen_orb_conj && orb_conj ∉ orbitals
                    occupancy[i] = degen_orb
                    push!(orbitals, orb_conj)
                    push!(occupancy, degen_orb_conj)
                    push!(states, states[i])
                elseif orb_conj ∈ orbitals
                    throw(ArgumentError("Higher occupancy than possible for $(orb) with degeneracy $(degen_orb)"))
                else
                    throw(ArgumentError("Can only specify higher occupancy for $(orb) if completely filling the $(orb),$(orb_conj) subshell (for total degeneracy of $(degen_orb+degen_orb_conj))"))
                end
            end
        end

        for i in eachindex(orbitals)
            states[i] == :closed && occupancy[i] < degeneracy(orbitals[i]) &&
                throw(ArgumentError("Can only close filled orbitals"))
        end

        p = sortperm(orbitals)

        new{I,R}(orbitals[p], occupancy[p], states[p])
    end
end

function Configuration(orbs::Vector{Tuple{Orbital{I,R},I,Symbol}}) where {I<:Integer,R<:Rational}
    orbitals = Vector{Orbital{I,R}}()
    occupancy = Vector{I}()
    states = Vector{Symbol}()
    for (orb,occ,state) in orbs
        push!(orbitals, orb)
        push!(occupancy, occ)
        push!(states, state)
    end
    Configuration(orbitals, occupancy, states)
end

Configuration(orbital::Orbital{I,R}, occupancy::I, state::Symbol=:open) where {I<:Integer,R<:Rational{I}} =
    Configuration([orbital], [occupancy], [state])

Configuration{I,R}() where {I,R} =
    Configuration(Orbital{I,R}[], I[], Symbol[])

issimilar(a::Configuration{I,R}, b::Configuration{I,R}) where {I,R} =
    a.orbitals == b.orbitals && a.occupancy == b.occupancy

import Base: ==
==(a::Configuration{I,R}, b::Configuration{I,R}) where {I,R} =
    issimilar(a, b) && a.states == b.states

noble_gases = Dict{String,Configuration}()

function write_orbitals(io::IO, config::Configuration)
    for (i,(orb,occ,state)) in enumerate(config)
        i > 1 && write(io, " ")
        write(io, "$(orb)")
        occ > 1 && write(io, to_superscript(occ))
        state == :closed && write(io, "ᶜ")
        state == :inactive && write(io, "ⁱ")
    end
end

function Base.show(io::IO, config::Configuration)
    core_config = core(config)
    if length(core_config) > 0
        for (gas,cfg) in noble_gases
            if issimilar(core_config, cfg)
                write(io, "[$(gas)]ᶜ")
                length(config) > length(core_config) && write(io, " ")
            end
        end
    end
    write_orbitals(io, peel(config))
end

function state_sym(state::AbstractString)
    if state == "c"
        :closed
    elseif state == "i"
        :inactive
    else
        :open
    end
end

function core_configuration(element::AbstractString, state::AbstractString)
    element ∉ keys(noble_gases) && throw(ArgumentError("Unknown noble gas $(element)"))
    state = state_sym(state == "" ? "c" : state) # By default, we'd like cores to be frozen
    core_config = noble_gases[element]
    Configuration(core_config.orbitals, core_config.occupancy,
                  [state for o in core_config.orbitals])
end

function parse_orbital(orb_str)
    m = match(r"([0-9]+([a-z]|\[[0-9]+\])[-]{0,1})([0-9]*)([*ci]{0,1})",orb_str)
    orbital_from_string(m[1]),m[3]=="" ? 1 : parse(Int, m[3]),state_sym(m[4])
end

function configuration_from_string(conf_str::AbstractString)
    isempty(conf_str) && return Configuration{Int,Rational{Int}}()
    orbs = split(conf_str, r"[\. ]")
    core_m = match(r"\[([a-zA-Z]+)\]([*ci]{0,1})", first(orbs))
    if core_m != nothing
        core_config = core_configuration(core_m[1], core_m[2])
        if length(orbs) > 1
            peel_config = Configuration(parse_orbital.(orbs[2:end]))
            Configuration(vcat(core_config.orbitals, peel_config.orbitals),
                          vcat(core_config.occupancy, peel_config.occupancy),
                          vcat(core_config.states, peel_config.states))
        else
            core_config
        end
    else
        Configuration(parse_orbital.(orbs))
    end
end

macro c_str(conf_str)
    configuration_from_string(conf_str)
end

for gas in ("He" => "1s2",
            "Ne" => "[He] 2s2 2p6",
            "Ar" => "[Ne] 3s2 3p6",
            "Kr" => "[Ar] 3d10 4s2 4p6",
            "Xe" => "[Kr] 4d10 5s2 5p6",
            "Rn" => "[Xe] 4f14 5d10 6s2 6p6")
    noble_gases[gas[1]] = configuration_from_string(gas[2])
end

Base.getindex(conf::Configuration{I,R}, i) where {I,R} =
    (conf.orbitals[i], conf.occupancy[i], conf.states[i])

Base.iterate(conf::Configuration{I,R}, (el, i)=(length(conf)>0 ? conf[1] : nothing,1)) where {I,R} =
    i > length(conf) ? nothing : (el, (conf[i==length(conf) ? i : i+1],i+1))

Base.length(conf::Configuration) = length(conf.orbitals)
Base.eltype(conf::Configuration{I,R}) where {I,R} = (Orbital{I,R},I,Symbol)

Base.in(orb::Orbital{I,R}, conf::Configuration{I,R}) where {I,R} =
    orb ∈ conf.orbitals

Base.filter(f::Function, conf::Configuration) =
    Configuration(conf[filter(j -> f(conf[j]...), eachindex(conf.orbitals))]...)

core(conf::Configuration) = filter((orb,occ,state) -> state == :closed, conf)
peel(conf::Configuration) = filter((orb,occ,state) -> state != :closed, conf)
inactive(conf::Configuration) = filter((orb,occ,state) -> state == :inactive, conf)
active(conf::Configuration) = filter((orb,occ,state) -> state != :inactive, peel(conf))

parity(conf::Configuration) = (-1)^mapreduce(o -> o[1].ℓ*o[2], +, conf)
Base.count(conf::Configuration) = mapreduce(o -> o[2], +, conf)

function Base.replace(conf::Configuration{I,R}, orbs::Pair{Orbital{I,R},Orbital{I,R}}) where {I,R}
    src,dest = orbs
    orbitals = copy(conf.orbitals)
    occupancy = copy(conf.occupancy)
    states = copy(conf.states)

    i = findfirst(isequal(src), orbitals)
    isnothing(i) && throw(ArgumentError("$(src) not present in $(conf)"))

    j = findfirst(isequal(dest), orbitals)
    if isnothing(j)
        push!(orbitals, dest)
        push!(occupancy, 1)
        push!(states, :open)
    else
        occupancy[j] == degeneracy(dest) &&
            throw(ArgumentError("$(dest) already maximally occupied in $(conf)"))
        occupancy[j] += 1
    end

    occupancy[i] -= 1
    if occupancy[i] == 0
        deleteat!(orbitals, i)
        deleteat!(occupancy, i)
        deleteat!(states, i)
    end

    Configuration(orbitals, occupancy, states)
end

import Base: +
function +(a::Configuration{I,R}, b::Configuration{I,R}) where {I,R}
    orbitals = copy(a.orbitals)
    occupancy = copy(a.occupancy)
    states = copy(a.states)

    for (orb,occ,state) in b
        i = findfirst(isequal(orb), orbitals)
        if isnothing(i)
            push!(orbitals, orb)
            push!(occupancy, occ)
            push!(states, state)
        else
            occupancy[i] += occ
            states[i] == state || throw(ArgumentError("Incompatible states for $(orb): $(states[i]) and $state"))
        end
    end
    Configuration(orbitals, occupancy, states)
end

export Configuration, @c_str, core, peel, active, inactive, parity
