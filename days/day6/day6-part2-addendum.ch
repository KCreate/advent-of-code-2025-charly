#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]

// ensure all lines have the same length, as the IDE will remove trailing spaces
const lines = readfile(input_path).lines().apply(->(lines) {
    const maxLength = lines.findMaxBy(->(it) it.length).length
    lines.map(->(line) line.padRight(maxLength, " "))
}).map(->(line) line.chars())

// originally implemented in Kotlin by @lukaslebo
let totalSum = 0
const currentProblemOperands = []
lines.first().indices().reverse().each(->(i) {
    const column = lines.map(->(line) line[i])
    const digits = column.dropLast(1)
    const operand = column.last()

    if (digits.all(->(d) d == " ")) {
        i -= 1
        return
    }

    currentProblemOperands.push(digits.join("").to_number())

    switch operand {
        case "+" totalSum += currentProblemOperands.sum()
        case "*" totalSum += currentProblemOperands.product()
        default return
    }
    currentProblemOperands.clear()
})

print("totalSum = {totalSum}")
