#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const lines = readfile(input_path).lines()

class PointGraph {
    property groups = []

    func constructor(count) {
        @groups = List.create_with(count, ->(i) [i, [i]])
    }

    // returns true if this edge caused two groups to be merged
    // returns false otherwise
    func add_edge(i1, i2) {

        // merge the groups for that id
        const (g1id, g1list) = self.groups[i1]
        const (g2id, g2list) = self.groups[i2]

        // check if they are already the same group
        if g1id == g2id {
            return false
        }

        const newGroupMemberList = g1list.concat(g2list)
        const newGroup = [g1id, newGroupMemberList]

        // update the group references of all points in this group
        newGroupMemberList.each(->(id) {
            self.groups[id] = newGroup
        })
        return true
    }
}

// parse the list of points from the source file
const points = lines
    .map(->(line) {
        line.split(",").map(->(s) s.to_number())
    })

// build a list with all possible edges between all points
// does not include edges where a node points to itself
// (1, 2) and (2, 1) are treated as being identical
const edges = List
    .build(->(list) {
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

// calculate the length of all edges
const edgeDistancePairs = edges
    .map(->(edge) {
        const (i1, i2) = edge
        const (x1, y1, z1) = points[i1]
        const (x2, y2, z2) = points[i2]
        const (dx, dy, dz) = (
            (x1 - x2).abs(),
            (y1 - y2).abs(),
            (z1 - z2).abs()
        )
        const distance = (dx * dx + dy * dy + dz * dz).sqrt()
        (edge, distance)
    })

// sort the list of edges by their distance
const sortedEdges = edgeDistancePairs
    .sort(->(a, b) {
        const (e1, d1) = a
        const (e2, d2) = b
        d1 - d2
    })
    .map(->(edgeDistancePair) edgeDistancePair[0])

// construct the point graph
const graph = PointGraph(points.length)

// add edges to the point graph until the entire graph is a single group
const queue = sortedEdges.reverse()
let group_count = points.length
loop {
    const edge = queue.pop()
    const (i1, i2) = edge
    const did_merge_groups = graph.add_edge(i1, i2)

    // update group count if this edge merged two groups
    if did_merge_groups {
        group_count -= 1
    }

    // coallesced all groups, print the solution to the puzzle
    if group_count == 1 {
        const (p1, p2) = (points[i1], points[i2])
        const (x1, x2) = (p1[0], p2[0])
        print("x1 * x2 = {x1 * x2}")
        break
    }
}

