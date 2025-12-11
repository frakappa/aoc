import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string

pub type Graph =
  Dict(String, List(String))

pub fn parse(input: String) {
  let p =
    input
    |> string.split("\n")
    |> list.fold(dict.new(), fn(acc, line) {
      let assert Ok(#(node, neighbors)) = string.split_once(line, ": ")

      dict.insert(acc, node, string.split(neighbors, " "))
    })

  pt_1(p)
  pt_2(p)

  p
}

pub fn pt_1(input: Graph) {
  count_paths(input, "you", "out")
}

pub fn pt_2(input: Graph) {
  {
    count_paths(input, "svr", "fft")
    * count_paths(input, "fft", "dac")
    * count_paths(input, "dac", "out")
  }
  + {
    count_paths(input, "svr", "dac")
    * count_paths(input, "dac", "fft")
    * count_paths(input, "fft", "out")
  }
}

fn count_paths(graph: Graph, start: String, end: String) -> Int {
  do_count_paths(graph, start, end, dict.new()).0
}

fn do_count_paths(
  graph: Graph,
  start: String,
  end: String,
  memo: Dict(#(String, String), Int),
) -> #(Int, Dict(#(String, String), Int)) {
  case dict.get(memo, #(start, end)) {
    Ok(count) -> #(count, memo)
    Error(_) ->
      case start == end {
        True -> #(1, memo)
        False -> {
          let #(count, memo) =
            graph
            |> dict.get(start)
            |> result.unwrap([])
            |> list.fold(#(0, memo), fn(acc, neighbor) {
              let #(count, memo) = do_count_paths(graph, neighbor, end, acc.1)

              #(acc.0 + count, memo)
            })

          #(count, dict.insert(memo, #(start, end), count))
        }
      }
  }
}
