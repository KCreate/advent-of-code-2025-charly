#!/usr/local/bin/charly

import hashmap as HashMap

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const lines = readfile(input_path).lines()

const device_connections = HashMap()

lines.each(->(line) {
    const entries = line.split(" ")
    const device = entries.first().dropLast()
    const out_connections = entries.dropFirst()
    device_connections.set(device, out_connections)
})

const initial_path = ["you"]
const target = "out"
const queue = [initial_path]
const found_paths = []
while queue.notEmpty() {
    const path = queue.pop_front()
    const last = path.last()

    if last == target {
        found_paths.push(path)
        continue
    }

    const out_devices = device_connections.at(last)
    out_devices.each(->(name) {
        queue.push([...path, name])
    })
}

found_paths.each(->(path) {
    print(path)
})

print("found {found_paths.length} paths")

