# Internals

!!! note
    The functions, methods and types documented here are _not_ part of the public API.

```@meta
CurrentModule = AtomicLevels
DocTestSetup = quote
    using AtomicLevels
end
```

```@autodocs
Modules = [AtomicLevels]
Public = false
Filter = fn -> !in(fn, [Base.parse, Base.fill, Base.fill!])
```

```@meta
CurrentModule = nothing
DocTestSetup = nothing
```
