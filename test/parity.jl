using UnicodeFun

@testset "Parity" begin
    @testset "Construction" begin
        @test p"even".p
        @test !p"odd".p
        @test convert(Parity, 1) == p"even"
        @test convert(Parity, -1) == p"odd"
        @test_throws ArgumentError convert(Parity, 5)
    end

    @testset "Boolean properties" begin
        @test iseven(p"even")
        @test !isodd(p"even")
        @test !iseven(p"odd")
        @test isodd(p"odd")
        @test p"odd" < p"even"
        @test p"even" ≥ p"odd"
    end

    @testset "Arithmetic" begin
        @test iseven(p"even"*p"even")
        @test isodd(p"even"*p"odd")
        @test isodd(p"odd"*p"even")
        @test iseven(p"odd"*p"odd")

        @test iseven(p"even"^0)
        @test iseven(p"even"^1)
        @test iseven(p"even"^2)
        @test iseven(p"even"^3)
        @test iseven(p"odd"^0)
        @test isodd(p"odd"^1)
        @test iseven(p"odd"^2)
        @test isodd(p"odd"^3)

        @test isodd(-p"even")
        @test iseven(-p"odd")
    end

    @testset "Conversion" begin
        @test convert(Int, p"even") == 1
        @test convert(Int, p"odd") == -1
    end

    @testset "Pretty-printing" begin
        @test "$(p"even")" == "even"
        @test "$(p"odd")" == "odd"
        @test to_superscript(p"even") == ""
        @test to_superscript(p"odd") == "ᵒ"
    end
end
