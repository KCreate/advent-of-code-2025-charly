#!/usr/local/bin/charly

import hashmap as HashMap

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const lines = readfile(input_path).lines()

print("Advent of Code 2025 completed! :)")
