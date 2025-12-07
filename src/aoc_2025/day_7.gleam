import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import gleam/string

pub fn parse(input: String) {
  let assert [first, ..rest] = string.split(input, "\n")

  let assert Ok(starting_pos) =
    first
    |> string.to_graphemes
    |> list.index_map(fn(grapheme, index) { #(grapheme, index) })
    |> list.find_map(fn(tup) {
      case tup {
        #("S", index) -> Ok(index)
        _ -> Error(Nil)
      }
    })

  let splitters =
    rest
    |> list.map(fn(line) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(grapheme, index) { #(grapheme, index) })
      |> list.filter_map(fn(tup) {
        case tup {
          #("^", index) -> Ok(index)
          _ -> Error(Nil)
        }
      })
    })

  let p = #(starting_pos, splitters)

  pt_1(p)
  pt_2(p)

  p
}

pub fn pt_1(input: #(Int, List(List(Int)))) {
  let #(starting_pos, splitters) = input

  let acc = #(set.new() |> set.insert(starting_pos), 0)
  let acc =
    list.fold(splitters, acc, fn(acc, row) {
      list.fold(row, acc, fn(acc, position) {
        let #(beams, count) = acc

        case set.contains(acc.0, position) {
          True -> {
            let beams =
              beams
              |> set.delete(position)
              |> set.insert(position - 1)
              |> set.insert(position + 1)
            let count = count + 1

            #(beams, count)
          }
          False -> acc
        }
      })
    })

  acc.1
}

pub fn pt_2(input: #(Int, List(List(Int)))) {
  let #(starting_pos, splitters) = input

  let acc = dict.new() |> dict.insert(starting_pos, 1)
  let acc =
    list.fold(splitters, acc, fn(acc, row) {
      list.fold(row, acc, fn(acc, position) {
        let prev = acc |> dict.get(position) |> result.unwrap(0)

        acc
        |> dict.delete(position)
        |> dict.upsert(position - 1, fn(value) {
          value |> option.unwrap(0) |> int.add(prev)
        })
        |> dict.upsert(position + 1, fn(value) {
          value |> option.unwrap(0) |> int.add(prev)
        })
      })
    })

  acc |> dict.values |> int.sum
}
