using Documenter
using AtomicLevels

makedocs(
    modules = [AtomicLevels],
    sitename = "AtomicLevels",
    pages = [
        "Home" => "index.md",
        "Orbitals" => "orbitals.md",
        "Configurations" => "configurations.md",
        "Term symbols" => "terms.md",
        "CSFs" => "csfs.md",
        "Other utilities" => "utilities.md",
        "Internals" => "internals.md",
    ],
    format = Documenter.HTML(
        mathengine = MathJax(Dict(
            :TeX => Dict(
                :equationNumbers => Dict(:autoNumber => "AMS"),
                :Macros => Dict(
                    :defd => "≝",
                    :ket => ["|#1\\rangle", 1],
                    :bra => ["\\langle#1|", 1],
                    :braket => ["\\langle#1|#2\\rangle", 2],
                    :ketbra => ["|#1\\rangle\\!\\langle#2|", 2],
                    :matrixel => ["\\langle#1|#2|#3\\rangle", 3],
                    :vec => ["\\mathbf{#1}", 1],
                    :mat => ["\\mathsf{#1}", 1],
                    :conj => ["#1^*", 1],
                    :im => "\\mathrm{i}",
                    :operator => ["\\mathfrak{#1}", 1],
                    :Hamiltonian => "\\operator{H}",
                    :hamiltonian => "\\operator{h}",
                    :Lagrangian => "\\operator{L}",
                    :fock => "\\operator{f}",
                    :lagrange => ["\\epsilon_{#1}", 1],
                    :vary => ["\\delta_{#1}", 1],
                    :onebody => ["(#1|#2)", 2],
                    :twobody => ["[#1|#2]", 2],
                    :twobodydx => ["[#1||#2]", 2],
                    :direct => ["{\\operator{J}_{#1}}", 1],
                    :exchange => ["{\\operator{K}_{#1}}", 1],
                    :diff => ["\\mathrm{d}#1\\,", 1]
                )
            )
        ))
    ),
    strict = true,
    doctest = false
)

deploydocs(repo = "github.com/JuliaAtoms/AtomicLevels.jl.git")
