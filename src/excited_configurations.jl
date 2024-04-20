"""
    orbital_priority(fun, orig_cfg, orbitals)

Generate priorities for the substitution `orbitals`, i.e. the
preferred ordering of the orbitals in configurations excited from
`orig_cfg`. `fun` can optionally transform the labels of substitution
orbitals, in which case they will be ordered just after their parent
orbital in the source configuration; otherwise they will be appended
to the priority list.
"""
function orbital_priority(fun::Function, orig_cfg::Configuration{O₁}, orbitals::Vector{O₂}) where {O₁<:AbstractOrbital,O₂<:AbstractOrbital}
    orbital_priority = Vector{promote_type(O₁,O₂)}()
    append!(orbital_priority, orig_cfg.orbitals)
    for (orb,occ,state) in orig_cfg
        for new_orb in orbitals
            subs_orb = fun(new_orb, orb)
            (new_orb == subs_orb || subs_orb ∈ orbital_priority) && continue
            push!(orbital_priority, subs_orb)
        end
    end
    # This is not exactly correct, since if there is a transformation
    # in effect (`fun` not returning the same orbital), they should
    # not be included in the orbital priority list, whereas if there
    # is no transformation, they should be appended since they have
    # the lowest priority (compared to the original
    # orbitals). However, if there is a transformation, the resulting
    # orbitals will be different from the ingoing ones, and the
    # subsequent excitations will never consider the untransformed
    # substitution orbitals, so there is really no harm done.
    for new_orb in orbitals
        (new_orb ∈ orbital_priority) && continue
        push!(orbital_priority, new_orb)
    end

    Dict(o => i for (i,o) in enumerate(orbital_priority))
end

function single_excitations!(fun::Function,
                             excitations::Vector{<:Configuration},
                             ref_set::Configuration,
                             orbitals::Vector{<:AbstractOrbital},
                             min_occupancy::Vector{Int},
                             max_occupancy::Vector{Int},
                             excite_from::Int)
    orig_cfg = first(excitations)
    orbital_order = orbital_priority(fun, orig_cfg, orbitals)
    for config ∈ excitations[end-excite_from+1:end]
        for (orb_i,(orb,occ,state)) ∈ enumerate(config)
            state != :open && continue
            # If the orbital we propose to excite from is among those
            # from the reference set and already at its minimum
            # occupancy, we continue.
            i = findfirst(isequal(orb), ref_set.orbitals)
            !isnothing(i) && occ == min_occupancy[i] && continue

            for (new_orb_i,new_orb) ∈ enumerate(orbitals)
                subs_orb = fun(new_orb, orb)
                subs_orb == orb && continue
                # If the proposed substitution orbital is among those
                # from the reference set and already present in the
                # configuration to excite, we check if it is already
                # at its maximum occupancy, in which case we continue.
                j = findfirst(isequal(subs_orb), ref_set.orbitals)
                k = findfirst(isequal(subs_orb), config.orbitals)
                !isnothing(j) && !isnothing(k) && config.occupancy[k] == max_occupancy[j] && continue
                # Likewise, if the proposed substitution orbital is
                # already at its maximum, due to the degeneracy, we
                # continue.
                !isnothing(k) && config.occupancy[k] == degeneracy(subs_orb) && continue

                # If we are working with unsorted configurations and
                # the substitution orbital is not already present in
                # config, we need to check if the substitution would
                # generate a configuration that violates the desired
                # orbital priority.
                if isnothing(k) && !config.sorted
                    sp = orbital_order[subs_orb]

                    # Make sure that no preceding orbital has higher
                    # value than subs_orb.
                    any(orbital_order[o] > sp
                        for o in config.orbitals) && continue
                end

                excited_config = replace(config, orb=>subs_orb, append=true)
                excited_config ∉ excitations && push!(excitations, excited_config)
            end
        end
    end
end

# For configurations of spatial orbitals only, the orbitals of the
# reference are valid orbitals to excite to as well.
substitution_orbitals(ref_set::Configuration, orbitals::O...) where {O<:AbstractOrbital} =
    unique(vcat(peel(ref_set).orbitals, orbitals...))

# For spin-orbitals, we do not want to excite to the orbitals of the
# reference set.
substitution_orbitals(ref_set::SpinConfiguration, orbitals::O...) where {O<:SpinOrbital} =
    filter(o -> o ∉ ref_set, O[orbitals...])

function substitutions!(fun, excitations, ref_set, orbitals,
                        min_excitations, max_excitations,
                        min_occupancy, max_occupancy)
    excite_from = 1
    retain = 1
    for i in 1:max_excitations
        i ≤ min_excitations && (retain = length(excitations)+1)
        single_excitations!(fun, excitations, ref_set, orbitals,
                            min_occupancy, max_occupancy, excite_from)
        excite_from = length(excitations)-excite_from
    end
    deleteat!(excitations, 1:retain-1)
end

function substitutions!(fun, excitations::Vector{<:SpinConfiguration},
                        ref_set::SpinConfiguration, orbitals::Vector{<:SpinOrbital},
                        min_excitations, max_excitations,
                        min_occupancy, max_occupancy)
    subs_orbs = Vector{Vector{eltype(orbitals)}}()
    for orb ∈ ref_set.orbitals
        push!(subs_orbs, filter(!isnothing, map(subs_orb -> fun(subs_orb, orb), orbitals)))
    end

    # Either all substitution orbitals are the same for all source
    # orbitals, or all source orbitals have unique substitution
    # orbitals (generated using `fun`); for simplicity, we do not
    # support a mixture.
    all_same = true
    for i ∈ 2:length(subs_orbs)
        d = [isempty(setdiff(subs_orbs[i], subs_orbs[j]))
             for j in 1:i-1]
        i == 2 && !any(d) && (all_same = false)
        all(d) && all_same || !any(d) && !all_same ||
            throw(ArgumentError("All substitution orbitals have to equal or non-overlapping"))
    end

    source_orbitals = findall(iszero, min_occupancy)

    for i ∈ min_excitations:max_excitations
        # Loop over all slots, e.g. all spin-orbitals we want to
        # excite from.
        for srci ∈ combinations(source_orbitals,i)
            all_substitutions = if all_same
                # In this case, in the first slot, any of the i..n
                # substitution orbitals goes, in the next i+1..n, in
                # the second i+2..n, &c.
                combinations(subs_orbs[1], i)
            else
                # In this case, we simply form the direct product of
                # the source-orbital specific substitution orbitals.
                Iterators.product([subs_orbs[src] for src in srci]...)
            end
            for substitutions in all_substitutions
                cfg = ref_set
                for (j,subs_orb) in enumerate(substitutions)
                    cfg = replace(cfg, ref_set.orbitals[srci[j]] => subs_orb)
                end
                push!(excitations, cfg)
            end
        end
    end
    deleteat!(excitations, 1)
end

"""
    excited_configurations([fun::Function, ] cfg::Configuration,
                           orbitals::AbstractOrbital...
                           [; min_excitations=0, max_excitations=:doubles,
                            min_occupancy=[0, 0, ...], max_occupancy=[..., g_i, ...],
                            keep_parity=true])

Generate all excitations from the reference set `cfg` by substituting
at least `min_excitations` and at most `max_excitations` of the
substitution `orbitals`. `min_occupancy` specifies the minimum
occupation number for each of the source orbitals (default `0`) and
equivalently `max_occupancy` specifies the maximum occupation number
(default is the degeneracy for each orbital). `keep_parity` controls
whether the excited configuration has to have the same parity as
`cfg`. Finally, `fun` allows modification of the substitution orbitals
depending on the source orbitals, which is useful for generating
ionized configurations. If `fun` returns `nothing`, that particular
substitution will be rejected.

# Examples

```jldoctest; filter = r"#s[0-9]+"
julia> excited_configurations(c"1s2", o"2s", o"2p")
4-element Vector{Configuration{Orbital{Int64}}}:
 1s²
 1s 2s
 2s²
 2p²

julia> excited_configurations(c"1s2 2p", o"2p")
2-element Vector{Configuration{Orbital{Int64}}}:
 1s² 2p
 2p³

julia> excited_configurations(c"1s2 2p", o"2p", max_occupancy=[2,2])
1-element Vector{Configuration{Orbital{Int64}}}:
 1s² 2p

julia> excited_configurations(first(scs"1s2"), sos"k[s]"...) do dst,src
           if isbound(src)
               # Generate label that indicates src orbital,
               # i.e. the resultant hole
               SpinOrbital(Orbital(Symbol("[\$(src)]"), dst.orb.ℓ), dst.m)
           else
               dst
           end
       end
9-element Vector{SpinConfiguration{SpinOrbital{<:Orbital, Tuple{Int64, HalfIntegers.Half{Int64}}}}}:
 1s₀α 1s₀β
 [1s₀α]s₀α 1s₀β
 [1s₀α]s₀β 1s₀β
 1s₀α [1s₀β]s₀α
 1s₀α [1s₀β]s₀β
 [1s₀α]s₀α [1s₀β]s₀α
 [1s₀α]s₀β [1s₀β]s₀α
 [1s₀α]s₀α [1s₀β]s₀β
 [1s₀α]s₀β [1s₀β]s₀β

julia> excited_configurations((a,b) -> a.m == b.m ? a : nothing,
                              spin_configurations(c"1s"), sos"k[s-d]"..., keep_parity=false)
8-element Vector{SpinConfiguration{SpinOrbital{<:Orbital, Tuple{Int64, HalfIntegers.Half{Int64}}}}}:
 1s₀α
 ks₀α
 kp₀α
 kd₀α
 1s₀β
 ks₀β
 kp₀β
 kd₀β
```
"""
function excited_configurations(fun::Function,
                                ref_set::Configuration{O},
                                orbitals...;
                                min_excitations::Int=zero(Int),
                                max_excitations::Union{Int,Symbol}=:doubles,
                                min_occupancy::Vector{Int}=zeros(Int, length(peel(ref_set))),
                                max_occupancy::Vector{Int}=[degeneracy(first(o)) for o in peel(ref_set)],
                                keep_parity::Bool=true) where {O<:AbstractOrbital}
    if max_excitations isa Symbol
        max_excitations = if max_excitations == :singles
            1
        elseif max_excitations == :doubles
            2
        else
            throw(ArgumentError("Invalid maximum excitations specification $(max_excitations)"))
        end
    elseif max_excitations < 0
        throw(ArgumentError("Invalid maximum excitations specification $(max_excitations)"))
    end

    min_excitations ≥ 0 && min_excitations ≤ max_excitations ||
        throw(ArgumentError("Invalid minimum excitations specification $(min_excitations)"))

    lp = length(peel(ref_set))
    length(min_occupancy) == lp ||
        throw(ArgumentError("Need to specify $(lp) minimum occupancies for active subshells: $(peel(ref_set))"))
    length(max_occupancy) == lp ||
        throw(ArgumentError("Need to specify $(lp) maximum occupancies for active subshells: $(peel(ref_set))"))

    all(min_occupancy .>= 0) || throw(ArgumentError("Invalid minimum occupancy requested"))
    all(min_occupancy .<= max_occupancy .<= [degeneracy(first(o)) for o in peel(ref_set)]) ||
        throw(ArgumentError("Invalid maximum occupancy requested"))

    ref_set_core = core(ref_set)
    ref_set_peel = peel(ref_set)

    orbitals = substitution_orbitals(ref_set, orbitals...)

    Cfg = Configuration{promote_type(O,eltype(orbitals))}
    excitations = Cfg[ref_set_peel]
    substitutions!(fun, excitations, ref_set_peel, orbitals,
                   min_excitations, max_excitations,
                   min_occupancy, max_occupancy)
    keep_parity && filter!(e -> parity(e) == parity(ref_set), excitations)

    Cfg[ref_set_core + e for e in excitations]
end

excited_configurations(fun::Function, ref_set::Vector{<:Configuration}, args...; kwargs...) =
    unique(reduce(vcat, map(r -> excited_configurations(fun, r, args...; kwargs...), ref_set)))

default_substitution(subs_orb,orb) = subs_orb

excited_configurations(ref_set::Configuration, args...; kwargs...) =
    excited_configurations(default_substitution, ref_set, args...; kwargs...)

excited_configurations(ref_set::Vector{<:Configuration}, args...; kwargs...) =
    excited_configurations(default_substitution, ref_set, args...; kwargs...)

ion_continuum(neutral::Configuration{<:Orbital{<:Integer}},
              continuum_orbitals::Vector{Orbital{Symbol}},
              max_excitations=:singles) =
                  excited_configurations(neutral, continuum_orbitals...;
                                         max_excitations=max_excitations, keep_parity=false)

export excited_configurations, ion_continuum
