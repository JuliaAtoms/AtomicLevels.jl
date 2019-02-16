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
    "text": "DocTestSetup = quote\n    using AtomicLevels\nend"
},

{
    "location": "orbitals/#AtomicLevels.Orbital",
    "page": "Orbitals",
    "title": "AtomicLevels.Orbital",
    "category": "type",
    "text": "struct Orbital{N <: AtomicLevels.MQ} <: AbstractOrbital\n\nRepresents an orbital with just the angular quantum number ℓ.\n\nThe type parameter has to be such that it can represent a proper main quantum number (i.e. a subtype of AtomicLevels.MQ).\n\n\n\n\n\n"
},

{
    "location": "orbitals/#AtomicLevels.SpinOrbital",
    "page": "Orbitals",
    "title": "AtomicLevels.SpinOrbital",
    "category": "type",
    "text": "struct SpinOrbital{O<:Orbital} <: AbstractOrbital\n\nSpin orbitals are fully characterized orbitals, i.e. the quantum numbers n, ℓ, mℓ and ms are all specified.\n\n\n\n\n\n"
},

{
    "location": "orbitals/#Orbital-types-1",
    "page": "Orbitals",
    "title": "Orbital types",
    "category": "section",
    "text": "Orbital\nSpinOrbital"
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
    "location": "orbitals/#Methods-1",
    "page": "Orbitals",
    "title": "Methods",
    "category": "section",
    "text": "isless\ndegeneracy\nparity(::Orbital)\nsymmetry\nisbound\nmℓrange\nspin_orbitalsDocTestSetup = nothing"
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
    "text": "struct Configuration{<:AbstractOrbital}\n\nRepresents a configuration – a set of orbitals and their associated occupation number. Furthermore, each orbital can be in one of the following states: :open, :closed or :inactive.\n\n\n\n\n\n"
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
    "text": "DocTestSetup = quote\n    using AtomicLevels\nendWe define a configuration to be a set of orbitals with their associated occupation (i.e. the number of electron on that orbital). We can represent a particular configuration with an instance of the Configuration type.Configurationtodo: TODO\nInterface of AbstractOrbital?The @c_str and @rc_str string macros can be used to conveniently construct configurations:@c_str\n@rc_str"
},

{
    "location": "configurations/#AtomicLevels.num_electrons-Tuple{Configuration}",
    "page": "Configurations",
    "title": "AtomicLevels.num_electrons",
    "category": "method",
    "text": "num_electrons(conf::Configuration) -> Int\n\nReturn the number of electrons in the configuration.\n\njulia> num_electrons(c\"1s2\")\n2\n\njulia> num_electrons(rc\"[Kr] 5s2 5p-2 5p2\")\n42\n\n\n\n\n\n"
},

{
    "location": "configurations/#Interface-1",
    "page": "Configurations",
    "title": "Interface",
    "category": "section",
    "text": "Various methods exist to query configurations for information.num_electrons(::Configuration)DocTestSetup = nothing"
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
    "location": "utilities/#Parity-1",
    "page": "Other utilities",
    "title": "Parity",
    "category": "section",
    "text": "AtomicLevels defines the Parity type, which is used to represent the parity of atomic states etc.DocTestSetup = quote\n    using AtomicLevels\nendParity\n@p_strThe parity values also define an algebra and an ordering:julia> p\"odd\" < p\"even\"\ntrue\n\njulia> p\"even\" * p\"odd\"\nodd\n\njulia> (p\"odd\")^3\nodd\n\njulia> -p\"odd\"\nevenDocTestSetup = nothing"
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
    "text": "rconfigurations_from_orbital(orbital::Orbital, occupancy)\n\nGenerate all Configurations with relativistic orbitals corresponding to the non-relativistic version of the orbital with a given occupancy.\n\nExamples\n\njulia> rconfigurations_from_orbital(o\"3p\", 2)\n3-element Array{Configuration{RelativisticOrbital},1}:\n 3p⁻²\n 3p⁻ 3p\n 3p²\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.rconfigurations_from_orbital-Union{Tuple{N}, Tuple{N,Int64,Int64}} where N<:Union{Int64, Symbol}",
    "page": "Internals",
    "title": "AtomicLevels.rconfigurations_from_orbital",
    "category": "method",
    "text": "rconfigurations_from_orbital(n, ℓ, occupancy)\n\nGenerate all Configurations with relativistic orbitals corresponding to the non-relativistic orbital with n and ℓ quantum numbers, with given occupancy.\n\nExamples\n\njulia> rconfigurations_from_orbital(3, 1, 2)\n3-element Array{Configuration{RelativisticOrbital},1}:\n 3p⁻²\n 3p⁻ 3p\n 3p²\n\n\n\n\n\n"
},

{
    "location": "internals/#AtomicLevels.ℓj_to_kappa-Tuple{Integer,Real}",
    "page": "Internals",
    "title": "AtomicLevels.ℓj_to_kappa",
    "category": "method",
    "text": "ℓj_to_kappa(ℓ::Integer, j::Real) :: Integer\n\nConverts a valid (ℓ, j) pair to the corresponding κ value.\n\nNote: there is a one-to-one correspondence between valid (ℓ,j) pairs and κ values such that for j = ℓ ± 1/2, κ = ∓(j + 1/2).\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.:--Union{Tuple{O₂}, Tuple{O₁}, Tuple{O}, Tuple{Configuration{O₁},O₂}, Tuple{Configuration{O₁},O₂,Int64}} where O₂<:O where O₁<:O where O<:AtomicLevels.AbstractOrbital",
    "page": "Internals",
    "title": "Base.:-",
    "category": "method",
    "text": "-(configuration::Configuration, orbital::AbstractOrbital[, n=1])\n\nRemove n electrons in the orbital orbital from the configuration configuration. If the orbital had previously been :closed or :inactive, it will now be :open.\n\n\n\n\n\n"
},

{
    "location": "internals/#Base.fill-Tuple{Configuration}",
    "page": "Internals",
    "title": "Base.fill",
    "category": "method",
    "text": "fill(configuration)\n\nEnsure all orbitals are at their maximum occupancy.\n\n\n\n\n\n"
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
    "text": "note: Note\nThe functions, methods and types documented here are not part of the public API.CurrentModule = AtomicLevels\nDocTestSetup = begin\n    using AtomicLevels\nendModules = [AtomicLevels]\nPublic = falseCurrentModule = nothing\nDocTestSetup = nothing"
},

]}
