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

const allIds = []
ranges.each(->(range) {
    const (first, last) = range
    first.upTo(last, ->(idx) {
        allIds.push(idx)
    })
})

func checkIsInvalid(entry) {
    const length = entry.length
    const possibleParts = 1.collectUpTo(length / 2, ->(partLength) {
        entry.substring(0, partLength)
    })
        .filter(->(part) {
            // filter out parts that cannot possibly form the entire pattern
            entry.length % part.length == 0
        })

    possibleParts.filter(->(part) {
        const multiplier = entry.length / part.length
        const check = part * multiplier
        check == entry
    }).notEmpty()
}

const invalidIds = allIds
    .map(->(id) "{id}")
    .filter(->(entry) {
        checkIsInvalid(entry)
    })
    .map(->(entry) entry.to_number())

const totalSum = invalidIds.reduce(0, ->(p, c) p + c)

print(totalSum)
