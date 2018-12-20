using Test
using AtomicLevels
# ^^^ -- to make it possible to run the test file separately

module ATSPParser
    using Test
    using AtomicLevels
    import AtomicLevels: CSF, csfs
    include("atsp/csfparser.jl")

    compare_with_atsp(f, csfout) = @testset "ATSP CSFs: $(csfout)" begin
        atsp_csfs = parse_csf(joinpath(@__DIR__, "atsp", csfout))
        atlev_csfs = f()
        @test length(atlev_csfs) == length(atsp_csfs)
        for atlev_csf in atlev_csfs
            @test atlev_csf in atsp_csfs
        end
    end

    export compare_with_atsp
end

using .ATSPParser

@testset "CSFs" begin
    @testset "Construction" begin
        csf = CSF(rc"1s2 2p- 2p", [0, 1//2, 3//2], [0, 1//2, 2])
        @test csf isa CSF{RelativisticOrbital{Int},HalfInteger,HalfInteger}
        @test csf == csf
        @test csf != CSF(rc"1s2 2p- 2p", [0, 1//2, 3//2], [0, 1//2, 1])
    end

    @testset "CSF list generation" begin
        @testset "ls coupling" begin
            csf_1s2 = CSF(c"1s2", [IntermediateTerm(T"1S",0)],[T"1S"])
            @test csfs(c"1s2") == [csf_1s2]
            @test string(csf_1s2) == "1s²(₀¹S|¹S)+"

            csfs_1s_kp = [CSF(c"1s kp",
                              [IntermediateTerm(T"2S",1),IntermediateTerm(T"2Po",1)],
                              [T"2S", T"1Po"]),
                          CSF(c"1s kp",
                              [IntermediateTerm(T"2S",1),IntermediateTerm(T"2Po",1)],
                              [T"2S", T"3Po"])]
            @test csfs(c"1s kp") == csfs_1s_kp

            #= zgenconf input
              OI
                1s  2s
                 2   4  -1   2   0   2   n_orbitals,  n_electrons, parity, n_ref, k_min, k_max
                2p  3d
                 0   0
                 6  10
            =#
            compare_with_atsp("1s2c_2s2c_2p1_3_3d3_1.csfs") do
                csfs(c"1s2c 2s2c" ⊗ [c"2p1 3d3", c"2p3 3d1"])
            end
        end
        @testset "jj coupling" begin
            # These are not real tests, they only make sure that the
            # generation does not crash.
            sort(csfs([rc"3s 3p2",rc"3s 3p- 3p"]))
            csfs(rc"[Kr] 5s2 5p-2 5p3 6s")
            csfs(rc"1s kp")

            @test string(CSF(rc"[Kr] 5s2 5p- 5p4 kd", [0//1, 1//2, 0//1, 5//2], [0//1, 1//2, 1//2, 3//1])) ==
                "[Kr]ᶜ 5s²(0|0) 5p⁻(1/2|1/2) 5p⁴(0|1/2) kd(5/2|3)-"
        end
    end
end
