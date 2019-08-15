struct Level{O,IT,T}
    csf::CSF{O,IT,T}
    J::HalfInt
    function Level(csf::CSF{O,IT,T}, J::HalfInteger) where {O,IT,T}
        J ∈ J_range(last(csf.terms)) ||
            throw(ArgumentError("Invalid J = $(J) for term $(last(csf.terms))"))
        new{O,IT,T}(csf, J)
    end
end

function Base.show(io::IO, level::Level)
    write(io, "|")
    show(io, level.csf)
    write(io, ", J = $(level.J)⟩")
end

weight(l::Level) = convert(Int, 2l.J + 1)

Base.:(==)(l1::Level, l2::Level) = ((l1.csf == l2.csf) && (l1.J == l2.J))

# It makes no sense to sort levels with different electron configurations
Base.isless(l1::Level, l2::Level) = ((l1.csf < l2.csf)) ||
    ((l1.csf == l2.csf)) && (l1.J < l2.J)

J_range(term::Term) = abs(term.L-term.S):(term.L+term.S)
J_range(term::HalfInteger) = term:term

levels(csf::CSF) = sort([Level(csf,J) for J in J_range(last(csf.terms))])

struct State{O,IT,T}
    level::Level{O,IT,T}
    M_J::HalfInt
    function State(level::Level{O,IT,T}, M_J::HalfInteger) where {O,IT,T}
        abs(M_J) ≤ level.J ||
            throw(ArgumentError("Invalid M_J = $(M_J) for level with J = $(level.J)"))
        new{O,IT,T}(level, M_J)
    end
end

function Base.show(io::IO, state::State)
    write(io, "|")
    show(io, state.level.csf)
    write(io, ", J = $(state.level.J), M_J = $(state.M_J)⟩")
end

Base.:(==)(a::State,b::State) = a.level == b.level && a.M_J == b.M_J
Base.isless(a::State,b::State) = a.level < b.level || a.level == b.level && a.M_J < b.M_J

function states(level::Level{O,IT,T}) where {O,IT,T}
    J = level.J
    [State(level, M_J) for M_J ∈ -J:J]
end
states(csf::CSF) = states.(levels(csf))

export Level, weight, J_range, levels, State, states
