module AtomicLevels

using UnicodeFun
using Formatting
using Parameters
using BlockBandedMatrices
using WignerSymbols

if VERSION < v"1.1-DEV"
    isnothing(::Nothing) = true
    isnothing(::Any) = false
end

include("common.jl")
include("parity.jl")
include("halfinteger.jl")
include("orbitals.jl")
include("configurations.jl")
include("excited_configurations.jl")
include("terms.jl")
include("allchoices.jl")
include("jj_terms.jl")
include("csfs.jl")
include("jj2lsj.jl")

end # module
