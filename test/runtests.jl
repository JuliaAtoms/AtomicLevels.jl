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

using PeriodicTable

@testset "PeriodicTable extension" begin
    @test Configuration(elements[:Ne], [:closed, :closed, :closed]) == parse(Configuration{Orbital}, "[Ne]")
    c1 = Configuration(elements[:Xe])
    c2 = parse(Configuration{Orbital}, "[Xe]")
    @test c1.orbitals == c2.orbitals
    @test c1.occupancy == c2.occupancy
end