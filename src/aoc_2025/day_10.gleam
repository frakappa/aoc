import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Machine {
  Machine(indicators: Int, buttons: List(Int), joltages: List(Int))
}

pub fn parse(input: String) {
  let p =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [indicators, ..buttons_and_joltages] = string.split(line, " ")

      let buttons =
        list.take(buttons_and_joltages, list.length(buttons_and_joltages) - 1)
      let assert Ok(joltages) = list.last(buttons_and_joltages)

      let indicators =
        indicators
        |> string.drop_start(1)
        |> string.drop_end(1)
        |> string.to_graphemes
        |> list.index_fold(0, fn(acc, indicator, index) {
          case indicator {
            "#" -> int.bitwise_or(acc, int.bitwise_shift_left(1, index))
            "." -> acc
            _ -> panic
          }
        })
      let buttons =
        buttons
        |> list.map(fn(button) {
          button
          |> string.drop_start(1)
          |> string.drop_end(1)
          |> string.split(",")
          |> list.fold(0, fn(acc, indicator) {
            let assert Ok(indicator) = int.parse(indicator)

            int.bitwise_or(acc, int.bitwise_shift_left(1, indicator))
          })
        })
      let joltages =
        joltages
        |> string.drop_start(1)
        |> string.drop_end(1)
        |> string.split(",")
        |> list.map(fn(joltage) {
          let assert Ok(joltage) = int.parse(joltage)

          joltage
        })

      Machine(indicators:, buttons:, joltages:)
    })

  pt_1(p)

  p
}

pub fn pt_1(input: List(Machine)) {
  input
  |> list.fold(0, fn(acc, machine) {
    let Machine(indicators:, buttons:, joltages: _) = machine

    let assert Ok(count_presses) =
      list.range(1, list.length(buttons))
      |> list.find(fn(n) {
        buttons
        |> list.combinations(n)
        |> list.find(fn(combination) {
          list.fold(combination, 0, int.bitwise_exclusive_or) == indicators
        })
        |> result.is_ok
      })

    acc + count_presses
  })
}

pub fn pt_2(input: List(Machine)) {
  todo
}
