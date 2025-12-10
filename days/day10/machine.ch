export class Machine {
    property indicatorLights
    property buttons
    property joltageRequirements

    func apply_buttons_to_indicators(buttons) {
        const state = List.create_with(self.indicatorLights.length, ->false)

        buttons.each(->(button) {
            button.each(->(i) state[i] = !state[i])
        })

        state.join("", ->(s) s ? "#" : ".")
    }

    func apply_buttons_to_joltage_levels(buttons) {
        const state = List.create_with(self.indicatorLights.length, ->0)

        buttons.each(->(button) {
            button.each(->(i) state[i] += 1)
        })

        state
    }
}
