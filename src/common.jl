const spectroscopic = "spdfghiklmnoqrtuvwxyz"
function spectroscopic_label(ℓ)
    ℓ >= 0 || throw(DomainError(ℓ, "Negative ℓ values not allowed"))
    ℓ + 1 ≤ length(spectroscopic) ? spectroscopic[ℓ+1] : "[$(ℓ)]"
end

"""
    @< a b [lt]

Helper macro that returns `true` if `a < b`, `false` if `a > b`, and
does nothing if `a == b`. The intended use-case is to simplify the
implementation of `isless` methods. Optionally accepts a custom
implementation of `lt`.
"""
macro <(a, b, lt=:(<))
    islt = :($(esc(lt))($(esc(a)), $(esc(b))) && return true)
    isgt = :($(esc(lt))($(esc(b)), $(esc(a))) && return false)
    Expr(:block, islt, isgt, :(false))
end
