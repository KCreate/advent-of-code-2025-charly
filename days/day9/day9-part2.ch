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

const polygon_lines = corners.adjacentPairs().concat([(
    corners.last(),
    corners.first()
)])

func polygon_lines_cross(line1, line2) {
    const (l1c1, l1c2) = line1
    const (l2c1, l2c2) = line2

    const l1_vertical = l1c1[0] == l1c2[0]
    const l2_vertical = l2c1[0] == l2c2[0]

    if l1_vertical && l2_vertical return false
    if !l1_vertical && !l2_vertical return false

    if l2_vertical {
        return polygon_lines_cross(line2, line1)
    }

    const own_x = l1c1[0]
    const own_y_lo = l1c1[1].min(l1c2[1])
    const own_y_hi = l1c1[1].max(l1c2[1])
    const other_y = l2c1[1]
    const other_x_lo = l2c1[0].min(l2c2[0])
    const other_x_hi = l2c1[0].max(l2c2[0])

    const x_match = own_x > other_x_lo && own_x < other_x_hi
    const y_match = other_y > own_y_lo && other_y < own_y_hi
    x_match && y_match
}

func point_is_on_line(point, line) {
    const (px, py) = point
    const (c1, c2) = line
    const (x1, y1) = c1
    const (x2, y2) = c2

    const line_is_vertical = x1 == x2

    if line_is_vertical {
        return px == x1 && py >= y1.min(y2) && py <= y1.max(y2)
    } else {
        return py == y1 && px >= x1.min(x2) && px <= x1.max(x2)
    }
}

// ray-casting point-in-polygon test
// implemented with the help of ChatGPT
func point_is_in_polygon(point, polygon) {
    let inside = false
    let i = 0
    const limit = polygon.length
    while i < limit {
        const line = polygon[i]
        const (px, py) = point
        const (c1, c2) = line
        const (x1, y1) = c1
        const (x2, y2) = c2

        if point_is_on_line(point, line) {
            return true
        }

        const crosses_scanline = y1 > py != y2 > py
        if crosses_scanline {
            const dy_total = (y2 - y1)
            const dy_to_point = (py - y1)
            const t = dy_to_point / dy_total
            const x_intersect = x1 + t * (x2 - x1)

            if px < x_intersect {
                inside = !inside
            }
        }

        i += 1
    }

    return inside
}

func get_rectangle_corners(rectangle) {
    const (c1, c2) = rectangle
    const (x1, y1) = c1
    const (x2, y2) = c2

    const minX = x1.min(x2)
    const minY = y1.min(y2)
    const maxX = x1.max(x2)
    const maxY = y1.max(y2)

    (
        (minX, minY),
        (maxX, minY),
        (maxX, maxY),
        (minX, maxY)
    )
}

func get_rectangle_lines(rectangle) {
    const (n1, n2, n3, n4) = get_rectangle_corners(rectangle)
    return [
        ((n1), (n2)),
        ((n2), (n3)),
        ((n3), (n4)),
        ((n4), (n1))
    ]
}

const rectangleAreaPairs = corners
    .unidirectionalPermutations()
    .map(->(corners) {
        const (c1, c2) = corners
        const (x1, y1) = c1
        const (x2, y2) = c2

        const lengthX = (x1 - x2).abs() + 1
        const lengthY = (y1 - y2).abs() + 1

        const area = lengthX * lengthY
        ((c1, c2), area)
    })
    .sort(->(a, b) {
        a[1] - b[1]
    })

func find_largest_rectangle {
    while rectangleAreaPairs.notEmpty() {
        const pair = rectangleAreaPairs.pop()
        const (rectangle, area) = pair

        const rectangle_lines = get_rectangle_lines(rectangle)
        const any_check_failed = rectangle_lines.any(->(line) {
            const crossed_any_polygon_line = polygon_lines.any(->(pline) {
                polygon_lines_cross(line, pline)
            })
            if crossed_any_polygon_line return true

            const (c1, c2) = line
            if !point_is_in_polygon(c1, polygon_lines) return true

            return false
        })
        if any_check_failed continue

        return pair
    }
}

const (largestRectangle, area) = find_largest_rectangle()
print("largest rectangle =", largestRectangle)
print("largest size =", area)
