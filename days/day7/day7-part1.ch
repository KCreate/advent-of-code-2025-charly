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
let beamPath = grid.first().map(->(point) {
    switch point {
        case "." return false
        case "S" return true
    }
})

splitters.each(->(row) {
    const newBeamPath = beamPath.copy()

    row.each(->(point, i) {
        if beamPath[i] && point == "^" {
            newBeamPath[i - 1] = true
            newBeamPath[i + 1] = true
            newBeamPath[i] = false
            totalSplits += 1
        }
    })

    beamPath = newBeamPath
})

print("totalSplits = {totalSplits}")
