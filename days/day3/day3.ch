#!/usr/local/bin/charly

if ARGV.length < 2 {
  print("Missing filepath")
  exit(1)
}

const input_path = ARGV[1]
const input = readfile(input_path)

const amountOfBatteriesToTurnOn = 12

func applyActivationRecord(bank, record) {
    assert bank.length == record.length

    const activatedBatteries = bank.filter(->(e, i) record[i])
    const finalNumber = activatedBatteries.join("").to_number()

    return finalNumber
}

const banks = input
    .split("\n")
    .map(->(bank) {
        bank.split("").map(->(battery) battery.to_number())
    })
    .parallelMap(->(bank) {
        const activationRecord = List.create(bank.length, false)

        amountOfBatteriesToTurnOn.times(->{
            const potentialFlips = activationRecord.mapNotNull(->(s, i) {
                if s return null

                const newRecord = activationRecord.copy()
                newRecord[i] = true

                const newNumber = applyActivationRecord(bank, newRecord)
                return (newNumber, i)
            })

            const (newNumber, flipIndex) = potentialFlips.findMaxBy(->(e) e[0])
            activationRecord[flipIndex] = true
        })

        applyActivationRecord(bank, activationRecord)
    })

const finalJoltage = banks.sum()
print(finalJoltage)
