import gleam/int
import gleam/list
import gleam/string

type Operation =
  fn(Int, Int) -> Int

pub fn parse(input: String) {
  let lines = string.split(input, "\n")

  let number_rows = list.take(lines, list.length(lines) - 1)
  let assert Ok(operations) = list.last(lines)

  let operations = parse_operations(operations, [])

  let p = #(number_rows, operations)

  pt_1(p)
  pt_2(p)

  p
}

pub fn pt_1(input: #(List(String), List(Operation))) {
  let #(number_rows, operations) = input

  let number_rows = list.map(number_rows, parse_numbers(_, []))

  number_rows
  |> list.transpose
  |> list.zip(operations)
  |> list.fold(0, fn(acc, tup) {
    let #(numbers, operation) = tup

    let assert Ok(result) = list.reduce(numbers, operation)

    acc + result
  })
}

pub fn pt_2(input: #(List(String), List(Operation))) {
  let #(number_rows, operations) = input

  let number_rows =
    number_rows
    |> list.map(string.to_graphemes)
    |> list.transpose
    |> list.map(fn(number) { number |> string.join("") |> string.trim })
    |> split("", [])
    |> list.map(
      list.map(_, fn(number) {
        let assert Ok(number) = int.parse(number)

        number
      }),
    )

  number_rows
  |> list.zip(operations)
  |> list.fold(0, fn(acc, tup) {
    let #(numbers, operation) = tup

    let assert Ok(res) = list.reduce(numbers, operation)

    acc + res
  })
}

fn split(list: List(a), separator: a, acc: List(List(a))) -> List(List(a)) {
  case list {
    [] -> list.reverse(acc)
    [first, ..rest] if first == separator -> split(rest, separator, acc)
    _ -> {
      let #(chunk, rest) = do_split(list, separator, #([], list))

      split(rest, separator, [chunk, ..acc])
    }
  }
}

fn do_split(
  list: List(a),
  separator: a,
  acc: #(List(a), List(a)),
) -> #(List(a), List(a)) {
  case list {
    [] -> #(list.reverse(acc.0), acc.1)
    [first, ..] if first == separator -> #(list.reverse(acc.0), acc.1)
    [first, ..rest] -> do_split(rest, separator, #([first, ..acc.0], rest))
  }
}

fn parse_numbers(string: String, acc: List(Int)) -> List(Int) {
  case string.trim_start(string) {
    "" -> list.reverse(acc)
    string -> {
      let #(number, rest) = pop_number(string)

      parse_numbers(rest, [number, ..acc])
    }
  }
}

fn pop_number(string: String) -> #(Int, String) {
  do_pop_number(string, #(0, string))
}

fn parse_operations(
  string: String,
  acc: List(fn(Int, Int) -> Int),
) -> List(fn(Int, Int) -> Int) {
  case string.trim_start(string) {
    "" -> list.reverse(acc)
    string ->
      case string.pop_grapheme(string) {
        Ok(#("+", rest)) -> parse_operations(rest, [int.add, ..acc])
        Ok(#("*", rest)) -> parse_operations(rest, [int.multiply, ..acc])
        _ -> panic
      }
  }
}

fn do_pop_number(string: String, acc: #(Int, String)) -> #(Int, String) {
  case string.pop_grapheme(string) {
    Ok(#(grapheme, rest)) ->
      case int.parse(grapheme) {
        Ok(digit) -> do_pop_number(rest, #(acc.0 * 10 + digit, rest))
        Error(_) -> acc
      }
    Error(_) -> acc
  }
}
