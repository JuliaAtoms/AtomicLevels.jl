using AtomicLevels
using UnicodeFun
using Combinatorics: combinations
using WignerSymbols
using Test

@testset "Terms" begin
    @testset "Construction" begin
        @test T"1S" == Term(0, 0, p"even")
        @test T"1S" == Term(0, 0, 1)
        @test T"1Se" == Term(0, 0, p"even")
        @test T"1So" == Term(0, 0, p"odd")
        @test T"1So" == Term(0, 0, -1)
        @test T"2So" == Term(0, 1//2, p"odd")
        @test T"4P" == Term(1, 3//2, p"even")
        @test T"3D" == Term(2, 1, p"even")
        @test T"3Do" == Term(2, 1, p"odd")
        @test T"1[54]" == Term(54, 0, p"even")
        @test T"1[3/2]" == Term(3//2, 0, p"even")
        @test T"2[3/2]o" == Term(3//2, 1//2, p"odd")
        @test T"2Z" == Term(20, 1//2, p"even")

        @test_throws DomainError Term(HalfInteger(-1,2), HalfInteger(1,2), p"even")
        @test_throws DomainError Term(3//2, -1//2, p"odd")
        @test_throws DomainError Term(-2, 1//2, 1)

        @test_throws ArgumentError parse(Term, "1[4/3]")
        @test_throws ArgumentError parse(Term, "1[43/]")
        @test_throws ArgumentError parse(Term, "1[/43/]")
        @test_throws ArgumentError parse(Term, "1[/43]")
        @test_throws ArgumentError parse(Term, "P")
        @test_throws ArgumentError parse(Term, "asdf")
    end

    @testset "Properties" begin
        @test multiplicity(T"1S") == 1
        @test multiplicity(T"1So") == 1
        @test multiplicity(T"2S") == 2
        @test multiplicity(T"2So") == 2
        @test multiplicity(T"3S") == 3
        @test multiplicity(T"3So") == 3

        @test weight(T"1S") == 1
        @test weight(T"1P") == 3
        @test weight(T"2S") == 2
        @test weight(T"2P") == 6

        @test T"1S" > T"1So"
        @test T"1So" < T"1S"
        @test T"1S" < T"2S"
        @test T"1S" < T"1P"
        @test T"1S" < T"3S"
        @test T"1P" < T"3S"
    end

    @testset "Pretty printing" begin
        map([T"1S" => "¹S",
             T"2So" => "²Sᵒ",
             T"4[3/2]" => "⁴[3/2]"]) do (t,s)
            @test "$(t)" == s
        end
    end

    @testset "Orbital terms" begin
        function test_single_orbital_terms(orb::Orbital, occ::Int, ts::Vector{Term})
            cts = sort(terms(orb, occ))
            ts = sort(ts)
            ccts = copy(cts)
            for t in cts
                if t in ts
                    @test count(e -> e == t, ccts) == count(e -> e == t, ts)
                    ccts = filter!(e -> e != t, ccts)
                    ts = filter!(e -> e != t, ts)
                end
            end
            if length(ts) != 0
                println("fail, terms: ", join(string.(cts), ", "))
                println("missing: ", join(string.(ts), ", "))
                println("should not be there: ", join(string.(ccts), ", "))
                println("==========================================================")
            end
            @test length(ts) == 0
        end

        function test_single_orbital_terms(orb::Orbital, occs::Tuple{Int,Int}, ts::Vector{Term})
            map(occs) do occ
                test_single_orbital_terms(orb, occ, ts)
            end
        end

        function get_orbital(o::AbstractString)
            n = something(findfirst(isequal(o[1]), AtomicLevels.spectroscopic), 0)
            ℓ = n - 1
            orb = Orbital(n, ℓ)
            g = 2(2ℓ + 1)
            occ = length(o)>1 ? parse(Int, o[2:end]) : 1
            if g != occ && g/2 != occ
                occ = (occ, g-occ)
            end
            orb, occ
        end

        function test_orbital_terms(o_ts::Pair{<:ST,<:ST}) where {ST<:AbstractString}
            orb,occ = get_orbital(o_ts[1])
            m = match(r"([0-9]+)([A-Z])", o_ts[2])
            L = something(findfirst(isequal(lowercase(m[2])[1]), AtomicLevels.spectroscopic), 0)-1
            S = (parse(Int, m[1])-1)//2
            test_single_orbital_terms(orb, occ, [Term(L, S, parity(orb)^occ[1])])
        end

        function test_orbital_terms(o_ts::Pair{<:ST,<:Vector{ST}}) where {ST<:AbstractString}
            orb,occ = get_orbital(o_ts[1])

            p = parity(orb)^occ[1]
            ts = o_ts[2]

            p1 = r"([0-9]+)\(((?:[A-Z][0-9]*)+)\)"
            p2 = r"([0-9]+)([A-Z])"
            toL = s -> something(findfirst(isequal(lowercase(s)[1]), AtomicLevels.spectroscopic), 0) - 1
            ts = map(ts) do t
                m = match(p1, t)
                if m != nothing
                    S = (parse(Int, m[1]) - 1)//2
                    map(eachmatch(r"([A-Z])([0-9]*)", m[2])) do mmm
                        mm = mmm.match
                        [Term(toL(mm[1]),S,p)
                         for j in 1:(length(mm)>1 ? parse(Int, mm[2:end]) : 1)]
                    end
                else
                    m = match(p2, t)
                    S = (parse(Int, m[1]) - 1)//2
                    Term(toL(m[2]), S, p)
                end
            end
            test_single_orbital_terms(orb, occ, vcat(vcat(ts...)...))
        end

        # Table taken from Cowan, p. 110
        # Numbers following term symbols indicate the amount of times
        # different terms with the same (L,S) occur.
        test_orbital_terms("s" => "2S")
        for o in ["s2", "p6", "d10", "f14"]
            test_orbital_terms(o => "1S")
        end
        test_orbital_terms("p" => "2P")
        test_orbital_terms("p2" => ["1(SD)", "3P"])
        test_orbital_terms("p3" => ["2(PD)", "4S"])
        test_orbital_terms("d" => "2D")
        test_orbital_terms("d2" => ["1(SDG)", "3(PF)"])
        test_orbital_terms("d3" => ["2(PD2FGH)", "4(PF)"])
        test_orbital_terms("d4" => ["1(S2D2FG2I)", "3(P2DF2GH)", "5D"])
        test_orbital_terms("d5" => ["2(SPD3F2G2HI)", "4(PDFG)", "6S"])
        test_orbital_terms("f" => "2F")
        test_orbital_terms("f2" => ["1(SDGI)", "3(PFH)"])
        test_orbital_terms("f3" => ["2(PD2F2G2H2IKL)", "4(SDFGI)"])
        test_orbital_terms("f4" => ["1(S2D4FG4H2I3KL2N)", "3(P3D2F4G3H4I2K2LM)", "5(SDFGI)"])
        test_orbital_terms("f5" => ["2(P4D5F7G6H7I5K5L3M2NO)", "4(SP2D3F4G4H3I3K2LM)", "6(PFH)"])
        test_orbital_terms("f6" => ["1(S4PD6F4G8H4I7K3L4M2N2Q)", "3(P6D5F9G7H9I6K6L3M3NO)", "5(SPD3F2G3H2I2KL)", "7F"])
        test_orbital_terms("f7" => ["2(S2P5D7F10G10H9I9K7L5M4N2OQ)", "4(S2P2D6F5G7H5I5K3L3MN)", "6(PDFGHI)", "8S"])
        # # Data below are from Xu2006
        # test_orbital_terms("g9" => [2(S8 P19 D35 F40 G52 H54 I56 K53 L53 M44 N40 O32 Q26 R19 T15 U9 V7 W4 X2 YZ) 4(S6 P16 D24 F34 G38 H40 I42 K39 L35 M32 N26 O20 Q16 R11 T7 U5 V3 WX) 6(S3P3D9F8G12H10I12K9L9M6N6O3Q3RT) 8(PDFGHIKL) 10(S)])
        # test_orbital_terms("h11" => [2(S36 P107 D173 F233 G283 H325 I353 K370 L376 M371 N357 O335 Q307 R275 T241 U207 V173 W142 X114 Y88 Z68 2150 2236 2325 2417 2511 267 274 282 29 30) 4 (S37 P89 D157 F199 G253 H277 I309 K313 L323 M308 N300 O271 Q251 R216 T190 U155 V131 W101 X81 Y59 Z45 2130 2222 2313 249 255 263 27 28) 6 (S12 P35 D55 F76 G90 H101 I109 K111 L109 M105 N97 O87 Q77 R65 T53 U43 V33 W24 X18 Y12 Z8 215 223 2324) 8(S4 P4 D12 F11 G17 H15 I19 K16 L18 M14 N14 O10 Q10 R6 T6 U3 V3WX) 10(PDFGHIKLMN) 12S])

        @test_throws ArgumentError terms(o"2p", 7)

        @testset "Reference implementation" begin
            # This is an independent implementation that calculates all the terms (L, S) terms
            # of a given ℓ^w orbital is LS coupling. It works by considering the distribution
            # of the M_L and M_S quantum numbers of the many-particle basis states of the ℓ^w
            # orbital. It is much less performant than the implementation of terms() in AtomicLevels.
            function ls_terms_reference(ℓ::Integer, w::Integer, parity::Parity)
                ℓ >= 0 || throw(DomainError("ℓ must be non-negative"))
                w >= 1 || throw(DomainError("w must be positive"))
                # First, let's build a histogram of (M_L, M_S) values of all the product
                # basis states.
                lsbasis = [(ml, ms) for ms = HalfInteger(-1,2):HalfInteger(1,2), ml = -ℓ:ℓ]
                @assert length(lsbasis) == 2*(2ℓ+1)
                Lmax, Smax = w * ℓ, w * HalfInteger(1,2)
                NL, NS = convert(Int, 2*Lmax + 1), convert(Int, 2*Smax + 1)
                hist =  zeros(Int, NL, NS)
                for c in combinations(1:length(lsbasis), w)
                    ML, MS = 0, 0
                    for i in c
                        ML += lsbasis[i][1]
                        MS += lsbasis[i][2]
                    end
                    i = convert(Int, ML + Lmax) + 1
                    j = convert(Int, MS + Smax) + 1
                    hist[i, j] += 1
                end
                # Find the valid (L, S) terms by removing maximal rectangular bases from the
                # 2D histogram. The width and breadth of the rectangles determines the (L,S)
                # term that generates the corresponding (M_L, M_S) values.
                terms = Term[]
                Lmid, Smid = div(NL, 2) + (isodd(NL) ? 1 : 0), div(NS, 2) + (isodd(NS) ? 1 : 0)
                for i = 1:Lmid
                    while !all(hist[i,:] .== 0)
                        is = i:(NL-i+1)
                        for j = 1:Smid
                            js = j:(NS-j+1)
                            any(hist[is, js] .== 0) && continue
                            L = convert(HalfInteger, Lmax - i + 1)
                            S = convert(HalfInteger, Smax - j + 1)
                            push!(terms, Term(L, S, parity))
                            hist[is, js] .-= 1
                            break
                        end
                    end
                    @assert all(hist[NL-i+1, :] .== 0) # make sure everything is symmetric
                end
                return terms
            end

            # We can't go too high in ℓ, since ls_terms_reference becomes quite slow.
            for ℓ = 0:5, w = 1:(4ℓ+2)
                o = Orbital(:X, ℓ)
                p = parity(o)^w
                reference_terms = ls_terms_reference(ℓ, w, p)
                @test sort(terms(o, w)) == sort(reference_terms)
            end
        end
    end

    @testset "Count terms" begin
        @test count_terms(o"1s", 1, T"2S") == 1
        @test count_terms(o"1s", 2, T"1S") == 1
        @test count_terms(o"3d", 1, T"2D") == 1
        @test count_terms(o"3d", 3, T"2D") == 2
        @test count_terms(o"3d", 5, T"2D") == 3
    end

    @testset "Intermediate terms" begin
        @test_throws ArgumentError IntermediateTerm(T"2S", 2)

        @test string(IntermediateTerm(T"2D", 3)) == "₃²D"

        @testset "Seniority" begin
            # Table taken from p. 25 of
            #
            # - Froese Fischer, C., Brage, T., & Jönsson, P. (1997). Computational
            #   Atomic Structure : An MCHF Approach. Bristol, UK Philadelphia, Penn:
            #   Institute of Physics Publ.
            subshell_terms = [
                o"1s" => (1 => "2S1",
                         2 => "1S0"),
                o"2p" => (1 => "2P1",
                         2 => ("1S0", "1D2", "3P2"),
                         3 => ("2P1", "2D3", "4S3")),
                o"3d" => (1 => "2D1",
                         2 => ("1S0", "1D2", "1G2", "3P2", "3F2"),
                         3 => ("2D1", "2P3", "2D3", "2F3", "2G3", "2H3", "4P3", "4F3"),
                         4 => ("1S0", "1D2", "1G2", "3P2", "3F2", "1S4", "1D4", "1F4", "1G4", "1I4", "3P4", "3D4", "3F4", "3G4", "3H4", "5D4"),
                         5 => ("2D1", "2P3", "2D3", "2F3", "2G3", "2H3", "4P3", "4F3", "2S5", "2D5", "2F5", "2G5", "2I5", "4D5", "4G5", "6S5")),
                o"4f" => (1 => "2F1",
                         2 => ("1S0", "1D2", "1G2", "1I2", "3P2", "3F2", "3H2"))
            ]

            foreach(subshell_terms) do (orb, data)
                foreach(data) do (occ, expected_its)
                    p = parity(orb)^occ
                    expected_its = map(expected_its isa String ? (expected_its,) : expected_its) do ei
                        t_str = "$(ei[1:2])$(isodd(p) ? "o" : "")"
                        IntermediateTerm(parse(Term, t_str), parse(Int, ei[end]))
                    end
                    its = intermediate_terms(orb, occ)
                    @test its == [expected_its...]
                end
            end
        end
    end
end
