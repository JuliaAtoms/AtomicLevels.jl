"""
    struct Configuration{<:AbstractOrbital}

Represents a configuration -- a set of orbitals and their associated
occupation number.  Furthermore, each orbital can be in one of the
following _states_: `:open`, `:closed` or `:inactive`.

# Constructors

    Configuration(orbitals :: Vector{<:AbstractOrbital},
                  occupancy :: Vector{Int},
                  states :: Vector{Symbol}
                  [; sorted=false])

    Configuration(orbitals :: Vector{Tuple{<:AbstractOrbital, Int, Symbol}}
                  [; sorted=false])

In the first case, the parameters of each orbital have to be passed as
separate vectors, and the orbitals and occupancy have to be of the
same length. The `states` vector can be shorter and then the latter
orbitals that were not explicitly specified by `states` are assumed to
be `:open`.

The second constructor allows you to pass a vector of tuples instead,
where each tuple is a triplet `(orbital :: AbstractOrbital, occupancy
:: Int, state :: Symbol)` corresponding to each orbital.

In all cases, all the orbitals have to be distinct. The orbitals in
the configuration will be sorted (if `sorted`) according to the
ordering defined for the particular [`AbstractOrbital`](@ref).
"""
struct Configuration{O<:AbstractOrbital}
    orbitals::Vector{O}
    occupancy::Vector{Int}
    states::Vector{Symbol}
    sorted::Bool
    function Configuration(
        orbitals::Vector{O},
        occupancy::Vector{Int},
        states::Vector{Symbol}=[:open for o in orbitals];
        sorted=false) where {O<:AbstractOrbital}
        length(orbitals) == length(occupancy) ||
            throw(ArgumentError("Need to specify occupation numbers for all orbitals"))
        length(states) ≤ length(orbitals) ||
            throw(ArgumentError("Cannot provide more states than orbitals"))

        length(orbitals) == length(unique(orbitals)) ||
            throw(ArgumentError("Not all orbitals are unique"))

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
                if O <: Orbital || O <: SpinOrbital
                    throw(ArgumentError("Higher occupancy than possible for $(orb) with degeneracy $(degen_orb)"))
                elseif O <: RelativisticOrbital
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
        end

        for i in eachindex(orbitals)
            states[i] == :closed && occupancy[i] < degeneracy(orbitals[i]) &&
                throw(ArgumentError("Can only close filled orbitals"))
        end

        p = sorted ? sortperm(orbitals) : eachindex(orbitals)

        new{O}(orbitals[p], occupancy[p], states[p], sorted)
    end
end

function Configuration(orbs::Vector{Tuple{O,Int,Symbol}}; sorted=false) where {O<:AbstractOrbital}
    orbitals = Vector{O}()
    occupancy = Vector{Int}()
    states = Vector{Symbol}()
    for (orb,occ,state) in orbs
        push!(orbitals, orb)
        push!(occupancy, occ)
        push!(states, state)
    end
    Configuration(orbitals, occupancy, states, sorted=sorted)
end

Configuration(orbital::O, occupancy::Int, state::Symbol=:open; sorted=false) where {O<:AbstractOrbital} =
    Configuration([orbital], [occupancy], [state], sorted=sorted)

Configuration{O}(;sorted=false) where {O<:AbstractOrbital} =
    Configuration(O[], Int[], Symbol[], sorted=sorted)

Base.copy(cfg::Configuration) =
    Configuration(copy(cfg.orbitals), copy(cfg.occupancy), copy(cfg.states),
                  sorted=cfg.sorted)

const RelativisticConfiguration = Configuration{<:RelativisticOrbital}

"""
    issorted(cfg::Configuration)

Tests if the orbitals of `cfg` is sorted.
"""
Base.issorted(cfg::Configuration) = cfg.sorted || issorted(cfg.orbitals)

"""
    sort(cfg::Configuration)

Returns a sorted copy of `cfg`.
"""
Base.sort(cfg::Configuration) =
    Configuration(cfg.orbitals, cfg.occupancy, cfg.states, sorted=true)

"""
    sorted(cfg::Configuration)

Returns `cfg` if it is already sorted or a sorted copy otherwise.
"""
sorted(cfg::Configuration) =
    issorted(cfg) ? cfg : sort(cfg)

"""
    issimilar(a::Configuration, b::Configuration)

Compares the electronic configurations `a` and `b`, only considering
the constituent orbitals and their occupancy, but disregarding their
ordering and states (`:open`, `:closed`, &c).

# Examples

```jldoctest
julia> a = c"1s 2s"
1s 2s

julia> b = c"2si 1s"
2sⁱ 1s

julia> issimilar(a, b)
true

julia> a==b
false
```

"""
function issimilar(a::Configuration{<:O}, b::Configuration{<:O}) where {O<:AbstractOrbital}
    ca = sorted(a)
    cb = sorted(b)
    ca.orbitals == cb.orbitals && ca.occupancy == cb.occupancy
end

"""
    ==(a::Configuration, b::Configuration)

Tests if configurations `a` and `b` are the same, considering orbital occupancy,
ordering, and states.

# Examples

```jldoctest
julia> c"1s 2s" == c"1s 2s"
true

julia> c"1s 2s" == c"1s 2si"
false

julia> c"1s 2s" == c"2s 1s"
false
```

"""
Base.:(==)(a::Configuration{<:O}, b::Configuration{<:O}) where {O<:AbstractOrbital} =
    a.orbitals == b.orbitals &&
    a.occupancy == b.occupancy &&
    a.states == b.states

Base.hash(c::Configuration, h::UInt) = hash(c.orbitals, hash(c.occupancy, hash(c.states, h)))

"""
    fill(c::Configuration)

Returns a corresponding configuration where the orbitals are completely filled (as
determined by [`degeneracy`](@ref)).

See also: [`fill!`](@ref)
"""
Base.fill(config::Configuration) = fill!(deepcopy(config))

"""
    fill!(c::Configuration)

Sets all the occupancies in configuration `c` to maximum, as determined by the
[`degeneracy`](@ref) function.

See also: [`fill`](@ref)
"""
function Base.fill!(config::Configuration)
    config.occupancy .= (degeneracy(o) for o in config.orbitals)
    return config
end

"""
    close(c::Configuration)

Return a corresponding configuration where where all the orbitals are marked `:closed`.

See also: [`close!`](@ref)
"""
Base.close(config::Configuration) = close!(deepcopy(config))

"""
    close!(c::Configuration)

Marks all the orbitals in configuration `c` as closed.

See also: [`close`](@ref)
"""
function close!(config::Configuration)
    if any(occ != degeneracy(o) for (o, occ, _) in config)
        throw(ArgumentError("Can't close $config due to unfilled orbitals."))
    end
    config.states .= :closed
    return config
end

function write_orbitals(io::IO, config::Configuration)
    ascii = get(io, :ascii, false)
    for (i,(orb,occ,state)) in enumerate(config)
        i > 1 && write(io, " ")
        show(io, orb)
        occ > 1 && write(io, ascii ? "$occ" : to_superscript(occ))
        state == :closed && write(io, ascii ? "c" : "ᶜ")
        state == :inactive && write(io, ascii ? "i" : "ⁱ")
    end
end

function Base.show(io::IO, config::Configuration{O}) where O
    ascii = get(io, :ascii, false)
    nc = length(config)
    if nc == 0
        write(io, ascii ? "empty" : "∅")
        return
    end
    noble_core_name = get_noble_core_name(config)
    core_config = core(config)
    ncc = length(core_config)
    if !isnothing(noble_core_name)
        write(io, "[$(noble_core_name)]")
        write(io, ascii ? "c" : "ᶜ")
        ngc = length(get_noble_gas(O, noble_core_name))
        core_config = core(config)
        if ncc > ngc
            write(io, ' ')
            write_orbitals(io, core_config[ngc+1:end])
        end
        nc > ncc && write(io, ' ')
    elseif ncc > 0
        write_orbitals(io, core_config)
    end
    write_orbitals(io, peel(config))
end

function Base.ascii(config::Configuration)
    io = IOBuffer()
    ctx = IOContext(io, :ascii=>true)
    show(ctx, config)
    String(take!(io))
end

"""
    get_noble_core_name(config::Configuration)

Returns the name of the noble gas with the most electrons whose configuration still forms
the first part of the closed part of `config`, or `nothing` if no such element is found.

```jldoctest
julia> AtomicLevels.get_noble_core_name(c"[He] 2s2")
"He"

julia> AtomicLevels.get_noble_core_name(c"1s2c 2s2c 2p6c 3s2c")
"Ne"

julia> AtomicLevels.get_noble_core_name(c"1s2") === nothing
true
```
"""
function get_noble_core_name(config::Configuration{O}) where O
    nc = length(config)
    nc == 0 && return nothing
    core_config = core(config)
    ncc = length(core_config)
    if length(core_config) > 0
        for gas in Iterators.reverse(noble_gases)
            gas_cfg = get_noble_gas(O, gas)
            ngc = length(gas_cfg)
            if ncc ≥ ngc && issimilar(core_config[1:length(gas_cfg)], gas_cfg)
                return gas
            end
        end
    end
    return nothing
end

function state_sym(state::AbstractString)
    if state == "c" || state == "ᶜ"
        :closed
    elseif state == "i" || state == "ⁱ"
        :inactive
    else
        :open
    end
end

function core_configuration(::Type{O}, element::AbstractString, state::AbstractString, sorted) where {O<:AbstractOrbital}
    element ∉ keys(noble_gases_configurations[O]) && throw(ArgumentError("Unknown noble gas $(element)"))
    state = state_sym(state == "" ? "c" : state) # By default, we'd like cores to be frozen
    core_config = noble_gases_configurations[O][element]
    Configuration(core_config.orbitals, core_config.occupancy,
                  [state for o in core_config.orbitals],
                  sorted=sorted)
end

function parse_orbital_occupation(::Type{O}, orb_str) where {O<:AbstractOrbital}
    m = match(r"^(([0-9]+|.)([a-z]|\[[0-9]+\])[-]{0,1})([0-9]*)([*ci]{0,1})$", orb_str)
    m2 = match(r"^(([0-9]+|.)([a-z]|\[[0-9]+\])[-]{0,1})([¹²³⁴⁵⁶⁷⁸⁹⁰]*)([ᶜⁱ]{0,1})$", orb_str)
    orb,occ,state = if !isnothing(m)
        m[1], m[4], m[5]
    elseif !isnothing(m2)
        m2[1], from_superscript(m2[4]), m2[5]
    else
        throw(ArgumentError("Unknown subshell specification $(orb_str)"))
    end
    parse(O, orb) , (occ == "") ? 1 : parse(Int, occ), state_sym(state)
end

function Base.parse(::Type{Configuration{O}}, conf_str; sorted=false) where {O<:AbstractOrbital}
    isempty(conf_str) && return Configuration{O}(sorted=sorted)
    orbs = split(conf_str, r"[\. ]")
    core_m = match(r"\[([a-zA-Z]+)\]([*ciᶜⁱ]{0,1})", first(orbs))
    if !isnothing(core_m)
        core_config = core_configuration(O, core_m[1], core_m[2], sorted)
        if length(orbs) > 1
            peel_config = Configuration(parse_orbital_occupation.(Ref(O), orbs[2:end]))
            Configuration(vcat(core_config.orbitals, peel_config.orbitals),
                          vcat(core_config.occupancy, peel_config.occupancy),
                          vcat(core_config.states, peel_config.states),
                          sorted=sorted)
        else
            core_config
        end
    else
        Configuration(parse_orbital_occupation.(Ref(O), orbs), sorted=sorted)
    end
end

function parse_conf_str(::Type{O}, conf_str, suffix) where O
    suffix ∈ ["", "s"] || throw(ArgumentError("Unknown configuration suffix $suffix"))
    parse(Configuration{O}, conf_str, sorted=suffix=="s")
end

"""
    @c_str -> Configuration{Orbital}

Construct a [`Configuration`](@ref), representing a non-relativistic
configuration, out of a string. With the added string macro suffix
`s`, the configuration is sorted.

# Examples

```jldoctest
julia> c"1s2 2s"
1s² 2s

julia> c"1s² 2s"
1s² 2s

julia> c"1s2.2s"
1s² 2s

julia> c"[Kr] 4d10 5s2 4f2"
[Kr]ᶜ 4d¹⁰ 5s² 4f²

julia> c"[Kr] 4d10 5s2 4f2"s
[Kr]ᶜ 4d¹⁰ 4f² 5s²
```
"""
macro c_str(conf_str, suffix="")
    parse_conf_str(Orbital, conf_str, suffix)
end

"""
    @rc_str -> Configuration{RelativisticOrbital}

Construct a [`Configuration`](@ref) representing a relativistic
configuration out of a string. With the added string macro suffix `s`,
the configuration is sorted.

# Examples

```jldoctest
julia> rc"[Ne] 3s 3p- 3p"
[Ne]ᶜ 3s 3p- 3p

julia> rc"[Ne] 3s 3p-2 3p4"
[Ne]ᶜ 3s 3p-² 3p⁴

julia> rc"[Ne] 3s 3p-² 3p⁴"
[Ne]ᶜ 3s 3p-² 3p⁴

julia> rc"2p- 1s"s
1s 2p-
```
"""
macro rc_str(conf_str, suffix="")
    parse_conf_str(RelativisticOrbital, conf_str, suffix)
end

"""
    @scs_str -> Vector{<:SpinConfiguration{<:Orbital}}

Generate all possible spin-configurations out of a string. With the
added string macro suffix `s`, the configuration is sorted.

# Examples

```jldoctest
julia> scs"1s2 2p2"
15-element Vector{SpinConfiguration{SpinOrbital{Orbital{Int64}, Tuple{Int64, HalfIntegers.Half{Int64}}}}}:
 1s₀α 1s₀β 2p₋₁α 2p₋₁β
 1s₀α 1s₀β 2p₋₁α 2p₀α
 1s₀α 1s₀β 2p₋₁α 2p₀β
 1s₀α 1s₀β 2p₋₁α 2p₁α
 1s₀α 1s₀β 2p₋₁α 2p₁β
 1s₀α 1s₀β 2p₋₁β 2p₀α
 1s₀α 1s₀β 2p₋₁β 2p₀β
 1s₀α 1s₀β 2p₋₁β 2p₁α
 1s₀α 1s₀β 2p₋₁β 2p₁β
 1s₀α 1s₀β 2p₀α 2p₀β
 1s₀α 1s₀β 2p₀α 2p₁α
 1s₀α 1s₀β 2p₀α 2p₁β
 1s₀α 1s₀β 2p₀β 2p₁α
 1s₀α 1s₀β 2p₀β 2p₁β
 1s₀α 1s₀β 2p₁α 2p₁β
```
"""
macro scs_str(conf_str, suffix="")
    spin_configurations(parse_conf_str(Orbital, conf_str, suffix))
end

"""
    @rscs_str -> Vector{<:SpinConfiguration{<:RelativisticOrbital}}

Generate all possible relativistic spin-configurations out of a
string. With the added string macro suffix `s`, the configuration is
sorted.

# Examples

```jldoctest
julia> rscs"1s2 2p2"
6-element Vector{SpinConfiguration{SpinOrbital{RelativisticOrbital{Int64}, Tuple{HalfIntegers.Half{Int64}}}}}:
 1s(-1/2) 1s(1/2) 2p(-3/2) 2p(-1/2)
 1s(-1/2) 1s(1/2) 2p(-3/2) 2p(1/2)
 1s(-1/2) 1s(1/2) 2p(-3/2) 2p(3/2)
 1s(-1/2) 1s(1/2) 2p(-1/2) 2p(1/2)
 1s(-1/2) 1s(1/2) 2p(-1/2) 2p(3/2)
 1s(-1/2) 1s(1/2) 2p(1/2) 2p(3/2)
```
"""
macro rscs_str(conf_str, suffix="")
    spin_configurations(parse_conf_str(RelativisticOrbital, conf_str, suffix))
end

Base.getindex(conf::Configuration{O}, i::Integer) where O =
    (conf.orbitals[i], conf.occupancy[i], conf.states[i])
Base.getindex(conf::Configuration{O}, i::Union{<:UnitRange{<:Integer},<:AbstractVector{<:Integer}}) where O =
    Configuration(Tuple{O,Int,Symbol}[conf[ii] for ii in i], sorted=conf.sorted)

Base.iterate(conf::Configuration{O}, (el, i)=(length(conf)>0 ? conf[1] : nothing,1)) where O =
    i > length(conf) ? nothing : (el, (conf[i==length(conf) ? i : i+1],i+1))

Base.length(conf::Configuration) = length(conf.orbitals)
Base.lastindex(conf::Configuration) = length(conf)
Base.eltype(conf::Configuration{O}) where O = (O,Int,Symbol)

function Base.write(io::IO, conf::Configuration{O}) where O
    write(io, 'c')
    if O <: Orbital
        write(io, 'n')
    elseif O <: RelativisticOrbital
        write(io, 'r')
    elseif O <: SpinOrbital
        write(io, 's')
    end
    write(io, length(conf))
    for (orb,occ,state) in conf
        write(io, orb, occ, first(string(state)))
    end
    write(io, conf.sorted)
end

function Base.read(io::IO, ::Type{Configuration})
    read(io, Char) == 'c' || throw(ArgumentError("Failed to read a Configuration from stream"))
    kind = read(io, Char)
    O = if kind == 'n'
        Orbital
    elseif kind == 'r'
        RelativisticOrbital
    elseif kind == 's'
        SpinOrbital
    else
        throw(ArgumentError("Unknown orbital type $(kind)"))
    end
    n = read(io, Int)
    occupations = Vector{Int}(undef, n)
    states = Vector{Symbol}(undef, n)
    orbitals = map(1:n) do i
        orb = read(io, O)
        occupations[i] = read(io, Int)
        s = read(io, Char)
        states[i] = if s == 'o'
            :open
        elseif s == 'c'
            :closed
        elseif s == 'i'
            :inactive
        else
            throw(ArgumentError("Unknown orbital state $(s)"))
        end
        orb
    end
    sorted = read(io, Bool)
    Configuration(orbitals, occupations, states, sorted=sorted)
end

function Base.isless(a::Configuration{<:O}, b::Configuration{<:O}) where {O<:AbstractOrbital}
    a = sorted(a)
    b = sorted(b)
    l = min(length(a),length(b))
    # If they are equal up to orbital l, designate the shorter config
    # as the smaller one.
    a[1:l] == b[1:l] && return length(a) == l
    norm_occ = (orb,w) -> 2w ≥ degeneracy(orb) ? degeneracy(orb) - w : w
    for ((orba,occa,statea),(orbb,occb,stateb)) in zip(a[1:l],b[1:l])
        if orba < orbb
            return true
        elseif orba == orbb
            # This is slightly arbitrary, but we designate the orbital
            # with occupation closest to a filled shell as the smaller
            # one.
            norm_occ(orba,occa) < norm_occ(orbb,occb) && return true
        else
            return false
        end
    end
    false
end

"""
    num_electrons(c::Configuration) -> Int

Return the number of electrons in the configuration.

```jldoctest
julia> num_electrons(c"1s2")
2

julia> num_electrons(rc"[Kr] 5s2 5p-2 5p2")
42
```
"""
num_electrons(c::Configuration) = sum(c.occupancy)

"""
    num_electrons(c::Configuration, o::AbstractOrbital) -> Int

Returns the number of electrons on orbital `o` in configuration `c`. If `o` is not part of
the configuration, returns `0`.

```jldoctest
julia> num_electrons(c"1s 2s2", o"2s")
2

julia> num_electrons(rc"[Rn] Qf-5 Pf3", ro"Qf-")
5

julia> num_electrons(c"[Ne]", o"3s")
0
```
"""
function num_electrons(c::Configuration, o::AbstractOrbital)
    idx = findfirst(isequal(o), c.orbitals)
    isnothing(idx) && return 0
    c.occupancy[idx]
end

"""
    in(o::AbstractOrbital, c::Configuration) -> Bool

Checks if orbital `o` is part of configuration `c`.

```jldoctest
julia> in(o"2s", c"1s2 2s2")
true

julia> o"2p" ∈ c"1s2 2s2"
false
```
"""
Base.in(orb::O, conf::Configuration{O}) where {O<:AbstractOrbital} =
    orb ∈ conf.orbitals

"""
    filter(f, c::Configuration) -> Configuration

Filter out the orbitals from configuration `c` for which the predicate `f` returns `false`.
The predicate `f` needs to take three arguments: `orbital`, `occupancy` and `state`.

```julia
julia> filter((o,occ,s) -> o.ℓ == 1, c"[Kr]")
2p⁶ᶜ 3p⁶ᶜ 4p⁶ᶜ
```
"""
Base.filter(f::Function, conf::Configuration) =
    conf[filter(j -> f(conf[j]...), eachindex(conf.orbitals))]

"""
    core(::Configuration) -> Configuration

Return the core configuration (i.e. the sub-configuration of all the orbitals that are
marked `:closed`).

```jldoctest
julia> core(c"1s2c 2s2c 2p6c 3s2")
[Ne]ᶜ

julia> core(c"1s2 2s2")
∅

julia> core(c"1s2 2s2c 2p6c")
2s²ᶜ 2p⁶ᶜ
```
"""
core(conf::Configuration) = filter((orb,occ,state) -> state == :closed, conf)

"""
    peel(::Configuration) -> Configuration

Return the non-core part of the configuration (i.e. orbitals not marked `:closed`).

```jldoctest
julia> peel(c"1s2c 2s2c 2p3")
2p³

julia> peel(c"[Ne] 3s 3p3")
3s 3p³
```
"""
peel(conf::Configuration) = filter((orb,occ,state) -> state != :closed, conf)

"""
    inactive(::Configuration) -> Configuration

Return the part of the configuration marked `:inactive`.

```jldoctest
julia> inactive(c"1s2c 2s2i 2p3i 3s2")
2s²ⁱ 2p³ⁱ
```
"""
inactive(conf::Configuration) = filter((orb,occ,state) -> state == :inactive, conf)

"""
    active(::Configuration) -> Configuration

Return the part of the configuration marked `:open`.

```jldoctest
julia> active(c"1s2c 2s2i 2p3i 3s2")
3s²
```
"""
active(conf::Configuration) = filter((orb,occ,state) -> state != :inactive, peel(conf))

"""
    bound(::Configuration) -> Configuration

Return the bound part of the configuration (see also [`isbound`](@ref)).

```jldoctest
julia> bound(c"1s2 2s2 2p4 Ks2 Kp1")
1s² 2s² 2p⁴
```
"""
bound(conf::Configuration) = filter((orb,occ,state) -> isbound(orb), conf)

"""
    continuum(::Configuration) -> Configuration

Return the non-bound (continuum) part of the configuration (see also [`isbound`](@ref)).

```jldoctest
julia> continuum(c"1s2 2s2 2p4 Ks2 Kp1")
Ks² Kp
```
"""
continuum(conf::Configuration) = filter((orb,occ,state) -> !isbound(orb), peel(conf))

Base.empty(conf::Configuration{O}) where {O<:AbstractOrbital} =
    Configuration(empty(conf.orbitals), empty(conf.occupancy), empty(conf.states), sorted=conf.sorted)

"""
    parity(::Configuration) -> Parity

Return the parity of the configuration.

```jldoctest
julia> parity(c"1s 2p")
odd

julia> parity(c"1s 2p2")
even
```

See also: [`Parity`](@ref)
"""
parity(conf::Configuration) = mapreduce(o -> parity(o[1])^o[2], *, conf)

"""
    replace(conf, a => b[; append=false])

Substitute one electron in orbital `a` of `conf` by one electron in
orbital `b`. If `conf` is unsorted the substitution is performed
in-place, unless `append`, in which case the new orbital is appended
instead.

# Examples

```jldoctest
julia> replace(c"1s2 2s", o"1s" => o"2p")
1s 2p 2s

julia> replace(c"1s2 2s", o"1s" => o"2p", append=true)
1s 2s 2p

julia> replace(c"1s2 2s"s, o"1s" => o"2p")
1s 2s 2p
```
"""
function Base.replace(conf::Configuration{O₁}, orbs::Pair{O₂,O₃};
                      append=false) where {O<:AbstractOrbital,O₁<:O,O₂<:O,O₃<:O}
    src,dest = orbs
    orbitals = promote_type(O₁,O₂,O₃)[]
    append!(orbitals, conf.orbitals)
    occupancy = copy(conf.occupancy)
    states = copy(conf.states)

    i = findfirst(isequal(src), orbitals)
    isnothing(i) && throw(ArgumentError("$(src) not present in $(conf)"))

    j = findfirst(isequal(dest), orbitals)
    if isnothing(j)
        j = (append ? length(orbitals) : i) + 1
        insert!(orbitals, j, dest)
        insert!(occupancy, j, 1)
        insert!(states, j, :open)
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

    Configuration(orbitals, occupancy, states, sorted=conf.sorted)
end

"""
    -(configuration::Configuration, orbital::AbstractOrbital[, n=1])

Remove `n` electrons in the orbital `orbital` from the configuration
`configuration`. If the orbital had previously been `:closed` or
`:inactive`, it will now be `:open`.
"""
function Base.:(-)(configuration::Configuration{O₁}, orbital::O₂, n::Int=1) where {O<:AbstractOrbital,O₁<:O,O₂<:O}
    orbitals = promote_type(O₁,O₂)[]
    append!(orbitals, configuration.orbitals)
    occupancy = copy(configuration.occupancy)
    states = copy(configuration.states)

    i = findfirst(isequal(orbital), orbitals)
    isnothing(i) && throw(ArgumentError("$(orbital) not present in $(configuration)"))

    occupancy[i] ≥ n ||
        throw(ArgumentError("Trying to remove $(n) electrons from orbital $(orbital) with occupancy $(occupancy[i])"))

    occupancy[i] -= n
    states[i] = :open
    if occupancy[i] == 0
        deleteat!(orbitals, i)
        deleteat!(occupancy, i)
        deleteat!(states, i)
    end

    Configuration(orbitals, occupancy, states, sorted=configuration.sorted)
end

"""
    +(::Configuration, ::Configuration)

Add two configurations together. If both configuration have an orbital, the number of
electrons gets added together, but in this case the status of the orbitals must match.

```jldoctest
julia> c"1s" + c"2s"
1s 2s

julia> c"1s" + c"1s"
1s²
```
"""
function Base.:(+)(a::Configuration{O₁}, b::Configuration{O₂}) where {O<:AbstractOrbital,O₁<:O,O₂<:O}
    orbitals = promote_type(O₁,O₂)[]
    append!(orbitals, a.orbitals)
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
    Configuration(orbitals, occupancy, states, sorted=a.sorted && b.sorted)
end

"""
    delete!(c::Configuration, o::AbstractOrbital)

Remove the entire subshell corresponding to orbital `o` from configuration `c`.

```jldoctest
julia> delete!(c"[Ar] 4s2 3d10 4p2", o"4s")
[Ar]ᶜ 3d¹⁰ 4p²
```
"""
function Base.delete!(c::Configuration{O}, o::O) where O <: AbstractOrbital
    idx = findfirst(isequal(o), [co[1] for co in c])
    idx === nothing && return c
    deleteat!(c.orbitals, idx)
    deleteat!(c.occupancy, idx)
    deleteat!(c.states, idx)
    return c
end

"""
    ⊗(::Union{Configuration, Vector{Configuration}}, ::Union{Configuration, Vector{Configuration}})

Given two collections of `Configuration`s, it creates an array of `Configuration`s with all
possible juxtapositions of configurations from each collection.

# Examples

```jldoctest
julia> c"1s" ⊗ [c"2s2", c"2s 2p"]
2-element Vector{Configuration{Orbital{Int64}}}:
 1s 2s²
 1s 2s 2p

julia> [rc"1s", rc"2s"] ⊗ [rc"2p-", rc"2p"]
4-element Vector{Configuration{RelativisticOrbital{Int64}}}:
 1s 2p-
 1s 2p
 2s 2p-
 2s 2p
```
"""
⊗(a::Vector{<:Configuration}, b::Vector{<:Configuration}) =
    [x+y for x in a for y in b]
⊗(a::Union{<:Configuration,Vector{<:Configuration}}, b::Configuration) =
    a ⊗ [b]
⊗(a::Configuration, b::Vector{<:Configuration}) =
    [a] ⊗ b

"""
    rconfigurations_from_orbital(n, ℓ, occupancy)

Generate all `Configuration`s with relativistic orbitals corresponding to the
non-relativistic orbital with `n` and `ℓ` quantum numbers, with given occupancy.

# Examples

```jldoctest
julia> AtomicLevels.rconfigurations_from_orbital(3, 1, 2)
3-element Vector{Configuration{var"#s16"} where var"#s16"<:RelativisticOrbital}:
 3p-²
 3p- 3p
 3p²
```
"""
function rconfigurations_from_orbital(n::N, ℓ::Int, occupancy::Int) where {N<:MQ}
    n isa Integer && ℓ + 1 > n && throw(ArgumentError("ℓ=$ℓ too high for given n=$n"))
    occupancy > 2*(2ℓ + 1) && throw(ArgumentError("occupancy=$occupancy too high for given ℓ=$ℓ"))

    degeneracy_ℓm, degeneracy_ℓp = 2ℓ, 2ℓ + 2 # degeneracies of nℓ- and nℓ orbitals
    nlow_min = max(occupancy - degeneracy_ℓp, 0)
    nlow_max = min(degeneracy_ℓm, occupancy)
    confs = RelativisticConfiguration[]
    for nlow = nlow_max:-1:nlow_min
        nhigh = occupancy - nlow
        conf = if nlow == 0
            Configuration([RelativisticOrbital(n, ℓ, ℓ + 1//2)], [nhigh])
        elseif nhigh == 0
            Configuration([RelativisticOrbital(n, ℓ, ℓ - 1//2)], [nlow])
        else
            Configuration(
                [RelativisticOrbital(n, ℓ, ℓ - 1//2),
                 RelativisticOrbital(n, ℓ, ℓ + 1//2)],
                [nlow, nhigh]
            )
        end
        push!(confs, conf)
    end
    return confs
end

"""
    rconfigurations_from_orbital(orbital::Orbital, occupancy)

Generate all `Configuration`s with relativistic orbitals corresponding to the
non-relativistic version of the `orbital` with a given occupancy.

# Examples

```jldoctest
julia> AtomicLevels.rconfigurations_from_orbital(o"3p", 2)
3-element Vector{Configuration{var"#s16"} where var"#s16"<:RelativisticOrbital}:
 3p-²
 3p- 3p
 3p²
```
"""
function rconfigurations_from_orbital(orbital::Orbital, occupation::Integer)
    rconfigurations_from_orbital(orbital.n, orbital.ℓ, occupation)
end

function rconfigurations_from_nrstring(orb_str::AbstractString)
    m = match(r"^([0-9]+|.)([a-z]+)([0-9]+)?$", orb_str)
    isnothing(m) && throw(ArgumentError("Invalid orbital string: $(orb_str)"))
    n = parse_orbital_n(m)
    ℓ = parse_orbital_ℓ(m)
    occupancy = isnothing(m[3]) ? 1 : parse(Int, m[3])
    return rconfigurations_from_orbital(n, ℓ, occupancy)
end

"""
    relconfigurations(c::Configuration{<:Orbital}) -> Vector{<:Configuration{<:RelativisticOrbital}}

Generate all relativistic configurations from the non-relativistic
configuration `c`, by applying [`rconfigurations_from_orbital`](@ref)
to each subshell and combining the results.
"""
function relconfigurations(c::Configuration{<:Orbital})
    rcs = map(c) do (orb,occ,state)
        orcs = rconfigurations_from_orbital(orb, occ)
        if state == :closed
            close!.(orcs)
        end
        orcs
    end
    if length(rcs) > 1
        rcs = map(Iterators.product(rcs...)) do subshells
            reduce(⊗, subshells)
        end
    end
    reduce(vcat, rcs)
end

relconfigurations(cs::Vector{<:Configuration{<:Orbital}}) =
    reduce(vcat, map(relconfigurations, cs))

"""
    @rcs_str -> Vector{Configuration{RelativisticOrbital}}

Construct a `Vector` of all `Configuration`s corresponding to the non-relativistic `nℓ`
orbital with the given occupancy from the input string.

The string is assumed to have the following syntax: `\$(n)\$(ℓ)\$(occupancy)`, where `n`
and `occupancy` are integers, and `ℓ` is in spectroscopic notation.

# Examples

```jldoctest
julia> rcs"3p2"
3-element Vector{Configuration{var"#s16"} where var"#s16"<:RelativisticOrbital}:
 3p-²
 3p- 3p
 3p²
```
"""
macro rcs_str(s)
    rconfigurations_from_nrstring(s)
end


"""
    spin_configurations(configuration)

Generate all possible configurations of spin-orbitals from `configuration`, i.e. all
permissible values for the quantum numbers `n`, `ℓ`, `mℓ`, `ms` for each electron. Example:

```jldoctest
julia> spin_configurations(c"1s2")
1-element Vector{SpinConfiguration{SpinOrbital{Orbital{Int64}, Tuple{Int64, HalfIntegers.Half{Int64}}}}}:
 1s₀α 1s₀β

julia> spin_configurations(c"1s2"s)
1-element Vector{SpinConfiguration{SpinOrbital{Orbital{Int64}, Tuple{Int64, HalfIntegers.Half{Int64}}}}}:
 1s₀α 1s₀β

julia> spin_configurations(c"1s ks")
4-element Vector{SpinConfiguration{SpinOrbital{var"#s10", Tuple{Int64, HalfIntegers.Half{Int64}}} where var"#s10"<:Orbital}}:
 1s₀α ks₀α
 1s₀β ks₀α
 1s₀α ks₀β
 1s₀β ks₀β
```
"""
function spin_configurations(cfg::Configuration{O}) where O
    states = Dict{O,Symbol}()
    orbitals = map(cfg) do (orb,occ,state)
        states[orb] = state
        sorbs = spin_orbitals(orb)
        collect(combinations(sorbs, occ))
    end
    map(Iterators.product(orbitals...)) do choice
        c = vcat(choice...)
        s = [states[orb.orb] for orb in c]
        Configuration(c, ones(Int,length(c)), s, sorted=cfg.sorted)
    end |> vec
end

Base.convert(::Type{Configuration{O}}, c::Configuration) where {O<:AbstractOrbital} =
    Configuration(Vector{O}(c.orbitals), c.occupancy, c.states, sorted=c.sorted)

Base.convert(::Type{Configuration{SO}}, c::Configuration{<:SpinOrbital}) where {SO<:SpinOrbital} =
    Configuration(Vector{SO}(c.orbitals), c.occupancy, c.states, sorted=c.sorted)

Base.promote_type(::Type{Configuration{SO}}, ::Type{Configuration{SO}}) where {SO<:SpinOrbital} =
    Configuration{SO}

Base.promote_type(::Type{CA}, ::Type{CB}) where {
    A<:SpinOrbital,CA<:Configuration{A},
    B<:SpinOrbital,CB<:Configuration{B}
} =
    Configuration{promote_type(A,B)}

Base.promote_type(::Type{Cfg}, ::Type{Union{}}) where {SO<:SpinOrbital,Cfg<:Configuration{SO}} = Cfg

"""
    spin_configurations(configurations)

For each configuration in `configurations`, generate all possible configurations of
spin-orbitals.
"""
function spin_configurations(cs::Vector{<:Configuration})
    scs = map(spin_configurations, cs)
    sort(reduce(vcat, scs))
end

"""
    SpinConfiguration

Specialization of [`Configuration`](@ref) for configurations
consisting of [`SpinOrbital`](@ref)s.
"""
const SpinConfiguration{O<:SpinOrbital} = Configuration{O}

spin_configurations(c::SpinConfiguration) = [c]

function Base.parse(::Type{SpinConfiguration{SO}}, conf_str; sorted=false) where {O<:AbstractOrbital,SO<:SpinOrbital{O}}
    isempty(conf_str) && return SpinConfiguration{SO}(sorted=sorted)
    orbs = split(conf_str, r"[ ]")
    core_m = match(r"\[([a-zA-Z]+)\]([*ci]{0,1})", first(orbs))
    if !isnothing(core_m)
        core_config = first(spin_configurations(core_configuration(O, core_m[1], core_m[2], sorted)))
        if length(orbs) > 1
            peel_orbitals = parse.(Ref(SO), orbs[2:end])
            orbitals = vcat(core_config.orbitals, peel_orbitals)
            Configuration(orbitals,
                          ones(Int, length(orbitals)),
                          vcat(core_config.states, fill(:open, length(peel_orbitals))),
                          sorted=sorted)
        else
            core_config
        end
    else
        Configuration(parse.(Ref(SO), orbs), ones(Int, length(orbs)), sorted=sorted)
    end
end

"""
    @sc_str -> SpinConfiguration{<:SpinOrbital{<:Orbital}}

A string macro to construct a non-relativistic [`SpinConfiguration`](@ref).

# Examples

```jldoctest
julia> sc"1s₀α 2p₋₁β"
1s₀α 2p₋₁β

julia> sc"ks(0,-1/2) l[4](-3,1/2)"
ks₀β lg₋₃α
```
"""
macro sc_str(conf_str, suffix="")
    parse(SpinConfiguration{SpinOrbital{Orbital}}, conf_str, sorted=suffix=="s")
end

"""
    @rsc_str -> SpinConfiguration{<:SpinOrbital{<:RelativisticOrbital}}

A string macro to construct a relativistic [`SpinConfiguration`](@ref).

# Examples

```jldoctest
julia> rsc"1s(1/2) 2p(-1/2)"
1s(1/2) 2p(-1/2)

julia> rsc"ks(-1/2) l[4]-(-5/2)"
ks(-1/2) lg-(-5/2)
```
"""
macro rsc_str(conf_str, suffix="")
    parse(SpinConfiguration{SpinOrbital{RelativisticOrbital}}, conf_str, sorted=suffix=="s")
end

function Base.show(io::IO, c::SpinConfiguration)
    ascii = get(io, :ascii, false)
    nc = length(c)
    if nc == 0
        write(io, ascii ? "empty" : "∅")
        return
    end

    orbitals = Dict{Orbital, Vector{<:SpinOrbital}}()
    core_orbitals = sort(unique(map(o -> o.orb, core(c).orbitals)))
    core_cfg = Configuration(core_orbitals, ones(Int, length(core_orbitals))) |> fill |> close

    if !isempty(core_cfg)
        show(io, core_cfg)
        write(io, " ")
    end
    # if !c.sorted
    # In the unsorted case, we do not yet contract subshells for
    # printing; to be implemented.
    so = string.(peel(c).orbitals)
    write(io, join(so, " "))
    return
    # end
    # for orb in peel(c).orbitals
    #     orbitals[orb.orb] = push!(get(orbitals, orb.orb, SpinOrbital[]), orb)
    # end
    # map(sort(collect(keys(orbitals)))) do orb
    #     ℓ = orb.ℓ
    #     g = degeneracy(orb)
    #     sub_shell = orbitals[orb]
    #     if length(sub_shell) == g
    #         format("{1:s}{2:s}", orb, to_superscript(g))
    #     else
    #         map(Iterators.product()mℓrange(orb)) do mℓ
    #             mℓshell = findall(o -> o.mℓ == mℓ, sub_shell)
    #             if length(mℓshell) == 2
    #                 format("{1:s}{2:s}{3:s}", orb, to_subscript(mℓ), to_superscript(2))
    #             elseif length(mℓshell) == 1
    #                 string(sub_shell[mℓshell[1]])
    #             else
    #                 ""
    #             end
    #         end |> so -> join(filter(s -> !isempty(s), so), " ")
    #     end
    # end |> so -> write(io, join(so, " "))
end

"""
    substitutions(src::SpinConfiguration, dst::SpinConfiguration)

Find all orbital substitutions going from spin-configuration `src` to
configuration `dst`.
"""
function substitutions(src::Configuration{A}, dst::Configuration{B}) where {A<:SpinOrbital,B<:SpinOrbital}
    src == dst && return []
    # This is only valid for spin-configurations, since occupation
    # numbers are not dealt with.
    num_electrons(src) == num_electrons(dst) ||
        throw(ArgumentError("Configurations not of same amount of electrons"))
    r = Vector{Pair{A,B}}()
    missing = A[]
    same = Int[]
    for (i,(orb,occ,state)) in enumerate(src)
        j = findfirst(isequal(orb), dst.orbitals)
        if j === nothing
            push!(missing, orb)
        else
            push!(same, j)
        end
    end
    new = [j for j ∈ 1:num_electrons(dst)
           if j ∉ same]
    [mo => dst.orbitals[j] for (mo,j) in zip(missing, new)]
end

# We need to declare noble_gases first, with empty entries for Orbital and RelativisticOrbital
# since parse(Configuration, ...) uses it.
const noble_gases_configurations = Dict(
    O => Dict{String,Configuration{<:O}}()
    for O in [Orbital, RelativisticOrbital]
)
const noble_gases_configuration_strings = [
    "He" => "1s2",
    "Ne" => "[He] 2s2 2p6",
    "Ar" => "[Ne] 3s2 3p6",
    "Kr" => "[Ar] 3d10 4s2 4p6",
    "Xe" => "[Kr] 4d10 5s2 5p6",
    "Rn" => "[Xe] 4f14 5d10 6s2 6p6",
]
const noble_gases = [gas for (gas, _) in noble_gases_configuration_strings]
for (gas, configuration) in noble_gases_configuration_strings, O in [Orbital, RelativisticOrbital]
    noble_gases_configurations[O][gas] = parse(Configuration{O}, configuration)
end

# This construct is needed since when showing configurations, they
# will be specialized on the Orbital parameterization, which we cannot
# index noble_gases with.
for O in [Orbital, RelativisticOrbital]
    @eval get_noble_gas(::Type{<:$O}, k) = noble_gases_configurations[$O][k]
end

"""
    nonrelconfiguration(c::Configuration{<:RelativisticOrbital}) -> Configuration{<:Orbital}

Reduces a relativistic configuration down to the corresponding non-relativistic configuration.

```jldoctest
julia> c = rc"1s2 2p-2 2s 2p2 3s2 3p-"s
1s² 2s 2p-² 2p² 3s² 3p-

julia> nonrelconfiguration(c)
1s² 2s 2p⁴ 3s² 3p
```
"""
function nonrelconfiguration(c::Configuration{<:RelativisticOrbital})
    mq = Union{mqtype.(c.orbitals)...}
    nrorbitals, nroccupancies, nrstates = Orbital{<:mq}[], Int[], Symbol[]
    for (orbital, occupancy, state) in c
        nrorbital = nonrelorbital(orbital)
        nridx = findfirst(isequal(nrorbital), nrorbitals)
        if isnothing(nridx)
            push!(nrorbitals, nrorbital)
            push!(nroccupancies, occupancy)
            push!(nrstates, state)
        else
            nrstates[nridx] == state || throw(ArgumentError("Mismatching states for $(nrorbital). Previously found $(nrstates[nridx]), but $(orbital) has $(state)"))
            nroccupancies[nridx] += occupancy
        end
    end
    Configuration(nrorbitals, nroccupancies, nrstates)
end

"""
    multiplicity(::Configuration)

Calculates the number of Slater determinants corresponding to the configuration.
"""
multiplicity(c::Configuration) = prod(binomial.(degeneracy.(c.orbitals), c.occupancy))

export Configuration, @c_str, @rc_str, @sc_str, @rsc_str, @scs_str, @rscs_str, issimilar,
    num_electrons, core, peel, active, inactive, bound, continuum, parity, ⊗, @rcs_str,
    SpinConfiguration, spin_configurations, substitutions, close!,
    nonrelconfiguration, relconfigurations
