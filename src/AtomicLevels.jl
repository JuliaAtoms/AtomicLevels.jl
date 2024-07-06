module AtomicLevels

using UnicodeFun
using Format
using Parameters
using BlockBandedMatrices
using BlockArrays
using FillArrays
using WignerSymbols
using HalfIntegers
using Combinatorics

include("common.jl")
include("unicode.jl")
include("parity.jl")
include("orbitals.jl")
include("relativistic_orbitals.jl")
include("spin_orbitals.jl")
include("configurations.jl")
include("excited_configurations.jl")
include("terms.jl")
include("allchoices.jl")
include("jj_terms.jl")
include("intermediate_terms.jl")
include("couple_terms.jl")
include("csfs.jl")
include("jj2lsj.jl")
include("levels.jl")

module Utils
include("utils/print_states.jl")
end

# Deprecations
@deprecate jj2lsj(args...) jj2ℓsj(args...)

end # module
