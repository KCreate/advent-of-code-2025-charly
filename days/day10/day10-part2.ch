#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const lines = readfile(input_path).lines()

const parse_input = import "./parse-input.ch"
const machines = parse_input(lines)

const totalPresses = machines.map(->(machine, machine_index) {
    const queue = machine.buttons.map(->(button) [button])

    let smallest_number_of_presses = 100000
    let checked = 0
    const visited_states = []

    while queue.notEmpty() {
        const combination = queue.pop()
        const current_state = machine.apply_buttons_to_joltage_levels(combination)
        checked += 1

        if current_state == machine.joltageRequirements {
            if combination.length < smallest_number_of_presses {
                print("#{machine_index} found {combination.length} in {checked} checks")
                smallest_number_of_presses = combination.length
            }
            continue
        }

        if combination.length >= smallest_number_of_presses {
            continue
        }

        if visited_states.contains((current_state, combination.length)) continue
        visited_states.push((current_state, combination.length))

        const limitForEachButton = machine.buttons.map(->(button) {
            button.map(->(i) machine.joltageRequirements[i] - current_state[i]).findMin()
        })

        machine.buttons.each(->(button, index) {
            if limitForEachButton[index] > 0 {
                queue.push([...combination, button])
            }
        })
    }

    print("machine {machine_index} found optimal solution")
    return smallest_number_of_presses
}).sum()

print("total button presses: {totalPresses}")
