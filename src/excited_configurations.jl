function single_excitations!(fun::Function,
                             excitations::Vector{<:Configuration},
                             ref_set::Configuration,
                             orbitals::Vector{O},
                             min_occupancy::Vector{Int},
                             max_occupancy::Vector{Int},
                             excite_from::Int) where {O<:AbstractOrbital}
    for config ∈ excitations[end-excite_from+1:end]
        for (orb,occ,state) ∈ config
            state != :open && continue
            # If the orbital we propose to excite from is among those
            # from the reference set and already at its minimum
            # occupancy, we continue.
            i = findfirst(isequal(orb), ref_set.orbitals)
            !isnothing(i) && occ == min_occupancy[i] && continue
            for subs_orb ∈ orbitals
                subs_orb == orb && continue
                # If the proposed substitution orbital is among those
                # from the reference set and already present in the
                # configuration to excite, we check if it is already
                # at its maximum occupancy, in which case we continue.
                j = findfirst(isequal(subs_orb), ref_set.orbitals)
                k = findfirst(isequal(subs_orb), config.orbitals)
                !isnothing(j) && !isnothing(k) && config.occupancy[k] == max_occupancy[j] && continue
                excited_config = replace(config, orb=>fun(subs_orb,orb))
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
    end

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
    orbitals = sort(unique(vcat(ref_set_peel.orbitals, orbitals...)))

    excitations = Configuration[ref_set_peel]
    excite_from = 1
    for i in 1:max_excitations
        single_excitations!(fun, excitations, ref_set_peel, orbitals,
                            min_occupancy, max_occupancy, excite_from)
        excite_from = length(excitations)-excite_from
    end
    keep_parity && filter!(e -> parity(e) == parity(ref_set), excitations)

    [ref_set_core + e for e in excitations]
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
