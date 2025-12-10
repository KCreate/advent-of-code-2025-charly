#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const lines = readfile(input_path).lines()

const parse_input = import "./parse-input.ch"
const machines = parse_input(lines)

const totalPresses = machines.parallelMap(->(machine) {
    const visited_states = []

    const queue = machine.buttons.map(->(button) [button])
    while queue.notEmpty() {
        const combination = queue.pop_front()
        const current_state = machine.apply_buttons_to_indicators(combination)

        if current_state == machine.indicatorLights return combination.length

        if !visited_states.contains(current_state) {
            visited_states.push(current_state)

            machine.buttons.each(->(button) {
                queue.push([...combination, button])
            })
        }
    }

    throw "failed to find a solution for {machine}"
}).sum()

print("total button presses: {totalPresses}")
