#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const input = readfile(input_path)

const ranges = input
    .split(",")
    .map(->(entry) {
        const (first, last) = entry.split("-")
        (first.to_number(), last.to_number())
    })

const invalidIdsPerRange = ranges
    .parallelMap(->(range) {
        const (first, last) = range

        const invalidIds = []

        first.upTo(last, ->(i) {
            const entry = "{i}"

            const length = entry.length
            const parts = 1.collectUpTo(length / 2, ->(partlength) entry.substring(0, partlength))
            const possibleParts = parts.filter(->(part) {
                entry.length % part.length == 0
            })

            const isInvalid = possibleParts.any(->(part) {
                const multiplier = entry.length / part.length
                const check = part * multiplier
                check == entry
            })

            if isInvalid {
                invalidIds.push(i)
            }
        })

        invalidIds
    })
    .flatten()

const totalSum = invalidIdsPerRange.reduce(0, ->(p, c) p + c)

print(totalSum)
