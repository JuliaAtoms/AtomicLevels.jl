@testset "Configurations" begin
    @testset "Construction" begin
        config = Configuration([o"1s", o"2s", o"2p", o"3s", o"3p"], [2,2,6,2,6], [:closed])
        rconfig = Configuration([ro"1s", ro"2s", ro"2p", ro"3s", ro"3p"], [2,2,6,2,6], [:closed], sorted=true)

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

        # We sort the configurations since the non-relativistic
        # convenience labels (2p) &c expand to two orbitals each, one
        # of which is appended to the orbitals list.
        @test rc"1s2c 2s2 2p6 3s2 3p6"s == rconfig
        @test rc"1s2c.2s2.2p6.3s2.3p6"s == rconfig
        @test rc"[He]c 2s2 2p6 3s2 3p6"s == rconfig

        @test c"[Kr]c 5s2" == Configuration([o"1s", o"2s", o"2p", o"3s", o"3p", o"3d", o"4s", o"4p", o"5s"],
                                            [2,2,6,2,6,10,2,6,2],
                                            [:closed,:closed,:closed,:closed,:closed,:closed,:closed,:closed,:open])

        @test length(c"") == 0
        @test length(rc"") == 0

        @test rc"1s ld-2 kp6" == Configuration([ro"1s", ro"ld-", ro"kp", ro"kp-"], [1, 2, 4, 2])
        @test rc"1s ld-2 kp6"s == Configuration([ro"1s", ro"kp-", ro"kp", ro"ld-"], [1, 2, 4, 2])

        @test_throws ArgumentError parse(Configuration{Orbital}, "1sc")
        @test_throws ArgumentError parse(Configuration{Orbital}, "1s 1s")
        @test_throws ArgumentError parse(Configuration{Orbital}, "[He]c 1s")
        @test_throws ArgumentError parse(Configuration{Orbital}, "1s3")
        @test_throws ArgumentError parse(Configuration{RelativisticOrbital}, "1s3")
        @test_throws ArgumentError parse(Configuration{Orbital}, "1s2 2p-2")

        @test fill(c"1s 2s 2p") == c"1s2 2s2 2p6"
        @test fill(rc"1s 2s 2p- 2p") == rc"1s2 2s2 2p-2 2p4"
        @test close(c"1s2") == c"1s2c"
        let c = c"1s2c 2s 2p"
            @test fill!(c) == c"1s2c 2s2 2p6"
            @test c == c"1s2c 2s2 2p6"
            close!(c)
            @test sort(c) == c"[Ne]"s
        end
        let c = rc"1s2c 2s 2p- 2p2"
            @test fill!(c) == rc"1s2c 2s2 2p-2 2p4"
            @test c == rc"1s2c 2s2 2p-2 2p4"
            close!(c)
            @test sort(c) == rc"[Ne]"s
        end
        @test_throws ArgumentError close(c"1s")
        @test_throws ArgumentError close(rc"1s2 2s")
        @test_throws ArgumentError close!(c"1s")
        @test_throws ArgumentError close!(rc"1s2 2s")

        # Tests for #19
        @test c"10s2" == Configuration([o"10s"], [2], [:open])
        @test c"9999l32" == Configuration([o"9999l"], [32], [:open])

        # Hashing
        let c1a = c"1s 2s", c1b = c"1s 2s", c2 = c"1s 2p"
            @test c1a == c1b
            @test isequal(c1a, c1b)
            @test c1a != c2
            @test !isequal(c1a, c2)

            @test hash(c1a) == hash(c1a)
            @test hash(c1a) == hash(c1b)

            # If hashing is not properly implemented, unique fails to detect all equal pairs
            @test unique([c1a, c1b]) == [c1a]
            @test unique([c1a, c1a]) == [c1a]
            @test unique([c1a, c1a, c1b]) == [c1a]
            @test length(unique([c1a, c2, c1a, c1b, c2])) == 2
        end
    end

    @testset "Number of electrons" begin
        @test num_electrons(c"[He]") == 2
        @test num_electrons(rc"[He]") == 2
        @test num_electrons(c"[Xe]") == 54
        @test num_electrons(rc"[Xe]") == 54

        @test num_electrons(c"[Xe]", o"1s") == 2
        @test num_electrons(rc"[Xe]", ro"1s") == 2
        @test num_electrons(c"[Ne] 3s 3p", o"3p") == 1
        @test num_electrons(rc"[Kr] Af-2 Bf5", ro"Bf") == 5
        @test num_electrons(c"[Kr]", ro"5s") == 0
        @test num_electrons(rc"[Rn]", ro"As") == 0
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
        @test ro"1s" ∈ rc"[He]"
    end

    @testset "Sorting" begin
        @test c"1s2" < c"1s 2s"
        @test c"1s2" < c"1s 2p"
        @test c"1s2" < c"ks2"
        # @test c"kp2" < c"kp kd" # Ideally this would be true, but too
        #                         # complicated to implement
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
             Xe⁺ => "[Kr]ᶜ 5s² 5p-² 5p³",
             core(Xe⁺) => "[Kr]ᶜ",
             peel(Xe⁺) => "5s² 5p-² 5p³",
             rc"[Kr] 5s2c 5p6"s => "[Kr]ᶜ 5s²ᶜ 5p-² 5p⁴",
             c"[Ne]"[end:end] => "2p⁶ᶜ",
             sort(rc"[Ne]"[end-1:end]) => "2p-²ᶜ 2p⁴ᶜ",
             c"5s2" => "5s²",
             rc"[Kr]*"s => "1s² 2s² 2p-² 2p⁴ 3s² 3p-² 3p⁴ 3d-⁴ 3d⁶ 4s² 4p-² 4p⁴",
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

        @test replace(c"1s2 2s", o"1s"=>o"2p") == c"1s 2p 2s"
        @test replace(c"1s2 2s", o"1s"=>o"2p", append=true) == c"1s 2s 2p"
        @test replace(c"1s2 2s"s, o"1s"=>o"2p") == c"1s 2s 2p"
    end

    @testset "Orbital removal" begin
        @test c"1s2" - o"1s" == c"1s"
        @test c"1s" - o"1s" == c""
        @test c"1s 2s" - o"1s" == c"2s"
        @test c"[Ne]" - o"2s" == c"[He] 2s 2p6c"
        @test -(c"1s2 2s", o"1s", 2) == c"2s"

        @test delete!(c"1s 2s", o"1s") == c"2s"
        @test delete!(c"1s2 2s", o"1s") == c"2s"
        @test delete!(c"[Ne]", o"2p") == c"1s2c 2s2c"
        @test delete!(rc"[Ne]", ro"2p-") == rc"1s2c 2s2c 2p4c"
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

    @testset "Spin-orbitals" begin
        up, down = half(1),-half(1)

        @test_throws ArgumentError Configuration(spin_orbitals(o"1s"), [2,1])
        @test_throws ArgumentError Configuration(spin_orbitals(o"1s"), [1,2])

        @test spin_configurations(c"1s2") ==
            [Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"1s",0,down)], [1, 1])]
        @test spin_configurations(c"1s2") isa Vector{Configuration{SpinOrbital{Orbital{Int},Tuple{Int,HalfInt}}}}
        @test spin_configurations(c"ks2") isa Vector{Configuration{SpinOrbital{Orbital{Symbol},Tuple{Int,HalfInt}}}}
        @test spin_configurations(c"1s ks") isa Vector{Configuration{SpinOrbital{<:Orbital,Tuple{Int,HalfInt}}}}

        @test scs"1s 2p" == spin_configurations(c"1s 2p") ==
            [Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"2p",-1,up)], [1, 1]),
             Configuration([SpinOrbital(o"1s",0,down), SpinOrbital(o"2p",-1,up)], [1, 1]),
             Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"2p",-1,down)], [1, 1]),
             Configuration([SpinOrbital(o"1s",0,down), SpinOrbital(o"2p",-1,down)], [1, 1]),
             Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"2p",0,up)], [1, 1]),
             Configuration([SpinOrbital(o"1s",0,down), SpinOrbital(o"2p",0,up)], [1, 1]),
             Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"2p",0,down)], [1, 1]),
             Configuration([SpinOrbital(o"1s",0,down), SpinOrbital(o"2p",0,down)], [1, 1]),
             Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"2p",1,up)], [1, 1]),
             Configuration([SpinOrbital(o"1s",0,down), SpinOrbital(o"2p",1,up)], [1, 1]),
             Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"2p",1,down)], [1, 1]),
             Configuration([SpinOrbital(o"1s",0,down), SpinOrbital(o"2p",1,down)], [1, 1])]

        @testset "Excited spin configurations" begin
            function excited_spin_configurations(cfg, orbitals)
                ec = excited_configurations(cfg, orbitals...,
                                            max_excitations=:singles, keep_parity=false)
                spin_configurations(ec)
            end

            a = excited_spin_configurations(c"1s2", os"2[s-p]")
            @test a isa Vector{Configuration{SpinOrbital{Orbital{Int},Tuple{Int,HalfInt}}}}
            b = excited_spin_configurations(c"1s2", os"k[s-p]")
            @test b isa Vector{<:Configuration{<:SpinOrbital{<:Orbital,Tuple{Int,HalfInt}}}}
            c = excited_spin_configurations(c"ks2", os"l[s-p]")
            @test c isa Vector{Configuration{SpinOrbital{Orbital{Symbol},Tuple{Int,HalfInt}}}}

            for (u,v) in [(a,b), (a,c), (b,c)]
                @test vcat(u,v) isa Vector{<:Configuration{<:SpinOrbital{<:Orbital,Tuple{Int,HalfInt}}}}
            end

            @test b ==
                [Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"1s",0,down)], [1, 1]),

                 Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"ks",0,up)], [1, 1]),
                 Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"ks",0,down)], [1, 1]),
                 Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"kp",-1,up)], [1, 1]),
                 Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"kp",-1,down)], [1, 1]),
                 Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"kp",0,up)], [1, 1]),
                 Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"kp",0,down)], [1, 1]),
                 Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"kp",1,up)], [1, 1]),
                 Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"kp",1,down)], [1, 1]),

                 Configuration([SpinOrbital(o"1s",0,down), SpinOrbital(o"ks",0,up)], [1, 1]),
                 Configuration([SpinOrbital(o"1s",0,down), SpinOrbital(o"ks",0,down)], [1, 1]),
                 Configuration([SpinOrbital(o"1s",0,down), SpinOrbital(o"kp",-1,up)], [1, 1]),
                 Configuration([SpinOrbital(o"1s",0,down), SpinOrbital(o"kp",-1,down)], [1, 1]),
                 Configuration([SpinOrbital(o"1s",0,down), SpinOrbital(o"kp",0,up)], [1, 1]),
                 Configuration([SpinOrbital(o"1s",0,down), SpinOrbital(o"kp",0,down)], [1, 1]),
                 Configuration([SpinOrbital(o"1s",0,down), SpinOrbital(o"kp",1,up)], [1, 1]),
                 Configuration([SpinOrbital(o"1s",0,down), SpinOrbital(o"kp",1,down)], [1, 1])]

            d=excited_spin_configurations(rc"1s2", ros"2[s-p]")
            @test d isa Vector{Configuration{SpinOrbital{RelativisticOrbital{Int},Tuple{HalfInt}}}}
            e=excited_spin_configurations(rc"1s2", ros"k[s-p]")
            @test e isa Vector{<:Configuration{<:SpinOrbital{<:RelativisticOrbital,Tuple{HalfInt}}}}
            f=excited_spin_configurations(rc"ks2", ros"l[s-p]")
            @test f isa Vector{Configuration{SpinOrbital{RelativisticOrbital{Symbol},Tuple{HalfInt}}}}

            for (u,v) in [(d,e), (d,f), (e,f)]
                @test vcat(u,v) isa Vector{<:Configuration{<:SpinOrbital{<:RelativisticOrbital,Tuple{HalfInt}}}}
            end

            for (u,v) in Iterators.product([a,b,c], [d,e,f])
                @test vcat(u,v) isa Vector{<:Configuration{<:SpinOrbital}}
            end
        end

        @test bound(Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"ks",0,up)], [1, 1])) ==
            Configuration([SpinOrbital(o"1s",0,up),], [1,])

        @test continuum(Configuration([SpinOrbital(o"1s",0,up), SpinOrbital(o"ks",0,up)], [1, 1])) ==
            Configuration([SpinOrbital(o"ks",0,up),], [1,])

        @test all([o ∈ spin_configurations(c"1s2")[1]
                   for o in spin_orbitals(o"1s")])

        @test map(spin_configurations(c"[Kr] 5s2 5p6")[1]) do (orb,occ,state)
            orb.orb.n < 5 && state == :closed || orb.orb.n == 5 && state == :open
        end |> all

        @test_broken string.(spin_configurations(c"2s2 2p"s)) ==
            ["2s² 2p₋₁α",
             "2s² 2p₋₁β",
             "2s² 2p₀α",
             "2s² 2p₀β",
             "2s² 2p₁α",
             "2s² 2p₁β"]

        @test_broken string.(spin_configurations(c"[Kr] 5s2 5p5 ks"s)) ==
            ["[Kr]ᶜ 5s² 5p₋₁² 5p₀² 5p₁α ks₀α",
             "[Kr]ᶜ 5s² 5p₋₁² 5p₀² 5p₁β ks₀α",
             "[Kr]ᶜ 5s² 5p₋₁² 5p₀α 5p₁² ks₀α",
             "[Kr]ᶜ 5s² 5p₋₁² 5p₀β 5p₁² ks₀α",
             "[Kr]ᶜ 5s² 5p₋₁α 5p₀² 5p₁² ks₀α",
             "[Kr]ᶜ 5s² 5p₋₁β 5p₀² 5p₁² ks₀α",
             "[Kr]ᶜ 5s² 5p₋₁² 5p₀² 5p₁α ks₀β",
             "[Kr]ᶜ 5s² 5p₋₁² 5p₀² 5p₁β ks₀β",
             "[Kr]ᶜ 5s² 5p₋₁² 5p₀α 5p₁² ks₀β",
             "[Kr]ᶜ 5s² 5p₋₁² 5p₀β 5p₁² ks₀β",
             "[Kr]ᶜ 5s² 5p₋₁α 5p₀² 5p₁² ks₀β",
             "[Kr]ᶜ 5s² 5p₋₁β 5p₀² 5p₁² ks₀β"]

        @test_broken string.(spin_configurations(c"[Kr] 5s2 5p4"s)) ==
            ["[Kr]ᶜ 5s² 5p₋₁² 5p₀²",
             "[Kr]ᶜ 5s² 5p₋₁² 5p₀α 5p₁α",
             "[Kr]ᶜ 5s² 5p₋₁² 5p₀α 5p₁β",
             "[Kr]ᶜ 5s² 5p₋₁² 5p₀β 5p₁α",
             "[Kr]ᶜ 5s² 5p₋₁² 5p₀β 5p₁β",
             "[Kr]ᶜ 5s² 5p₋₁² 5p₁²",
             "[Kr]ᶜ 5s² 5p₋₁α 5p₀² 5p₁α",
             "[Kr]ᶜ 5s² 5p₋₁α 5p₀² 5p₁β",
             "[Kr]ᶜ 5s² 5p₋₁α 5p₀α 5p₁²",
             "[Kr]ᶜ 5s² 5p₋₁α 5p₀β 5p₁²",
             "[Kr]ᶜ 5s² 5p₋₁β 5p₀² 5p₁α",
             "[Kr]ᶜ 5s² 5p₋₁β 5p₀² 5p₁β",
             "[Kr]ᶜ 5s² 5p₋₁β 5p₀α 5p₁²",
             "[Kr]ᶜ 5s² 5p₋₁β 5p₀β 5p₁²",
             "[Kr]ᶜ 5s² 5p₀² 5p₁²"]

        @test substitutions(spin_configurations(c"1s2")[1],
                            spin_configurations(c"1s2")[1]) == []

        @test substitutions(spin_configurations(c"1s2")[1],
                            spin_configurations(c"1s ks")[2]) ==
                                [SpinOrbital(o"1s",0,up)=>SpinOrbital(o"ks",0,up)]
    end

    @testset "Configuration transformations" begin
        @testset "Relativistic -> non-relativistic" begin
            @test nonrelconfiguration(rc"1s2 2p-2 2s 2p2 3s2 3p-"s) == c"1s2 2s 2p4 3s2 3p"s
            @test nonrelconfiguration(rc"1s2 ks2"s) == c"1s2 ks2"s
            @test nonrelconfiguration(rc"kp-2 kp4 lp-2 lp"s) == c"kp6 lp3"s
        end
        @testset "Non-relativistic -> relativistic" begin
            @test relconfigurations(c"[He] 2p") == [rc"[He] 2p-", rc"[He] 2p"]
            @test relconfigurations(c"[Ne]"s) == [rc"[Ne]"s]
        end
    end

    @testset "Internal utilities" begin
        @test AtomicLevels.get_noble_core_name(c"1s2 2s2 2p6") === nothing
        @test AtomicLevels.get_noble_core_name(c"1s2c 2s2 2p6") === "He"
        @test AtomicLevels.get_noble_core_name(c"1s2c 2s2c 2p6c") === "Ne"
        @test AtomicLevels.get_noble_core_name(c"[He] 2s2 2p6c 3s2c 3p6c") === "He"
        for gas in ["Rn", "Xe", "Kr", "Ar", "Ne", "He"]
            c = parse(Configuration{Orbital}, "[$gas]")
            @test AtomicLevels.get_noble_core_name(c) === gas
            rc = parse(Configuration{RelativisticOrbital}, "[$gas]")
            @test AtomicLevels.get_noble_core_name(rc) === gas
        end
    end

    @testset "Unsorted configurations" begin
        @testset "Comparisons" begin
            # These configurations should be similar but not equal
            @test issimilar(c"1s 2s", c"1s 2si")
            @test issimilar(c"1s 2s", c"2s 1s")
            @test issimilar(c"1s 2s", c"2si 1s")

            @test c"1s 2s" != c"1s 2si"
            @test c"1s 2s" != c"2s 1s"
            @test c"1s 2s" == c"2s 1s"s
            @test c"1s 2s" != c"2si 1s"

            @test rc"1s 2s" != rc"1s 2si"
            @test rc"1s 2s" != rc"2s 1s"
            @test rc"1s 2s" == rc"2s 1s"s
            @test rc"1s 2s" != rc"2si 1s"
        end
        @testset "Substitutions" begin
            @testset "Spatial orbitals" begin
                # Sorted case
                a = Configuration([o"1s", o"2s"], [1,1], [:open, :open], sorted=true)
                @test replace(a, o"1s" => o"2p").orbitals == [o"2s", o"2p"]

                b = Configuration([o"1s", o"2s"], [1,1], [:open, :open], sorted=false)
                c = replace(b, o"1s" => o"2p")
                @test c.orbitals == [o"2p", o"2s"]
                @test "$c" == "2p 2s"

                d = c"[He]" + Configuration([o"2p"], [1], [:open], sorted=false) + c"2s"
                @test core(d) == c"[He]"
                @test peel(d) == c
            end

            @testset "Spin orbitals" begin
                orbs = [spin_orbitals(o) for o in [o"1s", o"2s"]]

                a = spin_configurations(Configuration(o"1s", 2, :open, sorted=true))[1]
                @test replace(a, orbs[1][1]=>orbs[2][1]).orbitals == [orbs[1][2], orbs[2][1]]

                b = spin_configurations(Configuration(o"1s", 2, :open, sorted=false))[1]
                c = replace(b, orbs[1][1]=>orbs[2][1])
                @test c.orbitals == [orbs[2][1], orbs[1][2]]
                @test "$c" == "2s₀α 1s₀β"
            end
        end
    end

    @testset "String representation" begin
        @test string(c"[Ar]c 3d10c 4s2c 4p6 4d10 5s2i 5p6") == "[Ar]ᶜ 3d¹⁰ᶜ 4s²ᶜ 4p⁶ 4d¹⁰ 5s²ⁱ 5p⁶"
        @test ascii(c"[Ar]c 3d10c 4s2c 4p6 4d10 5s2i 5p6") == "[Ar]c 3d10c 4s2c 4p6 4d10 5s2i 5p6"
        @test string(rc"[Ar]*") == "1s² 2s² 2p⁴ 2p-² 3s² 3p⁴ 3p-²"
        @test ascii(rc"[Ar]*") == "1s2 2s2 2p4 2p-2 3s2 3p4 3p-2"
    end
end
