@testset "Levels & States" begin
    @testset "J values" begin
        @test J_range(T"¹S") == 0:0
        @test J_range(T"²S") == 1/2:1/2
        @test J_range(T"³P") == 0:2
        @test J_range(T"²D") == 3/2:5/2

        @test J_range(half(1)) == 1/2:1/2
        @test J_range(1) == 1:1
    end

    @testset "Construction" begin
        csfs_3s_3p = csfs(c"3s 3p")
        csf_1 = first(csfs_3s_3p)
        @test_throws ArgumentError Level(csf_1, HalfInteger(2))
        @test_throws ArgumentError Level(csf_1, 2)
        @test_throws ArgumentError State(Level(csf_1, HalfInteger(1)), HalfInteger(2))

        @test string(Level(csf_1, HalfInteger(1))) == "|3s(₁²S|²S) 3p(₁²Pᵒ|¹Pᵒ)-, J = 1⟩"
        @test string(Level(csf_1, 1)) == "|3s(₁²S|²S) 3p(₁²Pᵒ|¹Pᵒ)-, J = 1⟩"
        @test string(State(Level(csf_1, 1), HalfInteger(-1))) == "|3s(₁²S|²S) 3p(₁²Pᵒ|¹Pᵒ)-, J = 1, M_J = -1⟩"
        @test string(State(Level(csf_1, 1), -1)) == "|3s(₁²S|²S) 3p(₁²Pᵒ|¹Pᵒ)-, J = 1, M_J = -1⟩"

        @test sort([State(Level(csf_1, HalfInteger(1)), M_J) for M_J ∈ reverse(HalfInteger(-1):HalfInteger(1))]) ==
            [State(Level(csf_1, HalfInteger(1)), M_J) for M_J ∈ HalfInteger(-1):HalfInteger(1)]

        @test states.(csfs_3s_3p) == [[[State(Level(csf_1, HalfInteger(1)), M_J) for M_J ∈ HalfInteger(-1):HalfInteger(1)]],
                                      [[State(Level(csfs_3s_3p[2], J), M_J) for M_J ∈ -J:J] for J ∈ HalfInteger(0):HalfInteger(2) ]]

        rcsfs_3s_3p = csfs(rc"3s" ⊗ rcs"3p")

        @test states.(rcsfs_3s_3p)== [[[State(Level(rcsfs_3s_3p[1], HalfInteger(0)), HalfInteger(0))]],
                                      [[State(Level(rcsfs_3s_3p[2], HalfInteger(1)), M_J) for M_J ∈ HalfInteger(-1):HalfInteger(1)]],
                                      [[State(Level(rcsfs_3s_3p[3], HalfInteger(1)), M_J) for M_J ∈ HalfInteger(-1):HalfInteger(1)]],
                                      [[State(Level(rcsfs_3s_3p[4], HalfInteger(2)), M_J) for M_J ∈ HalfInteger(-2):HalfInteger(2)]]]
    end
end
