function from_subscript(s)
    inverse_subscript_map = Dict('₋' => '-', '₊' => '+', '₀' => '0',
                                 '₁' => '1', '₂' => '2', '₃' => '3',
                                 '₄' => '4', '₅' => '5', '₆' => '6',
                                 '₇' => '7', '₈' => '8', '₉' => '9',
                                 '₀' => '0')
    map(Base.Fix1(getindex, inverse_subscript_map), s)
end

function from_superscript(s)
    inverse_superscript_map = Dict('⁻' => '-', '⁺' => '+', '⁰' => '0',
                                   '¹' => '1', '²' => '2', '³' => '3',
                                   '⁴' => '4', '⁵' => '5', '⁶' => '6',
                                   '⁷' => '7', '⁸' => '8', '⁹' => '9',
                                   '⁰' => '0')
    map(Base.Fix1(getindex, inverse_superscript_map), s)
end
