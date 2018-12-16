@testset "Configurations" begin
    @testset "Construction" begin
        config = Configuration([o"1s", o"2s", o"2p", o"3s", o"3p"], [2,2,6,2,6], [:closed])

        @test config.orbitals ==
            [o"1s", o"2s", o"2p-", o"2p", o"3s", o"3p-", o"3p"]

        @test config.occupancy == [2, 2, 2, 4, 2, 2, 4]

        @test config.states == [:closed, :open, :open, :open, :open, :open, :open]

        @test c"1s2c 2s2 2p6 3s2 3p6" == config
        @test c"1s2c.2s2.2p6.3s2.3p6" == config
        @test c"[He]c 2s2 2p6 3s2 3p6" == config

        @test c"[Kr]c 5s2" == Configuration([o"1s", o"2s", o"2p", o"3s", o"3p", o"3d", o"4s", o"4p", o"5s"],
                                            [2,2,6,2,6,10,2,6,2],
                                            [:closed,:closed,:closed,:closed,:closed,:closed,:closed,:closed,:open])

        @test length(c"") == 0

        @test c"1s ld-2 kp6" == Configuration([o"1s", o"kp-", o"kp", o"ld-"], [1, 2, 4, 2])

        @test_throws ArgumentError AtomicLevels.configuration_from_string("1sc")
        @test_throws ArgumentError AtomicLevels.configuration_from_string("1s 1s")
        @test_throws ArgumentError AtomicLevels.configuration_from_string("[He]c 1s")
        @test_throws ArgumentError AtomicLevels.configuration_from_string("1s3")
    end

    @testset "Number of electrons" begin
        @test num_electrons(c"[He]") == 2
        @test num_electrons(c"[Xe]") == 54
    end

    @testset "Access subsets" begin
        @test core(c"[Kr]c 5s2") == c"[Kr]c"
        @test peel(c"[Kr]c 5s2") == c"5s2"
        @test core(c"[Kr]c 5s2c 5p6") == c"[Kr]c 5s2c"
        @test peel(c"[Kr]c 5s2c 5p6") == c"5p6"
        @test active(c"[Kr]c 5s2") == c"5s2"
        @test inactive(c"[Kr]c 5s2i") == c"5s2i"
        @test inactive(c"[Kr]c 5s2") == c""
        @test bound(c"[Kr] 5s2 5p-2 5p3 ks") == c"[Kr] 5s2 5p-2 5p3"
        @test continuum(c"[Kr] 5s2 5p-2 5p3 ks") == c"ks"
        @test bound(c"[Kr] 5s2 5p-2 5p2 ks ld") == c"[Kr] 5s2 5p-2 5p2"
        @test continuum(c"[Kr] 5s2 5p-2 5p2 ks ld") == c"ks ld"

        @test c"[Ne]"[1] == (o"1s",2,:closed)
        @test c"[Ne]"[1:2] == c"1s2c 2s2c"
        @test c"[Ne]"[end-1:end] == c"2p6c"

        @test o"1s" ∈ c"[He]"
    end

    @testset "Parity" begin
        @test parity(c"1s") == 1
        @test parity(c"1s2") == 1
        @test parity(c"1s2 2s") == 1
        @test parity(c"1s2 2s2") == 1
        @test parity(c"[He]c 2s") == 1
        @test parity(c"[He]c 2s2") == 1
        @test parity(c"[He]c 2s 2p") == -1
        @test parity(c"[He]c 2s2 2p") == -1
        @test parity(c"[He]c 2s 2p2") == 1
        @test parity(c"[He]c 2s2 2p2") == 1
        @test parity(c"[He]c 2s2 2p2 3d") == 1
        @test parity(c"[He]c 2s kp") == -1
    end

    @testset "Number of electrons" begin
        @test count(c"1s") == 1
        @test count(c"[He]") == 2
        @test count(c"[Xe]") == 54
        @test count(peel(c"[Kr]c 5s2 5p6")) == 8
    end

    @testset "Pretty printing" begin
        Xe⁺ = c"[Kr]c 5s2 5p-2 5p3"
        map([c"1s" => "1s",
             c"1s2" => "1s²",
             c"1s2 2s2" => "1s² 2s²",
             c"1s2 2s2 2p" => "1s² 2s² 2p",
             c"1s2c 2s2 2p" => "[He]ᶜ 2s² 2p",
             c"[He]* 2s2" => "1s² 2s²",
             c"[He]c 2s2" => "[He]ᶜ 2s²",
             c"[He]i 2s2" => "1s²ⁱ 2s²",
             c"[Kr]c 5s2" => "[Kr]ᶜ 5s²",
             Xe⁺ => "[Kr]ᶜ 5s² 5p⁻² 5p³",
             core(Xe⁺) => "[Kr]ᶜ",
             peel(Xe⁺) => "5s² 5p⁻² 5p³",
             c"[Kr] 5s2c 5p6" => "[Kr]ᶜ 5s²ᶜ 5p⁻² 5p⁴",
             c"[Ne]"[end-1:end] => "2p⁻²ᶜ 2p⁴ᶜ",
             c"5s2" => "5s²",
             c"[Kr]*" => "1s² 2s² 2p⁻² 2p⁴ 3s² 3p⁻² 3p⁴ 3d⁻⁴ 3d⁶ 4s² 4p⁻² 4p⁴",
             c"[Kr]c" =>"[Kr]ᶜ",
             c"1s2 kp" => "1s² kp",
             c"" => "∅"]) do (c,s)
                 @test "$(c)" == s
             end
    end

    @testset "Orbital substitutions" begin
        @test replace(c"1s2", o"1s"=>o"2p") == c"1s 2p"
        @test replace(c"1s2", o"1s"=>o"kp") == c"1s kp"
        @test replace(c"1s kp", o"kp"=>o"ld") == c"1s ld"
        @test_throws ArgumentError replace(c"1s2", o"2p"=>o"3p")
        @test_throws ArgumentError replace(c"1s2 2s", o"2s"=>o"1s")
    end

    @testset "Configuration additions" begin
        @test c"1s" + c"1s" == c"[He]*"
        @test c"1s" + c"2p" == c"1s 2p"
        @test c"1s" + c"ld" == c"1s ld"
        @test c"[Kr]*" + c"4d10" + c"5s2" + c"5p6" == c"[Xe]*"
        @test_throws ArgumentError c"[He]*" + c"1s"
        @test_throws ArgumentError c"1si" + c"1s"
    end

    @testset "Configuration juxtapositions" begin
        @test c"" ⊗ c"" == [c""]
        @test c"1s" ⊗ c"" == [c"1s"]
        @test c"" ⊗ c"1s" == [c"1s"]
        @test c"1s" ⊗ c"2s" == [c"1s 2s"]
        @test c"1s" ⊗ [c"2s", c"2p-", c"2p"] == [c"1s 2s", c"1s 2p-", c"1s 2p"]
        @test [c"1s", c"2s"] ⊗ c"2p-" == [c"1s 2p-", c"2s 2p-"]
        @test [c"1s", c"2s"] ⊗ [c"2p-", c"2p"] == [c"1s 2p-", c"1s 2p", c"2s 2p-", c"2s 2p"]
        @test [c"1s 2s"] ⊗ [c"2p-2", c"2p4"] == [c"1s 2s 2p-2", c"1s 2s 2p4"]
    end
end
