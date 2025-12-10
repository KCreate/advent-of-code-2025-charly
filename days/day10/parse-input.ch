class Machine {
    property indicatorLights
    property buttons
    property joltageRequirements

    func apply_buttons(buttons) {
        const state = List.create_with(self.indicatorLights.length, ->false)

        buttons.each(->(button) {
            button.each(->(i) state[i] = !state[i])
        })

        state.join("", ->(s) s ? "#" : ".")
    }
}

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
