import gleam/bool
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn parse(input: String) {
  let p =
    input
    |> string.trim
    |> string.split("\n")
    |> list.index_fold(set.new(), fn(acc, row, i) {
      row
      |> string.to_graphemes
      |> list.index_fold(acc, fn(acc, col, j) {
        case col {
          "@" -> set.insert(acc, #(i, j))
          _ -> acc
        }
      })
    })

  pt_1(p)
  pt_2(p)

  p
}

pub fn pt_1(input: Set(#(Int, Int))) {
  set.fold(input, 0, fn(acc, roll) {
    case count_neighbors(input, roll) < 4 {
      True -> acc + 1
      False -> acc
    }
  })
}

pub fn pt_2(input: Set(#(Int, Int))) {
  set.size(input) - set.size(set.fold(input, input, flood_delete))
}

fn flood_delete(input: Set(#(Int, Int)), roll: #(Int, Int)) -> Set(#(Int, Int)) {
  use <- bool.guard(!set.contains(input, roll), input)

  case count_neighbors(input, roll) < 4 {
    True ->
      list.fold(get_neighbors(roll), set.delete(input, roll), flood_delete)
    False -> input
  }
}

fn count_neighbors(input: Set(#(Int, Int)), roll: #(Int, Int)) -> Int {
  list.count(get_neighbors(roll), fn(neighbor) { set.contains(input, neighbor) })
}

fn get_neighbors(roll: #(Int, Int)) -> List(#(Int, Int)) {
  let #(i, j) = roll

  [
    #(i - 1, j - 1),
    #(i - 1, j),
    #(i - 1, j + 1),
    #(i, j - 1),
    #(i, j + 1),
    #(i + 1, j - 1),
    #(i + 1, j),
    #(i + 1, j + 1),
  ]
}
