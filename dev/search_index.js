var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#AtomicLevels.jl-1",
    "page": "Home",
    "title": "AtomicLevels.jl",
    "category": "section",
    "text": "AtomicLevels is a package for working with electron configurations of atoms. The goal is to provide a simple, generic and extensible API to make it easy to script tasks such as the generation of configuration lists for calculations."
},

{
    "location": "#Index-of-types-and-functions-1",
    "page": "Home",
    "title": "Index of types and functions",
    "category": "section",
    "text": "Modules = [AtomicLevels]"
},

{
    "location": "orbitals/#",
    "page": "Orbitals",
    "title": "Orbitals",
    "category": "page",
    "text": ""
},

{
    "location": "orbitals/#Atomic-orbitals-1",
    "page": "Orbitals",
    "title": "Atomic orbitals",
    "category": "section",
    "text": "DocTestSetup = quote\n    using AtomicLevels\nendAtomic orbitals, i.e. single particle states with well-defined orbital or total angular momentum, are usually the basic building blocks of atomic states. AtomicLevels provides various types and methods to conveniently label the orbitals."
},

{
    "location": "orbitals/#AtomicLevels.Orbital",
    "page": "Orbitals",
    "title": "AtomicLevels.Orbital",
    "category": "type",
    "text": "struct Orbital{N <: AtomicLevels.MQ} <: AbstractOrbital\n\nLabel for an atomic orbital with a principal quantum number n::N and orbital angular momentum ℓ.\n\nThe type parameter N has to be such that it can represent a proper principal quantum number (i.e. a subtype of AtomicLevels.MQ).\n\nConstructors\n\nOrbital(n::Int, ℓ::Int)\nOrbital(n::Symbol, ℓ::Int)\n\nConstruct an orbital label with principal quantum number n and orbital angular momentum ℓ. If the principal quantum number n is an integer, it has to positive and the angular momentum must satisfy 0 <= ℓ < n.\n\njulia> Orbital(1, 0)\n1s\n\njulia> Orbital(:K, 2)\nKd\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.RelativisticOrbital",
    "page": "Orbitals",
    "title": "AtomicLevels.RelativisticOrbital",
    "category": "type",
    "text": "struct RelativisticOrbital{N <: AtomicLevels.MQ} <: AbstractOrbital\n\nLabel for an atomic orbital with a principal quantum number n::N and well-defined total angular momentum j. The angular component of the orbital is labelled by the (ell j) pair, conventionally written as ell_j (e.g. p_32).\n\nThe ell and j can not be arbitrary, but must satisfy j = ell pm 12. Internally, the kappa quantum number, which is a unique integer corresponding to every physical (ell j) pair, is used to label each allowed pair. When j = ell pm 12, the corresponding kappa = mp(j + 12).\n\nWhen printing and parsing RelativisticOrbitals, the notation nℓ and nℓ- is used (e.g. 2p and 2p-), corresponding to the orbitals with j = ell + 12 and j = ell - 12, respectively.\n\nThe type parameter N has to be such that it can represent a proper principal quantum number (i.e. a subtype of AtomicLevels.MQ).\n\nConstructors\n\nRelativisticOrbital(n::Integer, κ::Integer)\nRelativisticOrbital(n::Symbol, κ::Integer)\nRelativisticOrbital(n, ℓ::Integer, j::Real)\n\nConstruct an orbital label with the quantum numbers n and κ. If the principal quantum number n is an integer, it has to positive and the orbital angular momentum must satisfy 0 <= ℓ < n. Instead of κ, valid ℓ and j values can also be specified instead.\n\njulia> RelativisticOrbital(1, 0, 1//2)\n1s\n\njulia> RelativisticOrbital(2, -1)\n2s\n\njulia> RelativisticOrbital(:K, 2, 3//2)\nKd⁻\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.SpinOrbital",
    "page": "Orbitals",
    "title": "AtomicLevels.SpinOrbital",
    "category": "type",
    "text": "struct SpinOrbital{O<:Orbital} <: AbstractOrbital\n\nSpin orbitals are fully characterized orbitals, i.e. the quantum numbers n, ℓ, mℓ and ms are all specified.\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.@o_str",
    "page": "Orbitals",
    "title": "AtomicLevels.@o_str",
    "category": "macro",
    "text": "@o_str -> Orbital\n\nA string macro to construct an Orbital from the canonical string representation.\n\njulia> o\"1s\"\n1s\n\njulia> o\"Fd\"\nFd\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.@ro_str",
    "page": "Orbitals",
    "title": "AtomicLevels.@ro_str",
    "category": "macro",
    "text": "@ro_str -> RelativisticOrbital\n\nA string macro to construct an RelativisticOrbital from the canonical string representation.\n\njulia> ro\"1s\"\n1s\n\njulia> ro\"2p-\"\n2p⁻\n\njulia> ro\"Kf-\"\nKf⁻\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.@os_str",
    "page": "Orbitals",
    "title": "AtomicLevels.@os_str",
    "category": "macro",
    "text": "@os_str -> Vector{Orbital}\n\nCan be used to easily construct a list of Orbitals.\n\njulia> os\"5[d] 6[s-p] k[7-10]\"\n7-element Array{Orbital,1}:\n 5d\n 6s\n 6p\n kk\n kl\n km\n kn\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.@ros_str",
    "page": "Orbitals",
    "title": "AtomicLevels.@ros_str",
    "category": "macro",
    "text": "@ros_str -> Vector{RelativisticOrbital}\n\nCan be used to easily construct a list of RelativisticOrbitals.\n\njulia> ros\"2[s-p] 3[p] k[0-d]\"\n10-element Array{RelativisticOrbital,1}:\n 2s\n 2p⁻\n 2p\n 3p⁻\n 3p\n ks\n kp⁻\n kp\n kd⁻\n kd\n\n\n\n\n\n"
},

{
    "location": "orbitals/#Orbital-types-1",
    "page": "Orbitals",
    "title": "Orbital types",
    "category": "section",
    "text": "AtomicLevels provides two basic types for labelling atomic orbitals: Orbital and RelativisticOrbital. Stricly speaking, these types do not label orbitals, but groups of orbitals with the same angular symmetry and radial behaviour (i.e. a subshell).Orbital\nRelativisticOrbitalThe SpinOrbital type can be used to fully qualify all the quantum numbers (that is, also m_ell and m_s) of an Orbital. It represent a since, distinct orbital.SpinOrbitalThe string macros @o_str and @ro_str can be used to conveniently contruct orbitals, while @os_str and @ros_str can be used to construct whole lists of them very easily.@o_str\n@ro_str\n@os_str\n@ros_str"
},

{
    "location": "orbitals/#Base.isless",
    "page": "Orbitals",
    "title": "Base.isless",
    "category": "function",
    "text": "isless(a::Orbital, b::Orbital)\n\nCompares the orbitals a and b to decide which one comes before the other in a configuration.\n\nExamples\n\njulia> o\"1s\" < o\"2s\"\ntrue\n\njulia> o\"1s\" < o\"2p\"\ntrue\n\njulia> o\"ks\" < o\"2p\"\nfalse\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.degeneracy",
    "page": "Orbitals",
    "title": "AtomicLevels.degeneracy",
    "category": "function",
    "text": "degeneracy(orbital::Orbital)\n\nReturns the degeneracy of orbital which is 2(2ℓ+1)\n\nExamples\n\njulia> degeneracy(o\"1s\")\n2\n\njulia> degeneracy(o\"2p\")\n6\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.parity-Tuple{Orbital}",
    "page": "Orbitals",
    "title": "AtomicLevels.parity",
    "category": "method",
    "text": "parity(orbital::Orbital)\n\nReturns the parity of orbital, defined as (-1)^ℓ.\n\nExamples\n\njulia> parity(o\"1s\")\neven\n\njulia> parity(o\"2p\")\nodd\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.symmetry",
    "page": "Orbitals",
    "title": "AtomicLevels.symmetry",
    "category": "function",
    "text": "symmetry(orbital::Orbital)\n\nReturns the symmetry for orbital which is simply ℓ.\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.isbound",
    "page": "Orbitals",
    "title": "AtomicLevels.isbound",
    "category": "function",
    "text": "isbound(::Orbital)\n\nReturns true is the main quantum number is an integer, false otherwise.\n\njulia> isbound(o\"1s\")\ntrue\n\njulia> isbound(o\"ks\")\nfalse\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.mℓrange",
    "page": "Orbitals",
    "title": "AtomicLevels.mℓrange",
    "category": "function",
    "text": "mℓrange(orbital::Orbital)\n\nReturns the range of valid values of mℓ for orbital.\n\nExamples\n\njulia> mℓrange(o\"2p\")\n-1:1\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.spin_orbitals",
    "page": "Orbitals",
    "title": "AtomicLevels.spin_orbitals",
    "category": "function",
    "text": "spin_orbitals(orbital)\n\nGenerate all permissible spin-orbitals for a given orbital, e.g. 2p -> 2p ⊗ mℓ = {-1,0,1} ⊗ s = {α,β}\n\nExamples\n\njulia> spin_orbitals(o\"2p\")\n6-element Array{SpinOrbital{Orbital{Int64}},1}:\n 2p₋₁α\n 2p₋₁β\n 2p₀α\n 2p₀β\n 2p₁α\n 2p₁β\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.@κ_str",
    "page": "Orbitals",
    "title": "AtomicLevels.@κ_str",
    "category": "macro",
    "text": "@κ_str -> Int\n\nA string macro to convert the canonical string representation of a ell_j angular label (i.e. ℓ- or ℓ) into the corresponding kappa quantum number.\n\njulia> κ\"s\", κ\"p-\", κ\"p\"\n(-1, 1, -2)\n\n\n\n\n\n"
},

{
    "location": "orbitals/#Methods-1",
    "page": "Orbitals",
    "title": "Methods",
    "category": "section",
    "text": "isless\ndegeneracy\nparity(::Orbital)\nsymmetry\nisbound\nmℓrange\nspin_orbitals\n@κ_strDocTestSetup = nothing"
},

{
    "location": "configurations/#",
    "page": "Configurations",
    "title": "Configurations",
    "category": "page",
    "text": ""
},

{
    "location": "configurations/#AtomicLevels.Configuration",
    "page": "Configurations",
    "title": "AtomicLevels.Configuration",
    "category": "type",
    "text": "struct Configuration{<:AbstractOrbital}\n\nRepresents a configuration – a set of orbitals and their associated occupation number. Furthermore, each orbital can be in one of the following states: :open, :closed or :inactive.\n\nConstructors\n\nConfiguration(orbitals :: Vector{<:AbstractOrbital}, occupancy :: Vector{Int}, states :: Vector{Symbol})\nConfiguration(orbitals :: Vector{Tuple{<:AbstractOrbital, Int, Symbol}})\n\nIn the first case, the paramaters of each orbital have to be passed as separate vectors, and the orbitals and occupancy have to be of the same length. The states vector can be shorter and then the latter orbitals that were not explicitly specified by states are assumed to be :open.\n\nThe second constructor allows you to pass a vector of tuples instead, where each tuple is a triplet (orbital :: AbstractOrbital, occupancy :: Int, state :: Symbol) corresponding to each orbital.\n\nIn all cases, all the orbitals have to be distinct. The orbitals in the configuration will be sorted according to the ordering defined for the particular AbstractOrbital.\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.@c_str",
    "page": "Configurations",
    "title": "AtomicLevels.@c_str",
    "category": "macro",
    "text": "@c_str -> Configuration{Orbital}\n\nConstruct a Configuration, representing a non-relativistic configuration, out of a string.\n\njulia> c\"1s2 2s\"\n1s² 2s\n\njulia> c\"[Kr] 4d10 5s2 4f2\"\n[Kr]ᶜ 4d¹⁰ 4f² 5s²\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.@rc_str",
    "page": "Configurations",
    "title": "AtomicLevels.@rc_str",
    "category": "macro",
    "text": "@rc_str -> Configuration{RelativisticOrbital}\n\nConstruct a Configuration representing a relativistic configuration out of a string.\n\njulia> rc\"[Ne] 3s 3p- 3p\"\n[Ne]ᶜ 3s 3p⁻ 3p\n\njulia> rc\"[Ne] 3s 3p-2 3p4\"\n[Ne]ᶜ 3s 3p⁻² 3p⁴\n\n\n\n\n\n"
},

{
    "location": "configurations/#Atomic-configurations-1",
    "page": "Configurations",
    "title": "Atomic configurations",
    "category": "section",
    "text": "DocTestSetup = quote\n    using AtomicLevels\nendWe define a configuration to be a set of orbitals with their associated occupation (i.e. the number of electron on that orbital). We can represent a particular configuration with an instance of the Configuration type.ConfigurationThe @c_str and @rc_str string macros can be used to conveniently construct configurations:@c_str\n@rc_str"
},

{
    "location": "configurations/#AtomicLevels.num_electrons-Tuple{Configuration}",
    "page": "Configurations",
    "title": "AtomicLevels.num_electrons",
    "category": "method",
    "text": "num_electrons(c::Configuration) -> Int\n\nReturn the number of electrons in the configuration.\n\njulia> num_electrons(c\"1s2\")\n2\n\njulia> num_electrons(rc\"[Kr] 5s2 5p-2 5p2\")\n42\n\n\n\n\n\n"
},

{
    "location": "configurations/#Base.delete!",
    "page": "Configurations",
    "title": "Base.delete!",
    "category": "function",
    "text": "delete!(c::Configuration, o::AbstractOrbital)\n\nRemove the entire subshell corresponding to orbital o from configuration c.\n\njulia> delete!(c\"[Ar] 4s2 3d10 4p2\", o\"4s\")\n[Ar]ᶜ 3d¹⁰ 4p²\n\n\n\n\n\n"
},

{
    "location": "configurations/#Base.:+",
    "page": "Configurations",
    "title": "Base.:+",
    "category": "function",
    "text": "+(::Configuration, ::Configuration)\n\nAdd two configurations together. If both configuration have an orbital, the number of electrons gets added together, but in this case the status of the orbitals must match.\n\njulia> c\"1s\" + c\"2s\"\n1s 2s\n\njulia> c\"1s\" + c\"1s\"\n1s²\n\n\n\n\n\n"
},

{
    "location": "configurations/#Base.:-",
    "page": "Configurations",
    "title": "Base.:-",
    "category": "function",
    "text": "-(configuration::Configuration, orbital::AbstractOrbital[, n=1])\n\nRemove n electrons in the orbital orbital from the configuration configuration. If the orbital had previously been :closed or :inactive, it will now be :open.\n\n\n\n\n\n"
},

{
    "location": "configurations/#Base.close",
    "page": "Configurations",
    "title": "Base.close",
    "category": "function",
    "text": "close(c::Configuration)\n\nReturn a corresponding configuration where where all the orbitals are marked :closed.\n\nSee also: close!\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.close!",
    "page": "Configurations",
    "title": "AtomicLevels.close!",
    "category": "function",
    "text": "close!(c::Configuration)\n\nMarks all the orbitals in configuration c to be closed.\n\nSee also: close\n\n\n\n\n\n"
},

{
    "location": "configurations/#Base.fill",
    "page": "Configurations",
    "title": "Base.fill",
    "category": "function",
    "text": "fill(c::Configuration)\n\nReturns a corresponding configuration where the orbitals are completely filled (as determined by degeneracy).\n\nSee also: fill!\n\n\n\n\n\n"
},

{
    "location": "configurations/#Base.fill!",
    "page": "Configurations",
    "title": "Base.fill!",
    "category": "function",
    "text": "fill!(c::Configuration)\n\nSets all the occupancies in configuration c to maximum, as determined by the degeneracy function.\n\nSee also: fill\n\n\n\n\n\n"
},

{
    "location": "configurations/#Base.in",
    "page": "Configurations",
    "title": "Base.in",
    "category": "function",
    "text": "in(o::AbstractOrbital, c::Configuration) -> Bool\n\nChecks if orbital o is part of configuration c.\n\njulia> in(o\"2s\", c\"1s2 2s2\")\ntrue\n\njulia> o\"2p\" ∈ c\"1s2 2s2\"\nfalse\n\n\n\n\n\n"
},

{
    "location": "configurations/#Base.filter",
    "page": "Configurations",
    "title": "Base.filter",
    "category": "function",
    "text": "filter(f, c::Configuration) -> Configuration\n\nFilter out the orbitals from configuration c for which the predicate f returns false. The predicate f needs to take three arguments: orbital, occupancy and state.\n\njulia> filter((o,occ,s) -> o.ℓ == 1, c\"[Kr]\")\n2p⁶ᶜ 3p⁶ᶜ 4p⁶ᶜ\n\n\n\n\n\n"
},

{
    "location": "configurations/#Base.count",
    "page": "Configurations",
    "title": "Base.count",
    "category": "function",
    "text": "count(::Configuration) -> Int\n\nReturn the number of electrons in the configuration.\n\njulia> count(c\"[Kr] 5s\")\n37\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.core",
    "page": "Configurations",
    "title": "AtomicLevels.core",
    "category": "function",
    "text": "core(::Configuration) -> Configuration\n\nReturn the core configuration (i.e. the sub-configuration of all the orbitals that are marked :closed).\n\njulia> core(c\"1s2c 2s2c 2p6c 3s2\")\n[Ne]ᶜ\n\njulia> core(c\"1s2 2s2\")\n∅\n\njulia> core(c\"1s2 2s2c 2p6c\")\n2s²ᶜ 2p⁶ᶜ\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.peel",
    "page": "Configurations",
    "title": "AtomicLevels.peel",
    "category": "function",
    "text": "peel(::Configuration) -> Configuration\n\nReturn the non-core part of the configuration (i.e. orbitals not marked :closed).\n\njulia> peel(c\"1s2c 2s2c 2p3\")\n2p³\n\njulia> peel(c\"[Ne] 3s 3p3\")\n3s 3p³\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.active",
    "page": "Configurations",
    "title": "AtomicLevels.active",
    "category": "function",
    "text": "active(::Configuration) -> Configuration\n\nReturn the part of the configuration marked :open.\n\njulia> active(c\"1s2c 2s2i 2p3i 3s2\")\n3s²\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.inactive",
    "page": "Configurations",
    "title": "AtomicLevels.inactive",
    "category": "function",
    "text": "inactive(::Configuration) -> Configuration\n\nReturn the part of the configuration marked :inactive.\n\njulia> inactive(c\"1s2c 2s2i 2p3i 3s2\")\n2s²ⁱ 2p³ⁱ\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.bound",
    "page": "Configurations",
    "title": "AtomicLevels.bound",
    "category": "function",
    "text": "bound(::Configuration) -> Configuration\n\nReturn the bound part of the configuration (see also isbound).\n\njulia> bound(c\"1s2 2s2 2p4 Ks2 Kp1\")\n1s² 2s² 2p⁴\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.continuum",
    "page": "Configurations",
    "title": "AtomicLevels.continuum",
    "category": "function",
    "text": "continuum(::Configuration) -> Configuration\n\nReturn the non-bound (continuum) part of the configuration (see also isbound).\n\njulia> continuum(c\"1s2 2s2 2p4 Ks2 Kp1\")\nKs² Kp\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.parity-Tuple{Configuration}",
    "page": "Configurations",
    "title": "AtomicLevels.parity",
    "category": "method",
    "text": "parity(::Configuration) -> Parity\n\nReturn the parity of the configuration.\n\njulia> parity(c\"1s 2p\")\nodd\n\njulia> parity(c\"1s 2p2\")\neven\n\nSee also: Parity\n\n\n\n\n\n"
},

{
    "location": "configurations/#Interface-1",
    "page": "Configurations",
    "title": "Interface",
    "category": "section",
    "text": "For example, it is possible to index into a configuration, including with a range of indices, returning a sub-configuration consisting of only those orbitals. With an integer index, an (orbital, occupancy, state) tuple is returned.julia> config = c\"1s2c 2si 2p3\"\n[He]ᶜ 2sⁱ 2p³\n\njulia> config[2]\n(2s, 1, :inactive)\n\njulia> config[1:2]\n[He]ᶜ 2sⁱ\n\njulia> config[[3,1]]\n[He]ᶜ 2p³The configuration can also be iterated over. Each item is a (orbital, occupancy, state) tuple.julia> for (o, nelec, s) in config\n           @show o, nelec, s\n       end\n(o, nelec, s) = (1s, 2, :closed)\n(o, nelec, s) = (2s, 1, :inactive)\n(o, nelec, s) = (2p, 3, :open)Various other methods exist to manipulate or transform configurations or to query them for information.num_electrons(::Configuration)\nBase.delete!\nBase.:(+)\nBase.:(-)\nBase.close\nclose!\nBase.fill\nBase.fill!\nBase.in\nBase.filter\nBase.count\ncore\npeel\nactive\ninactive\nbound\ncontinuum\nparity(::Configuration)"
},

{
    "location": "configurations/#AtomicLevels.:⊗",
    "page": "Configurations",
    "title": "AtomicLevels.:⊗",
    "category": "function",
    "text": "⊗(::Union{Configuration, Vector{Configuration}}, ::Union{Configuration, Vector{Configuration}})\n\nGiven two collections of Configurations, it creates an array of Configurations with all possible juxtapositions of configurations from each collection.\n\nExamples\n\njulia> c\"1s\" ⊗ [c\"2s2\", c\"2s 2p\"]\n2-element Array{Configuration{Orbital{Int64}},1}:\n 1s 2s²\n 1s 2s 2p\n\njulia> [rc\"1s\", rc\"2s\"] ⊗ [rc\"2p-\", rc\"2p\"]\n4-element Array{Configuration{RelativisticOrbital{Int64}},1}:\n 1s 2p⁻\n 1s 2p\n 2s 2p⁻\n 2s 2p\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.@rcs_str",
    "page": "Configurations",
    "title": "AtomicLevels.@rcs_str",
    "category": "macro",
    "text": "@rcs_str -> Vector{Configuration{RelativisticOrbital}}\n\nConstruct a Vector of all Configurations corresponding to the non-relativistic nℓ orbital with the given occupancy from the input string.\n\nThe string is assumed to have the following syntax: $(n)$(ℓ)$(occupancy), where n and occupancy are integers, and ℓ is in spectroscopic notation.\n\nExamples\n\njulia> rcs\"3p2\"\n3-element Array{Configuration{RelativisticOrbital{N}} where N,1}:\n 3p⁻²\n 3p⁻ 3p\n 3p²\n\n\n\n\n\n"
},

{
    "location": "configurations/#Generating-configuration-lists-1",
    "page": "Configurations",
    "title": "Generating configuration lists",
    "category": "section",
    "text": "The ⊗ operator can be used to easily generate lists of configurations from existing pieces. E.g. to create all the valence configurations on top of an closed core, you only need to writejulia> c\"[Ne]\" ⊗ [c\"3s2\", c\"3s 3p\", c\"3p2\"]\n3-element Array{Configuration{Orbital{Int64}},1}:\n [Ne]ᶜ 3s²\n [Ne]ᶜ 3s 3p\n [Ne]ᶜ 3p²That can be combined with the @rcs_str string macro to easily generate all possible relativistic configurations from a non-relativistic definition:julia> rc\"[Ne] 3s2\" ⊗ rcs\"3p2\"\n3-element Array{Configuration{RelativisticOrbital{Int64}},1}:\n [Ne]ᶜ 3s² 3p⁻²\n [Ne]ᶜ 3s² 3p⁻ 3p\n [Ne]ᶜ 3s² 3p²⊗\n@rcs_str"
},

{
    "location": "configurations/#AtomicLevels.spin_configurations",
    "page": "Configurations",
    "title": "AtomicLevels.spin_configurations",
    "category": "function",
    "text": "spin_configurations(configuration)\n\nGenerate all possible configurations of spin-orbitals from configuration, i.e. all permissible values for the quantum numbers n, ℓ, mℓ, ms for each electron. Example:\n\njulia> spin_configurations(c\"1s2\")\n1-element Array{Configuration{SpinOrbital{Orbital{Int64}}},1}:\n 1s²\n\n\n\n\n\nspin_configurations(configurations)\n\nFor each configuration in configurations, generate all possible configurations of spin-orbitals.\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.substitutions",
    "page": "Configurations",
    "title": "AtomicLevels.substitutions",
    "category": "function",
    "text": "substitutions(src::Configuration{<:SpinOrbital}, dst::Configuration{<:SpinOrbital})\n\nFind all orbital substitutions going from spin-configuration src to configuration dst.\n\n\n\n\n\n"
},

{
    "location": "configurations/#Spin-configurations-1",
    "page": "Configurations",
    "title": "Spin configurations",
    "category": "section",
    "text": "spin_configurations\nsubstitutionsDocTestSetup = nothing"
},

{
    "location": "csfs/#",
    "page": "CSFs",
    "title": "CSFs",
    "category": "page",
    "text": ""
},

{
    "location": "csfs/#Atomic-configuration-state-functions-(CSFs)-1",
    "page": "CSFs",
    "title": "Atomic configuration state functions (CSFs)",
    "category": "section",
    "text": ""
},

{
    "location": "utilities/#",
    "page": "Other utilities",
    "title": "Other utilities",
    "category": "page",
    "text": ""
},

{
    "location": "utilities/#Other-utilities-1",
    "page": "Other utilities",
    "title": "Other utilities",
    "category": "section",
    "text": ""
},

{
    "location": "utilities/#AtomicLevels.Parity",
    "page": "Other utilities",
    "title": "AtomicLevels.Parity",
    "category": "type",
    "text": "struct Parity\n\nRepresents the parity of a quantum system, taking two possible values: even or odd.\n\nThe integer values that correspond to even and odd parity are +1 and -1, respectively. Base.convert can be used to convert integers into Parity values.\n\njulia> convert(Parity, 1)\neven\n\njulia> convert(Parity, -1)\nodd\n\n\n\n\n\n"
},

{
    "location": "utilities/#AtomicLevels.@p_str",
    "page": "Other utilities",
    "title": "AtomicLevels.@p_str",
    "category": "macro",
    "text": "@p_str\n\nA string macro to easily construct Parity values.\n\njulia> p\"even\"\neven\n\njulia> p\"odd\"\nodd\n\n\n\n\n\n"
},

{
    "location": "utilities/#AtomicLevels.parity",
    "page": "Other utilities",
    "title": "AtomicLevels.parity",
    "category": "function",
    "text": "parity(object) -> Parity\n\nReturns the parity of object.\n\n\n\n\n\n"
},

{
    "location": "utilities/#Parity-1",
    "page": "Other utilities",
    "title": "Parity",
    "category": "section",
    "text": "AtomicLevels defines the Parity type, which is used to represent the parity of atomic states etc.DocTestSetup = quote\n    using AtomicLevels\nendParity\n@p_strThe parity values also define an algebra and an ordering:julia> p\"odd\" < p\"even\"\ntrue\n\njulia> p\"even\" * p\"odd\"\nodd\n\njulia> (p\"odd\")^3\nodd\n\njulia> -p\"odd\"\nevenThe exported parity function is overloaded for many of the types in AtomicLevels, defining a uniform API to determine the parity of an object.parityDocTestSetup = nothing"
},

{
    "location": "internals/#",
    "page": "Internals",
    "title": "Internals",
    "category": "page",
    "text": ""
},

{
    "location": "internals/#AtomicLevels.MQ",
    "page": "Internals",
    "title": "AtomicLevels.MQ",
    "category": "constant",
    "text": "const MQ = Union{Int,Symbol}\n\nDefines the possible types that may represent the main quantum number. It can either be an non-negative integer or a Symbol value (generally used to label continuum electrons).\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.get_noble_core_name-Union{Tuple{Configuration{O}}, Tuple{O}} where O",
    "page": "Internals",
    "title": "AtomicLevels.get_noble_core_name",
    "category": "method",
    "text": "get_noble_core_name(config::Configuration)\n\nReturns the name of the noble gas with the most electrons whose configuration still forms the first part of the closed part of config, or nothing if no such element is found.\n\njulia> AtomicLevels.get_noble_core_name(c\"[He] 2s2\")\n\"He\"\n\njulia> AtomicLevels.get_noble_core_name(c\"1s2c 2s2c 2p6c 3s2c\")\n\"Ne\"\n\njulia> AtomicLevels.get_noble_core_name(c\"1s2\") === nothing\ntrue\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.kappa_to_j-Tuple{Integer}",
    "page": "Internals",
    "title": "AtomicLevels.kappa_to_j",
    "category": "method",
    "text": "kappa_to_j(κ::Integer) :: HalfInteger\n\nCalculate the j quantum number corresponding to the κ quantum number.\n\nNote: κ is always an integer.\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.kappa_to_ℓ-Tuple{Integer}",
    "page": "Internals",
    "title": "AtomicLevels.kappa_to_ℓ",
    "category": "method",
    "text": "kappa_to_ℓ(κ::Integer) :: Integer\n\nCalculate the ℓ quantum number corresponding to the κ quantum number.\n\nNote: κ and ℓ values are always integers.\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.rconfigurations_from_orbital-Tuple{Orbital,Integer}",
    "page": "Internals",
    "title": "AtomicLevels.rconfigurations_from_orbital",
    "category": "method",
    "text": "rconfigurations_from_orbital(orbital::Orbital, occupancy)\n\nGenerate all Configurations with relativistic orbitals corresponding to the non-relativistic version of the orbital with a given occupancy.\n\nExamples\n\njulia> AtomicLevels.rconfigurations_from_orbital(o\"3p\", 2)\n3-element Array{Configuration{RelativisticOrbital{N}} where N,1}:\n 3p⁻²\n 3p⁻ 3p\n 3p²\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.rconfigurations_from_orbital-Union{Tuple{N}, Tuple{N,Int64,Int64}} where N<:Union{Int64, Symbol}",
    "page": "Internals",
    "title": "AtomicLevels.rconfigurations_from_orbital",
    "category": "method",
    "text": "rconfigurations_from_orbital(n, ℓ, occupancy)\n\nGenerate all Configurations with relativistic orbitals corresponding to the non-relativistic orbital with n and ℓ quantum numbers, with given occupancy.\n\nExamples\n\njulia> AtomicLevels.rconfigurations_from_orbital(3, 1, 2)\n3-element Array{Configuration{RelativisticOrbital{N}} where N,1}:\n 3p⁻²\n 3p⁻ 3p\n 3p²\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.ℓj_to_kappa-Tuple{Integer,Real}",
    "page": "Internals",
    "title": "AtomicLevels.ℓj_to_kappa",
    "category": "method",
    "text": "ℓj_to_kappa(ℓ::Integer, j::Real) :: Integer\n\nConverts a valid (ℓ, j) pair to the corresponding κ value.\n\nNote: there is a one-to-one correspondence between valid (ℓ,j) pairs and κ values such that for j = ℓ ± 1/2, κ = ∓(j + 1/2).\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.:+-Union{Tuple{O₂}, Tuple{O₁}, Tuple{O}, Tuple{Configuration{O₁},Configuration{O₂}}} where O₂<:O where O₁<:O where O<:AtomicLevels.AbstractOrbital",
    "page": "Internals",
    "title": "Base.:+",
    "category": "method",
    "text": "+(::Configuration, ::Configuration)\n\nAdd two configurations together. If both configuration have an orbital, the number of electrons gets added together, but in this case the status of the orbitals must match.\n\njulia> c\"1s\" + c\"2s\"\n1s 2s\n\njulia> c\"1s\" + c\"1s\"\n1s²\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.:--Union{Tuple{O₂}, Tuple{O₁}, Tuple{O}, Tuple{Configuration{O₁},O₂}, Tuple{Configuration{O₁},O₂,Int64}} where O₂<:O where O₁<:O where O<:AtomicLevels.AbstractOrbital",
    "page": "Internals",
    "title": "Base.:-",
    "category": "method",
    "text": "-(configuration::Configuration, orbital::AbstractOrbital[, n=1])\n\nRemove n electrons in the orbital orbital from the configuration configuration. If the orbital had previously been :closed or :inactive, it will now be :open.\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.close-Tuple{Configuration}",
    "page": "Internals",
    "title": "Base.close",
    "category": "method",
    "text": "close(c::Configuration)\n\nReturn a corresponding configuration where where all the orbitals are marked :closed.\n\nSee also: close!\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.count-Tuple{Configuration}",
    "page": "Internals",
    "title": "Base.count",
    "category": "method",
    "text": "count(::Configuration) -> Int\n\nReturn the number of electrons in the configuration.\n\njulia> count(c\"[Kr] 5s\")\n37\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.delete!-Union{Tuple{O}, Tuple{Configuration{O},O}} where O<:AtomicLevels.AbstractOrbital",
    "page": "Internals",
    "title": "Base.delete!",
    "category": "method",
    "text": "delete!(c::Configuration, o::AbstractOrbital)\n\nRemove the entire subshell corresponding to orbital o from configuration c.\n\njulia> delete!(c\"[Ar] 4s2 3d10 4p2\", o\"4s\")\n[Ar]ᶜ 3d¹⁰ 4p²\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.fill!-Tuple{Configuration}",
    "page": "Internals",
    "title": "Base.fill!",
    "category": "method",
    "text": "fill!(c::Configuration)\n\nSets all the occupancies in configuration c to maximum, as determined by the degeneracy function.\n\nSee also: fill\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.fill-Tuple{Configuration}",
    "page": "Internals",
    "title": "Base.fill",
    "category": "method",
    "text": "fill(c::Configuration)\n\nReturns a corresponding configuration where the orbitals are completely filled (as determined by degeneracy).\n\nSee also: fill!\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.filter-Tuple{Function,Configuration}",
    "page": "Internals",
    "title": "Base.filter",
    "category": "method",
    "text": "filter(f, c::Configuration) -> Configuration\n\nFilter out the orbitals from configuration c for which the predicate f returns false. The predicate f needs to take three arguments: orbital, occupancy and state.\n\njulia> filter((o,occ,s) -> o.ℓ == 1, c\"[Kr]\")\n2p⁶ᶜ 3p⁶ᶜ 4p⁶ᶜ\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.in-Union{Tuple{O}, Tuple{O,Configuration{O}}} where O<:AtomicLevels.AbstractOrbital",
    "page": "Internals",
    "title": "Base.in",
    "category": "method",
    "text": "in(o::AbstractOrbital, c::Configuration) -> Bool\n\nChecks if orbital o is part of configuration c.\n\njulia> in(o\"2s\", c\"1s2 2s2\")\ntrue\n\njulia> o\"2p\" ∈ c\"1s2 2s2\"\nfalse\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.isless-Tuple{Orbital,Orbital}",
    "page": "Internals",
    "title": "Base.isless",
    "category": "method",
    "text": "isless(a::Orbital, b::Orbital)\n\nCompares the orbitals a and b to decide which one comes before the other in a configuration.\n\nExamples\n\njulia> o\"1s\" < o\"2s\"\ntrue\n\njulia> o\"1s\" < o\"2p\"\ntrue\n\njulia> o\"ks\" < o\"2p\"\nfalse\n\n\n\n\n\n"
},

{
    "location": "internals/#Internals-1",
    "page": "Internals",
    "title": "Internals",
    "category": "section",
    "text": "note: Note\nThe functions, methods and types documented here are not part of the public API.CurrentModule = AtomicLevels\nDocTestSetup = quote\n    using AtomicLevels\nendModules = [AtomicLevels]\nPublic = falseCurrentModule = nothing\nDocTestSetup = nothing"
},

]}
