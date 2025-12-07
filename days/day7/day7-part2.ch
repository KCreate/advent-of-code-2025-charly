#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const lines = readfile(input_path).lines().filter(->(r, i) i % 2 == 0)
const grid = lines.map(->(row) { row.chars() })
const splitters = grid.dropFirst(1)

let totalSplits = 0
let beamPathsCount = grid.first().map(->(point) {
    switch point {
        case "." return 0
        case "S" return 1
    }
})

splitters.each(->(row) {
    const newBeamCount = beamPathsCount.copy()

    row.each(->(point, i) {
        if beamPathsCount[i] > 0 && point == "^" {
            newBeamCount[i - 1] += newBeamCount[i]
            newBeamCount[i + 1] += newBeamCount[i]
            newBeamCount[i] = 0
            totalSplits += 1
        }
    })

    beamPathsCount = newBeamCount
})

const totalAvailablePaths = beamPathsCount.sum()

print("totalSplits = {totalSplits}")
print("totalAvailablePaths = {totalAvailablePaths}")
