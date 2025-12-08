import gleam/bool
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub type Point {
  Point(x: Int, y: Int, z: Int)
}

fn get_distance(point_a: Point, point_b: Point) -> Float {
  let diff_x = int.to_float(point_b.x - point_a.x)
  let diff_y = int.to_float(point_b.y - point_a.y)
  let diff_z = int.to_float(point_b.z - point_a.z)

  let assert Ok(dist) =
    float.square_root(diff_x *. diff_x +. diff_y *. diff_y +. diff_z *. diff_z)

  dist
}

pub fn parse(input: String) {
  let p =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [x, y, z] = string.split(line, ",")

      let assert Ok(x) = int.parse(x)
      let assert Ok(y) = int.parse(y)
      let assert Ok(z) = int.parse(z)

      Point(x, y, z)
    })

  pt_1(p)
  pt_2(p)

  p
}

pub fn pt_1(input: List(Point)) {
  input
  |> list.combination_pairs
  |> list.map(fn(pair) { #(pair, get_distance(pair.0, pair.1)) })
  |> list.sort(fn(a, b) { float.compare(a.1, b.1) })
  |> list.fold_until(#(dict.new(), 1000), fn(acc, tup) {
    let #(graph, remaining) = acc

    use <- bool.guard(remaining == 0, list.Stop(acc))

    let #(#(point_a, point_b), _) = tup

    let neighbors = graph |> dict.get(point_a) |> result.unwrap(set.new())
    case set.contains(neighbors, point_b) {
      True -> list.Continue(acc)
      False -> {
        let graph =
          graph
          |> dict.upsert(point_a, fn(set) {
            set |> option.unwrap(set.new()) |> set.insert(point_b)
          })
          |> dict.upsert(point_b, fn(set) {
            set |> option.unwrap(set.new()) |> set.insert(point_a)
          })

        list.Continue(#(graph, remaining - 1))
      }
    }
  })
  |> fn(acc) { acc.0 }
  |> get_connected_components
  |> list.sort(fn(a, b) { int.compare(b, a) })
  |> list.take(3)
  |> list.fold(1, int.multiply)
}

pub fn pt_2(input: List(Point)) {
  input
  |> list.combination_pairs
  |> list.map(fn(pair) { #(pair, get_distance(pair.0, pair.1)) })
  |> list.sort(fn(a, b) { float.compare(a.1, b.1) })
  |> list.fold_until(#(dict.new(), set.new(), 0), fn(acc, tup) {
    let #(graph, connected, _) = acc
    let #(#(point_a, point_b), _) = tup

    use <- bool.lazy_guard(set.size(connected) == 1000, fn() {
      case list.length(get_connected_components(graph)) == 1 {
        True -> list.Stop(acc)
        False -> connect(graph, connected, point_a, point_b, acc)
      }
    })

    connect(graph, connected, point_a, point_b, acc)
  })
  |> fn(acc) { acc.2 }
}

fn connect(
  graph: Dict(Point, Set(Point)),
  connected: Set(Point),
  point_a: Point,
  point_b: Point,
  acc: #(Dict(Point, Set(Point)), Set(Point), Int),
) -> list.ContinueOrStop(#(Dict(Point, Set(Point)), Set(Point), Int)) {
  let neighbors = graph |> dict.get(point_a) |> result.unwrap(set.new())
  case set.contains(neighbors, point_b) {
    True -> list.Continue(acc)
    False -> {
      let graph =
        graph
        |> dict.upsert(point_a, fn(set) {
          set |> option.unwrap(set.new()) |> set.insert(point_b)
        })
        |> dict.upsert(point_b, fn(set) {
          set |> option.unwrap(set.new()) |> set.insert(point_a)
        })
      let connected = connected |> set.insert(point_a) |> set.insert(point_b)

      list.Continue(#(graph, connected, point_a.x * point_b.x))
    }
  }
}

fn get_connected_components(graph: Dict(Point, Set(Point))) -> List(Int) {
  let acc =
    graph
    |> dict.keys
    |> list.fold(#(set.new(), []), fn(acc, point_a) {
      let #(visited, components) = acc

      case set.contains(visited, point_a) {
        True -> acc
        False -> {
          let #(visited, component) = dfs(graph, point_a, visited)

          #(visited, [component, ..components])
        }
      }
    })

  acc.1
}

fn dfs(
  graph: Dict(Point, Set(Point)),
  point_a: Point,
  visited: Set(Point),
) -> #(Set(Point), Int) {
  case set.contains(visited, point_a) {
    True -> #(visited, 0)
    False -> {
      let visited = set.insert(visited, point_a)

      graph
      |> dict.get(point_a)
      |> result.unwrap(set.new())
      |> set.fold(#(visited, 1), fn(acc, point_b) {
        let #(visited, component) = dfs(graph, point_b, acc.0)

        #(visited, acc.1 + component)
      })
    }
  }
}
