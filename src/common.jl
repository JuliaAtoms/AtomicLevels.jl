const spectroscopic = "spdfghiklmnoqrtuvwxyz"
function spectroscopic_label(ℓ)
    ℓ >= 0 || throw(DomainError(ℓ, "Negative ℓ values not allowed"))
    ℓ + 1 ≤ length(spectroscopic) ? spectroscopic[ℓ+1] : "[$(ℓ)]"
end
