using Random

@testset "Orbitals" begin
    @testset "kappa" begin
        import AtomicLevels: assert_orbital_ℓj
        @test assert_orbital_ℓj(0, HalfInteger(1//2)) === nothing
        @test assert_orbital_ℓj(1, HalfInteger(1//2)) === nothing
        @test assert_orbital_ℓj(1, 3//2) === nothing
        @test assert_orbital_ℓj(2, 2.5) === nothing
        @test_throws ArgumentError assert_orbital_ℓj(0, 0)
        @test_throws ArgumentError assert_orbital_ℓj(0, 1)
        @test_throws ArgumentError assert_orbital_ℓj(0, 3//2)
        @test_throws ArgumentError assert_orbital_ℓj(5, 1//2)
        @test_throws MethodError assert_orbital_ℓj(HalfInteger(1), HalfInteger(1//2))

        import AtomicLevels: kappa_to_ℓ
        @test_throws ArgumentError kappa_to_ℓ(0)
        @test kappa_to_ℓ(-1) == 0
        @test kappa_to_ℓ( 1) == 1
        @test kappa_to_ℓ(-2) == 1
        @test kappa_to_ℓ( 2) == 2
        @test kappa_to_ℓ(-3) == 2
        @test kappa_to_ℓ( 3) == 3

        import AtomicLevels: kappa_to_j
        @test_throws ArgumentError kappa_to_j(0)
        @test kappa_to_j(-1) === half(1)
        @test kappa_to_j( 1) === half(1)
        @test kappa_to_j(-2) === half(3)
        @test kappa_to_j( 2) === half(3)
        @test kappa_to_j(-3) === half(5)
        @test kappa_to_j( 3) === half(5)

        import AtomicLevels: ℓj_to_kappa
        @test ℓj_to_kappa(0, half(1)) == -1
        @test κ"s" == -1
        @test ℓj_to_kappa(1, half(1)) == 1
        @test κ"p-" == 1
        @test ℓj_to_kappa(1, 3//2) == -2
        @test κ"p" == -2
        @test ℓj_to_kappa(2, 3//2) == 2
        @test κ"d-" == 2
        @test ℓj_to_kappa(2, 5//2) == -3
        @test κ"d" == -3
        @test ℓj_to_kappa(3, 5//2) == 3
        @test κ"f-" == 3
        @test ℓj_to_kappa(3, 7//2) == -4
        @test κ"f" == -4
        @test_throws ArgumentError ℓj_to_kappa(0, half(3))
        @test_throws ArgumentError ℓj_to_kappa(0, 0)
        @test_throws ArgumentError ℓj_to_kappa(6, 1//2)
    end

    @testset "Construction" begin
        @test o"1s"   == Orbital(1, 0)
        @test o"2p"   == Orbital(2, 1)
        @test o"2[1]" == Orbital(2, 1)

        @test ro"1s"   == RelativisticOrbital(1, -1) # κ=-1 => s orbital
        @test ro"2p-"  == RelativisticOrbital(2,  1, half(1))
        @test ro"2p-"  == RelativisticOrbital(2,  1, 1//2)
        @test ro"2p"   == RelativisticOrbital(2,  1, 3//2)
        @test ro"2[1]" == RelativisticOrbital(2,  1, 3//2)

        @test o"kp" == Orbital(:k,1)
        @test o"ϵd" == Orbital(:ϵ,2)

        @test ro"kp"  == RelativisticOrbital(:k, 1, 3//2)
        @test ro"ϵd-" == RelativisticOrbital(:ϵ, 2, 3//2)

        @test_throws ArgumentError AtomicLevels.orbital_from_string(Orbital, "2p-")
        @test_throws ArgumentError AtomicLevels.orbital_from_string(Orbital, "sdkfl")

        @test_throws ArgumentError Orbital(0, 0)
        @test_throws ArgumentError Orbital(1, 1)
        @test_throws ArgumentError RelativisticOrbital(0, 0)
        @test_throws ArgumentError RelativisticOrbital(1, 1)
        @test_throws ArgumentError RelativisticOrbital(1, 0, 3//2)

        @test nonrelorbital(o"2p") == o"2p"
        @test nonrelorbital(ro"2p") == o"2p"
        @test nonrelorbital(ro"2p-") == o"2p"
    end

    @testset "Properties" begin
        let o = o"3d"
            @test o.n == 3
            @test o.ℓ == 2
        end
        let o = o"ks"
            @test o.n == :k
            @test o.ℓ == 0
        end

        @test propertynames(o"1s") == (:n , :ℓ)
        @test propertynames(ro"1s") == (:n, :κ, :j, :ℓ)

        let o = ro"3d"
            @test o.n == 3
            @test o.κ == -3
            @test o.j == 5//2
            @test o.ℓ == 2
        end
        let o = ro"ks"
            @test o.n == :k
            @test o.κ == -1
            @test o.j == 1//2
            @test o.ℓ == 0
        end
        let o = ro"2p-"
            @test o.n == 2
            @test o.κ == 1
            @test o.j == 1//2
            @test o.ℓ == 1
        end
    end

    @testset "Order" begin
        @test sort(shuffle([o"1s", o"2s", o"2p", o"3s", o"3p"])) ==
            [o"1s", o"2s", o"2p", o"3s", o"3p"]
        @test sort([o"ls", o"kp", o"2p", o"1s"]) ==
            [o"1s", o"2p", o"kp", o"ls"]

        @test sort(shuffle([ro"1s", ro"2s", ro"2p-", ro"2p", ro"3s", ro"3p-", ro"3p"])) ==
            [ro"1s", ro"2s", ro"2p-", ro"2p", ro"3s", ro"3p-", ro"3p"]
        @test sort([ro"ls", ro"kp", ro"2p", ro"1s"]) ==
            [ro"1s", ro"2p", ro"kp", ro"ls"]
    end

    @testset "Range of orbitals" begin
        @test os"6[s-d] 5[d]" == [o"5d", o"6s", o"6p", o"6d"]
        @test os"k[s-g] l[s-g]" == [o"ks", o"kp", o"kd", o"kf", o"kg",
                                    o"ls", o"lp", o"ld", o"lf", o"lg"]

        @test ros"6[s-d] 5[d]" == [ro"5d-", ro"5d", ro"6s", ro"6p-", ro"6p", ro"6d-", ro"6d"]
        @test ros"k[s-g] l[s-g]" == [ro"ks", ro"kp-", ro"kp", ro"kd-", ro"kd", ro"kf-", ro"kf", ro"kg-", ro"kg",
                                     ro"ls", ro"lp-", ro"lp", ro"ld-", ro"ld", ro"lf-", ro"lf", ro"lg-", ro"lg"]
    end

    @testset "Flip j" begin
        @test AtomicLevels.flip_j(ro"1s") == ro"1s"
        @test AtomicLevels.flip_j(ro"2p-") == ro"2p"
        @test AtomicLevels.flip_j(ro"2p") == ro"2p-"
        @test AtomicLevels.flip_j(ro"3d-") == ro"3d"
        @test AtomicLevels.flip_j(ro"3d") == ro"3d-"

        @test AtomicLevels.flip_j(ro"kd-") == ro"kd"
        @test AtomicLevels.flip_j(ro"kd") == ro"kd-"
    end

    @testset "Degeneracy" begin
        @test degeneracy(o"1s") == 2
        @test degeneracy(o"2p") == 6
        @test degeneracy(o"3d") == 10

        @test degeneracy(o"kp") == 6

        @test degeneracy(ro"1s") == 2
        @test degeneracy(ro"2p-") == 2
        @test degeneracy(ro"2p") == 4
        @test degeneracy(ro"3d-") == 4
        @test degeneracy(ro"3d") == 6

        @test degeneracy(ro"kp-") == 2
        @test degeneracy(ro"kp") == 4
    end

    @testset "Parity" begin
        @test iseven(parity(o"1s"))
        @test isodd(parity(o"2p"))
        @test iseven(parity(o"3s"))
        @test isodd(parity(o"3p"))
        @test iseven(parity(o"3d"))

        @test isodd(parity(o"kp"))

        @test iseven(parity(ro"1s"))
        @test isodd(parity(ro"2p"))
        @test iseven(parity(ro"3s"))
        @test isodd(parity(ro"3p"))
        @test iseven(parity(ro"3d"))

        @test isodd(parity(ro"kp"))
    end

    @testset "Symmetry" begin
        @test symmetry(o"1s") == 0
        @test symmetry(o"2s") == symmetry(o"1s")
        @test symmetry(o"2s") != symmetry(o"2p")

        @test symmetry(ro"1s") == symmetry(ro"2s")
        @test symmetry(ro"2p") == symmetry(ro"3p")
        @test symmetry(ro"2p") != symmetry(ro"2p-")
    end

    @testset "Bound" begin
        @test isbound(o"1s")
        @test isbound(o"3d")
        @test isbound(ro"1s")
        @test isbound(ro"3d")
        @test !isbound(o"ks")
        @test !isbound(o"ϵd")
        @test !isbound(ro"ks")
        @test !isbound(ro"ϵd")
    end

    @testset "Angular momenta" begin
        @test angular_momenta(o"2s") == (0,half(1))
        @test angular_momenta(o"2p") == (1,half(1))
        @test angular_momenta(o"4f") == (3,half(1))
        @test angular_momentum_ranges(o"4f") == (-3:3,-half(1):half(1))

        @test angular_momenta(ro"1s") == (half(1),)
        @test angular_momenta(ro"2p-") == (half(1),)
        @test angular_momenta(ro"2p") == (half(3),)
        @test angular_momenta(ro"3d-") == (half(3),)
        @test angular_momenta(ro"3d") == (half(5),)
        @test angular_momentum_ranges(ro"3d") == (-half(5):half(5),)
    end

    @testset "Spin orbitals" begin
        up, down = half(1),-half(1)

        @test_throws ArgumentError SpinOrbital(o"1s", 1, up)
        @test_throws ArgumentError SpinOrbital(o"ks", 1, up)
        @test_throws ArgumentError SpinOrbital(o"2p", -3, up)
        @test_throws ArgumentError SpinOrbital(o"2p", 1, half(3))
        @test_throws ArgumentError SpinOrbital(ro"2p-", half(3))

        soα = SpinOrbital(o"1s", 0, up)
        soβ = SpinOrbital(o"1s", 0, down)

        po₋α = SpinOrbital(o"2p", -1, up)
        po₀α = SpinOrbital(o"2p", 0, up)
        po₊α = SpinOrbital(o"2p", 1, up)
        po₋β = SpinOrbital(o"2p", -1, down)
        po₀β = SpinOrbital(o"2p", 0, down)
        po₊β = SpinOrbital(o"2p", 1, down)

        @test degeneracy(soα) == 1
        @test soα < soβ

        @test parity(soα) == parity(soβ) == p"even"

        @test parity(po₋α) == p"odd"
        @test parity(po₀α) == p"odd"
        @test parity(po₊α) == p"odd"
        @test parity(po₋β) == p"odd"
        @test parity(po₀β) == p"odd"
        @test parity(po₊β) == p"odd"

        @test symmetry(soα) != symmetry(soβ)

        @test symmetry(po₋α) != symmetry(po₀α)
        @test symmetry(po₋α) != symmetry(po₊α)
        @test symmetry(po₊α) != symmetry(po₀α)

        @test symmetry(po₋β) != symmetry(po₀β)
        @test symmetry(po₋β) != symmetry(po₊β)
        @test symmetry(po₊β) != symmetry(po₀β)

        @test symmetry(po₋α) != symmetry(po₋β)
        @test symmetry(po₀α) != symmetry(po₀β)
        @test symmetry(po₊α) != symmetry(po₊β)

        @test symmetry(po₋α) == symmetry(SpinOrbital(o"3p", -1, up))

        @test isbound(soα)
        @test !isbound(SpinOrbital(o"ks", 0, up))

        @test spin_orbitals(o"1s") == [soα, soβ]
        @test spin_orbitals(o"2p") == [po₋α, po₋β, po₀α, po₀β, po₊α, po₊β]
        for orb in [o"1s", o"2p", o"3d", o"4f", o"5g"]
            @test length(spin_orbitals(orb)) == degeneracy(orb)
        end

        @test sos"1[s] 2[p]" == [soα, soβ, po₋α, po₋β, po₀α, po₀β, po₊α, po₊β]

        @test "$(soα)" == "1s₀α"
        @test "$(po₊β)" == "2p₁β"
    end

    @testset "Internal methods" begin
        @test AtomicLevels.mqtype(o"2s") == Int
        @test AtomicLevels.mqtype(o"ks") == Symbol
        @test AtomicLevels.mqtype(ro"2s") == Int
        @test AtomicLevels.mqtype(ro"ks") == Symbol
    end

    @testset "String representation" begin
        @test string(o"1s") == "1s"
        @test string(ro"2p-") == "2p-"
        @test ascii(ro"2p-") == "2p-"
    end
end
