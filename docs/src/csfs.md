# [Atomic configuration state functions (CSFs)](@id CSFs)

AtomicLevels also provides types to represent symmetry-adapted atomic states, commonly referred to as [configuration state functions (CSFs)](https://en.wikipedia.org/wiki/Configuration_state_function). These are linear combinations of Slater determinants arising from a particular _configuration_, that are also

...

## Background

orbital angular momentum ``\hat{L}``, spin angular momentum ``\hat{S}`` and the total angular momentum ``\hat{J} = \hat{L} + \hat{S}``

orbital ``\hat{L}^2`` and ``\hat{S}^2``

final states are eigenfunctions of

``\hat{J}^2``

Given two sets of

```math
\ket{\alpha\beta; j, m} = C() \ket{\alpha}
```

futhermore, as the `S` and the `L` spaces are orthogonal,
you can simultaneously

First, each subshell

* The ordering of the configuration is significant.
* First, couple each subshell. Note, in general you end up with non-unique states. Hence, we actually need to also keep

As these states do not appear to be distinguishable by any fundamental symmetry,


## Coupling schemes

### ``LS``-coupling

### ``jj``-coupling

## Types and functions
