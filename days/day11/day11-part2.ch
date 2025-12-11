#!/usr/local/bin/charly

import hashmap as HashMap

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const lines = readfile(input_path).lines()

const devices = []
const device_out_connections = HashMap()
const device_in_connections = HashMap()

lines.each(->(line) {
    const entries = line.split(" ")
    const device = entries.first().dropLast()
    const out_connections = entries.dropFirst()
    devices.push(device)
    device_out_connections.set(device, out_connections)
    device_in_connections.set(device, [])
})

device_in_connections.set("svr", ["svr"])
device_in_connections.set("out", [])
device_out_connections.set("out", [])

devices.each(->(device) {
    const outconns = device_out_connections.at(device)
    outconns.each(->(out) {
        device_in_connections.at(out).push(device)
    })
})

class Wave {
    property name
    property to_here
    property with_fft
    property with_dac
    property with_both
}

const collapsed_waves = HashMap().also(->(map) {
    map.set("svr", Wave("svr", 1, 0, 0, 0))
})

let wavefront = HashMap().also(->(map) map.set("svr", true)).keys()

while wavefront.notEmpty() {
    const next_wavefront = HashMap()

    wavefront.each(->(wave) {
        const in_waves = device_in_connections.at(wave)
        const can_be_collapsed = in_waves.all(->(in_name) collapsed_waves.contains(in_name))

        if can_be_collapsed {
            const collapsed_wave = Wave(wave, 0, 0, 0, 0)
            const collapsed_in_waves = in_waves.map(->(in_name) collapsed_waves.at(in_name))
            collapsed_wave.to_here = collapsed_in_waves.map(->(wave) wave.to_here).sum()
            collapsed_wave.with_fft = collapsed_in_waves.map(->(wave) wave.with_fft).sum()
            collapsed_wave.with_dac = collapsed_in_waves.map(->(wave) wave.with_dac).sum()
            collapsed_wave.with_both = collapsed_in_waves.map(->(wave) wave.with_both).sum()
            collapsed_waves.set(wave, collapsed_wave)

            if wave == "fft" collapsed_wave.with_fft = collapsed_wave.to_here
            if wave == "dac" collapsed_wave.with_dac = collapsed_wave.to_here

            if collapsed_wave.with_both == 0 {
                const with_fft = collapsed_wave.with_fft
                const with_dac = collapsed_wave.with_dac
                collapsed_wave.with_both = with_fft.min(with_dac)
            }

            device_out_connections.at(wave).each(->(out_name) {
                next_wavefront.set(out_name, true)
            })
        } else {
            next_wavefront.set(wave, true)
        }
    })

    wavefront = next_wavefront.keys()
}

const out_wave = collapsed_waves.at("out")
print("total paths with both fft and dac =", out_wave.with_both)
