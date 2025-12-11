#!/usr/local/bin/charly

const HashMap = import "./hashmap.ch"

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

print("digraph G \{")
device_connections.each(->(entry) {
    const (device, out) = entry
    out.each(->(n) {
        print("{device} -> {n};")
    })
})
print("}")
