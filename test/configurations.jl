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

@test_throws ArgumentError AtomicLevels.configuration_from_string("1sc")
@test_throws ArgumentError AtomicLevels.configuration_from_string("1s 1s")
@test_throws ArgumentError AtomicLevels.configuration_from_string("[He]c 1s")

@test core(c"[Kr]c 5s2") == c"[Kr]c"
@test peel(c"[Kr]c 5s2") == c"5s2"
@test active(c"[Kr]c 5s2") == c"5s2"
@test inactive(c"[Kr]c 5s2i") == c"5s2i"
@test inactive(c"[Kr]c 5s2") == c""

# * Parity

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

# * Test pretty printing

Xe⁺ = c"[Kr]c 5s2 5p-2 5p3"
map([c"1s" => "1s",
     c"1s2" => "1s²",
     c"1s2 2s2" => "1s² 2s²",
     c"1s2 2s2 2p" => "1s² 2s² 2p",
     c"1s2c 2s2 2p" => "[He]ᶜ 2s² 2p",
     c"[He] 2s2" => "1s² 2s²",
     c"[He]c 2s2" => "[He]ᶜ 2s²",
     c"[He]i 2s2" => "1s²ⁱ 2s²",
     c"[Kr]c 5s2" => "[Kr]ᶜ 5s²",
     Xe⁺ => "[Kr]ᶜ 5s² 5p⁻² 5p³",
     core(Xe⁺) => "[Kr]ᶜ",
     peel(Xe⁺) => "5s² 5p⁻² 5p³",
     c"5s2" => "5s²",
     c"[Kr]" => "1s² 2s² 2p⁻² 2p⁴ 3s² 3p⁻² 3p⁴ 3d⁻⁴ 3d⁶ 4s² 4p⁻² 4p⁴",
     c"[Kr]c" =>"[Kr]ᶜ"]) do (c,s)
         @test "$(c)" == s
     end
