#!/usr/local/bin/charly

import hashmap as HashMap
import "./parse-input.ch" as parse_input

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const lines = readfile(input_path).lines()

const (presents, regions) = parse_input(lines)

const valid_regions = regions.filter(->(region, region_id) {
    const (size, present_ids) = region
    const (x, y) = size

    const gridArea = x * y
    const minimumRequiredArea = present_ids.map(->(count, i) {
        count * presents[i].map(->(r) [...r].sum()).sum()
    }).sum()

    const enoughArea = gridArea >= minimumRequiredArea
    enoughArea
})

print("there are {valid_regions.length} regions that might fit the presents")
