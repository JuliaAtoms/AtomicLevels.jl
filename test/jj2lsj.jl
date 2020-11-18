using LinearAlgebra
import AtomicLevels: angular_integral

@testset "jj2lsj" begin
    @testset "Transform matrix" begin
        R = jj2lsj(ros"1[s] 2[s-p] k[s-d]"...)
        # Since it is a rotation matrix, its inverse is simply the
        # transpose.
        @test norm(inv(Matrix(R)) - R') < 10eps()
    end

    @testset "Transform individual spin-orbitals" begin
        for o in [o"5s", o"5p", o"5d"]
            for so in spin_orbitals(o)
                ℓ = so.orb.ℓ
                mℓ,ms = so.m
                mj = mℓ + ms
                pure = abs(mj) == ℓ + half(1)
                linear_combination = jj2lsj(so)
                @test length(linear_combination) == (pure ? 1 : 2)
                @test norm(last.(linear_combination)) ≈ 1
                @test all(isequal(mj), map(o -> first(o.m), first.(linear_combination)))
            end
        end
    end

    @testset "Angular integrals" begin
        @test isone(angular_integral(SpinOrbital(o"ks", (0,half(1))), SpinOrbital(o"1s", (0,half(1)))))
        @test iszero(angular_integral(SpinOrbital(o"ks", (0,half(1))), SpinOrbital(o"2p", (0,half(1)))))

        @test isone(angular_integral(SpinOrbital(ro"ks", half(1)), SpinOrbital(ro"1s", half(1))))
        @test iszero(angular_integral(SpinOrbital(ro"ks", half(1)), SpinOrbital(ro"2p-", half(1))))

        @test isone(angular_integral(SpinOrbital(o"ks", (0,half(1))), SpinOrbital(ro"1s", half(1))))
        @test isone(angular_integral(SpinOrbital(ro"1s", half(1)), SpinOrbital(o"ks", (0,half(1)))))

        @test angular_integral(SpinOrbital(o"2p", (0,half(1))), SpinOrbital(ro"2p-", half(1))) == clebschgordan(1, 0, half(1), half(1), half(1), half(1))
    end

    @testset "#orbitals = $(length(ros))" for (ros,nb) in ((rsos"l[p]", 4), (rsos"k[s-d] l[d]", 18), (filter(o -> o.m[1]==1//2, rsos"l[d]"), 1))
        os, bs = jj2lsj(ros)
        @test length(os) == length(ros)
        for (ro,o) in zip(ros, os)
            @test sum(o.m) == ro.m[1]
            @test o.orb.n == ro.orb.n
            @test o.orb.ℓ == ro.orb.ℓ
        end
        @test length(bs) == nb
        for (i,j,b) in bs
            if size(b,1) == 1
                @test i == j
            else
                @test i ≠ j
            end
            @test b == b'
            @test b^2 ≈ I
        end
    end
end
