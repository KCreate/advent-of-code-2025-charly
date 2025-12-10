#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const lines = readfile(input_path).lines()

const parse_input = import "./parse-input.ch"
const machines = parse_input(lines)

func apply_button_to_state(machine, state, button_index) {
    const button = machine.buttons[button_index]
    button.each(->(i) state[i] = !state[i])
}

func apply_buttons_to_state(machine, state, button_list) {
    button_list.each(->(button_index) {
        apply_button_to_state(machine, state, button_index)
    })
}

class Queue {
    property buffer = []

    func push(value) = self.buffer.push(value)

    func has_items = self.buffer.notEmpty()

    func pop {
        if self.buffer.empty() return null
        const value = self.buffer.first()
        self.buffer.erase(0, 1)
        value
    }
}

func solve_machine(machine) {
    const initial_state = machine.indicatorLights.map(->false)
    const goal = machine.indicatorLights.copy()

    let queue = Queue()

    // push initial buttons to queue
    machine.buttons.each(->(button, i) {
        queue.push([i])
    })

    const visited_states = []

    loop {
        const new_queue = Queue()
        if !queue.has_items() throw "failed to find a solution for {machine}"
        while queue.has_items() {
            const combination = queue.pop()

            if combination.length > 13 {
                continue
            }

            const final_state = initial_state.copy()
            apply_buttons_to_state(machine, final_state, combination)
            if final_state.all(->(v, i) v == machine.indicatorLights[i]) {
                return combination
            }

            const str_state = final_state.map(->(s) s ? "#" : ".").join()

            if (visited_states.find(str_state) != null) continue
            visited_states.push(str_state)

            // push next combinations
            machine.buttons.each(->(button, button_index) {
                const new_combination = combination.copy()
                new_combination.push(button_index)
                new_queue.push(new_combination)
            })
        }
        queue = new_queue
    }
}

print("total machine count: {machines.length}")

const totalPresses = machines.parallelMap(->(machine, index) {
    const solution = solve_machine(machine)
    print("found solution (N = {solution.length}) for machine {index}")
    solution.length
}).sum()


print("total button presses: {totalPresses}")
