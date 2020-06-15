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
    "text": "struct Orbital{N <: AtomicLevels.MQ} <: AbstractOrbital\n\nLabel for an atomic orbital with a principal quantum number n::N and orbital angular momentum ℓ.\n\nThe type parameter N has to be such that it can represent a proper principal quantum number (i.e. a subtype of AtomicLevels.MQ).\n\nProperties\n\nThe following properties are part of the public API:\n\n.n :: N – principal quantum number n\n.ℓ :: Int – the orbital angular momentum ell\n\nConstructors\n\nOrbital(n::Int, ℓ::Int)\nOrbital(n::Symbol, ℓ::Int)\n\nConstruct an orbital label with principal quantum number n and orbital angular momentum ℓ. If the principal quantum number n is an integer, it has to positive and the angular momentum must satisfy 0 <= ℓ < n.\n\njulia> Orbital(1, 0)\n1s\n\njulia> Orbital(:K, 2)\nKd\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.RelativisticOrbital",
    "page": "Orbitals",
    "title": "AtomicLevels.RelativisticOrbital",
    "category": "type",
    "text": "struct RelativisticOrbital{N <: AtomicLevels.MQ} <: AbstractOrbital\n\nLabel for an atomic orbital with a principal quantum number n::N and well-defined total angular momentum j. The angular component of the orbital is labelled by the (ell j) pair, conventionally written as ell_j (e.g. p_32).\n\nThe ell and j can not be arbitrary, but must satisfy j = ell pm 12. Internally, the kappa quantum number, which is a unique integer corresponding to every physical (ell j) pair, is used to label each allowed pair. When j = ell pm 12, the corresponding kappa = mp(j + 12).\n\nWhen printing and parsing RelativisticOrbitals, the notation nℓ and nℓ- is used (e.g. 2p and 2p-), corresponding to the orbitals with j = ell + 12 and j = ell - 12, respectively.\n\nThe type parameter N has to be such that it can represent a proper principal quantum number (i.e. a subtype of AtomicLevels.MQ).\n\nProperties\n\nThe following properties are part of the public API:\n\n.n :: N – principal quantum number n\n.κ :: Int – kappa quantum number\n.ℓ :: Int – the orbital angular momentum label ell\n.j :: HalfInteger – total angular momentum j\n\njulia> orb = ro\"5g-\"\n5g-\n\njulia> orb.n\n5\n\njulia> orb.j\n7/2\n\njulia> orb.ℓ\n4\n\nConstructors\n\nRelativisticOrbital(n::Integer, κ::Integer)\nRelativisticOrbital(n::Symbol, κ::Integer)\nRelativisticOrbital(n, ℓ::Integer, j::Real)\n\nConstruct an orbital label with the quantum numbers n and κ. If the principal quantum number n is an integer, it has to positive and the orbital angular momentum must satisfy 0 <= ℓ < n. Instead of κ, valid ℓ and j values can also be specified instead.\n\njulia> RelativisticOrbital(1, 0, 1//2)\n1s\n\njulia> RelativisticOrbital(2, -1)\n2s\n\njulia> RelativisticOrbital(:K, 2, 3//2)\nKd-\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.AbstractOrbital",
    "page": "Orbitals",
    "title": "AtomicLevels.AbstractOrbital",
    "category": "type",
    "text": "abstract type AbstractOrbital\n\nAbstract supertype of all orbital types.\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.SpinOrbital",
    "page": "Orbitals",
    "title": "AtomicLevels.SpinOrbital",
    "category": "type",
    "text": "struct SpinOrbital{O<:Orbital} <: AbstractOrbital\n\nSpin orbitals are fully characterized orbitals, i.e. the projections of all angular momenta are specified.\n\n\n\n\n\n"
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
    "text": "@ro_str -> RelativisticOrbital\n\nA string macro to construct an RelativisticOrbital from the canonical string representation.\n\njulia> ro\"1s\"\n1s\n\njulia> ro\"2p-\"\n2p-\n\njulia> ro\"Kf-\"\nKf-\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.@os_str",
    "page": "Orbitals",
    "title": "AtomicLevels.@os_str",
    "category": "macro",
    "text": "@os_str -> Vector{Orbital}\n\nCan be used to easily construct a list of Orbitals.\n\nExamples\n\njulia> os\"5[d] 6[s-p] k[7-10]\"\n7-element Array{Orbital,1}:\n 5d\n 6s\n 6p\n kk\n kl\n km\n kn\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.@sos_str",
    "page": "Orbitals",
    "title": "AtomicLevels.@sos_str",
    "category": "macro",
    "text": "@sos_str -> Vector{<:SpinOrbital{<:Orbital}}\n\nCan be used to easily construct a list of SpinOrbitals.\n\nExamples\n\njulia> sos\"3[s-p]\"\n8-element Array{SpinOrbital{Orbital{Int64},Tuple{Int64,HalfIntegers.Half{Int64}}},1}:\n 3s₀α\n 3s₀β\n 3p₋₁α\n 3p₋₁β\n 3p₀α\n 3p₀β\n 3p₁α\n 3p₁β\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.@ros_str",
    "page": "Orbitals",
    "title": "AtomicLevels.@ros_str",
    "category": "macro",
    "text": "@ros_str -> Vector{RelativisticOrbital}\n\nCan be used to easily construct a list of RelativisticOrbitals.\n\nExamples\n\njulia> ros\"2[s-p] 3[p] k[0-d]\"\n10-element Array{RelativisticOrbital,1}:\n 2s\n 2p-\n 2p\n 3p-\n 3p\n ks\n kp-\n kp\n kd-\n kd\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.@rsos_str",
    "page": "Orbitals",
    "title": "AtomicLevels.@rsos_str",
    "category": "macro",
    "text": "@rsos_str -> Vector{<:SpinOrbital{<:RelativisticOrbital}}\n\nCan be used to easily construct a list of SpinOrbitals.\n\nExamples\n\njulia> rsos\"3[s-p]\"\n8-element Array{SpinOrbital{RelativisticOrbital{Int64},Tuple{HalfIntegers.Half{Int64}}},1}:\n 3s(-1/2)\n 3s(1/2)\n 3p-(-1/2)\n 3p-(1/2)\n 3p(-3/2)\n 3p(-1/2)\n 3p(1/2)\n 3p(3/2)\n\n\n\n\n\n"
},

{
    "location": "orbitals/#Orbital-types-1",
    "page": "Orbitals",
    "title": "Orbital types",
    "category": "section",
    "text": "AtomicLevels provides two basic types for labelling atomic orbitals: Orbital and RelativisticOrbital. Stricly speaking, these types do not label orbitals, but groups of orbitals with the same angular symmetry and radial behaviour (i.e. a subshell).All orbitals are subtypes of AbstractOrbital. Types and methods that work on generic orbitals can dispatch on that.Orbital\nRelativisticOrbital\nAbstractOrbitalThe SpinOrbital type can be used to fully qualify all the quantum numbers (that is, also m_ell and m_s) of an Orbital. It represent a since, distinct orbital.SpinOrbitalThe string macros @o_str and @ro_str can be used to conveniently construct orbitals, while @os_str, @sos_str, @ros_str, and @rsos_str can be used to construct whole lists of them very easily.@o_str\n@ro_str\n@os_str\n@sos_str\n@ros_str\n@rsos_str"
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
    "location": "orbitals/#AtomicLevels.angular_momenta",
    "page": "Orbitals",
    "title": "AtomicLevels.angular_momenta",
    "category": "function",
    "text": "angular_momenta(orbital)\n\nReturns the angular momentum quantum numbers of orbital.\n\nExamples\n\njulia> angular_momenta(o\"2s\")\n(0, 1/2)\n\njulia> angular_momenta(o\"3d\")\n(2, 1/2)\n\n\n\n\n\nangular_momenta(orbital)\n\nReturns the angular momentum quantum numbers of orbital.\n\nExamples\n\njulia> angular_momenta(ro\"2p-\")\n(1/2,)\n\njulia> angular_momenta(ro\"3d\")\n(5/2,)\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.angular_momentum_ranges",
    "page": "Orbitals",
    "title": "AtomicLevels.angular_momentum_ranges",
    "category": "function",
    "text": "angular_momentum_ranges(orbital)\n\nReturn the valid ranges within which projections of each of the angular momentum quantum numbers of orbital must fall.\n\nExamples\n\njulia> angular_momentum_ranges(o\"2s\")\n(0:0, -1/2:1/2)\n\njulia> angular_momentum_ranges(o\"4f\")\n(-3:3, -1/2:1/2)\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.spin_orbitals",
    "page": "Orbitals",
    "title": "AtomicLevels.spin_orbitals",
    "category": "function",
    "text": "spin_orbitals(orbital)\n\nGenerate all permissible spin-orbitals for a given orbital, e.g. 2p -> 2p ⊗ mℓ = {-1,0,1} ⊗ ms = {α,β}\n\nExamples\n\njulia> spin_orbitals(o\"2p\")\n6-element Array{SpinOrbital{Orbital{Int64},Tuple{Int64,HalfIntegers.Half{Int64}}},1}:\n 2p₋₁α\n 2p₋₁β\n 2p₀α\n 2p₀β\n 2p₁α\n 2p₁β\n\njulia> spin_orbitals(ro\"2p-\")\n2-element Array{SpinOrbital{RelativisticOrbital{Int64},Tuple{HalfIntegers.Half{Int64}}},1}:\n 2p-(-1/2)\n 2p-(1/2)\n\njulia> spin_orbitals(ro\"2p\")\n4-element Array{SpinOrbital{RelativisticOrbital{Int64},Tuple{HalfIntegers.Half{Int64}}},1}:\n 2p(-3/2)\n 2p(-1/2)\n 2p(1/2)\n 2p(3/2)\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.@κ_str",
    "page": "Orbitals",
    "title": "AtomicLevels.@κ_str",
    "category": "macro",
    "text": "@κ_str -> Int\n\nA string macro to convert the canonical string representation of a ell_j angular label (i.e. ℓ- or ℓ) into the corresponding kappa quantum number.\n\njulia> κ\"s\", κ\"p-\", κ\"p\"\n(-1, 1, -2)\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.nonrelorbital",
    "page": "Orbitals",
    "title": "AtomicLevels.nonrelorbital",
    "category": "function",
    "text": "nonrelorbital(o)\n\nReturn the non-relativistic orbital corresponding to o.\n\nExamples\n\njulia> nonrelorbital(o\"2p\")\n2p\n\njulia> nonrelorbital(ro\"2p-\")\n2p\n\n\n\n\n\n"
},

{
    "location": "orbitals/#Methods-1",
    "page": "Orbitals",
    "title": "Methods",
    "category": "section",
    "text": "isless\ndegeneracy\nparity(::Orbital)\nsymmetry\nisbound\nangular_momenta\nangular_momentum_ranges\nspin_orbitals\n@κ_str\nnonrelorbitalDocTestSetup = nothing"
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
    "text": "struct Configuration{<:AbstractOrbital}\n\nRepresents a configuration – a set of orbitals and their associated occupation number.  Furthermore, each orbital can be in one of the following states: :open, :closed or :inactive.\n\nConstructors\n\nConfiguration(orbitals :: Vector{<:AbstractOrbital},\n              occupancy :: Vector{Int},\n              states :: Vector{Symbol}\n              [; sorted=false])\n\nConfiguration(orbitals :: Vector{Tuple{<:AbstractOrbital, Int, Symbol}}\n              [; sorted=false])\n\nIn the first case, the parameters of each orbital have to be passed as separate vectors, and the orbitals and occupancy have to be of the same length. The states vector can be shorter and then the latter orbitals that were not explicitly specified by states are assumed to be :open.\n\nThe second constructor allows you to pass a vector of tuples instead, where each tuple is a triplet (orbital :: AbstractOrbital, occupancy :: Int, state :: Symbol) corresponding to each orbital.\n\nIn all cases, all the orbitals have to be distinct. The orbitals in the configuration will be sorted (if sorted) according to the ordering defined for the particular AbstractOrbital.\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.@c_str",
    "page": "Configurations",
    "title": "AtomicLevels.@c_str",
    "category": "macro",
    "text": "@c_str -> Configuration{Orbital}\n\nConstruct a Configuration, representing a non-relativistic configuration, out of a string. With the added string macro suffix s, the configuration is sorted.\n\nExamples\n\njulia> c\"1s2 2s\"\n1s² 2s\n\njulia> c\"[Kr] 4d10 5s2 4f2\"\n[Kr]ᶜ 4d¹⁰ 5s² 4f²\n\njulia> c\"[Kr] 4d10 5s2 4f2\"s\n[Kr]ᶜ 4d¹⁰ 4f² 5s²\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.@rc_str",
    "page": "Configurations",
    "title": "AtomicLevels.@rc_str",
    "category": "macro",
    "text": "@rc_str -> Configuration{RelativisticOrbital}\n\nConstruct a Configuration representing a relativistic configuration out of a string. With the added string macro suffix s, the configuration is sorted.\n\nExamples\n\njulia> rc\"[Ne] 3s 3p- 3p\"\n[Ne]ᶜ 3s 3p- 3p\n\njulia> rc\"[Ne] 3s 3p-2 3p4\"\n[Ne]ᶜ 3s 3p-² 3p⁴\n\njulia> rc\"2p- 1s\"s\n1s 2p-\n\n\n\n\n\n"
},

{
    "location": "configurations/#Atomic-configurations-1",
    "page": "Configurations",
    "title": "Atomic configurations",
    "category": "section",
    "text": "DocTestSetup = quote\n    using AtomicLevels\nendWe define a configuration to be a set of orbitals with their associated occupation (i.e. the number of electron on that orbital). We can represent a particular configuration with an instance of the Configuration type. The orbitals of a configuration can be unsorted (default) or sorted according to the canonical ordering (first by n, then by ell, &c). It is important to allow for arbitrary order, since permutation of the orbitals in a configuration, in general incurs a phase shift of matrix elements, &c.ConfigurationThe @c_str and @rc_str string macros can be used to conveniently construct configurations:@c_str\n@rc_str"
},

{
    "location": "configurations/#AtomicLevels.issimilar",
    "page": "Configurations",
    "title": "AtomicLevels.issimilar",
    "category": "function",
    "text": "issimilar(a::Configuration, b::Configuration)\n\nCompares the electronic configurations a and b, only considering the constituent orbitals and their occupancy, but disregarding their ordering and states (:open, :closed, &c).\n\nExamples\n\njulia> a = c\"1s 2s\"\n1s 2s\n\njulia> b = c\"2si 1s\"\n2sⁱ 1s\n\njulia> issimilar(a, b)\ntrue\n\njulia> a==b\nfalse\n\n\n\n\n\n"
},

{
    "location": "configurations/#Base.:==-Union{Tuple{O}, Tuple{Configuration{#s1} where #s1<:O,Configuration{#s2} where #s2<:O}} where O<:AbstractOrbital",
    "page": "Configurations",
    "title": "Base.:==",
    "category": "method",
    "text": "==(a::Configuration, b::Configuration)\n\nTests if configurations a and b are the same, considering orbital occupancy, ordering, and states.\n\nExamples\n\njulia> c\"1s 2s\" == c\"1s 2s\"\ntrue\n\njulia> c\"1s 2s\" == c\"1s 2si\"\nfalse\n\njulia> c\"1s 2s\" == c\"2s 1s\"\nfalse\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.num_electrons-Tuple{Configuration}",
    "page": "Configurations",
    "title": "AtomicLevels.num_electrons",
    "category": "method",
    "text": "num_electrons(c::Configuration) -> Int\n\nReturn the number of electrons in the configuration.\n\njulia> num_electrons(c\"1s2\")\n2\n\njulia> num_electrons(rc\"[Kr] 5s2 5p-2 5p2\")\n42\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.num_electrons-Tuple{Configuration,AbstractOrbital}",
    "page": "Configurations",
    "title": "AtomicLevels.num_electrons",
    "category": "method",
    "text": "num_electrons(c::Configuration, o::AbstractOrbital) -> Int\n\nReturns the number of electrons on orbital o in configuration c. If o is not part of the configuration, returns 0.\n\njulia> num_electrons(c\"1s 2s2\", o\"2s\")\n2\n\njulia> num_electrons(rc\"[Rn] Qf-5 Pf3\", ro\"Qf-\")\n5\n\njulia> num_electrons(c\"[Ne]\", o\"3s\")\n0\n\n\n\n\n\n"
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
    "text": "close!(c::Configuration)\n\nMarks all the orbitals in configuration c as closed.\n\nSee also: close\n\n\n\n\n\n"
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
    "location": "configurations/#Base.replace",
    "page": "Configurations",
    "title": "Base.replace",
    "category": "function",
    "text": "replace(conf, a => b[; append=false])\n\nSubstitute one electron in orbital a of conf by one electron in orbital b. If conf is unsorted the substitution is performed in-place, unless append, in which case the new orbital is appended instead.\n\nExamples\n\njulia> replace(c\"1s2 2s\", o\"1s\" => o\"2p\")\n1s 2p 2s\n\njulia> replace(c\"1s2 2s\", o\"1s\" => o\"2p\", append=true)\n1s 2s 2p\n\njulia> replace(c\"1s2 2s\"s, o\"1s\" => o\"2p\")\n1s 2s 2p\n\n\n\n\n\n"
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
    "location": "configurations/#AtomicLevels.nonrelconfiguration",
    "page": "Configurations",
    "title": "AtomicLevels.nonrelconfiguration",
    "category": "function",
    "text": "nonrelconfiguration(c::Configuration{<:RelativisticOrbital}) -> Configuration{<:Orbital}\n\nReduces a relativistic configuration down to the corresponding non-relativistic configuration.\n\njulia> c = rc\"1s2 2p-2 2s 2p2 3s2 3p-\"s\n1s² 2s 2p-² 2p² 3s² 3p-\n\njulia> nonrelconfiguration(c)\n1s² 2s 2p⁴ 3s² 3p\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.relconfigurations",
    "page": "Configurations",
    "title": "AtomicLevels.relconfigurations",
    "category": "function",
    "text": "relconfigurations(c::Configuration{<:Orbital}) -> Vector{<:Configuration{<:RelativisticOrbital}}\n\nGenerate all relativistic configurations from the non-relativistic configuration c, by applying rconfigurations_from_orbital to each subshell and combining the results.\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.multiplicity-Tuple{Configuration}",
    "page": "Configurations",
    "title": "AtomicLevels.multiplicity",
    "category": "method",
    "text": "multiplicity(::Configuration)\n\nCalculates the number of Slater determinants corresponding to the configuration.\n\n\n\n\n\n"
},

{
    "location": "configurations/#Interface-1",
    "page": "Configurations",
    "title": "Interface",
    "category": "section",
    "text": "For example, it is possible to index into a configuration, including with a range of indices, returning a sub-configuration consisting of only those orbitals. With an integer index, an (orbital, occupancy, state) tuple is returned.julia> config = c\"1s2c 2si 2p3\"\n[He]ᶜ 2sⁱ 2p³\n\njulia> config[2]\n(2s, 1, :inactive)\n\njulia> config[1:2]\n[He]ᶜ 2sⁱ\n\njulia> config[[3,1]]\n[He]ᶜ 2p³The configuration can also be iterated over. Each item is a (orbital, occupancy, state) tuple.julia> for (o, nelec, s) in config\n           @show o, nelec, s\n       end\n(o, nelec, s) = (1s, 2, :closed)\n(o, nelec, s) = (2s, 1, :inactive)\n(o, nelec, s) = (2p, 3, :open)Various other methods exist to manipulate or transform configurations or to query them for information.issimilar\nBase.:(==)(a::Configuration{<:O}, b::Configuration{<:O}) where {O<:AbstractOrbital}\nnum_electrons(::Configuration)\nnum_electrons(::Configuration, ::AtomicLevels.AbstractOrbital)\nBase.delete!\nBase.:(+)\nBase.:(-)\nBase.close\nclose!\nBase.fill\nBase.fill!\nBase.in\nBase.filter\nBase.count\nBase.replace\ncore\npeel\nactive\ninactive\nbound\ncontinuum\nparity(::Configuration)\nnonrelconfiguration\nrelconfigurations\nmultiplicity(::Configuration)"
},

{
    "location": "configurations/#AtomicLevels.:⊗",
    "page": "Configurations",
    "title": "AtomicLevels.:⊗",
    "category": "function",
    "text": "⊗(::Union{Configuration, Vector{Configuration}}, ::Union{Configuration, Vector{Configuration}})\n\nGiven two collections of Configurations, it creates an array of Configurations with all possible juxtapositions of configurations from each collection.\n\nExamples\n\njulia> c\"1s\" ⊗ [c\"2s2\", c\"2s 2p\"]\n2-element Array{Configuration{Orbital{Int64}},1}:\n 1s 2s²\n 1s 2s 2p\n\njulia> [rc\"1s\", rc\"2s\"] ⊗ [rc\"2p-\", rc\"2p\"]\n4-element Array{Configuration{RelativisticOrbital{Int64}},1}:\n 1s 2p-\n 1s 2p\n 2s 2p-\n 2s 2p\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.@rcs_str",
    "page": "Configurations",
    "title": "AtomicLevels.@rcs_str",
    "category": "macro",
    "text": "@rcs_str -> Vector{Configuration{RelativisticOrbital}}\n\nConstruct a Vector of all Configurations corresponding to the non-relativistic nℓ orbital with the given occupancy from the input string.\n\nThe string is assumed to have the following syntax: $(n)$(ℓ)$(occupancy), where n and occupancy are integers, and ℓ is in spectroscopic notation.\n\nExamples\n\njulia> rcs\"3p2\"\n3-element Array{Configuration{RelativisticOrbital{N}} where N,1}:\n 3p-²\n 3p- 3p\n 3p²\n\n\n\n\n\n"
},

{
    "location": "configurations/#Generating-configuration-lists-1",
    "page": "Configurations",
    "title": "Generating configuration lists",
    "category": "section",
    "text": "The ⊗ operator can be used to easily generate lists of configurations from existing pieces. E.g. to create all the valence configurations on top of an closed core, you only need to writejulia> c\"[Ne]\" ⊗ [c\"3s2\", c\"3s 3p\", c\"3p2\"]\n3-element Array{Configuration{Orbital{Int64}},1}:\n [Ne]ᶜ 3s²\n [Ne]ᶜ 3s 3p\n [Ne]ᶜ 3p²That can be combined with the @rcs_str string macro to easily generate all possible relativistic configurations from a non-relativistic definition:julia> rc\"[Ne] 3s2\" ⊗ rcs\"3p2\"\n3-element Array{Configuration{RelativisticOrbital{Int64}},1}:\n [Ne]ᶜ 3s² 3p-²\n [Ne]ᶜ 3s² 3p- 3p\n [Ne]ᶜ 3s² 3p²⊗\n@rcs_str"
},

{
    "location": "configurations/#AtomicLevels.SpinConfiguration",
    "page": "Configurations",
    "title": "AtomicLevels.SpinConfiguration",
    "category": "type",
    "text": "SpinConfiguration\n\nSpecialization of Configuration for configurations consisting of SpinOrbitals.\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.spin_configurations",
    "page": "Configurations",
    "title": "AtomicLevels.spin_configurations",
    "category": "function",
    "text": "spin_configurations(configuration)\n\nGenerate all possible configurations of spin-orbitals from configuration, i.e. all permissible values for the quantum numbers n, ℓ, mℓ, ms for each electron. Example:\n\njulia> spin_configurations(c\"1s2\")\n1-element Array{Configuration{SpinOrbital{Orbital{Int64},Tuple{Int64,HalfIntegers.Half{Int64}}}},1}:\n 1s₀α 1s₀β\n\njulia> spin_configurations(c\"1s2\"s)\n1-element Array{Configuration{SpinOrbital{Orbital{Int64},Tuple{Int64,HalfIntegers.Half{Int64}}}},1}:\n 1s²\n\njulia> spin_configurations(c\"1s ks\")\n4-element Array{Configuration{SpinOrbital{#s16,Tuple{Int64,HalfIntegers.Half{Int64}}} where #s16<:Orbital},1}:\n 1s₀α ks₀α\n 1s₀β ks₀α\n 1s₀α ks₀β\n 1s₀β ks₀β\n\n\n\n\n\nspin_configurations(configurations)\n\nFor each configuration in configurations, generate all possible configurations of spin-orbitals.\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.substitutions",
    "page": "Configurations",
    "title": "AtomicLevels.substitutions",
    "category": "function",
    "text": "substitutions(src::SpinConfiguration, dst::SpinConfiguration)\n\nFind all orbital substitutions going from spin-configuration src to configuration dst.\n\n\n\n\n\n"
},

{
    "location": "configurations/#AtomicLevels.@scs_str",
    "page": "Configurations",
    "title": "AtomicLevels.@scs_str",
    "category": "macro",
    "text": "@scs_str -> Vector{<:SpinConfiguration}\n\nGenerate all possible spin-configurations out of a string. With the added string macro suffix s, the configuration is sorted.\n\nExamples\n\njulia> scs\"1s2 2p2\"\n15-element Array{Configuration{SpinOrbital{Orbital{Int64},Tuple{Int64,HalfIntegers.Half{Int64}}}},1}:\n 1s₀α 1s₀β 2p₋₁α 2p₋₁β\n 1s₀α 1s₀β 2p₋₁α 2p₀α\n 1s₀α 1s₀β 2p₋₁α 2p₀β\n 1s₀α 1s₀β 2p₋₁α 2p₁α\n 1s₀α 1s₀β 2p₋₁α 2p₁β\n 1s₀α 1s₀β 2p₋₁β 2p₀α\n 1s₀α 1s₀β 2p₋₁β 2p₀β\n 1s₀α 1s₀β 2p₋₁β 2p₁α\n 1s₀α 1s₀β 2p₋₁β 2p₁β\n 1s₀α 1s₀β 2p₀α 2p₀β\n 1s₀α 1s₀β 2p₀α 2p₁α\n 1s₀α 1s₀β 2p₀α 2p₁β\n 1s₀α 1s₀β 2p₀β 2p₁α\n 1s₀α 1s₀β 2p₀β 2p₁β\n 1s₀α 1s₀β 2p₁α 2p₁β\n\n\n\n\n\n"
},

{
    "location": "configurations/#Spin-configurations-1",
    "page": "Configurations",
    "title": "Spin configurations",
    "category": "section",
    "text": "SpinConfiguration\nspin_configurations\nsubstitutions\n@scs_str"
},

{
    "location": "configurations/#AtomicLevels.excited_configurations",
    "page": "Configurations",
    "title": "AtomicLevels.excited_configurations",
    "category": "function",
    "text": "excited_configurations([fun::Function, ] cfg::Configuration,\n                       orbitals::AbstractOrbital...\n                       [; min_excitations=0, max_excitations=:doubles,\n                        min_occupancy=[0, 0, ...], max_occupancy=[..., g_i, ...],\n                        keep_parity=true])\n\nGenerate all excitations from the reference set cfg by substituting at least min_excitations and at most max_excitations of the substitution orbitals. min_occupancy specifies the minimum occupation number for each of the source orbitals (default 0) and equivalently max_occupancy specifies the maximum occupation number (default is the degeneracy for each orbital). keep_parity controls whether the excited configuration has to have the same parity as cfg. Finally, fun allows modification of the substitution orbitals depending on the source orbitals, which is useful for generating ionized configurations. If fun returns nothing, that particular substitution will be rejected.\n\nExamples\n\njulia> excited_configurations(c\"1s2\", o\"2s\", o\"2p\")\n4-element Array{Configuration{Orbital{Int64}},1}:\n 1s²\n 1s 2s\n 2s²\n 2p²\n\njulia> excited_configurations(c\"1s2 2p\", o\"2p\")\n2-element Array{Configuration{Orbital{Int64}},1}:\n 1s² 2p\n 2p³\n\njulia> excited_configurations(c\"1s2 2p\", o\"2p\", max_occupancy=[2,2])\n1-element Array{Configuration{Orbital{Int64}},1}:\n 1s² 2p\n\njulia> excited_configurations(first(scs\"1s2\"), sos\"k[s]\"...) do dst,src\n           if isbound(src)\n               # Generate label that indicates src orbital,\n               # i.e. the resultant hole\n               SpinOrbital(Orbital(Symbol(\"[$(src)]\"), dst.orb.ℓ), dst.m)\n           else\n               dst\n           end\n       end\n9-element Array{Configuration{SpinOrbital{#s16,Tuple{Int64,HalfIntegers.Half{Int64}}} where #s16<:Orbital},1}:\n 1s₀α 1s₀β\n [1s₀α]s₀α 1s₀β\n [1s₀α]s₀β 1s₀β\n 1s₀α [1s₀β]s₀α\n 1s₀α [1s₀β]s₀β\n [1s₀α]s₀α [1s₀β]s₀α\n [1s₀α]s₀β [1s₀β]s₀α\n [1s₀α]s₀α [1s₀β]s₀β\n [1s₀α]s₀β [1s₀β]s₀β\n\njulia> excited_configurations((a,b) -> a.m == b.m ? a : nothing,\n                              spin_configurations(c\"1s\"), sos\"k[s-d]\"..., keep_parity=false)\n8-element Array{Configuration{SpinOrbital{#s16,Tuple{Int64,Half{Int64}}} where #s16<:Orbital},1}:\n 1s₀α\n ks₀α\n kp₀α\n kd₀α\n 1s₀β\n ks₀β\n kp₀β\n kd₀β\n\n\n\n\n\n"
},

{
    "location": "configurations/#Excited-configurations-1",
    "page": "Configurations",
    "title": "Excited configurations",
    "category": "section",
    "text": "AtomicLevels.jl provides an easy interface for generating lists of configurations which are the result of exciting one or more orbitals of a reference set to a set of substitution orbitals. This is done with excited_configurations, which provides various parameters for controlling which excitations are generated. A very simple example could bejulia> excited_configurations(c\"1s2\", os\"2[s-p]\"...)\n4-element Array{Configuration{Orbital{Int64}},1}:\n 1s²\n 1s 2s\n 2s²\n 2p²which as we see contains all configurations generated by at most exciting two orbitals 1s² and keeping the overall parity. By lifting these restrictions, more configurations can be generated:julia> excited_configurations(c\"1s2 2s\", os\"3[s-p]\"...,\n                              keep_parity=false, max_excitations=2)\n14-element Array{Configuration{Orbital{Int64}},1}:\n 1s² 2s\n 1s 2s²\n 1s 2s 3s\n 1s 2s 3p\n 1s² 3s\n 1s² 3p\n 2s² 3s\n 2s² 3p\n 2s 3s²\n 2s 3s 3p\n 1s 3s²\n 1s 3s 3p\n 2s 3p²\n 1s 3p²\n\njulia> excited_configurations(c\"1s2 2s\", os\"3[s-p]\"...,\n                              keep_parity=false, max_excitations=3)\n17-element Array{Configuration{Orbital{Int64}},1}:\n 1s² 2s\n 1s 2s²\n 1s 2s 3s\n 1s 2s 3p\n 1s² 3s\n 1s² 3p\n 2s² 3s\n 2s² 3p\n 2s 3s²\n 2s 3s 3p\n 1s 3s²\n 1s 3s 3p\n 2s 3p²\n 1s 3p²\n 3s² 3p\n 3s 3p²\n 3p³Since configurations by default are unsorted, when exciting from SpinConfigurations, the substitutions are performed in-place:julia> excited_configurations(first(scs\"1s2\"), sos\"2[s-p]\"...)\n21-element Array{Configuration{SpinOrbital{Orbital{Int64},Tuple{Int64,HalfIntegers.Half{Int64}}}},1}:\n 1s₀α 1s₀β\n 2s₀α 1s₀β\n 2s₀β 1s₀β\n 1s₀α 2s₀α\n 1s₀α 2s₀β\n 2s₀α 2s₀β\n 2p₋₁α 2p₋₁β\n 2p₋₁α 2p₀α\n 2p₋₁α 2p₀β\n 2p₋₁α 2p₁α\n 2p₋₁α 2p₁β\n 2p₋₁β 2p₀α\n 2p₋₁β 2p₀β\n 2p₋₁β 2p₁α\n 2p₋₁β 2p₁β\n 2p₀α 2p₀β\n 2p₀α 2p₁α\n 2p₀α 2p₁β\n 2p₀β 2p₁α\n 2p₀β 2p₁β\n 2p₁α 2p₁βexcited_configurationsDocTestSetup = nothing"
},

{
    "location": "terms/#",
    "page": "Term symbols",
    "title": "Term symbols",
    "category": "page",
    "text": ""
},

{
    "location": "terms/#AtomicLevels.Term",
    "page": "Term symbols",
    "title": "AtomicLevels.Term",
    "category": "type",
    "text": "struct Term\n\nRepresent a term symbol ^2S+1L_J with specific parity in LS-coupling. As determining valid J values is simple for given S and L (L - S leq J leq L+S), it is not specified.\n\nConstructors\n\nTerm(L::Real, S::Real, parity::Union{Parity,Integer})\n\nConstructs a Term object with the given L and S quantum numbers and parity. L and S both have to be convertible to HalfIntegers and parity must be of type Parity or ±1.\n\n\n\n\n\n"
},

{
    "location": "terms/#AtomicLevels.@T_str",
    "page": "Term symbols",
    "title": "AtomicLevels.@T_str",
    "category": "macro",
    "text": "@T_str -> Term\n\nConstructs a Term object out of its canonical string representation.\n\njulia> T\"1S\"\n¹S\n\njulia> T\"4Po\"\n⁴Pᵒ\n\njulia> T\"2[3/2]o\" # jK coupling, common in noble gases\n²[3/2]ᵒ\n\n\n\n\n\n"
},

{
    "location": "terms/#AtomicLevels.terms",
    "page": "Term symbols",
    "title": "AtomicLevels.terms",
    "category": "function",
    "text": "terms(orb::Orbital, w::Int=one(Int))\n\nReturns a list of valid LS term symbols for the orbital orb with w occupancy.\n\nExamples\n\njulia> terms(o\"3d\", 3)\n8-element Array{Term,1}:\n ²P\n ²D\n ²D\n ²F\n ²G\n ²H\n ⁴P\n ⁴F\n\n\n\n\n\nterms(config)\n\nGenerate all final LS terms for config.\n\nExamples\n\njulia> terms(c\"1s\")\n1-element Array{Term,1}:\n ²S\n\njulia> terms(c\"1s 2p\")\n2-element Array{Term,1}:\n ¹Pᵒ\n ³Pᵒ\n\njulia> terms(c\"[Ne] 3d3\")\n7-element Array{Term,1}:\n ²P\n ²D\n ²F\n ²G\n ²H\n ⁴P\n ⁴F\n\n\n\n\n\nterms(o::RelativisticOrbital, w = 1) -> Vector{HalfInt}\n\nReturns a sorted list of valid J values of w equivalent jj-coupled particles on orbital o (i.e. oʷ).\n\nWhen there are degeneracies (i.e. multiple states with the same J and M quantum numbers), the corresponding J value is repeated in the output array.\n\nExamples\n\njulia> terms(ro\"3d\", 3)\n3-element Array{HalfIntegers.Half{Int64},1}:\n 3/2\n 5/2\n 9/2\n\njulia> terms(ro\"3d-\", 3)\n1-element Array{HalfIntegers.Half{Int64},1}:\n 3/2\n\njulia> terms(ro\"4f\", 4)\n8-element Array{HalfIntegers.Half{Int64},1}:\n 0\n 2\n 2\n 4\n 4\n 5\n 6\n 8\n\n\n\n\n\n"
},

{
    "location": "terms/#Term-symbols-1",
    "page": "Term symbols",
    "title": "Term symbols",
    "category": "section",
    "text": "DocTestSetup = quote\n    using AtomicLevels\nendAtomicLevels provides types and methods to work and determine term symbols. The \"Term symbol\" and \"Angular momentum coupling\" Wikipedia articles give a good basic overview of the terminology.For term symbols in LS coupling, AtomicLevels provides the Term type.TermThe Term objects can also be constructed with the @T_str string macro.@T_strThe terms function can be used to generate all possible term symbols. In the case of relativistic orbitals, the term symbols are simply the valid J values, represented with the HalfInteger type.terms"
},

{
    "location": "terms/#AtomicLevels.IntermediateTerm",
    "page": "Term symbols",
    "title": "AtomicLevels.IntermediateTerm",
    "category": "type",
    "text": "IntermediateTerm(term, ν)\n\nRepresents a term together with its extra disambiguating quantum numbers, labelled by ν, which should be sortable (i.e. comparable by isless). The most common implementation of this is a single quantum number, Seniority.\n\n\n\n\n\n"
},

{
    "location": "terms/#AtomicLevels.intermediate_terms",
    "page": "Term symbols",
    "title": "AtomicLevels.intermediate_terms",
    "category": "function",
    "text": "intermediate_terms(orb::Orbital, w::Int=one(Int))\n\nGenerates all IntermediateTerm for a given non-relativstic orbital orb and occupation w.\n\nExamples\n\njulia> intermediate_terms(o\"2p\", 2)\n3-element Array{IntermediateTerm,1}:\n ₀¹S\n ₂¹D\n ₂³P\n\nThe preceding subscript is the seniority number, which indicates at which occupancy a certain term is first seen, cf.\n\njulia> intermediate_terms(o\"3d\", 1)\n1-element Array{IntermediateTerm,1}:\n ₁²D\n\njulia> intermediate_terms(o\"3d\", 3)\n8-element Array{IntermediateTerm,1}:\n ₁²D\n ₃²P\n ₃²D\n ₃²F\n ₃²G\n ₃²H\n ₃⁴P\n ₃⁴F\n\nIn the second case, we see both ₁²D and ₃²D, since there are two ways of coupling 3 d electrons to a ²D symmetry.\n\n\n\n\n\nintermediate_terms(config)\n\nGenerate the intermediate terms for each subshell of config.\n\nExamples\n\njulia> intermediate_terms(c\"1s 2p3\")\n2-element Array{Array{IntermediateTerm,1},1}:\n [₁²S]\n [₁²Pᵒ, ₃²Dᵒ, ₃⁴Sᵒ]\n\njulia> intermediate_terms(rc\"3d2 5g3\")\n2-element Array{Array{HalfIntegers.Half{Int64},1},1}:\n [0, 2, 4]\n [3/2, 5/2, 7/2, 9/2, 9/2, 11/2, 13/2, 15/2, 17/2, 21/2]\n\n\n\n\n\n"
},

{
    "location": "terms/#AtomicLevels.count_terms",
    "page": "Term symbols",
    "title": "AtomicLevels.count_terms",
    "category": "function",
    "text": "count_terms(orb, occ, term)\n\nCount how many times term occurs among the valid terms of orb^occ. For example:\n\njulia> count_terms(o\"1s\", 2, T\"1S\")\n1\n\n\n\n\n\n"
},

{
    "location": "terms/#Term-multiplicity-and-intermediate-terms-1",
    "page": "Term symbols",
    "title": "Term multiplicity and intermediate terms",
    "category": "section",
    "text": "For subshells starting with d³, the possible terms may occur more than once (multiplicity higher than one), corresponding to different physical states. These arise from different sequences of coupling the w equivalent electrons of the same ell, and are distinguished using a seniority number, which the IntermediateTerm type implements. For partially filled f shells, seniority is not enough to distinguish all possible couplings. Using count_terms, we can see that e.g. the ²Dᵒ has higher multiplicity than can be described with seniority only:julia> count_terms(o\"4f\", 3, T\"2Do\")\n2\n\njulia> count_terms(o\"4f\", 5, T\"2Do\")\n5IntermediateTerm\nintermediate_terms\ncount_terms"
},

{
    "location": "terms/#AtomicLevels.xu_terms",
    "page": "Term symbols",
    "title": "AtomicLevels.xu_terms",
    "category": "function",
    "text": "xu_terms(ℓ, w, p)\n\nReturn all term symbols for the orbital ℓʷ and parity p; the term multiplicity is computed using AtomicLevels.Xu.X.\n\nExamples\n\njulia> AtomicLevels.xu_terms(3, 3, parity(c\"3d3\"))\n17-element Array{Term,1}:\n ²P\n ²D\n ²D\n ²F\n ²F\n ²G\n ²G\n ²H\n ²H\n ²I\n ²K\n ²L\n ⁴S\n ⁴D\n ⁴F\n ⁴G\n ⁴I\n\n\n\n\n\n"
},

{
    "location": "terms/#AtomicLevels.Xu.X",
    "page": "Term symbols",
    "title": "AtomicLevels.Xu.X",
    "category": "function",
    "text": "X(N, ℓ, S′, L)\n\nCalculate the multiplicity of the term ^2S+1L (S=2S) for the orbital ℓ with occupancy N, according to the formula:\n\nbeginaligned\nX(N ell S L) =+ A(N ellellSL)\n- A(N ellellSL+1)\n+A(N ellellS+2L+1)\n- A(N ellellS+2L)\nendaligned\n\nNote that this is not correct for filled (empty) shells, for which the only possible term trivially is ¹S.\n\nExamples\n\njulia> AtomicLevels.Xu.X(1, 0, 1, 0) # Multiplicity of ²S term for s¹\n1\n\njulia> AtomicLevels.Xu.X(3, 3, 1, 3) # Multiplicity of ²D term for d³\n2\n\n\n\n\n\n"
},

{
    "location": "terms/#AtomicLevels.Xu.A",
    "page": "Term symbols",
    "title": "AtomicLevels.Xu.A",
    "category": "function",
    "text": "A(Nellell_bM_SM_L) obeys four different cases:\n\nCase 1\n\nM_S=1, M_Lleqell, and N=1:\n\nA(1ellell_b1M_L) = 1\n\nCase 2\n\nM_S=2-N4-NN-2, M_L leq fleft(fracN-M_S2-1right)+fleft(fracN+M_S2-1right), and 1Nleq 2ell+1:\n\nbeginaligned\nA(NellellM_SM_L) =\nsum_M_L-maxleft-fleft(fracN-M_S2-1right)M_L-fleft(fracN+M_S2-1right)right\n^minleftfleft(fracN-M_S2-1right)M_L+fleft(fracN+M_S2-1right)right\nBiggAleft(fracN-M_S2ellellfracN-M_S2M_L-right)\ntimes\nAleft(fracN+M_S2ellellfracN+M_S2M_L-M_L-right)Bigg\nendaligned\n\nCase 3\n\nM_S=N, M_Lleq f(N-1), and 1Nleq 2ell+1:\n\nA(Nellell_bNM_L) =\nsum_M_L_I = leftlfloorfracM_L-1N+fracN+12rightrfloor\n^minell_bM_L+f(N-2)\nA(N-1ellM_L_I-1N-1M_L-M_L_I)\n\nCase 4\n\nelse:\n\nA(Nellell_bM_SM_L) = 0\n\n\n\n\n\n"
},

{
    "location": "terms/#AtomicLevels.Xu.f",
    "page": "Term symbols",
    "title": "AtomicLevels.Xu.f",
    "category": "function",
    "text": "f(n,ℓ)\n\nf(nell)=begincases\ndisplaystylesum_m=0^n ell-m  ngeq0\n0  n0\nendcases\n\n\n\n\n\n"
},

{
    "location": "terms/#Internal-implementation-of-term-multiplicity-calculation-1",
    "page": "Term symbols",
    "title": "Internal implementation of term multiplicity calculation",
    "category": "section",
    "text": "AtomicLevels.jl uses the algorithm presented inAlternative mathematical technique to determine LS spectral terms by Xu Renjun and Dai Zhenwen, published in JPhysB, 2006.\ndoi:10.1088/0953-4075/39/16/007to compute the multiplicity of individual subshells, beyond the trivial cases of a single electron or a filled subshell. These routines need not be used directly, instead use terms and count_terms.In the following, S=2SinmathbbZ and M_S=2M_SinmathbbZ, as in the original article.AtomicLevels.xu_terms\nAtomicLevels.Xu.X\nAtomicLevels.Xu.A\nAtomicLevels.Xu.f"
},

{
    "location": "terms/#AtomicLevels.couple_terms",
    "page": "Term symbols",
    "title": "AtomicLevels.couple_terms",
    "category": "function",
    "text": "couple_terms(t1, t2)\n\nGenerate all possible coupling terms between t1 and t2.  It is assumed that t1 and t2 originate from non-equivalent electrons (i.e. from different subshells), since the vector model does not predict correct term couplings for equivalent electrons; some of the generated terms would violate the Pauli principle; cf. Cowan p. 108–109.\n\nExamples\n\njulia> couple_terms(T\"1Po\", T\"2Se\")\n1-element Array{Term,1}:\n ²Pᵒ\n\njulia> couple_terms(T\"3Po\", T\"2Se\")\n2-element Array{Term,1}:\n ²Pᵒ\n ⁴Pᵒ\n\njulia> couple_terms(T\"3Po\", T\"2De\")\n6-element Array{Term,1}:\n ²Pᵒ\n ²Dᵒ\n ²Fᵒ\n ⁴Pᵒ\n ⁴Dᵒ\n ⁴Fᵒ\n\n\n\n\n\ncouple_terms(t1s, t2s)\n\nGenerate all coupling between all terms in t1s and all terms in t2s.\n\n\n\n\n\n"
},

{
    "location": "terms/#AtomicLevels.final_terms",
    "page": "Term symbols",
    "title": "AtomicLevels.final_terms",
    "category": "function",
    "text": "final_terms(ts::Vector{<:Vector{<:Union{Term,Real}}})\n\nGenerate all possible final terms from the vector of vectors of individual subshell terms by coupling from left to right.\n\nExamples\n\njulia> ts = [[T\"1S\", T\"3S\"], [T\"2P\", T\"2D\"]]\n2-element Array{Array{Term,1},1}:\n [¹S, ³S]\n [²P, ²D]\n\njulia> AtomicLevels.final_terms(ts)\n4-element Array{Term,1}:\n ²P\n ²D\n ⁴P\n ⁴D\n\n\n\n\n\n"
},

{
    "location": "terms/#AtomicLevels.intermediate_couplings",
    "page": "Term symbols",
    "title": "AtomicLevels.intermediate_couplings",
    "category": "function",
    "text": "intermediate_couplings(its::Vector{IntermediateTerm,Integer,HalfInteger}, t₀ = T\"1S\")\n\nGenerate all intermediate coupling trees from the vector of intermediate terms its, starting from the initial term t₀.\n\nExamples\n\njulia> intermediate_couplings([IntermediateTerm(T\"2S\", 1), IntermediateTerm(T\"2D\", 1)])\n2-element Array{Array{Term,1},1}:\n [¹S, ²S, ¹D]\n [¹S, ²S, ³D]\n\n\n\n\n\nintermediate_couplings(J::Vector{<:Real}, j₀ = 0)\n\nExamples\n\njulia> intermediate_couplings([1//2, 3//2])\n2-element Array{Array{HalfIntegers.Half{Int64},1},1}:\n [0, 1/2, 1]\n [0, 1/2, 2]\n\n\n\n\n\n"
},

{
    "location": "terms/#Term-couplings-1",
    "page": "Term symbols",
    "title": "Term couplings",
    "category": "section",
    "text": "The angular momentum coupling method is based on the vector model, where two angular momenta can be combined via vector addition to form a total angular momentum:vecJ = vecL + vecSwhere the length of the resultant momentum vecJ obeysL-S leq J leq L+SRelations such as these are used to couple the term symbols in both LS and jj coupling; however, not all values of J predicted by the vector model are valid physical states, see couple_terms.To generate the possible terms of a configuration, all the possible terms of the individual subshells, have to be coupled together to form the final terms; this is done from left-to-right. When generating all possible CSFs from a configuration, it is also necessary to find the intermediate couplings of the individual subshells. As an example, if we want to find the possible terms of 3p² 4s 5p², we first find the possible terms of the individual subshells:julia> its = intermediate_terms(c\"3p2 4s 5p2\")\n3-element Array{Array{IntermediateTerm,1},1}:\n [₀¹S, ₂¹D, ₂³P]\n [₁²S]\n [₀¹S, ₂¹D, ₂³P]where the seniority numbers are indicated as preceding subscripts. We then need to couple each intermediate term of the first subshell with each of the second subshell, and couple each of the resulting terms with each of the third subshell, and so on. E.g. coupling the ₂³P intermediate term with ₁²S produces two terms:julia> couple_terms(T\"3P\", T\"2S\")\n2-element Array{Term,1}:\n ²P\n ⁴Peach of which need to be coupled with e.g. ₂¹D:julia> couple_terms(T\"2P\", T\"1D\")\n3-element Array{Term,1}:\n ²P\n ²D\n ²F\n\njulia> couple_terms(T\"4P\", T\"1D\")\n3-element Array{Term,1}:\n ⁴P\n ⁴D\n ⁴Fterms uses couple_terms (through AtomicLevels.final_terms) to produce all possible terms coupling trees, folding from left-to-right:julia> a = couple_terms([T\"1S\", T\"1D\", T\"3P\"], [T\"2S\"])\n4-element Array{Term,1}:\n ²S\n ²P\n ²D\n ⁴P\n\njulia> couple_terms(a, [T\"1S\", T\"1D\", T\"3P\"])\n12-element Array{Term,1}:\n ²S\n ²P\n ²D\n ²F\n ²G\n ⁴S\n ⁴P\n ⁴D\n ⁴F\n ⁶S\n ⁶P\n ⁶Dwhich gives the same result asjulia> terms(c\"3p2 4s 5p2\")\n12-element Array{Term,1}:\n ²S\n ²P\n ²D\n ²F\n ²G\n ⁴S\n ⁴P\n ⁴D\n ⁴F\n ⁶S\n ⁶P\n ⁶DNote that for the generation of final terms, the intermediate terms need not be kept (and their seniority is not important). However, for the generation of CSFs, we need to form all possible combinations of intermediate terms for each subshell, and couple them, again left-to-right, to form all possible coupling chains (each one corresponding to a unique physical state). E.g. for the last term of each subshell of 3p² 4s 5p²julia> last.(its)\n3-element Array{IntermediateTerm,1}:\n ₂³P\n ₁²S\n ₂³Pwe find the following chains:julia> intermediate_couplings(last.(its))\n15-element Array{Array{Term,1},1}:\n [¹S, ³P, ²P, ²S]\n [¹S, ³P, ²P, ²P]\n [¹S, ³P, ²P, ²D]\n [¹S, ³P, ²P, ⁴S]\n [¹S, ³P, ²P, ⁴P]\n [¹S, ³P, ²P, ⁴D]\n [¹S, ³P, ⁴P, ²S]\n [¹S, ³P, ⁴P, ²P]\n [¹S, ³P, ⁴P, ²D]\n [¹S, ³P, ⁴P, ⁴S]\n [¹S, ³P, ⁴P, ⁴P]\n [¹S, ³P, ⁴P, ⁴D]\n [¹S, ³P, ⁴P, ⁶S]\n [¹S, ³P, ⁴P, ⁶P]\n [¹S, ³P, ⁴P, ⁶D]couple_terms\nAtomicLevels.final_terms\nintermediate_couplingsDocTestSetup = nothing"
},

{
    "location": "csfs/#",
    "page": "CSFs",
    "title": "CSFs",
    "category": "page",
    "text": ""
},

{
    "location": "csfs/#CSFs-1",
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
    "location": "internals/#AtomicLevels.final_terms-Union{Tuple{Array{#s40,1} where #s40<:(Array{#s38,1} where #s38<:T)}, Tuple{T}} where T<:Union{Term, Real}",
    "page": "Internals",
    "title": "AtomicLevels.final_terms",
    "category": "method",
    "text": "final_terms(ts::Vector{<:Vector{<:Union{Term,Real}}})\n\nGenerate all possible final terms from the vector of vectors of individual subshell terms by coupling from left to right.\n\nExamples\n\njulia> ts = [[T\"1S\", T\"3S\"], [T\"2P\", T\"2D\"]]\n2-element Array{Array{Term,1},1}:\n [¹S, ³S]\n [²P, ²D]\n\njulia> AtomicLevels.final_terms(ts)\n4-element Array{Term,1}:\n ²P\n ²D\n ⁴P\n ⁴D\n\n\n\n\n\n"
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
    "location": "internals/#AtomicLevels.mqtype-Union{Tuple{Orbital{MQ}}, Tuple{MQ}} where MQ",
    "page": "Internals",
    "title": "AtomicLevels.mqtype",
    "category": "method",
    "text": "mqtype(::Orbital{MQ}) = MQ\n\nReturns the main quantum number type of an Orbital.\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.mqtype-Union{Tuple{RelativisticOrbital{MQ}}, Tuple{MQ}} where MQ",
    "page": "Internals",
    "title": "AtomicLevels.mqtype",
    "category": "method",
    "text": "mqtype(::RelativisticOrbital{MQ}) = MQ\n\nReturns the main quantum number type of a RelativisticOrbital.\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.orbital_priority-Union{Tuple{O₂}, Tuple{O₁}, Tuple{Function,Configuration{O₁},Array{O₂,1}}} where O₂<:AbstractOrbital where O₁<:AbstractOrbital",
    "page": "Internals",
    "title": "AtomicLevels.orbital_priority",
    "category": "method",
    "text": "orbital_priority(fun, orig_cfg, orbitals)\n\nGenerate priorities for the substitution orbitals, i.e. the preferred ordering of the orbitals in configurations excited from orig_cfg. fun can optionally transform the labels of substitution orbitals, in which case they will be ordered just after their parent orbital in the source configuration; otherwise they will be appended to the priority list.\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.rconfigurations_from_orbital-Tuple{Orbital,Integer}",
    "page": "Internals",
    "title": "AtomicLevels.rconfigurations_from_orbital",
    "category": "method",
    "text": "rconfigurations_from_orbital(orbital::Orbital, occupancy)\n\nGenerate all Configurations with relativistic orbitals corresponding to the non-relativistic version of the orbital with a given occupancy.\n\nExamples\n\njulia> AtomicLevels.rconfigurations_from_orbital(o\"3p\", 2)\n3-element Array{Configuration{RelativisticOrbital{N}} where N,1}:\n 3p-²\n 3p- 3p\n 3p²\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.rconfigurations_from_orbital-Union{Tuple{N}, Tuple{N,Int64,Int64}} where N<:Union{Int64, Symbol}",
    "page": "Internals",
    "title": "AtomicLevels.rconfigurations_from_orbital",
    "category": "method",
    "text": "rconfigurations_from_orbital(n, ℓ, occupancy)\n\nGenerate all Configurations with relativistic orbitals corresponding to the non-relativistic orbital with n and ℓ quantum numbers, with given occupancy.\n\nExamples\n\njulia> AtomicLevels.rconfigurations_from_orbital(3, 1, 2)\n3-element Array{Configuration{RelativisticOrbital{N}} where N,1}:\n 3p-²\n 3p- 3p\n 3p²\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.sorted-Tuple{Configuration}",
    "page": "Internals",
    "title": "AtomicLevels.sorted",
    "category": "method",
    "text": "sorted(cfg::Configuration)\n\nReturns cfg if it is already sorted or a sorted copy otherwise.\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.xu_terms-Tuple{Int64,Int64,Parity}",
    "page": "Internals",
    "title": "AtomicLevels.xu_terms",
    "category": "method",
    "text": "xu_terms(ℓ, w, p)\n\nReturn all term symbols for the orbital ℓʷ and parity p; the term multiplicity is computed using AtomicLevels.Xu.X.\n\nExamples\n\njulia> AtomicLevels.xu_terms(3, 3, parity(c\"3d3\"))\n17-element Array{Term,1}:\n ²P\n ²D\n ²D\n ²F\n ²F\n ²G\n ²G\n ²H\n ²H\n ²I\n ²K\n ²L\n ⁴S\n ⁴D\n ⁴F\n ⁴G\n ⁴I\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.ℓj_to_kappa-Tuple{Integer,Real}",
    "page": "Internals",
    "title": "AtomicLevels.ℓj_to_kappa",
    "category": "method",
    "text": "ℓj_to_kappa(ℓ::Integer, j::Real) :: Integer\n\nConverts a valid (ℓ, j) pair to the corresponding κ value.\n\nNote: there is a one-to-one correspondence between valid (ℓ,j) pairs and κ values such that for j = ℓ ± 1/2, κ = ∓(j + 1/2).\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.:+-Union{Tuple{O₂}, Tuple{O₁}, Tuple{O}, Tuple{Configuration{O₁},Configuration{O₂}}} where O₂<:O where O₁<:O where O<:AbstractOrbital",
    "page": "Internals",
    "title": "Base.:+",
    "category": "method",
    "text": "+(::Configuration, ::Configuration)\n\nAdd two configurations together. If both configuration have an orbital, the number of electrons gets added together, but in this case the status of the orbitals must match.\n\njulia> c\"1s\" + c\"2s\"\n1s 2s\n\njulia> c\"1s\" + c\"1s\"\n1s²\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.:--Union{Tuple{O₂}, Tuple{O₁}, Tuple{O}, Tuple{Configuration{O₁},O₂}, Tuple{Configuration{O₁},O₂,Int64}} where O₂<:O where O₁<:O where O<:AbstractOrbital",
    "page": "Internals",
    "title": "Base.:-",
    "category": "method",
    "text": "-(configuration::Configuration, orbital::AbstractOrbital[, n=1])\n\nRemove n electrons in the orbital orbital from the configuration configuration. If the orbital had previously been :closed or :inactive, it will now be :open.\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.:==-Union{Tuple{O}, Tuple{Configuration{#s19} where #s19<:O,Configuration{#s18} where #s18<:O}} where O<:AbstractOrbital",
    "page": "Internals",
    "title": "Base.:==",
    "category": "method",
    "text": "==(a::Configuration, b::Configuration)\n\nTests if configurations a and b are the same, considering orbital occupancy, ordering, and states.\n\nExamples\n\njulia> c\"1s 2s\" == c\"1s 2s\"\ntrue\n\njulia> c\"1s 2s\" == c\"1s 2si\"\nfalse\n\njulia> c\"1s 2s\" == c\"2s 1s\"\nfalse\n\n\n\n\n\n"
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
    "location": "internals/#Base.delete!-Union{Tuple{O}, Tuple{Configuration{O},O}} where O<:AbstractOrbital",
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
    "location": "internals/#Base.in-Union{Tuple{O}, Tuple{O,Configuration{O}}} where O<:AbstractOrbital",
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
    "location": "internals/#Base.issorted-Tuple{Configuration}",
    "page": "Internals",
    "title": "Base.issorted",
    "category": "method",
    "text": "issorted(cfg::Configuration)\n\nTests if the orbitals of cfg is sorted.\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.replace-Union{Tuple{O₃}, Tuple{O₂}, Tuple{O₁}, Tuple{O}, Tuple{Configuration{O₁},Pair{O₂,O₃}}} where O₃<:O where O₂<:O where O₁<:O where O<:AbstractOrbital",
    "page": "Internals",
    "title": "Base.replace",
    "category": "method",
    "text": "replace(conf, a => b[; append=false])\n\nSubstitute one electron in orbital a of conf by one electron in orbital b. If conf is unsorted the substitution is performed in-place, unless append, in which case the new orbital is appended instead.\n\nExamples\n\njulia> replace(c\"1s2 2s\", o\"1s\" => o\"2p\")\n1s 2p 2s\n\njulia> replace(c\"1s2 2s\", o\"1s\" => o\"2p\", append=true)\n1s 2s 2p\n\njulia> replace(c\"1s2 2s\"s, o\"1s\" => o\"2p\")\n1s 2s 2p\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.sort-Tuple{Configuration}",
    "page": "Internals",
    "title": "Base.sort",
    "category": "method",
    "text": "sort(cfg::Configuration)\n\nReturns a sorted copy of cfg.\n\n\n\n\n\n"
},

{
    "location": "internals/#Internals-1",
    "page": "Internals",
    "title": "Internals",
    "category": "section",
    "text": "note: Note\nThe functions, methods and types documented here are not part of the public API.CurrentModule = AtomicLevels\nDocTestSetup = quote\n    using AtomicLevels\nendModules = [AtomicLevels]\nPublic = falseCurrentModule = nothing\nDocTestSetup = nothing"
},

]}
