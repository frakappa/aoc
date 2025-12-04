import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(#(Int, Int)) {
  let parsed =
    input
    |> string.split("\n")
    |> list.filter_map(fn(line) {
      case line {
        "L" <> amount -> {
          let assert Ok(amount) = int.parse(amount)

          Ok(#(-1, amount))
        }
        "R" <> amount -> {
          let assert Ok(amount) = int.parse(amount)

          Ok(#(1, amount))
        }
        _ -> Error(Nil)
      }
    })

  pt_1(parsed)
  pt_2(parsed)

  parsed
}

pub fn pt_1(input: List(#(Int, Int))) {
  let acc =
    input
    |> list.fold(#(50, 0), fn(acc, rotation) {
      let #(dial, count) = acc
      let #(direction, amount) = rotation

      let dial = { dial + direction * amount } % 100
      let count = case dial {
        0 -> count + 1
        _ -> count
      }

      #(dial, count)
    })

  acc.1
}

pub fn pt_2(input: List(#(Int, Int))) {
  let acc =
    input
    |> list.fold(#(50, 0), fn(acc, rotation) {
      let #(dial, count) = acc
      let #(direction, amount) = rotation

      let count = count + { { 100 + direction * dial } % 100 + amount } / 100
      let dial = { dial + direction * amount } % 100

      #(dial, count)
    })

  acc.1
}
