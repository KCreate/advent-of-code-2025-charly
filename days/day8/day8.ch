#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const lines = readfile(input_path).lines()

const positions = lines.map(->(line) {
    line.split(",").map(->(n) n.to_number())
})

class Graph {
    property nodes = []
    property edges = []
    property groups = []
    property distanceFn = null
    property cached_node_distances = []
    property cached_node_outgoing_edges = []

    func constructor(@distanceFn) {}

    func cache_distances {
        const permutations = []
        nodes.each(->(n1, i1) {
            nodes.each(->(n2, i2) {
                if i1 != i2 {
                    permutations.push((i1, i2))
                }
            })
        })

        @cached_node_distances = List.create_with(@nodes.length, ->{
            List.create(@nodes.length)
        })

        permutations.map(->(permutation) {
            const (i1, i2) = permutation
            const distance = @distance_between(i1, i2)

            // [distance, isConnected]
            @cached_node_distances[i1][i2] = [distance, false]
        })
    }

    func add_node(node) {
        @nodes.push(node)
        @nodes.length - 1
        @cached_node_outgoing_edges.push([])
    }

    func add_edge(id1, id2) {
        @edges.push((id1, id2))
        @edges.push((id2, id1))
        @cached_node_distances[id1][id2][1] = true
        @cached_node_distances[id2][id1][1] = true
        @cached_node_outgoing_edges[id1].push(id2)
        @cached_node_outgoing_edges[id2].push(id1)
    }

    func in_same_group(i1, i2) {
        const groupOf1 = @groups.find(->(group) group.contains(i1))
        const groupOf2 = @groups.find(->(group) group.contains(i2))
        if groupOf1 == null || groupOf2 == null return false
        groupOf1 == groupOf2
    }

    func update_groups() {
        @groups.clear()

        // [ [node, hasBeenVisited] ]
        const workList = @nodes.map(->(node, index) [node, index, false])

        loop {

            // find the first entry that hasn't been visited yet
            const unvisited = workList
                .filter(->(entry) {
                    const (node, index, isVisited) = entry
                    !isVisited
                })
                .first()
            if unvisited == null {
                break
            }
            const unvisitedIndex = unvisited[1]

            // find all connected nodes
            const visitQueue = [unvisitedIndex]
            const groupIds = []
            while visitQueue.notEmpty() {
                const id = visitQueue.pop()

                // item already visited
                if (workList[id][2]) {
                    continue
                }

                // mark as visited
                workList[id][2] = true
                groupIds.push(id)

                // collect neighbours
                const neighbours = get_connected_nodes(id)
                neighbours.each(->(neighbourId) {
                    visitQueue.push(neighbourId)
                })
            }

            @groups.push(groupIds)
        }
    }

    func get_connected_nodes(id) {
        @cached_node_outgoing_edges[id]
    }

    func has_edge(id1, id2) {
        const v1 = id1.min(id2)
        const v2 = id1.max(id2)
        @edges.find((v1, v2)) >= 0
    }

    func distance_between(id1, id2) {
        const node1 = @nodes[id1]
        const node2 = @nodes[id2]
        @distanceFn(node1, node2)
    }

    func find_shortest_unconnected_edge() {
        let shortestEdge = null
        let shortestDistance = null

        @cached_node_distances.each(->(row, i1) {
            row.each(->(entry, i2) {
                if entry == null {
                    return
                }
                const (distance, isConnected) = entry
                if isConnected {
                    return
                }

                if shortestDistance == null || distance < shortestDistance {
                    shortestEdge = (i1, i2)
                    shortestDistance = distance
                }
            })
        })

        shortestEdge
    }
}

func vectorDistance(a, b) {
    const (x1, y1, z1) = a
    const (x2, y2, z2) = b

    const (dx, dy, dz) = (
        (x1 - x2).abs(),
        (y1 - y2).abs(),
        (z1 - z2).abs()
    )

    (dx * dx + dy * dy + dz * dz).cbrt()
}

const g = Graph(vectorDistance)
positions.each(->(p) g.add_node(p))
print("caching distances")
g.cache_distances()

let i = 0
loop {
    const shortest_edge = g.find_shortest_unconnected_edge()
    if shortest_edge == null return
    const (i1, i2) = shortest_edge
    const n1 = g.nodes[i1]
    const n2 = g.nodes[i2]

    if !g.in_same_group(i1, n2) {
        g.add_edge(i1, i2)
        g.update_groups()
    }

    print("iteration {i}")
    print("connected {n1} <-> {n2}")
    print("g.groups.length = {g.groups.length}")

    if g.groups.length == 1 {
        print("productOfXCoordinates = {n1[0] * n2[0]}")
        break
    }

    i += 1
}

const groupsSortedBySize = g.groups.copy().sort(->(a, b) b.length - a.length)

const largestThreeGroups = groupsSortedBySize.takeFirst(3)

const sizeProduct = largestThreeGroups.map(->(group) group.length).product()

print("sizeProduct = {sizeProduct}")

