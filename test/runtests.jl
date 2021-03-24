using AtomicLevels
using WignerSymbols
using HalfIntegers
using Test

@testset "Unicode super-/subscripts" begin
    @test AtomicLevels.from_subscript("₋₊₁₂₃₄₅₆₇₈₉₀") == "-+1234567890"
    @test AtomicLevels.from_superscript("⁻⁺¹²³⁴⁵⁶⁷⁸⁹⁰") == "-+1234567890"
end

include("parity.jl")
include("orbitals.jl")
include("configurations.jl")
include("excited_configurations.jl")
include("terms.jl")
include("jj_terms.jl")
include("intermediate_terms.jl")
include("couple_terms.jl")
include("csfs.jl")
include("levels.jl")
include("jj2lsj.jl")
