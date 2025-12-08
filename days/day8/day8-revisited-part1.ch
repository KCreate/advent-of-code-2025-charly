#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const lines = readfile(input_path).lines()

class StringSet {
    property bins
    property bin_count

    func constructor(@bin_count = 256) {
        self.bins = List.create(self.bin_count)
    }

    func add(value) {
        value = "{value}"
        if !self.contains(value) {
            const bin = self.get_bin_for_value(value)
            bin.push(value)
        }
        self
    }

    func contains(value) {
        value = "{value}"
        const bin = self.get_bin_for_value(value)
        bin.find(value) != null
    }

    func remove(value) {
        value = "{value}"
        const bin = self.get_bin_for_value(value)
        const index = bin.find(value)
        if index == null return false
        bin.erase(index)
    }

    func collect {
        self.bins.flatten().filter(->(e) e!= null)
    }

    private func get_bin_for_value(value) {
        const index = self.get_bin_index_for_value(value)
        self.get_or_initialize_bin(index)
    }

    private func get_or_initialize_bin(index) {
        if self.bins[index] == null {
            self.bins[index] = []
        }
        self.bins[index]
    }

    private func get_bin_index_for_value(value) {
        self.hash(value) % self.bin_count
    }

    private func hash(value) {
        value.hashcode
    }
}

class Point {
    property x
    property y
    property z

    func distance_to(other) {
        const (dx, dy, dz) = (
            (self.x - other.x).abs(),
            (self.y - other.y).abs(),
            (self.z - other.z).abs()
        )

        (dx * dx + dy * dy + dz * dz).sqrt()
    }

    func to_string {
        "({self.x}, {self.y}, {self.z})"
    }
}

class PointGraph {
    property nodes = []
    property edges = []
    property groups = []

    func add_point(node) {
        self.nodes.push([
            node,
            [] // indexes of connected nodes
        ])
    }

    func add_edge(i1, i2) {
        self.edges.push((i1, i2))
        self.nodes[i1][1].push(i2)
        self.nodes[i2][1].push(i1)
    }

    func calculate_groups {
        self.groups.clear()

        const workset = StringSet().also(->(workset) {
            self.nodes.each(->(node, index) {
                workset.add("{index}")
            })
        })

        loop {
            const unvisited = workset.collect().first()
            if unvisited == null break

            const visitQueue = [unvisited.to_number()]
            const group = []
            while visitQueue.notEmpty() {
                const id = visitQueue.pop()

                if !workset.contains(id) continue

                workset.remove(id)
                group.push(id)

                // visit neighbours
                const connected_ids = self.nodes[id][1]
                connected_ids.each(->(id) visitQueue.push(id))
            }

            print("finished gruop {self.groups.length}")
            self.groups.push(group)
        }
    }
}

const points = lines.map(->(line) {
    const (x, y, z) = line.split(",").map(->(s) s.to_number())
    Point(x, y, z)
})

const edges = List.build(->(list) {
    const alreadyInserted = StringSet(1024 * 64)

    print("determining edges")
    points.each(->(p1, i1) {
        points.each(->(p2, i2) {
            if i1 != i2 {
                // (2, 3) and (3, 2) are the same edge
                if !alreadyInserted.contains("{i1}.{i2}") && !alreadyInserted.contains("{i2}.{i1}") {
                    list.push((i1, i2))
                    alreadyInserted.add("{i1}.{i2}")
                }
            }
        })
        print("added all edges for ({i1}, *)")
    })
})

func get_distance_for_edge(edge) {
    const (i1, i2) = edge
    const (n1, n2) = (
        points[i1],
        points[i2]
    )
    n1.distance_to(n2)
}

print("sorting edges")
const sortedEdges = edges.sort(->(a, b) {
    const d1 = get_distance_for_edge(a)
    const d2 = get_distance_for_edge(b)
    d1 - d2
})

const graph = PointGraph()
print("adding points")
points.each(->(point) {
    graph.add_point(point)
})

print("adding edges")
sortedEdges.takeFirst(1000).each(->(edge) {
    const (i1, i2) = edge
    graph.add_edge(i1, i2)
})

print("adding calculating groups")
graph.calculate_groups()

const groups = graph.groups
const sortedGroups = groups.sort(->(a, b) b.length - a.length)
const threeLargest = sortedGroups.takeFirst(3)
const productOfGroupSizes = threeLargest.map(->(group) group.length).product()

print("productOfGroupSizes = {productOfGroupSizes}")
