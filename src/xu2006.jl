module Xu

@doc raw"""
    f(n,ℓ)

```math
f(n,\ell)=\begin{cases}
\displaystyle\sum_{m=0}^n \ell-m, & n\geq0\\
0, & n<0
\end{cases}
```
"""
f(n::I,ℓ::I) where {I<:Integer} = n >= 0 ? sum(ℓ-m for m in 0:n) : 0

@doc raw"""
``A(N,\ell,\ell_b,M_S',M_L)`` obeys four different cases:

## Case 1

``M_S'=1``, ``|M_L|\leq\ell``, and ``N=1``:

```math
A(1,\ell,\ell_b,1,M_L) = 1
```

## Case 2

``\{M_S'\}={2-N,4-N,...,N-2}``, ``|M_L| \leq f\left(\frac{N-M_S'}{2}-1\right)+f\left(\frac{N+M_S'}{2}-1\right)``, and ``1<N\leq 2\ell+1``:

```math
\begin{aligned}
A(N,\ell,\ell,M_S',M_L) =
\sum_{M_{L-}\max\left\{-f\left(\frac{N-M_S'}{2}-1\right),M_L-f\left(\frac{N+M_S'}{2}-1\right)\right\}}
^{\min\left\{f\left(\frac{N-M_S'}{2}-1\right),M_L+f\left(\frac{N+M_S'}{2}-1\right)\right\}}
\Bigg\{A\left(\frac{N-M_S'}{2},\ell,\ell,\frac{N-M_S'}{2},M_{L-}\right)\\
\times
A\left(\frac{N+M_S'}{2},\ell,\ell,\frac{N+M_S'}{2},M_L-M_{L-}\right)\Bigg\}
\end{aligned}
```

## Case 3

``M_S'=N``, ``|M_L|\leq f(N-1)``, and ``1<N\leq 2\ell+1``:

```math
A(N,\ell,\ell_b,N,M_L) =
\sum_{M_{L_I} = \left\lfloor{\frac{M_L-1}{N}+\frac{N+1}{2}}\right\rfloor}
^{\min\{\ell_b,M_L+f(N-2)\}}
A(N-1,\ell,M_{L_I}-1,N-1,M_L-M_{L_I})
```

## Case 4

else:

```math
A(N,\ell,\ell_b,M_S',M_L) = 0
```
"""
function A(N::I, ℓ::I, ℓ_b::I, M_S′::I, M_L::I) where {I<:Integer}
    if M_S′ == 1 && abs(M_L) <= ℓ && N == 1
        1 # Case 1
    elseif 1 < N && N <= 2ℓ + 1
        # Cases 2 and 3
        # N ± M_S' is always an even number
        a = (N-M_S′) >> 1
        b = (N+M_S′) >> 1
        fa = f(a-1,ℓ)
        fb = f(b-1,ℓ)

        if M_S′ in 2-N:2:N-2 && abs(M_L) <= fa + fb
            mapreduce(+, max(-fa, M_L - fb):min(fa, M_L + fb)) do M_Lm
                A(a,ℓ,ℓ,a,M_Lm)*A(b,ℓ,ℓ,b,M_L-M_Lm)
            end
        elseif M_S′ == N && abs(M_L) <= f(N-1,ℓ)
            mapreduce(+, floor(Int, (M_L-1)//N + (N+1)//2):min(ℓ_b,M_L + f(N-2,ℓ))) do M_LI
                A(N - 1, ℓ, M_LI - 1, N - 1, M_L-M_LI)
            end
        else
            0 # Case 4
        end
    else
        0 # Case 4
    end
end

@doc raw"""
    X(N, ℓ, S′, L)

Calculate the multiplicity of the term ``^{2S+1}L`` (``S'=2S``) for
the orbital `ℓ` with occupancy `N`, according to the formula:

```math
\begin{aligned}
X(N, \ell, S', L) =&+ A(N, \ell,\ell,S',L)\\
&- A(N, \ell,\ell,S',L+1)\\
&+A(N, \ell,\ell,S'+2,L+1)\\
&- A(N, \ell,\ell,S'+2,L)
\end{aligned}
```

Note that this is not correct for filled (empty) shells, for which the
only possible term trivially is `¹S`.

# Examples

```jldoctest
julia> AtomicLevels.Xu.X(1, 0, 1, 0) # Multiplicity of ²S term for s¹
1

julia> AtomicLevels.Xu.X(3, 3, 1, 3) # Multiplicity of ²D term for d³
2
```

"""
X(N::I, ℓ::I, S′::I, L::I) where {I<:Integer} = A(N,ℓ,ℓ,S′,L) - A(N,ℓ,ℓ,S′,L+1) + A(N,ℓ,ℓ,S′+2,L+1) - A(N,ℓ,ℓ,S′+2,L)

end
