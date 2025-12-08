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
        const id = self.nodes.length
        self.nodes.push([
            node,
            [] // indexes of connected nodes
        ])
        self.groups.push([id, [id]])
    }

    // returns false if no groups were merged, true if two groups were merged
    func add_edge(i1, i2) {
        self.edges.push((i1, i2))
        self.nodes[i1][1].push(i2)
        self.nodes[i2][1].push(i1)

        // merge the groups for that id
        const (g1id, g1list) = self.groups[i1]
        const (g2id, g2list) = self.groups[i2]

        // check if they are already the same group
        if g1id == g2id {
            return false
        }

        const newGroupMemberList = g1list.concat(g2list)
        const newGroup = [g1id, newGroupMemberList]
        newGroupMemberList.each(->(id) {
            self.groups[id] = newGroup
        })
        return true
    }
}

const points = lines.map(->(line) {
    const (x, y, z) = line.split(",").map(->(s) s.to_number())
    Point(x, y, z)
})

const edges = List.build(->(list) {
    Stopwatch.section("Building permutations", ->{
        let length = points.length
        let i = 0
        let j = 1

        while i < length {
            while j < length {
                list.push((i, j))
                j += 1
            }
            i += 1
            j = i + 1
        }
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

const edgeDistancePairs = Stopwatch.section("Calculating edge lengths", ->{
    edges.map(->(edge) {
        (edge, get_distance_for_edge(edge))
    })
})

const sortedEdges = Stopwatch.section("Sorting edges by length", ->{
    edgeDistancePairs.sort(->(a, b) {
        const (e1, d1) = a
        const (e2, d2) = b
        d1 - d2
    }).map(->(edgeDistancePair) edgeDistancePair[0])
})

const graph = PointGraph()
Stopwatch.section("Adding points to graph", ->{
    points.each(->(point) {
        graph.add_point(point)
    })
})

try Stopwatch.section("Adding edges to graph", ->{
    let group_count = graph.nodes.length
    sortedEdges.each(->(edge, index) {
        const (i1, i2) = edge
        const did_merge_groups = graph.add_edge(i1, i2)

        if did_merge_groups {
            group_count -= 1
        }

        if group_count == 1 {
            const (p1, p2) = (points[i1], points[i2])
            const (x1, x2) = (p1.x, p2.x)
            print("x1 * x2 = {x1 * x2}")
            throw "program completed"
        }
    })
}) catch {}
