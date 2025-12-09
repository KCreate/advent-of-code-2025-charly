#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const lines = readfile(input_path).lines()

const corners = lines.map(->(line) {
    const (x, y) = line.split(",")
    (x.to_number(), y.to_number())
})

const minCornerX = corners.findMinBy(->(c) c[0])[0]
const minCornerY = corners.findMinBy(->(c) c[1])[1]
const maxCornerX = corners.findMaxBy(->(c) c[0])[0]
const maxCornerY = corners.findMaxBy(->(c) c[1])[1]

const edges = corners.adjacentPairs().concat([(
    corners.last(),
    corners.first()
)])

func rectangle_area(rectangle) {
    const (c1, c2) = rectangle
    const (x1, y1) = c1
    const (x2, y2) = c2
    const lengthX = (x1 - x2).abs() + 1
    const lengthY = (y1 - y2).abs() + 1
    return lengthX * lengthY
}

func rectangle_contains_point_no_border(rectangle, point) {
    const (c1, c2) = rectangle
    const (x1, y1) = c1
    const (x2, y2) = c2
    const (px, py) = point
    return px > x1 && px < x2 && py > y1 && py < y2
}

func rectangle_contains_point_with_border(rectangle, point) {
    const (c1, c2) = rectangle
    const (x1, y1) = c1
    const (x2, y2) = c2
    const (px, py) = point
    return px >= x1 && px <= x2 && py >= y1 && py <= y2
}

func min_point(line) {
    const (p1, p2) = line
    const (p1x, p1y) = p1
    const (p2x, p2y) = p2
    (
        p1x.min(p2x),
        p1y.min(p2y)
    )
}

func max_point(line) {
    const (p1, p2) = line
    const (p1x, p1y) = p1
    const (p2x, p2y) = p2
    (
        p1x.max(p2x),
        p1y.max(p2y)
    )
}

func lines_intersect(line1, line2) {
    const (minX1, minY1) = min_point(line1)
    const (maxX1, maxY1) = max_point(line1)

    const (minX2, minY2) = min_point(line2)
    const (maxX2, maxY2) = max_point(line2)

    const noIntersection = minX1 >= maxX2 || maxX1 <= minX2 || minY1 >= maxY2 || maxY1 <= minY2
    return !noIntersection
}

func dump_grid(rectangle) {
    const limitX = maxCornerX + 1
    const limitY = maxCornerY + 1

    let x = 0
    let y = 0
    while y < limitY {
        while x < limitX {
            const is_corner = corners.findBy(->(c) c == (x, y)) != null
            const is_rectangle = rectangle_contains_point_with_border(rectangle, (x, y))

            if is_corner {
                write("O")
            } else if is_rectangle {
                write("x")
            } else {
                write(" ")
            }

            x += 1
        }
        print()
        x = 0
        y += 1
    }
}

const rectangles = corners
    .unidirectionalPermutations()
    .map(->(rectangle) {
        const (c1, c2) = rectangle
        const (x1, y1) = c1
        const (x2, y2) = c2

        const minX = x1.min(x2)
        const minY = y1.min(y2)
        const maxX = x1.max(x2)
        const maxY = y1.max(y2)

        return (
            (minX, minY),
            (maxX, maxY)
        )
    })

    .sort(->(a, b) {
        const a_area = rectangle_area(a)
        const b_area = rectangle_area(b)
        b_area - a_area
    })

    .also(->(r) print("total rectangles = {r.length}"))

const queue = rectangles.reverse()
while queue.notEmpty() {
    const rectangle = queue.pop()

    const filter1 =
        corners.any(->(point) {
            rectangle_contains_point_no_border(rectangle, point)
        })
    if filter1 continue

    const filter2 =
        edges.any(->(edge) {
            lines_intersect(rectangle, edge)
        })
    if filter2 continue

    print("Largest rectangle:")
    const area = rectangle_area(rectangle)
    print(rectangle, area)
    dump_grid(rectangle)

    break
}

