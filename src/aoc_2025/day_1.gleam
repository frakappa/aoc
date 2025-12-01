import gleam/bool
import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(#(Int, Int)) {
  input
  |> string.split("\n")
  |> list.filter_map(fn(line) {
    use <- bool.guard(string.is_empty(line), Error(Nil))

    case string.pop_grapheme(line) {
      Ok(#(direction, amount)) -> {
        let direction = case direction {
          "L" -> -1
          "R" -> 1
          _ -> panic
        }
        let assert Ok(amount) = int.parse(amount)

        Ok(#(direction, amount))
      }
      Error(error) -> Error(error)
    }
  })
}

pub fn pt_1(input: List(#(Int, Int))) {
  let acc =
    input
    |> list.fold(#(50, 0), fn(acc, rotation) {
      let #(dial, count) = acc
      let #(direction, amount) = rotation

      let assert Ok(dial) = int.modulo(dial + direction * amount, 100)

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

      let assert Ok(dial) = int.modulo(dial + direction * amount, 100)

      #(dial, count)
    })

  acc.1
}
