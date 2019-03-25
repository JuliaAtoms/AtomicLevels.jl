const spectroscopic = "spdfghiklmnoqrtuvwxyz"
function spectroscopic_label(ℓ)
    ℓ >= 0 || throw(DomainError(ℓ, "Negative ℓ values not allowed"))
    ℓ + 1 ≤ length(spectroscopic) ? spectroscopic[ℓ+1] : "[$(ℓ)]"
end

# Nicer string representation for rationals
rs(r::Number) = "$(r)"
rs(r::Rational) = denominator(r) == 1 ? "$(numerator(r))" : "$(numerator(r))/$(denominator(r))"
