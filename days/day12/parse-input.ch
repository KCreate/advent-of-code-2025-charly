import hashmap

export func parse_input(lines) {
    const presents = lines
        .takeFirst(30)
        .inGroupsOf(5)
        .map(->(lines) {
            lines
                .dropLast()
                .takeLast(3)
                .map(->(line) {
                    let (a, b, c) = line.split("")
                    a = a == "#" ? 1 : 0
                    b = b == "#" ? 1 : 0
                    c = c == "#" ? 1 : 0
                    (a, b, c)
                })
        })

    const regions = List.build(->(list) {
        lines
            .dropFirst(30)
            .each(->(region_line) {
                const parts = region_line.split(":")
                const size = parts.first().split("x").map(->(s) s.to_number())
                const present_ids = parts.last().dropFirst().split(" ").map(->(s) s.to_number())
                list.push(((...size), present_ids))
            })
    })

    return (presents, regions)
}
