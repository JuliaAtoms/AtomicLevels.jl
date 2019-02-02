using LinearAlgebra
using Parameters

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
                @unpack mℓ,spin = so
                mj = mℓ + (spin ? 1 : -1)//2
                pure = abs(mj) == ℓ + 1//2
                linear_combination = jj2lsj(so)
                @test length(linear_combination) == (pure ? 1 : 2)
                @test norm(last.(linear_combination)) ≈ 1
                @test all(mj .== last.(first.(linear_combination)))
            end
        end
    end
end
