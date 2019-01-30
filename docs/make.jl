using Documenter

makedocs(
    sitename = "AtomicLevels",
    pages = [
        "Home" => "index.md",
    ],
)

deploydocs(repo = "github.com/JuliaAtoms/AtomicLevels.jl.git")
