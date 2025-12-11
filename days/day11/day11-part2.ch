#!/usr/local/bin/charly

const HashMap = import "./hashmap.ch"

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
    property total_paths_to_here
    property total_paths_with_fft
    property total_paths_with_dac
    property total_paths_with_both

    func to_tuple {
        (name, total_paths_to_here, total_paths_with_fft, total_paths_with_dac, total_paths_with_both)
    }
}

const collapsed_waves = HashMap().also(->(map) {
    map.set("svr", Wave("svr", 1, 0, 0, 0))
})

let wavefront = HashMap().also(->(map) map.set("svr", true)).keys()

func solve {
    loop {
        const next_wavefront = HashMap()

        print(wavefront)
        // prompt("")

        wavefront.each(->(wave) {
            const in_waves = device_in_connections.at(wave)
            const can_be_collapsed = in_waves.all(->(in_name) collapsed_waves.contains(in_name))

            if can_be_collapsed {

                // collapse the wave
                const collapsed_wave = Wave(wave, 0, 0, 0, 0)
                const collapsed_in_waves = in_waves.map(->(in_name) collapsed_waves.at(in_name))
                collapsed_wave.total_paths_to_here = collapsed_in_waves.map(->(wave) wave.total_paths_to_here).sum()
                collapsed_wave.total_paths_with_fft = collapsed_in_waves.map(->(wave) wave.total_paths_with_fft).sum()
                collapsed_wave.total_paths_with_dac = collapsed_in_waves.map(->(wave) wave.total_paths_with_dac).sum()
                collapsed_wave.total_paths_with_both = collapsed_in_waves.map(->(wave) wave.total_paths_with_both).sum()
                collapsed_waves.set(wave, collapsed_wave)

                if wave == "fft" {
                    collapsed_wave.total_paths_with_fft = collapsed_wave.total_paths_to_here
                }

                if wave == "dac" {
                    collapsed_wave.total_paths_with_dac = collapsed_wave.total_paths_to_here
                }

                if collapsed_wave.total_paths_with_both == 0 {
                    const with_fft = collapsed_wave.total_paths_with_fft
                    const with_dac = collapsed_wave.total_paths_with_dac
                    collapsed_wave.total_paths_with_both = with_fft.min(with_dac)
                }

                print("collapsed", collapsed_wave.to_tuple())

                // propagate out waves
                device_out_connections.at(wave).each(->(out_name) {
                    next_wavefront.set(out_name, true)
                })
            } else {
                next_wavefront.set(wave, true)
            }
        })

        if next_wavefront.entries().empty() {
            return collapsed_waves.at("out")
        }

        wavefront = next_wavefront.keys()
    }
}

const out_wave = solve()
print(out_wave.to_tuple())
print("total paths with both fft and dac =", out_wave.total_paths_with_both)



/*
svr 1 0 0 0

bbb ? ? ? ? aaa ? ? ? ?

bbb 1 0 0 0 aaa 1 0 0 0

tty ? ? ? ? fft ? ? ? ?

tty 1 0 0 0 fft 2 2 0 0

ddd ? ? ? ? ccc ? ? ? ?

ddd ? ? ? ? ccc 3 2 0 0

ddd ? ? ? ? eee ? ? ? ?

ddd 4 2 0 0 eee 3 2 0 0

hub ? ? ? ? dac ? ? ? ?

hub 4 2 0 0 dac 3 2 3 2

fff ? ? ? ?

fff 7 4 3 2

ggg ? ? ? ? hhh ? ? ? ?

ggg 7 4 3 2 hhh 7 4 3 2

out 14 8 6 4
*/
