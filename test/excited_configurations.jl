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

"""
    ispermutation(a, b[; cmp=isequal])

Tests is `a` is a permutation of `b`, i.e. if all elements are present
in both arrays. The comparison of two elements can be customized by
supplying a binary function `cmp`.

# Examples

```jldoctest
julia> ispermutation([1,2],[1,2])
true

julia> ispermutation([1,2],[2,1])
true

julia> ispermutation([1,2],[2,2])
false

julia> ispermutation([1,2],[1,-2])
false

julia> ispermutation([1,2],[1,-2],cmp=(a,b)->abs(a)==abs(b))
true
```
"""
ispermutation(a, b; cmp=isequal) =
    length(a) == length(b) &&
    all(any(Base.Fix2(cmp, x), b)
        for x in a)

@testset "Excited configurations" begin
    @testset "Simple" begin
        @test_throws ArgumentError excited_configurations(rc"[Kr] 5s2 5p6", min_excitations=-1)
        @test_throws ArgumentError excited_configurations(rc"[Kr] 5s2 5p6", min_excitations=3, max_excitations=2)
        @test_throws ArgumentError excited_configurations(rc"[Kr] 5s2 5p6", max_excitations=-1)
        @test_throws ArgumentError excited_configurations(rc"[Kr] 5s2 5p6", max_excitations=:triples)
        @test_throws ArgumentError excited_configurations(rc"[Kr] 5s2 5p6", min_occupancy=[2,0])
        @test_throws ArgumentError excited_configurations(rc"[Kr] 5s2 5p6", max_occupancy=[2,0])

        @test_throws ArgumentError excited_configurations(rc"[Kr] 5s2 5p6", min_occupancy=[-1,0,0])
        @test_throws ArgumentError excited_configurations(rc"[Kr] 5s2 5p6", max_occupancy=[3,2,4])

        @testset "Minimum excitations" begin
            @testset "Beryllium" begin
                @test ispermutation(excited_configurations(c"1s2 2s2", o"2p", keep_parity=false,
                                                           min_excitations=0),
                                    [c"1s2 2s2",
                                     c"1s 2s2 2p",
                                     c"1s2 2s 2p",
                                     c"2s2 2p2",
                                     c"1s 2s 2p2",
                                     c"1s2 2p2"])
                @test ispermutation(excited_configurations(c"1s2 2s2", o"2p", keep_parity=false,
                                                           min_excitations=1),
                                    [c"1s 2s2 2p",
                                     c"1s2 2s 2p",
                                     c"2s2 2p2",
                                     c"1s 2s 2p2",
                                     c"1s2 2p2"])
                @test ispermutation(excited_configurations(c"1s2 2s2", o"2p", keep_parity=false,
                                                           min_excitations=2),
                                    [c"2s2 2p2",
                                     c"1s 2s 2p2",
                                     c"1s2 2p2"])
            end

            @testset "Neon" begin
                Ne_singles = [
                    c"1s 2s2 2p6 3s",
                    c"1s 2s2 2p6 3p",
                    c"1s2 2s 2p6 3s",
                    c"1s2 2s 2p6 3p",
                    c"1s2 2s2 2p5 3s",
                    c"1s2 2s2 2p5 3p"
                ]

                Ne_doubles = [
                    c"2s2 2p6 3s2",
                    c"2s2 2p6 3s 3p",
                    c"1s 2s 2p6 3s2",
                    c"1s 2s 2p6 3s 3p",
                    c"1s 2s2 2p5 3s2",
                    c"1s 2s2 2p5 3s 3p",
                    c"2s2 2p6 3p2",
                    c"1s 2s 2p6 3p2",
                    c"1s 2s2 2p5 3p2",
                    c"1s2 2p6 3s2",
                    c"1s2 2p6 3s 3p",
                    c"1s2 2s 2p5 3s2",
                    c"1s2 2s 2p5 3s 3p",
                    c"1s2 2p6 3p2",
                    c"1s2 2s 2p5 3p2",
                    c"1s2 2s2 2p4 3s2",
                    c"1s2 2s2 2p4 3s 3p",
                    c"1s2 2s2 2p4 3p2"
                ]

                @test ispermutation(excited_configurations(c"[Ne]*", os"3[s-p]"..., keep_parity=false),
                                    vcat(c"[Ne]*", Ne_singles, Ne_doubles))
                @test ispermutation(excited_configurations(c"[Ne]*", os"3[s-p]"..., keep_parity=false,
                                                           min_excitations=1),
                                    vcat(Ne_singles, Ne_doubles))
                @test ispermutation(excited_configurations(c"[Ne]*", os"3[s-p]"..., keep_parity=false,
                                                           min_excitations=2),
                                    Ne_doubles)
            end
        end

        @testset "Unsorted base configuration" begin
            # Expect respected substitution orbitals ordering
            @test ispermutation(excited_configurations(c"1s2", o"2s", o"2p", keep_parity=false),
                                [c"1s2", c"1s 2s", c"1s 2p", c"2s2", c"2s 2p", c"2p2"])
            @test ispermutation(excited_configurations(c"1s2", o"2p", o"2s", keep_parity=false),
                                [c"1s2", c"1s 2p", c"1s 2s", c"2p2", c"2p 2s", c"2s2"])
            @test ispermutation(excited_configurations(c"1s 2s", o"2p", o"2s", keep_parity=false),
                                [c"1s 2s", c"2s2", c"1s2", c"1s 2p", c"2s 2p", c"2p2"])
            @test ispermutation(excited_configurations(c"1s 2s", o"2p", o"3s", keep_parity=false),
                                [c"1s 2s", c"2s2", c"1s2", c"1s 2p", c"1s 3s", c"2s 2p", c"2s 3s", c"2p2", c"2p 3s", c"3s2"])

            @test ispermutation(excited_configurations(rc"1s2", ro"2s", ro"2p-", ro"2p"),
                                [rc"1s2", rc"1s 2s", rc"2s2", rc"2p-2", rc"2p- 2p", rc"2p2"])
            @test ispermutation(excited_configurations(rc"1s2", ro"2s", ro"2p", ro"2p-"),
                                [rc"1s2", rc"1s 2s", rc"2s2", rc"2p2", rc"2p 2p-", rc"2p-2"])

            @testset "Core orbital replacements" begin
                reference = excited_configurations(c"[Ne]*"s, os"3[s-d]"...,
                                                   keep_parity=false)
                @test length(reference) == 46
                test1 = excited_configurations(c"[Ne]*", os"3[s-d]"...,
                                               keep_parity=false)
                test2 = excited_configurations(c"[Ne]*", o"3p", o"3d", o"3s",
                                               keep_parity=false)

                @test ispermutation(reference, test1)
                @test !ispermutation(reference, test2)
                @test ispermutation(reference, test2, cmp=issimilar)
                for cfg in test2
                    i = findfirst(isequal(o"3p"), cfg.orbitals)
                    j = findfirst(isequal(o"3d"), cfg.orbitals)
                    k = findfirst(isequal(o"3s"), cfg.orbitals)

                    if !isnothing(i)
                        !isnothing(j) && @test i < j
                        !isnothing(k) && @test i < k
                    end
                    !isnothing(j) && !isnothing(k) && @test j < k
                end
            end
        end

        @testset "Sorted base configuration" begin
            # Expect canonical ordering (of the orbitals, not the configurations)
            @test excited_configurations(c"1s2"s, o"2p", o"2s", keep_parity=false) ==
                [c"1s2", c"1s 2p", c"1s 2s", c"2p2", c"2s 2p", c"2s2"]
            @test excited_configurations(rc"1s2"s, ro"2s", ro"2p", ro"2p-") ==
                [rc"1s2", rc"1s 2s", rc"2s2", rc"2p2", rc"2p- 2p", rc"2p-2"]
        end
    end

    @testset "Custom substitutions" begin
        @test excited_configurations(c"1s2 2s2", os"k[s-p]"...,
                                     max_excitations=:singles, keep_parity=false) do a,b
                                         Orbital(Symbol("{$b}"), a.ℓ)
                                     end == [
                                         c"1s2 2s2",
                                         replace(c"1s2 2s2", o"1s" => Orbital(Symbol("{1s}"), 0), append=true),
                                         replace(c"1s2 2s2", o"1s" => Orbital(Symbol("{1s}"), 1), append=true),
                                         replace(c"1s2 2s2", o"2s" => Orbital(Symbol("{2s}"), 0), append=true),
                                         replace(c"1s2 2s2", o"2s" => Orbital(Symbol("{2s}"), 1), append=true)
                                     ]
    end

    @testset "Multiple references" begin
        @test ispermutation(excited_configurations([c"1s2"s, c"2s2"s], o"1s", o"2s",
                                                   max_excitations=:singles, keep_parity=false),
                            [c"1s2", c"1s 2s", c"2s2"])
    end

    @testset "Spin-configurations" begin
        @testset "Bound substitutions" begin
            cfg = first(scs"1s2")
            orbitals = sos"3[s]"
            @test ispermutation(excited_configurations(cfg, orbitals..., keep_parity=false),
                                 vcat(cfg,
                                      [replace(cfg, cfg.orbitals[1]=>o) for o in orbitals],
                                      [replace(cfg, cfg.orbitals[2]=>o) for o in orbitals],
                                      scs"3s2"))
            @test ispermutation(excited_configurations(cfg, orbitals..., keep_parity=false,
                                                       min_occupancy=[1,0]),
                                 vcat(cfg,
                                      [replace(cfg, cfg.orbitals[2]=>o) for o in orbitals]))
        end
        @testset "Continuum substitutions" begin
            gst = first(scs"1s2 2s2")
            orbitals = sos"k[s]"
            ionize = (subs_orb, orb) -> isbound(orb) ? SpinOrbital(Orbital(Symbol("[$(orb)]"), subs_orb.orb.ℓ), subs_orb.m) : subs_orb
            singles = [replace(gst, o => ionize(so,o))
                       for so in orbitals
                       for o in gst.orbitals]
            doubles = unique([replace(cfg, o => ionize(so,o))
                              for cfg in singles
                              for so in orbitals
                              for o in bound(cfg).orbitals])
            @test ispermutation(excited_configurations(ionize, gst, orbitals..., keep_parity=false),
                                vcat(gst, singles, doubles))
        end
        @testset "Double excitations of spin-configurations" begin
            gst = spin_configurations(Configuration(o"1s", 2, :open, sorted=false))[1]
            orbitals = reduce(vcat, spin_orbitals.(os"2[s]"))
            cs = excited_configurations(gst, orbitals...)
            @test cs[1] == gst
            @test cs[2:3] == [replace(gst, gst.orbitals[1]=>o) for o in orbitals]
            @test cs[4:5] == [replace(gst, gst.orbitals[2]=>o) for o in orbitals]
            @test cs[6] == Configuration(orbitals, [1,1])
        end
    end

    @testset "Ion–continuum" begin
        ic = ion_continuum(c"1s2", os"k[s-d]")
        @test ic == [c"1s2", c"1s ks", c"1s kp", c"1s kd"]
        @test spin_configurations(ic) isa Vector{<:Configuration{<:SpinOrbital{<:Orbital,Tuple{Int,HalfInt}}}}
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
            csfs(rc"[Ne]* 3s1"s ⊗ rcs"3p2" ⊗ rcs"3d2")
        end


        # TODO: The following two tests are wrapped in
        # unique(map(sort, ...)) until excited_configurations are
        # fixed to take the ordering of excitation orbitals into
        # account.

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
