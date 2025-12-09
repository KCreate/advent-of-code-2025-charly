#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const lines = readfile(input_path).lines()

const corners = lines.map(->(line) {
    const (x, y) = line.split(",")
    (x.to_number(), y.to_number())
})

const rectangles = corners.unidirectionalPermutations()

const areas = rectangles.map(->(pair) {
    const (c1, c2) = pair
    const (x1, y1) = c1
    const (x2, y2) = c2

    const lengthX = (x1 - x2).abs() + 1
    const lengthY = (y1 - y2).abs() + 1

    lengthX * lengthY
})

const largestArea = areas.findMax()

print("largestArea = {largestArea}")
