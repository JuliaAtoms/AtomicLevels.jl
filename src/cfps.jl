# Eqs. (2) & (3) of Jahn (1951)
jahnU(::Type{T}, j₁, j₂, J, j₃, J₁₂, J₂₃) where T=
    racahW(T, j₁, j₂, J, j₃, J₁₂, J₂₃)*sqrt((2J₁₂+1)*(2J₂₃+1))

# Eq. (10) of Bayman & Lande (1966)
function SU2jp1Casimir(j::HalfInt, N::Integer)
    a = twice(j) + 1
    (a+1)/a*N*(a - N)
end

# Eq. (12) of Bayman & Lande (1966)
Sp2jp1Casimir(j::HalfInteger, v::Integer) =
    half(1)*v*(twice(j) + 3 - v)

powneg1(i::Int) = iseven(i) ? 1 : -1

function bayman_lande(::Type{T}, j::HalfInt; verbosity=2) where T
    verbosity > 0 &&
        @info "Bayman–Lande algorithm for jj cfps, j = $(j)"

    StateLabel = @NamedTuple{j::HalfInt, v::Int, α::Int, J::HalfInt}

    Nmax = twice(j)+1
    states = Vector{Vector{StateLabel}}()
    push!(states, [(j=j, v=1, α=1, J=j)])
    cfps = Vector{Matrix{T}}()
    # First case is trivial, there is only one way to create the
    # configuration j¹ from j⁰.
    push!(cfps, ones(T, 1, 1))

    let Js = terms(j, 2)
        push!(cfps, ones(T, length(Js), 1))
        push!(states, [(j=j, v=J == 0 ? 0 : 2, α=1, J=J)
                       for J in Js])
    end

    verbosity > 2 && @info "CFPs so far" cfps states

    for N = 3:Nmax
        Js = terms(j, N)

        new_states = StateLabel[]

        prevg = size(cfps[N-1], 1)
        newg = length(Js)
        push!(cfps, zeros(T, newg, prevg))
        if prevg == 1
            cfps[N] .= true
        end

        # We diagonalize the Casimir operator separately for each J.
        Jmap = [J => findall(==(J), Js)
                for J in unique(Js)]

        for (J,Jindices) in Jmap
            GSU = zeros(T, prevg, prevg)
            GSp = zeros(T, prevg, prevg)

            for (x,state) in enumerate(states[N-1])
                GSU[x,x] = SU2jp1Casimir(j, N-1) + (4*j*(j+1)-2*(N-1))/(2j+1)
                GSp[x,x] = Sp2jp1Casimir(j, state.v) + j + 1
            end

            for (x,sx) in enumerate(states[N-1])
                J₁ = sx.J
                for (y,sy) in enumerate(states[N-1])
                    J₂ = sy.J

                    # Last term of Eq. (13b)
                    Spfac = -powneg1(Int(J₁-J₂))*(N-1)*√((twice(J₁)+1)*(twice(J₂)+1))/(twice(J)+1)

                    for (z,sz) in enumerate(states[N-2])
                        Λ = sz.J

                        cfgp_prod = cfps[N-1][x,z]*cfps[N-1][y,z]
                        U = jahnU(T, Λ, j, j, J, J₁, J₂)
                        # @show (Λ, j, j, J, J₁, J₂) U
                        f = (N-1)*powneg1(Int(J₁+J₂-Λ-J))*cfgp_prod*U

                        # Second term of Eq. (13a)
                        GSU[x,y] += 2f

                        # Second term of Eq. (13b)
                        GSp[x,y] += f

                        if sz.J == J
                            # Last term of Eq. (13b)
                            GSp[x,y] += Spfac*cfgp_prod
                        end
                    end
                end
            end

            # The factor 0.11 is suggested by Bayman & Lande (1966)
            A = hermitianpart(GSU + 0.11GSp)
            ee = eigen(A)
            Q = ee.vectors
            # We try to get consistent phases by giving the CFP
            # component with largest magnitude positive sign. This is
            # not necessarily in agreement with the signs of Bayman &
            # Lande (1966).
            for i in axes(Q, 2)
                qᵢ = view(Q, :, i)
                qᵢmax = argmax(abs, qᵢ)
                qᵢ .*= sign(qᵢmax)
            end

            # We know from Eq. (10) of Bayman & Lande (1966) what the
            # analytic eigenvalue of the SU(2j+1) Casimir operator for
            # the fully antisymmetric irrep labelled by [1^N] should
            # be. We find all numeric eigenvalues matching this value.
            SUeigs = diag(Q'GSU*Q)
            SU_analytic = SU2jp1Casimir(j, N)
            # We remember that comparing approximately with an
            # expected zero can only be done on an absolute scale.
            SUsel = findall(≈(SU_analytic, atol = iszero(SU_analytic) ? √(eps(T)) : zero(T)), SUeigs)

            # We round the corresponding eigenvalues of the Sp(2j+1)
            # Casimir operator to half-integers.
            Speigs = half.(round.(Int, 2diag(Q'GSp*Q)))
            # Again, we know from Eq. (12) of Bayman & Lande (1966)
            # what the analytic eigenvalues of the Sp(2j+1) Casimir
            # operator should be, for the various candidates for the
            # seniority quantum number v.
            Sp_analytic = Sp2jp1Casimir.(j,0:N)
            v_cands = Vector{Pair{Int,Int}}()
            for i in SUsel
                ii = findfirst(==(Speigs[i]), Sp_analytic)
                isnothing(ii) && continue
                v = ii - 1 # We subtract one, since the first element
                           # of Sp_analytic corresponds to v = 0.
                push!(v_cands, i => v)
            end

            if verbosity > 2
                @info "J = $(J)" GSU GSp A ee
                @info "SU(2j+1) eigenvalues" SUeigs SU2jp1Casimir(j, N) SUsel
                @info "Symplectic eigenvalues" Q'GSp*Q Speigs Sp2jp1Casimir.(j,0:N) v_cands
            end

            # Ad hoc label to disambiguate states with the same
            # seniority.
            αcounter = Dict{Int,Int}()

            for (Ji,(i,v)) in zip(Jindices, v_cands)
                α = get!(αcounter, v, 1)
                αcounter[v] += 1
                push!(new_states, (j=j, v=v, α=α, J=J))
                cfps[N][Ji,:] .= Q[:,i]
            end
        end
        push!(states, new_states)

        if verbosity > 1
            @info "Subshell ($(j))$(to_superscript(N))"
            for (i,state) in enumerate(states[N])
                println(state)
                printfmtln("{1:>4s} {2:>6s}", "v₁", "J₁")
                for (ii,parent_state) in enumerate(states[N-1])
                    c = cfps[N][i,ii]
                    abs(c) < √(eps(T)) && continue
                    printfmtln("{1:>4d} {2:>6s} {3:16.10f}",
                               parent_state.v, parent_state.J, c)
                end
            end
            println()
        end

    end
    states, cfps
end

bayman_lande(j::HalfInt; kwargs...) =
    bayman_lande(Float64, j; kwargs...)
