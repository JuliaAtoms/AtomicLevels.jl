using AtomicLevels
using HalfIntegers
using Test

@testset "Intermediate terms" begin
    @testset "LS coupling" begin
        @test !AtomicLevels.istermvalid(T"2S", Seniority(2))

        @test string(IntermediateTerm(T"2D", Seniority(3))) == "₃²D"
        @test string(IntermediateTerm(T"2D", 3)) == "₍₃₎²D"

        for t in [T"2D", T"2Do"], ν in [1, Seniority(2), 3]
            it = IntermediateTerm(t, ν)
            @test length(propertynames(it)) == 3
            @test hasproperty(it, :term)
            @test hasproperty(it, :ν)
            @test hasproperty(it, :nu)
            @test it.term == t
            @test it.ν == it.nu
            @test it.nu == ν
            @test !hasproperty(it, :foo)
            @test_throws ErrorException it.foo
        end

        @testset "Seniority" begin
            # Table taken from p. 25 of
            #
            # - Froese Fischer, C., Brage, T., & Jönsson, P. (1997). Computational
            #   Atomic Structure : An MCHF Approach. Bristol, UK Philadelphia, Penn:
            #   Institute of Physics Publ.
            subshell_terms = [
                o"1s" => (1 => "2S1",
                          2 => "1S0"),
                o"2p" => (1 => "2P1",
                          2 => ("1S0", "1D2", "3P2"),
                          3 => ("2P1", "2D3", "4S3")),
                o"3d" => (1 => "2D1",
                          2 => ("1S0", "1D2", "1G2", "3P2", "3F2"),
                          3 => ("2D1", "2P3", "2D3", "2F3", "2G3", "2H3", "4P3", "4F3"),
                          4 => ("1S0", "1D2", "1G2", "3P2", "3F2", "1S4", "1D4", "1F4", "1G4", "1I4", "3P4", "3D4", "3F4", "3G4", "3H4", "5D4"),
                          5 => ("2D1", "2P3", "2D3", "2F3", "2G3", "2H3", "4P3", "4F3", "2S5", "2D5", "2F5", "2G5", "2I5", "4D5", "4G5", "6S5")),
                o"4f" => (1 => "2F1",
                          2 => ("1S0", "1D2", "1G2", "1I2", "3P2", "3F2", "3H2"))
            ]

            foreach(subshell_terms) do (orb, data)
                foreach(data) do (occ, expected_its)
                    p = parity(orb)^occ
                    expected_its = map(expected_its isa String ? (expected_its,) : expected_its) do ei
                        t_str = "$(ei[1:2])$(isodd(p) ? "o" : "")"
                        IntermediateTerm(parse(Term, t_str), Seniority(parse(Int, ei[end])))
                    end
                    its = intermediate_terms(orb, occ)
                    @test its == [expected_its...]
                end
            end
        end
    end

    @testset "Term enumeration" begin
        @test !allunique(intermediate_terms(c"2p2 4f11")[2])
        @test allunique(intermediate_terms(SeniorityEnumeration, c"2p2 4f11")[2])
        @test allunique(intermediate_terms(TermEnumeration, c"2p2 4f11")[2])

        @test !allunique(intermediate_terms(rc"5g4")[1])
        @test allunique(intermediate_terms(SeniorityEnumeration, rc"5g4")[1])
        @test allunique(intermediate_terms(TermEnumeration, rc"5g4")[1])
    end

    @testset "jj coupling" begin
        # Taken from Table A.10 of
        #
        # - Grant, I. P. (2007). Relativistic Quantum Theory of Atoms and
        #   Molecules : Theory and Computation. New York: Springer.
        #
        # except for the last row, which seems to have a typo since J=19/2 is
        # missing. Cf. Table 4-5 of
        #
        # - Cowan, R. (1981). The Theory of Atomic Structure and
        #   Spectra. Berkeley: University of California Press.
        ref_table = [[rc"1s2", rc"2p-2"] => [0 => [0]],
                     [rc"1s", rc"2p-"] => [1 => [1/2]],
                     [rc"2p4", rc"3d-4"] => [0 => [0]],
                     [rc"2p", rc"2p3", rc"3d-", rc"3d-3"] => [1 => [3/2]],
                     [rc"2p2", rc"3d-2"] => [0 => [0], 2 => [2]],
                     [rc"3d6", rc"4f-6"] => [0 => [0]],
                     [rc"3d", rc"3d5", rc"4f-", rc"4f-5"] => [1 => [5/2]],
                     [rc"3d2", rc"3d4", rc"4f-2", rc"4f-4"] => [0 => [0], 2 => [2,4]],
                     [rc"3d3", rc"4f-3"] => [1 => [5/2], 3 => [3/2, 9/2]],
                     [rc"4f8", rc"5g-8"] => [0 => [0]],
                     [rc"4f", rc"4f7", rc"5g-", rc"5g-7"] => [1 => [7/2]],
                     [rc"4f2", rc"4f6", rc"5g-2", rc"5g-6"] => [0 => [0], 2 => [2,4,6]],
                     [rc"4f3", rc"4f5", rc"5g-3", rc"5g-5"] => [1 => [7/2], 3 => [3/2, 5/2, 9/2, 11/2, 15/2]],
                     [rc"4f4", rc"5g-4"] => [0 => [0], 2 => [2,4,6], 4 => [2,4,5,8]],
                     [rc"5g10", rc"6h-10"] => [0 => [0]],
                     [rc"5g", rc"5g9", rc"6h-", rc"6h-9"] => [1 => [9/2]],
                     [rc"5g2", rc"5g8", rc"6h-2", rc"6h-8"] => [0 => [0], 2 => [2,4,6,8]],
                     [rc"5g3", rc"5g7", rc"6h-3", rc"6h-7"] => [1 => [9/2],
                                                                3 => vcat((3:2:17), 21)./2],
                     [rc"5g4", rc"5g6", rc"6h-4", rc"6h-6"] => [0 => 0, 2 => [2,4,6,8],
                                                                4 => [0,2,3,4,4,5,6,6,7,8,9,10,12]],
                     [rc"5g5", rc"6h-5"] => [1 => [9/2], 3 => vcat((3:2:17), 21)./2,
                                             5 => vcat(1, (5:2:19), 25)./2]]

        for (cfgs,cases) in ref_table
            ref = [reduce(vcat, [[IntermediateTerm(convert(HalfInt, J), Seniority(ν))
                                  for J in Js]
                                 for (ν,Js) in cases])]
            for cfg in cfgs
                @test intermediate_terms(cfg) == ref
            end
        end
    end
end
