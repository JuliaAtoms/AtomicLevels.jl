using Test
using AtomicLevels
# ^^^ -- to make it possible to run the test file separately

module GRASPParser
using Test
using AtomicLevels
import AtomicLevels: CSF, csfs
using WignerSymbols
include("grasp/rcsfparser.jl")

compare_with_grasp(f, rcsfout) = @testset "GRASP CSFs: $(rcsfout)" begin
    grasp_csfs = parse_rcsf(joinpath(@__DIR__, "grasp", rcsfout))
    atlev_csfs = f()
    @test length(atlev_csfs) == length(grasp_csfs)
    for atlev_csf in atlev_csfs
        @test atlev_csf in grasp_csfs
    end
end

export compare_with_grasp
end

using .GRASPParser

@testset "Excited configurations" begin
    @testset "Simple" begin
        @test_throws ArgumentError excited_configurations(rc"[Kr] 5s2 5p6", max_excitations=:triples)
        @test_throws ArgumentError excited_configurations(rc"[Kr] 5s2 5p6", min_occupancy=[2,0])
        @test_throws ArgumentError excited_configurations(rc"[Kr] 5s2 5p6", max_occupancy=[2,0])

        @test_throws ArgumentError excited_configurations(rc"[Kr] 5s2 5p6", min_occupancy=[-1,0,0])
        @test_throws ArgumentError excited_configurations(rc"[Kr] 5s2 5p6", max_occupancy=[3,2,4])
    end
    
    @testset "Ion–continuum" begin
        @test ion_continuum(c"1s2", os"k[s-d]") == [c"1s2", c"1s ks", c"1s kp", c"1s kd"]
    end
    
    @testset "GRASP comparisons" begin
        @test excited_configurations(c"1s2", os"2[s-p]"...) ==
            [c"1s2", c"1s 2s", c"2s2", c"2p2"]
        @test excited_configurations(c"1s2", os"k[s-p]"...) ==
            [c"1s2", c"1s ks", c"ks2", c"kp2"]

        @test excited_configurations(rc"1s2", ros"2[s-p]"...) ==
            [rc"1s2", rc"1s 2s", rc"2s2", rc"2p-2", rc"2p- 2p", rc"2p2"]
        @test excited_configurations(rc"1s2", ro"2s") == [rc"1s2", rc"1s 2s", rc"2s2"]
        @test excited_configurations(rc"1s2", ro"2p-") == [rc"1s2", rc"2p-2"]

        #= rcsfgenerate input:
        *
        1
        2s(2,i)2p(2,i)

        2s,2p
        0 10
        0
        n
        =#
        compare_with_grasp("rcsf.out.1.txt") do
            csfs(rc"1s2 2s2" ⊗ rcs"2p2")
        end

        #= rcsfgenerate input:
        *
        0
        3s(1,i)3p(3,i)3d(4,i)

        3s,3p,3d
        0 50
        0
        n
        =#
        compare_with_grasp("rcsf.out.2.txt") do
            csfs(rc"3s1" ⊗ rcs"3p3" ⊗ rcs"3d4")
        end

        #= rcsfgenerate input:
        *
        2
        3s(1,i)3p(2,i)3d(2,i)

        3s,3p,3d
        1 51
        0
        n
        =#
        compare_with_grasp("rcsf.out.3.txt") do
            csfs(rc"[Ne]* 3s1" ⊗ rcs"3p2" ⊗ rcs"3d2")
        end

        #= rcsfgenerate input:
        *
        0
        1s(2,*)

        2s,2p
        0 20
        2
        n
        =#
        compare_with_grasp("rcsf.out.4.txt") do
            csfs(excited_configurations(rc"1s2", ro"2s", ro"2p-", ro"2p"))
        end

        #= rcsfgenerate input:
        *
        0
        1s(2,*)

        3s,3p,3d
        0 20
        2
        n
        =#
        compare_with_grasp("rcsf.out.5.txt") do
            excited_configurations(
                rc"1s2",
                ro"2s", ro"2p-", ro"2p", ro"3s", ro"3p-", ro"3p", ro"3d-", ro"3d"
            ) |> csfs
        end

        # TODO:

        #= rcsfgenerate input: (problematic alphas with semicolons etc)
        *
        0
        5f(5,i)

        5s,5p,5d,5f
        1 51
        0
        n
        =#
    end
end
