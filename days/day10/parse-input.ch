const Machine = import "./machine.ch"

export func parse_input(lines) = lines.map(->(line) {
    const (indicatorLights, ...buttons, joltageRequirements) = line.split(" ")

    return Machine(
        indicatorLights.substring(1, indicatorLights.length - 2),
        buttons.map(->(button) {
            button
                .substring(1, button.length - 2)
                .split(",")
                .map(->(c) c.to_number())
        }),
        joltageRequirements
            .substring(1, joltageRequirements.length - 2)
            .split(",")
            .map(->(c) c.to_number())
    )
})
