#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]

let lines = readfile(input_path).lines()
const maxLineLength = lines.map(->(l) l.length).findMax()
lines = lines.map(->(line) {
    while line.length < maxLineLength {
        line = "{line} "
    }
    line
})

const (...inputLines, operandLine) = lines
const (inputs, operands) = (
    inputLines.map(->(line) line.chars()),
    operandLine.split(" ").filterEmpty().reverse()
)

let readerOffset = 0
const problems = operands
    .map(->(operand) {
        let inputData = []

        while readerOffset < maxLineLength {
            readerOffset += 1

            const charsRead = inputs.map(->(chars) {
                chars.pop()
            })

            if charsRead.all(->(c) c == " ") {
                break
            }

            const number = charsRead
                .filter(->(c) c != " ")
                .join("")
                .to_number()

            inputData.push(number)
        }

        (operand, inputData)
    })

const solutions = problems.map(->(problem) {
    const (operand, inputs) = problem
    const result = operand == "+" ? inputs.sum() : inputs.product()
    result
})

const totalSum = solutions.sum()

print(totalSum)
