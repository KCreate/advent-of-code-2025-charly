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

const (firstRange, ...remainingRanges) = freshIdRanges.sort(->(left, right) left[0] <=> right[0])
const mergedRanges = [firstRange]

remainingRanges.each(->(range) {
    const (newStart, newEnd) = range
    const (lastStart, lastEnd) = mergedRanges.last()

    if newStart <= lastEnd + 1 {
        mergedRanges[mergedRanges.length - 1] = (lastStart, newEnd.max(lastEnd))
    } else {
        mergedRanges.push(range)
    }
})

const totalFreshIds = mergedRanges.reduce(0, ->(acc, c) {
    const (start, end) = c
    const length = end - start + 1
    acc + length
})

print("total fresh ids: {totalFreshIds}")

