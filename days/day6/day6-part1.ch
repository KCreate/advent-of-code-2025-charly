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
            .filterEmpty()

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

const results = problems.map(->(problem) {
    const (operand, inputs) = problem
    const result = operand == "+" ? inputs.sum() : inputs.product()
    result
})

const totalSum = results.sum()

print("totalSum = {totalSum}")
