class Machine {
    property indicatorLights
    property buttons
    property joltageRequirements

    func dump {
        print("#: {@indicatorLights} {@buttons} {@joltageRequirements}")
    }
}

export func parse_input(lines) = lines.map(->(line) {
    let (indicatorLights, ...buttons, joltageRequirements) = line.split(" ")

    indicatorLights = indicatorLights
        .split("")
        .dropFirst()
        .dropLast()
        .map(->(i) {
            if i == "." return false
            return true
        })

    buttons = buttons.map(->(button) {
        button
            .split("")
            .dropFirst()
            .dropLast()
            .join("")
            .split(",")
            .map(->(c) c.to_number())
    })

    joltageRequirements = joltageRequirements
        .split("")
        .dropFirst()
        .dropLast()
        .join("")
        .split(",")
        .map(->(c) c.to_number())

    return Machine(indicatorLights, buttons, joltageRequirements)
})
