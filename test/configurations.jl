@testset "Configurations" begin
    @testset "Construction" begin
        config = Configuration([o"1s", o"2s", o"2p", o"3s", o"3p"], [2,2,6,2,6], [:closed])
        rconfig = Configuration([ro"1s", ro"2s", ro"2p", ro"3s", ro"3p"], [2,2,6,2,6], [:closed])

        @test config.orbitals ==
            [o"1s", o"2s", o"2p", o"3s", o"3p"]
        @test rconfig.orbitals ==
            [ro"1s", ro"2s", ro"2p-", ro"2p", ro"3s", ro"3p-", ro"3p"]

        @test config.occupancy == [2, 2, 6, 2, 6]
        @test rconfig.occupancy == [2, 2, 2, 4, 2, 2, 4]

        @test config.states == [:closed, :open, :open, :open, :open]
        @test rconfig.states == [:closed, :open, :open, :open, :open, :open, :open]

        @test c"1s2c 2s2 2p6 3s2 3p6" == config
        @test c"1s2c.2s2.2p6.3s2.3p6" == config
        @test c"[He]c 2s2 2p6 3s2 3p6" == config

        @test rc"1s2c 2s2 2p6 3s2 3p6" == rconfig
        @test rc"1s2c.2s2.2p6.3s2.3p6" == rconfig
        @test rc"[He]c 2s2 2p6 3s2 3p6" == rconfig

        @test c"[Kr]c 5s2" == Configuration([o"1s", o"2s", o"2p", o"3s", o"3p", o"3d", o"4s", o"4p", o"5s"],
                                            [2,2,6,2,6,10,2,6,2],
                                            [:closed,:closed,:closed,:closed,:closed,:closed,:closed,:closed,:open])

        @test length(c"") == 0
        @test length(rc"") == 0

        @test rc"1s ld-2 kp6" == Configuration([ro"1s", ro"kp-", ro"kp", ro"ld-"], [1, 2, 4, 2])

        @test_throws ArgumentError parse(Configuration{Orbital}, "1sc")
        @test_throws ArgumentError parse(Configuration{Orbital}, "1s 1s")
        @test_throws ArgumentError parse(Configuration{Orbital}, "[He]c 1s")
        @test_throws ArgumentError parse(Configuration{Orbital}, "1s3")
        @test_throws ArgumentError parse(Configuration{RelativisticOrbital}, "1s3")
        @test_throws ArgumentError parse(Configuration{Orbital}, "1s2 2p-2")

        @test fill(c"1s 2s 2p") == c"1s2 2s2 2p6"
        @test fill(rc"1s 2s 2p- 2p") == rc"1s2 2s2 2p-2 2p4"
        @test close(c"1s2") == c"1s2c"
        @test_throws ArgumentError close(c"1s")

        # Tests for #19
        @test c"10s2" == Configuration([o"10s"], [2], [:open])
        @test c"9999l32" == Configuration([o"9999l"], [32], [:open])
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

        @test bound(c"[Kr] 5s2 5p5 ks") == c"[Kr] 5s2 5p5"
        @test continuum(c"[Kr] 5s2 5p5 ks") == c"ks"
        @test bound(c"[Kr] 5s2 5p4 ks ld") == c"[Kr] 5s2 5p4"
        @test continuum(c"[Kr] 5s2 5p4 ks ld") == c"ks ld"

        @test bound(rc"[Kr] 5s2 5p-2 5p3 ks") == rc"[Kr] 5s2 5p-2 5p3"
        @test continuum(rc"[Kr] 5s2 5p-2 5p3 ks") == rc"ks"
        @test bound(rc"[Kr] 5s2 5p-2 5p2 ks ld") == rc"[Kr] 5s2 5p-2 5p2"
        @test continuum(rc"[Kr] 5s2 5p-2 5p2 ks ld") == rc"ks ld"

        @test c"[Ne]"[1] == (o"1s",2,:closed)
        @test c"[Ne]"[1:2] == c"1s2c 2s2c"
        @test c"[Ne]"[end-1:end] == c"2s2c 2p6c"

        @test c"1s2 2p kp"[2:3] == c"2p kp"

        @test o"1s" ∈ c"[He]"
    end

    @testset "Parity" begin
        @test iseven(parity(c"1s"))
        @test iseven(parity(c"1s2"))
        @test iseven(parity(c"1s2 2s"))
        @test iseven(parity(c"1s2 2s2"))
        @test iseven(parity(c"[He]c 2s"))
        @test iseven(parity(c"[He]c 2s2"))
        @test isodd(parity(c"[He]c 2s 2p"))
        @test isodd(parity(c"[He]c 2s2 2p"))
        @test iseven(parity(c"[He]c 2s 2p2"))
        @test iseven(parity(c"[He]c 2s2 2p2"))
        @test iseven(parity(c"[He]c 2s2 2p2 3d"))
        @test isodd(parity(c"[He]c 2s kp"))
    end

    @testset "Number of electrons" begin
        @test count(c"1s") == 1
        @test count(c"[He]") == 2
        @test count(c"[Xe]") == 54
        @test count(peel(c"[Kr]c 5s2 5p6")) == 8
    end

    @testset "Pretty printing" begin
        Xe⁺ = rc"[Kr]c 5s2 5p-2 5p3"
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
             rc"[Kr] 5s2c 5p6" => "[Kr]ᶜ 5s²ᶜ 5p⁻² 5p⁴",
             c"[Ne]"[end:end] => "2p⁶ᶜ",
             rc"[Ne]"[end-1:end] => "2p⁻²ᶜ 2p⁴ᶜ",
             c"5s2" => "5s²",
             rc"[Kr]*" => "1s² 2s² 2p⁻² 2p⁴ 3s² 3p⁻² 3p⁴ 3d⁻⁴ 3d⁶ 4s² 4p⁻² 4p⁴",
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
        @test rc"1s" ⊗ [rc"2s", rc"2p-", rc"2p"] == [rc"1s 2s", rc"1s 2p-", rc"1s 2p"]
        @test [rc"1s", rc"2s"] ⊗ rc"2p-" == [rc"1s 2p-", rc"2s 2p-"]
        @test [rc"1s", rc"2s"] ⊗ [rc"2p-", rc"2p"] == [rc"1s 2p-", rc"1s 2p", rc"2s 2p-", rc"2s 2p"]
        @test [rc"1s 2s"] ⊗ [rc"2p-2", rc"2p4"] == [rc"1s 2s 2p-2", rc"1s 2s 2p4"]
        @test [rc"1s 2s"] ⊗ [rc"kp-2", rc"lp4"] == [rc"1s 2s kp-2", rc"1s 2s lp4"]
    end

    @testset "Non-relativistic orbitals" begin
        import AtomicLevels: rconfigurations_from_orbital
        @test rconfigurations_from_orbital(1, 0, 1) == [rc"1s"]
        @test rconfigurations_from_orbital(1, 0, 2) == [rc"1s2"]
        @test rconfigurations_from_orbital(2, 0, 2) == [rc"2s2"]

        @test rconfigurations_from_orbital(2, 1, 1) == [rc"2p-", rc"2p"]
        @test rconfigurations_from_orbital(2, 1, 2) == [rc"2p-2", rc"2p- 2p", rc"2p2"]
        @test rconfigurations_from_orbital(2, 1, 3) == [rc"2p-2 2p1", rc"2p- 2p2", rc"2p3"]
        @test rconfigurations_from_orbital(2, 1, 4) == [rc"2p-2 2p2", rc"2p- 2p3", rc"2p4"]
        @test rconfigurations_from_orbital(2, 1, 5) == [rc"2p-2 2p3", rc"2p- 2p4"]
        @test rconfigurations_from_orbital(2, 1, 6) == [rc"2p-2 2p4"]

        @test rconfigurations_from_orbital(4, 2, 10) == [rc"4d-4 4d6"]
        @test rconfigurations_from_orbital(4, 2, 5) == [rc"4d-4 4d1", rc"4d-3 4d2", rc"4d-2 4d3", rc"4d-1 4d4", rc"4d5"]

        @test rconfigurations_from_orbital(:k, 2, 5) == [rc"kd-4 kd1", rc"kd-3 kd2", rc"kd-2 kd3", rc"kd-1 kd4", rc"kd5"]

        @test_throws ArgumentError rconfigurations_from_orbital(1, 2, 1)
        @test_throws ArgumentError rconfigurations_from_orbital(1, 0, 3)

        @test rconfigurations_from_orbital(o"1s", 2) == [rc"1s2"]
        @test rconfigurations_from_orbital(o"2p", 2) == [rc"2p-2", rc"2p- 2p", rc"2p2"]
        @test_throws ArgumentError rconfigurations_from_orbital(o"3d", 20)

        @test rcs"1s" == [rc"1s"]
        @test rcs"2s2" == [rc"2s2"]
        @test rcs"2p4" == [rc"2p-2 2p2", rc"2p- 2p3", rc"2p4"]
        @test rcs"4d5" == [rc"4d-4 4d1", rc"4d-3 4d2", rc"4d-2 4d3", rc"4d-1 4d4", rc"4d5"]

        @test rc"1s2" ⊗ rcs"2p" == [rc"1s2 2p-", rc"1s2 2p"]
        @test rc"1s2" ⊗ rcs"kp" == [rc"1s2 kp-", rc"1s2 kp"]
    end
end
