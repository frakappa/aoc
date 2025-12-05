import gleam/int
import gleam/list
import gleam/order
import gleam/string

pub type Tree {
  EmptyTree
  Tree(interval: #(Int, Int), max: Int, left: Tree, right: Tree)
}

fn insert(tree: Tree, interval: #(Int, Int)) -> Tree {
  case tree {
    EmptyTree -> Tree(interval, interval.1, EmptyTree, EmptyTree)
    Tree(interval: #(l, _), max:, left:, right:) -> {
      let max = int.max(max, interval.1)

      case interval.0 < l {
        True -> Tree(..tree, max:, left: insert(left, interval))
        False -> Tree(..tree, max:, right: insert(right, interval))
      }
    }
  }
}

fn is_in_range(tree: Tree, x: Int) -> Bool {
  case tree {
    EmptyTree -> False
    Tree(interval:, max: _, left:, right:) ->
      case interval.0 <= x && x <= interval.1 {
        True -> True
        False ->
          case left {
            Tree(interval: _, max:, left: _, right: _) if max > x ->
              is_in_range(left, x)
            _ ->
              case right {
                Tree(interval: _, max: _, left: _, right: _) ->
                  is_in_range(right, x)
                _ -> False
              }
          }
      }
  }
}

pub fn parse(input: String) {
  let assert Ok(#(ranges, ingredients)) = string.split_once(input, "\n\n")

  let ranges =
    ranges
    |> string.split("\n")
    |> list.map(fn(range) {
      let assert Ok(#(l, r)) = string.split_once(range, "-")
      let assert Ok(l) = int.parse(l)
      let assert Ok(r) = int.parse(r)

      #(l, r)
    })

  let ingredients =
    ingredients
    |> string.split("\n")
    |> list.map(fn(ingredient) {
      let assert Ok(ingredient) = int.parse(ingredient)

      ingredient
    })

  let p = #(ranges, ingredients)

  pt_1(p)
  pt_2(p)

  p
}

pub fn pt_1(input: #(List(#(Int, Int)), List(Int))) {
  let #(ranges, ingredients) = input

  let tree = list.fold(ranges, EmptyTree, insert)

  list.count(ingredients, is_in_range(tree, _))
}

pub fn pt_2(input: #(List(#(Int, Int)), List(Int))) {
  let #(ranges, _) = input

  let ranges =
    list.sort(ranges, fn(left, right) {
      order.break_tie(
        int.compare(left.0, right.0),
        int.compare(left.1, right.1),
      )
    })

  let acc =
    list.fold(ranges, #(0, -1), fn(acc, range) {
      let #(res, prev) = acc
      let #(l, r) = range

      let l = int.max(l, prev)

      #(res + int.max(r - l + 1, 0), int.max(prev, r + 1))
    })

  acc.0
}
