#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const input = readfile(input_path)

const lines = input.lines()

const emptyLineIndex = lines.find("")

const freshIdRanges = lines
    .sublist(0, emptyLineIndex)
    .map(->(range) {
        range
            .split("-")
            .map(->(num) num.to_number())
    })

const availableIds = lines
    .sublist(emptyLineIndex + 1)
    .map(->(num) num.to_number())

func isFresh(id) {
    return freshIdRanges.any(->(range) {
        const (start, end) = range
        return id >= start && id <= end
    })
}

const freshIds = availableIds.filter(->(id) isFresh(id))

print("fresh ids: {freshIds.length}")

const rangesToProcess = freshIdRanges.copy()
const trimmedRanges = []
while (rangesToProcess.notEmpty()) {

    const newRange = rangesToProcess.pop()
    const (start, end) = newRange

    // ignore invalid ranges
    if !(start <= end) {
        continue
    }

    // case: new range fully encompasses existing range
    if trimmedRanges.any(->(existing) {
        const (otherStart, otherEnd) = existing
        if otherStart >= start && otherEnd <= end {
            const (leftStart, leftEnd) = (start, otherStart - 1)
            const (rightStart, rightEnd) = (otherEnd + 1, end)

            // queue the new subranges
            rangesToProcess.push((leftStart, leftEnd))
            rangesToProcess.push((rightStart, rightEnd))

            return true
        }

        return false
    }) {
        continue
    }

    // new range overlaps existing range
    if trimmedRanges.any(->(existing) {
        const (otherStart, otherEnd) = existing
        const startOverlap = start >= otherStart && start <= otherEnd
        const endOverlap = end >= otherStart && end <= otherEnd

        if startOverlap || endOverlap {
            rangesToProcess.push((start, otherStart - 1))
            rangesToProcess.push((otherEnd + 1, end))
            return true
        }

        return false
    }) {
        continue
    }

    // new range does not overlap any existing range, can add to trimmed set
    trimmedRanges.push(newRange)
}

const totalFreshIds = trimmedRanges.reduce(0, ->(acc, range) {
    const (start, end) = range
    const rangeLength = end - start + 1
    acc + rangeLength
})

print("totalFreshIds: {totalFreshIds}")
