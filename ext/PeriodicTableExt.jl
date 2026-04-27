module PeriodicTableExt

using AtomicLevels
using PeriodicTable

AtomicLevels.Configuration(element::Element) = sort(parse(Configuration{Orbital}, element.el_config))

function AtomicLevels.Configuration(element::Element, states::Vector{Symbol})
    config = Configuration(element)
    return Configuration(config.orbitals, config.occupancy, states)
end

end