if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_file_path = ARGV[1]

const input = readfile(input_file_path)

class Dial {
  property limit = 100
  property dial = 50
  property total_zeroes = 0

  func turn(dir, count) {
    count.times(->@click(dir))
  }

  func click(dir) {
    switch dir {
      case "L" {
        @dial -= 1
      }
      case "R" {
        @dial += 1
      }
    }

    if @dial == @limit {
      @dial = 0
    }

    if @dial < 0 {
      @dial += @limit
    }

    if @dial == 0 {
      @total_zeroes += 1
    }
  }
}

const dial = Dial()

const operations = input
  .split("\n")
  .map(->(line) {
    const dir = line.substring(0, 1)
    const count = line.substring(1).to_number()
    return (dir, count)
  })

operations.each(->(op) {
  const (dir, count) = op
  dial.turn(dir, count)
})

print("dial: {dial.dial}")
print("total_zeroes: {dial.total_zeroes}")
