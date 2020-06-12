@testset "JJ terms" begin
    @testset "_terms_jw" begin
        function terms_reference(j::HalfInteger, w::Integer)
            w <= 2j+1 || throw(ArgumentError("w=$w too large for $orb orbital"))

            2w ≥ 2j+1 && (w = convert(Int, 2j) + 1 - w)
            w == 0 && return [zero(HalfInt)]
            w == 1 && return [j]

            # Forms full Cartesian product of all mⱼ, not necessarily the most
            # performant method.
            mⱼs = filter(allunique, collect(AtomicLevels.allchoices([-j:j for i = 1:w])))
            MJs = map(x -> reduce(+, x), mⱼs) # TODO: make map(sum, mⱼs) work

            Js = HalfInt[]

            while !isempty(MJs)
                # Identify the maximum MJ and associate it with J.
                MJmax = maximum(MJs)
                N = count(isequal(MJmax), MJs)
                append!(Js, repeat([MJmax], N))
                # Remove the -MJ:MJ series, N times.
                for MJ = -MJmax:MJmax
                    deleteat!(MJs, findall(isequal(MJ), MJs)[1:N])
                end
            end

            # Do we really want unique here?
            sort(unique(Js))
        end

        for twoj = 0:10, w = 1:twoj+1
            j = HalfInteger(twoj//2)
            ts = AtomicLevels._terms_jw(j, w)

            @test issorted(ts, rev=true) # make sure that the array is sorted in descending order
            @test terms_reference(j, w) == sort(unique(ts))
            # Check particle-hole symmetry
            if w != twoj + 1
                @test AtomicLevels._terms_jw(j, twoj+1-w) == ts
            end
        end
    end

    @testset "jj coupling of equivalent electrons" begin
        @test terms(ro"1s", 0) == [0]
        @test terms(ro"1s", 1) == [1//2]
        @test terms(ro"1s", 2) == [0]

        @test terms(ro"3d-", 0) == [0]
        @test terms(ro"3d-", 1) == [3//2]
        @test terms(ro"3d-", 4) == [0]

        @test terms(ro"Xd", 0) == [0]
        @test terms(ro"Xd", 1) == [5//2]
        @test terms(ro"Xd", 6) == [0]

        # Table 4.5, Cowan 1981
        foreach([
            (ro"1s",ro"2p-") => [(0,2) => 0, 1 => 1//2],
            (ro"2p",ro"3d-") => [(0,4) => 0, (1,3) => 3//2, 2 => [0,2]],
            (ro"3d",ro"4f-") => [(0,6) => 0, (1,5) => 5//2, (2,4) => [0,2,4],
                                 3 => [3//2,5//2,9//2]],
            (ro"4f",ro"5g-") => [(0,8) => 0, (1,7) => 7//2, (2,6) => [0,2,4,6],
                                 (3,5) => [3//2,5//2,7//2,9//2,11/2,15//2],
                                 4 => [0,2,2,4,4,5,6,8]],
            (ro"5g",ro"6h-") => [(0,10) => 0, (1,9) => 9//2, (2,8) => [0,2,4,6,8],
                                 (3,7) => [3//2,5//2,7//2,9//2,9//2,11//2,13//2,15//2,17//2,21//2],
                                 (4,6) => [0,0,2,2,3,4,4,4,5,6,6,6,7,8,8,9,10,12],
                                 5 => [1//2,3//2,5//2,5//2,7//2,7//2,9//2,9//2,9//2,11//2,11//2,13//2,13//2,15//2,15//2,17//2,17//2,19//2,21//2,25//2]]
        ]) do (orbs,wsj)
            foreach(orbs) do orb
                foreach(wsj) do (ws,j)
                    js = map(HalfInteger, isa(j, Number) ? [j] : j)
                    foreach(ws) do w
                        @test terms(orb,w) == js
                    end
                end
            end
        end
    end
end
