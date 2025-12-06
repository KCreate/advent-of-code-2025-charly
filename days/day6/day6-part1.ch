#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const lines = readfile(input_path)
    .lines()
    .map(->(line, i, lines) {
        let line = line
            .split(" ")
            .filter(->(l) l.length > 0)

        if i < lines.length - 1 {
            line = line.map(->(l) l.to_number())
        }

        line
    })
const (...data, operators) = lines

const problems = operators
    .map(->(op, index) {
        const operands = data.map(->(row) row[index])
        (op, operands)
    })

const add = ->(a, b) a + b
const mul = ->(a, b) a * b

const results = problems.map(->(problem) {
    const (operand, inputs) = problem
    const initial = operand == "+" ? 0 : 1
    const transformer = operand == "+" ? add : mul
    const result = inputs.reduce(initial, transformer)

    print("{operand} {inputs} = {result}")

    result
})

const totalSum = results.reduce(0, ->(p, e) p + e)

print("totalSum = {totalSum}")
