# AtomicLevels

[![Documentation][docs-stable-img]][docs-stable-img]
[![Documentation (dev)][docs-dev-img]][docs-dev-img]
[![GitHub Actions CI][ci-gha-img]][ci-gha-url]
[![CodeCov][codecov-img]][codecov-url]

AtomicLevels provides a collections of types and methods to facilitate working with atomic states (or, more generally, states with spherical symmetry), both in the relativistic (eigenstates of `J = L + S`) and non-relativistic (eigenstates on `L` and `S` separately) frameworks.


* Orbitals and orbital subshells
* Configurations
* Configuration state functions (CSFs)
* Term symbols

The aim is to make sure that the types used to label and store information about atomic states are both efficient and user-friendly at the same time.
In addition, it also provides various utility methods, such as generation of a list CSFs corresponding to a given configuration, serialization of orbitals and configurations, methods for introspecting physical quantities etc.

## Example

To install and load the package, you can just type in the Julia REPL

```julia-repl
julia> using Pkg; Pkg.add("DataFrames")
julia> using AtomicLevels
```

As an simple usage example, to constructing a configuration for an S-like state with an open `3p` shell looks like

```julia-repl
julia> configuration = c"[Ne]* 3s2 3p4"
1s² 2s² 2p⁶ 3s² 3p⁴
```

which is of type `Configuration`. To access information about subshells, you can index into
the configuration which returns a tuple (including a corresponding `Orbital` object, so you
can, for example, access the `ℓ` and `s` angular momentum quantum numbers):

```
julia> shell = configuration[end]
(3p, 4, :open)

julia> angular_momenta(shell[1])
(1, 1/2)
```

Also, you can convert the configurations to the corresponding relativistic configurations
and CSFs by simply doing

```
julia> rconfigurations = relconfigurations(configuration)
3-element Array{Configuration{RelativisticOrbital{Int64}},1}:
 1s² 2s² 2p-² 2p⁴ 3s² 3p-² 3p²
 1s² 2s² 2p-² 2p⁴ 3s² 3p- 3p³
 1s² 2s² 2p-² 2p⁴ 3s² 3p⁴

julia> csfs(rconfigurations)
5-element Array{CSF{RelativisticOrbital{Int64},HalfIntegers.Half{Int64},Seniority},1}:
 1s²(₀0|0) 2s²(₀0|0) 2p-²(₀0|0) 2p⁴(₀0|0) 3s²(₀0|0) 3p-²(₀0|0) 3p²(₀0|0)+
 1s²(₀0|0) 2s²(₀0|0) 2p-²(₀0|0) 2p⁴(₀0|0) 3s²(₀0|0) 3p-²(₀0|0) 3p²(₂2|2)+
 1s²(₀0|0) 2s²(₀0|0) 2p-²(₀0|0) 2p⁴(₀0|0) 3s²(₀0|0) 3p-(₁1/2|1/2) 3p³(₁3/2|1)+
 1s²(₀0|0) 2s²(₀0|0) 2p-²(₀0|0) 2p⁴(₀0|0) 3s²(₀0|0) 3p-(₁1/2|1/2) 3p³(₁3/2|2)+
 1s²(₀0|0) 2s²(₀0|0) 2p-²(₀0|0) 2p⁴(₀0|0) 3s²(₀0|0) 3p⁴(₀0|0)+
```

For more examples and information about how to work with the various types, please see that [documentation][docs-stable-url].

[ci-gha-url]: https://github.com/JuliaAtoms/AtomicLevels.jl/actions
[ci-gha-img]: https://github.com/JuliaAtoms/AtomicLevels.jl/workflows/CI/badge.svg
[codecov-url]: https://codecov.io/gh/JuliaAtoms/AtomicLevels.jl
[codecov-img]: https://codecov.io/gh/JuliaAtoms/AtomicLevels.jl/branch/master/graph/badge.svg
[docs-stable-url]: https://juliaatoms.org/AtomicLevels.jl/stable/
[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-dev-url]: https://juliaatoms.org/AtomicLevels.jl/dev/
[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
