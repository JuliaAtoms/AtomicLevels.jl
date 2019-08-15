@testset "Term coupling" begin
    @testset "LS Coupling" begin
        # Coupling two 2S terms should yields singlets and triplets of S,P,D
        @test couple_terms(Term(1,1//2,1), Term(1,1//2,1)) ==
            sort([Term(2,0,1), Term(2,1,1), Term(0,0,1), Term(1,1,1), Term(1,0,1), Term(0,1,1)])

        @test couple_terms(Term(0,1//2,1), Term(1,1//2,-1)) ==
            sort([Term(1,0,-1), Term(1,1,-1)])

        @test couple_terms(Term(0,1//2,-1), Term(1,1//2,-1)) ==
            sort([Term(1,0,1), Term(1,1,1)])

        function test_coupling(o1, o2)
            c1 = couple_terms(terms(o1), terms(o2))
            r = o1 + o2
            c2 = terms(r)
            @test c1 == c2
        end

        test_coupling(c"1s", c"2p")
        test_coupling(c"2s", c"2p")
        test_coupling(c"2p", c"3p")
        test_coupling(c"2p", c"3d")

        @test terms(c"1s") == [T"2S"]
        @test terms(c"1s2") == [T"1S"]
        @test terms(c"2p") == [T"2Po"]
        @test terms(c"[He]") == [T"1S"]
        @test terms(c"[Ne]") == [T"1S"]
        @test terms(c"[Ar]") == [T"1S"]
        @test terms(c"[Kr]") == [T"1S"]
        @test terms(c"[Xe]") == [T"1S"]
        @test terms(c"[Rn]") == [T"1S"]

        @test terms(c"1s ks") == [T"1S", T"3S"]
        @test terms(c"1s kp") == [T"1Po", T"3Po"]
    end

    @testset "Coupling of jj terms" begin
        @test couple_terms(1, 2) isa Vector{Int}
        @test couple_terms(1//2, 1//2) isa Vector{HalfInt}
        @test couple_terms(1.0, 1.5) isa Vector{HalfInt}

        @test couple_terms(HalfInteger(1//2), HalfInteger(0)) == [1//2]
        @test couple_terms(1//2, HalfInteger(0)) == [1//2]
        @test couple_terms(HalfInteger(1//2), 0) == [1//2]

        @test couple_terms(0, 1) == 1:1
        @test couple_terms(1//2,1//2) == 0:1
        @test couple_terms(1, 1) == 0:2
        @test couple_terms(1//1, 3//2) == 1//2:5//2

        @test couple_terms(0, 1.0) == 1:1
        @test couple_terms(1.0, 1.5) == 1//2:5//2

        @test intermediate_couplings([1, 2], 3) isa Vector{Vector{Int}}
        @test intermediate_couplings([1, 2], HalfInteger(3)) isa Vector{Vector{HalfInt}}
        @test intermediate_couplings([1, 2], HalfInteger(3//2)) isa Vector{Vector{HalfInt}}
        @test intermediate_couplings([1, 2.5], 3) isa Vector{Vector{HalfInt}}

        @test intermediate_couplings([0, 0], 0) == [[0,0,0]]
        @test intermediate_couplings([0, 0], 1) == [[1,1,1]]
        @test intermediate_couplings([1//2, 1//2], 0) == [[0,1//2,0],[0,1//2,1]]
    end
end
