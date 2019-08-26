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

function excited_configurations(fun::Function,
                                ref_set::Configuration{O₁},
                                orbitals::O₂...;
                                min_excitations::Int=zero(Int),
                                max_excitations::Union{Int,Symbol}=:doubles,
                                min_occupancy::Vector{Int}=zeros(Int, length(peel(ref_set))),
                                max_occupancy::Vector{Int}=[degeneracy(first(o)) for o in peel(ref_set)],
                                keep_parity::Bool=true) where {O<:AbstractOrbital,
                                                               O₁<:O,O₂<:O}
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
    all(max_occupancy .<= [degeneracy(first(o)) for o in peel(ref_set)]) ||
        throw(ArgumentError("Invalid maximum occupancy requested"))

    ref_set_core = core(ref_set)
    ref_set_peel = peel(ref_set)

    # The orbitals of the reference are valid orbitals to excite to as
    # well.
    orbitals = unique(vcat(ref_set_peel.orbitals, orbitals...))

    excitations = Configuration[ref_set_peel]
    excite_from = 1
    retain = 1
    for i in 1:max_excitations
        i ≤ min_excitations && (retain = length(excitations)+1)
        single_excitations!(fun, excitations, ref_set_peel, orbitals,
                            min_occupancy, max_occupancy, excite_from)
        excite_from = length(excitations)-excite_from
    end
    keep_parity && filter!(e -> parity(e) == parity(ref_set), excitations)

    [ref_set_core + e for e in excitations[retain:end]]
end

excited_configurations(ref_set::Configuration,
                       orbitals...;
                       kwargs...) =
                           excited_configurations((subs_orb,orb)->subs_orb,
                                                  ref_set, orbitals...;
                                                  kwargs...)


ion_continuum(neutral::Configuration{<:Orbital{<:Integer}},
              continuum_orbitals::Vector{Orbital{Symbol}},
              max_excitations=:singles) =
                  excited_configurations(neutral, continuum_orbitals...;
                                         max_excitations=max_excitations, keep_parity=false)

export excited_configurations, ion_continuum
