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

    // comments in this file refer to this as an example
    // [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}

    // (3, 5, 4, 7)
    const goal = machine.joltageRequirements

    // (0, 0, 0, 0)
    const zero_state = (...goal.map(->0))

    // (0, 0, 0, 0, 0, 0)
    const zero_activation = (...machine.buttons.map(->0))

    // [
    //   (0, 0, 0, 1),
    //   (0, 1, 0, 1),
    //   (0, 0, 1, 0),
    //   (0, 0, 1, 1),
    //   (1, 0, 1, 0),
    //   (1, 1, 0, 0)
    // ]
    const buttons = machine.buttons.map(->(button) {
        const x = List.create(goal.length, 0)
        button.each(->(i) x[i] = 1)
        (...x)
    })

    // [
    //   (1, 0, 0, 0, 0, 0)
    //   (0, 1, 0, 0, 0, 0)
    //   (0, 0, 1, 0, 0, 0)
    //   (0, 0, 0, 1, 0, 0)
    //   (0, 0, 0, 0, 1, 0)
    //   (0, 0, 0, 0, 0, 1)
    // ]
    const button_activations = buttons.map(->(button, i) {
        (...0.collectUpTo(buttons.length - 1, ->(n) n == i ? 1 : 0))
    })

    // [7, 5, 4, 4, 3, 3]
    const buttons_upper_limit = machine.buttons.map(->(button) {
        button.map(->(index) goal[index]).findMin()
    })

    // check if two buttons refer to the same index -> they overlap
    func buttons_overlap(a, b) {
        const sum = a + b
        return [...sum].any(->(n) n == 2)
    }

    // matrix[b1][b2] = do the buttons overlap?
    const button_couple_matrix = buttons.map(->(button1, i1) {
        buttons.map(->(button2, i2) {
            if i1 == i2 return false
            buttons_overlap(button1, button2)
        })
    })

    // list[b] = list of button indices that overlap this button (excluding self)
    const button_couples = button_couple_matrix.map(->(m) {
        m.map(->(v, i) (v, i)).filter(->(e) e[0]).map(->(e) e[1])
    })

    // ----- max-first solver -----

    const button_count = buttons.length
    const channel_count = goal.length

    let current_state = goal.map(->0)           // accumulated jolts per channel
    let current_activation = machine.buttons.map(->0) // presses per button
    let current_total = 0

    let best_activation = null
    let best_total = null

    func max_presses_for_button(index) {
        const button = buttons[index]
        let max_dynamic = buttons_upper_limit[index]

        let c = 0
        while c < channel_count {
            const inc = button[c]
            if inc > 0 {
                const remaining = goal[c] - current_state[c]
                if remaining < 0 {
                    return 0
                }
                const local_max = (remaining / inc).floor()
                if local_max < max_dynamic {
                    max_dynamic = local_max
                }
            }
            c += 1
        }

        max_dynamic
    }

    func search(index) {
        if index == button_count {
            // check exact match
            let ok = true
            let c = 0
            while c < channel_count {
                if current_state[c] != goal[c] {
                    ok = false
                    break
                }
                c += 1
            }
            if !ok return

            if best_total == null || current_total < best_total {
                best_total = current_total
                best_activation = current_activation.map(->(v) v) // copy
            }
            return
        }

        let max_presses = max_presses_for_button(index)
        let presses = max_presses

        while presses >= 0 {
            if presses > 0 {
                const button = buttons[index]

                // apply presses
                let c = 0
                while c < channel_count {
                    current_state[c] += button[c] * presses
                    c += 1
                }
                current_activation[index] = presses
                current_total += presses

                // prune if already worse than best
                if best_total != null && current_total >= best_total {
                    c = 0
                    while c < channel_count {
                        current_state[c] -= button[c] * presses
                        c += 1
                    }
                    current_activation[index] = 0
                    current_total -= presses
                    presses -= 1
                    continue
                }
            }

            // recurse to next button
            search(index + 1)

            // undo before trying next press count
            if presses > 0 {
                const button2 = buttons[index]
                let c2 = 0
                while c2 < channel_count {
                    current_state[c2] -= button2[c2] * presses
                    c2 += 1
                }
                current_activation[index] = 0
                current_total -= presses
            }

            presses -= 1
        }
    }

    func find_best_activation {
        search(0)
        if best_activation == null {
            throw "No exact solution for given goal/buttons within limits"
        }
        (best_activation, best_total)
    }

    const (solution_activation, minimal_presses) = find_best_activation()
    print("solution activation =", solution_activation)
    print("minimal total presses =", minimal_presses)

    minimal_presses
}).sum()

print("total button presses: {totalPresses}")
/*

            0 1 2 3     index

            3 5 4 7     target joltage

                  x     button 1 (3)
              x   x     button 2 (1, 3)
                x       button 3 (2)
                x x     button 4 (2, 3)
            x   x       button 5 (0, 2)
            x x         button 6 (0, 1)

target = (3, 5, 4, 7)
t1 = (0, 0, 0, 1)
t2 = (0, 1, 0, 1)
t3 = (0, 0, 1, 0)
t4 = (0, 0, 1, 1)
t5 = (1, 0, 1, 0)
t6 = (1, 1, 0, 0)

x1 * t1 + x2 * t2 + x3 * t3 + x4 * t4 + x5 * t5 + x6 * t6 = target

equations:
x0 = 7 - x1 - x3
x1 = 5 - x0 - x3 - x5
x2 = 4 - x3 - x4
x3 = 4 - x0 - x1 - x2 - x4
x4 = 3 - x2 - x3 - x5
x5 = 3 - x1 - x4


 */
