# * Level

"""
    Level(csf, J)

Given a [`CSF`](@ref) with a final [`Term`](@ref), a `Level`
additionally specifies a total angular momentum ``J``. By further
specifying a projection quantum number ``M_J``, we get a
[`State`](@ref).
"""
struct Level{O,IT,T}
    csf::CSF{O,IT,T}
    J::HalfInt
    function Level(csf::CSF{O,IT,T}, J::HalfInteger) where {O,IT,T}
        J ∈ J_range(last(csf.terms)) ||
            throw(ArgumentError("Invalid J = $(J) for term $(last(csf.terms))"))
        new{O,IT,T}(csf, J)
    end
end

Level(csf::CSF, J::Integer) = Level(csf, convert(HalfInteger, J))

function Base.show(io::IO, level::Level)
    write(io, "|")
    show(io, level.csf)
    write(io, ", J = $(level.J)⟩")
end

"""
    weight(l::Level)

Returns the statistical weight of the [`Level`](@ref) `l`, i.e. the
number of possible microstates: ``2J+1``.

# Example

```jldoctest
julia> l = Level(first(csfs(c"1s 2p")), 1)
|1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-, J = 1⟩

julia> weight(l)
3
```
"""
weight(l::Level) = convert(Int, 2l.J + 1)

Base.:(==)(l1::Level, l2::Level) = ((l1.csf == l2.csf) && (l1.J == l2.J))

# It makes no sense to sort levels with different electron configurations
Base.isless(l1::Level, l2::Level) = ((l1.csf < l2.csf)) ||
    ((l1.csf == l2.csf)) && (l1.J < l2.J)

"""
    J_range(term::Term)

List the permissible values of the total angular momentum ``J`` for
`term`.

# Examples

```jldoctest
julia> J_range(T"¹S")
0:0

julia> J_range(T"²S")
1/2:1/2

julia> J_range(T"³P")
0:2

julia> J_range(T"²D")
3/2:5/2
```
"""
J_range(term::Term) = abs(term.L-term.S):(term.L+term.S)

"""
    J_range(J)

The permissible range of the total angular momentum ``J`` in ``jj``
coupling is simply the value of ``J`` for the final term.
"""
J_range(J::HalfInteger) = J:J
J_range(J::Integer) = J_range(convert(HalfInteger, J))

"""
    levels(csf)

Generate all permissible [`Level`](@ref)s given `csf`.

# Examples

```jldoctest
julia> csfs(c"1s 2p")
2-element Array{CSF{Orbital{Int64},Term,Seniority},1}:
 1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-
 1s(₁²S|²S) 2p(₁²Pᵒ|³Pᵒ)-

julia> csfs(rc"1s 2p")
2-element Array{CSF{RelativisticOrbital{Int64},HalfIntegers.Half{Int64},Seniority},1}:
 1s(₁1/2|1/2) 2p(₁3/2|1)-
 1s(₁1/2|1/2) 2p(₁3/2|2)-

julia> csfs(rc"1s 2p-")
2-element Array{CSF{RelativisticOrbital{Int64},HalfIntegers.Half{Int64},Seniority},1}:
 1s(₁1/2|1/2) 2p-(₁1/2|0)-
 1s(₁1/2|1/2) 2p-(₁1/2|1)-
```
"""
levels(csf::CSF) = sort([Level(csf,J) for J in J_range(last(csf.terms))])

# * State

@doc raw"""
    State(level, M_J)

A states defines, in addition to the total angular momentum ``J`` of
`level`, its projection ``M_J\in -J..J``.
"""
struct State{O,IT,T}
    level::Level{O,IT,T}
    M_J::HalfInt
    function State(level::Level{O,IT,T}, M_J::HalfInteger) where {O,IT,T}
        abs(M_J) ≤ level.J ||
            throw(ArgumentError("Invalid M_J = $(M_J) for level with J = $(level.J)"))
        new{O,IT,T}(level, M_J)
    end
end
State(level::Level, M_J::Integer) = State(level, convert(HalfInteger, M_J))

function Base.show(io::IO, state::State)
    write(io, "|")
    show(io, state.level.csf)
    write(io, ", J = $(state.level.J), M_J = $(state.M_J)⟩")
end

Base.:(==)(a::State,b::State) = a.level == b.level && a.M_J == b.M_J
Base.isless(a::State,b::State) = a.level < b.level || a.level == b.level && a.M_J < b.M_J

"""
   states(level)

Generate all permissible [`State`](@ref) given `level`.

# Example

```jldoctest
julia> l = Level(first(csfs(c"1s 2p")), 1)
|1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-, J = 1⟩

julia> states(l)
3-element Array{State{Orbital{Int64},Term,Seniority},1}:
 |1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-, J = 1, M_J = -1⟩
 |1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-, J = 1, M_J = 0⟩
 |1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-, J = 1, M_J = 1⟩
```
"""
function states(level::Level{O,IT,T}) where {O,IT,T}
    J = level.J
    [State(level, M_J) for M_J ∈ -J:J]
end

"""
    states(csf)

Directly generate all permissible [`State`](@ref)s for `csf`.

# Example

```jldoctest
julia> c = first(csfs(c"1s 2p"))
1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-

julia> states(c)
1-element Array{Array{State{Orbital{Int64},Term,Seniority},1},1}:
 [|1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-, J = 1, M_J = -1⟩, |1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-, J = 1, M_J = 0⟩, |1s(₁²S|²S) 2p(₁²Pᵒ|¹Pᵒ)-, J = 1, M_J = 1⟩]
```
"""
states(csf::CSF) = states.(levels(csf))

export Level, weight, J_range, levels, State, states
