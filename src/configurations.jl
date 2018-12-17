struct Configuration{I<:Integer,R<:Rational{I}}
    orbitals::Vector{<:Orbital{I,R,<:MQ{I}}}
    occupancy::Vector{I}
    states::Vector{Symbol}
    function Configuration(
        orbitals::Vector{<:Orbital{I,R,<:MQ{I}}},
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

function Configuration(orbs::Vector{<:Tuple{<:Orbital{I,R,<:MQ{I}},I,Symbol}}) where {I<:Integer,R<:Rational}
    orbitals = Vector{Orbital{I,R,<:MQ{I}}}()
    occupancy = Vector{I}()
    states = Vector{Symbol}()
    for (orb,occ,state) in orbs
        push!(orbitals, orb)
        push!(occupancy, occ)
        push!(states, state)
    end
    Configuration(orbitals, occupancy, states)
end

Configuration(orbital::Orbital{I,R,<:MQ{I}}, occupancy::I, state::Symbol=:open) where {I<:Integer,R<:Rational{I}} =
    Configuration([orbital], [occupancy], [state])

Configuration{I,R}() where {I,R} =
    Configuration(Orbital{I,R,<:MQ{I}}[], I[], Symbol[])

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
    nc = length(config)
    if nc == 0
        write(io, "∅")
        return
    end
    core_config = core(config)
    ncc = length(core_config)
    if length(core_config) > 0
        core_printed = false
        for gas in ["Rn", "Xe", "Kr", "Ar", "Ne", "He"]
            gas_cfg = noble_gases[gas]
            ngc = length(gas_cfg)
            if ncc ≥ ngc && issimilar(core_config[1:length(gas_cfg)], gas_cfg)
                write(io, "[$(gas)]ᶜ")
                if ncc > ngc
                    write(io, " ")
                    write_orbitals(io, core_config[ngc+1:end])
                end
                nc > ncc && write(io, " ")
                core_printed = true
                break
            end
        end
        if !core_printed
            write_orbitals(io, core_config)
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
    m = match(r"^([0-9]+|.([a-z]|\[[0-9]+\])[-]{0,1})([0-9]*)([*ci]{0,1})$",orb_str)
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

Base.getindex(conf::Configuration{I,R}, i::Integer) where {I,R} =
    (conf.orbitals[i], conf.occupancy[i], conf.states[i])
Base.getindex(conf::Configuration{I,R}, i::Union{<:UnitRange{<:Integer},<:AbstractVector{<:Integer}}) where {I,R} =
    Configuration([conf[ii] for ii in i])

Base.iterate(conf::Configuration{I,R}, (el, i)=(length(conf)>0 ? conf[1] : nothing,1)) where {I,R} =
    i > length(conf) ? nothing : (el, (conf[i==length(conf) ? i : i+1],i+1))

Base.length(conf::Configuration) = length(conf.orbitals)
Base.lastindex(conf::Configuration) = length(conf)
Base.eltype(conf::Configuration{I,R}) where {I,R} = (Orbital{I,R},I,Symbol)

num_electrons(conf::Configuration) = sum(conf.occupancy)

Base.in(orb::Orbital{I,R}, conf::Configuration{I,R}) where {I,R} =
    orb ∈ conf.orbitals

Base.filter(f::Function, conf::Configuration) =
    conf[filter(j -> f(conf[j]...), eachindex(conf.orbitals))]

core(conf::Configuration) = filter((orb,occ,state) -> state == :closed, conf)
peel(conf::Configuration) = filter((orb,occ,state) -> state != :closed, conf)
inactive(conf::Configuration) = filter((orb,occ,state) -> state == :inactive, conf)
active(conf::Configuration) = filter((orb,occ,state) -> state != :inactive, peel(conf))
bound(conf::Configuration) = filter((orb,occ,state) -> orb.n isa Integer, conf)
continuum(conf::Configuration) = filter((orb,occ,state) -> orb.n isa Symbol, peel(conf))

parity(conf::Configuration) = (-1)^mapreduce(o -> o[1].ℓ*o[2], +, conf)
Base.count(conf::Configuration) = mapreduce(o -> o[2], +, conf)

function Base.replace(conf::Configuration{I,R}, orbs::Pair{Orbital{I,R,N₁},Orbital{I,R,N₂}}) where {I,R,N₁,N₂}
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

"""
    ⊗(::Union{Configuration, Vector{Configuration}}, ::Union{Configuration, Vector{Configuration}})

Given two collections of `Configuration`s, it creates an array of `Configuration`s with all
possible juxtapositions of configurations from each collection.

# Examples

```jldoctest
julia> [c"1s", c"2s"] ⊗ [c"2p-", c"2p"]
4-element Array{Configuration{Int64,Rational{Int64}},1}:
 1s 2p⁻
 1s 2p
 2s 2p⁻
 2s 2p

julia> c"1s" ⊗ [c"2s2", c"2s 2p-"]
2-element Array{Configuration{Int64,Rational{Int64}},1}:
 1s 2s²
 1s 2s 2p⁻
```
"""
function ⊗(a::Vector{T}, b::Vector{T}) where {T <: Configuration}
    [x+y for x in a for y in b]
end
⊗(a::Union{T,Vector{T}}, b::T) where {T <: Configuration} = a ⊗ [b]
⊗(a::T, b::Vector{T}) where {T <: Configuration} = [a] ⊗ b

"""
    configurations_from_nrorbital(n, ℓ, occupancy)

Generate all `Configuration`s corresponding to the non-relativistic `nℓ` orbital with the
given occupancy.

# Examples

```jldoctest
julia> configurations_from_nrorbital(3, 1, 2)
3-element Array{Configuration{Int64,Rational{Int64}},1}:
 3p⁻²
 3p⁻ 3p
 3p²
```
"""
function configurations_from_nrorbital(n::I, ℓ::I, occupancy::I) where {I <: Integer}
    ℓ + 1 > n && throw(ArgumentError("ℓ=$ℓ too high for given n=$n"))
    occupancy > 2*(2ℓ + 1) && throw(ArgumentError("occupancy=$occupancy too high for given ℓ=$ℓ"))

    degeneracy_ℓm, degeneracy_ℓp = 2ℓ, 2ℓ + 2 # degeneracies of nℓ- and nℓ orbitals
    nlow_min = max(occupancy - degeneracy_ℓp, 0)
    nlow_max = min(degeneracy_ℓm, occupancy)
    confs = Configuration{Int,Rational{Int}}[]
    for nlow = nlow_max:-1:nlow_min
        nhigh = occupancy - nlow
        conf = if nlow == 0
            Configuration([Orbital(n, ℓ, ℓ + 1//2)], [nhigh])
        elseif nhigh == 0
            Configuration([Orbital(n, ℓ, ℓ - 1//2)], [nlow])
        else
            Configuration(
                [Orbital(n, ℓ, ℓ - 1//2), Orbital(n, ℓ, ℓ + 1//2)],
                [nlow, nhigh]
            )
        end
        push!(confs, conf)
    end
    return confs
end

"""
    configurations_from_nrorbital(orbital::Orbital, occupancy)

Generate all `Configuration`s corresponding to the non-relativistic version of the `orbital`.

Only `Orbital`s with `j > ℓ` are allowed as input (i.e. the ℓ- orbitals are disallowed).

# Examples

```jldoctest
julia> configurations_from_nrorbital(o"3p", 2)
3-element Array{Configuration{Int64,Rational{Int64}},1}:
 3p⁻²
 3p⁻ 3p
 3p²
```
"""
function configurations_from_nrorbital(orbital::Orbital, occupation::Integer)
    orbital.j < orbital.ℓ && throw(ArgumentError("Can't use ℓ- orbital ($orbital) as input."))
    configurations_from_nrorbital(orbital.n, orbital.ℓ, occupation)
end

function configurations_from_nrstring(orb_str::AbstractString)
    m = match(r"^([0-9]+)([a-z]+)([0-9]+)?$", orb_str)
    m === nothing && throw(ArgumentError("Invalid orbital string: $(orb_str)"))
    n = parse(Int, m[1])
    ℓi = findfirst(m[2], spectroscopic)
    isnothing(ℓi) && throw(ArgumentError("Invalid spectroscopic label: $(m[2]) in $(orb_str)"))
    ℓ = first(ℓi) - 1
    occupancy = isnothing(m[3]) ? 1 : parse(Int, m[3])
    return configurations_from_nrorbital(n, ℓ, occupancy)
end

"""
    @rcs_str -> Vector{Configuration}

Construct a `Vector` of all `Configuration`s corresponding to the non-relativistic `nℓ`
orbital with the given occupancy from the input string.

The string is assumed to have the following syntax: `\$(n)\$(ℓ)\$(occupancy)`, where `n`
and `occupancy` are integers, and `ℓ` is in spectroscopic notation.

# Examples

```jldoctest
julia> rcs"3p2"
3-element Array{Configuration{Int64,Rational{Int64}},1}:
 3p⁻²
 3p⁻ 3p
 3p²
```
"""
macro rcs_str(s)
    configurations_from_nrstring(s)
end

export Configuration, @c_str, num_electrons, core, peel, active, inactive, bound, continuum, parity, ⊗, @rcs_str
