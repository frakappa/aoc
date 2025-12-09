import gleam/bool
import gleam/int
import gleam/list
import gleam/string

pub type Point {
  Point(x: Int, y: Int)
}

pub fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(#(x, y)) = string.split_once(line, ",")
    let assert Ok(x) = int.parse(x)
    let assert Ok(y) = int.parse(y)

    Point(x, y)
  })
}

pub fn pt_1(input: List(Point)) {
  let assert Ok(max_area) =
    input
    |> list.combination_pairs
    |> list.map(calculate_area)
    |> list.max(int.compare)

  max_area
}

fn calculate_area(rect: #(Point, Point)) -> Int {
  { int.absolute_value({ rect.1 }.x - { rect.0 }.x) + 1 }
  * { int.absolute_value({ rect.1 }.y - { rect.0 }.y) + 1 }
}

pub type Polygon {
  Polygon(
    horizontal_edges: List(#(Point, Point)),
    vertical_edges: List(#(Point, Point)),
  )
}

pub fn pt_2(input: List(Point)) {
  let polygon = build_polygon(input)

  let assert Ok(max_area) =
    input
    |> list.combination_pairs
    |> list.map(fn(rect) {
      let top_left =
        Point(
          int.min({ rect.0 }.x, { rect.1 }.x),
          int.min({ rect.0 }.y, { rect.1 }.y),
        )
      let top_right =
        Point(
          int.max({ rect.0 }.x, { rect.1 }.x),
          int.min({ rect.0 }.y, { rect.1 }.y),
        )
      let bottom_left =
        Point(
          int.min({ rect.0 }.x, { rect.1 }.x),
          int.max({ rect.0 }.y, { rect.1 }.y),
        )
      let bottom_right =
        Point(
          int.max({ rect.0 }.x, { rect.1 }.x),
          int.max({ rect.0 }.y, { rect.1 }.y),
        )

      let are_vertices_in_polygon =
        is_point_in_polygon(polygon, top_left)
        && is_point_in_polygon(polygon, top_right)
        && is_point_in_polygon(polygon, bottom_left)
        && is_point_in_polygon(polygon, bottom_right)

      let are_edges_in_polygon =
        is_horizontal_edge_in_polygon(polygon, #(top_left, top_right))
        && is_horizontal_edge_in_polygon(polygon, #(bottom_left, bottom_right))
        && is_vertical_edge_in_polygon(polygon, #(top_left, bottom_left))
        && is_vertical_edge_in_polygon(polygon, #(top_right, bottom_right))

      case are_vertices_in_polygon && are_edges_in_polygon {
        True -> calculate_area(rect)
        False -> 0
      }
    })
    |> list.max(int.compare)

  max_area
}

fn build_polygon(input: List(Point)) -> Polygon {
  let assert Ok(first) = list.first(input)
  let assert Ok(last) = list.last(input)

  input
  |> list.window_by_2
  |> list.prepend(#(last, first))
  |> list.fold(Polygon([], []), fn(acc, pair) {
    case pair {
      #(Point(x0, _), Point(x1, _)) if x0 == x1 ->
        Polygon(..acc, vertical_edges: [pair, ..acc.vertical_edges])
      #(Point(_, y0), Point(_, y1)) if y0 == y1 ->
        Polygon(..acc, horizontal_edges: [pair, ..acc.horizontal_edges])
      _ -> acc
    }
  })
}

fn is_point_in_polygon(polygon: Polygon, point: Point) -> Bool {
  use <- bool.guard(is_point_on_edge(polygon, point), True)

  let count_edges_left =
    list.count(polygon.vertical_edges, fn(edge) {
      { edge.0 }.x < point.x
      && int.min({ edge.0 }.y, { edge.1 }.y) < point.y
      && point.y <= int.max({ edge.0 }.y, { edge.1 }.y)
    })
  let count_edges_right =
    list.count(polygon.vertical_edges, fn(edge) {
      { edge.0 }.x > point.x
      && int.min({ edge.0 }.y, { edge.1 }.y) < point.y
      && point.y <= int.max({ edge.0 }.y, { edge.1 }.y)
    })
  let count_edges_up =
    list.count(polygon.horizontal_edges, fn(edge) {
      { edge.0 }.y < point.y
      && int.min({ edge.0 }.x, { edge.1 }.x) < point.x
      && point.x <= int.max({ edge.0 }.x, { edge.1 }.x)
    })
  let count_edges_down =
    list.count(polygon.horizontal_edges, fn(edge) {
      { edge.0 }.y > point.y
      && int.min({ edge.0 }.x, { edge.1 }.x) < point.x
      && point.x <= int.max({ edge.0 }.x, { edge.1 }.x)
    })

  count_edges_left % 2 == 1
  && count_edges_right % 2 == 1
  && count_edges_up % 2 == 1
  && count_edges_down % 2 == 1
}

fn is_point_on_edge(polygon: Polygon, point: Point) -> Bool {
  let is_point_on_horizontal_edge =
    list.any(polygon.horizontal_edges, fn(edge) {
      { edge.0 }.y == point.y
      && int.min({ edge.0 }.x, { edge.1 }.x) <= point.x
      && point.x <= int.max({ edge.0 }.x, { edge.1 }.x)
    })
  let is_point_on_vertical_edge =
    list.any(polygon.vertical_edges, fn(edge) {
      { edge.0 }.x == point.x
      && int.min({ edge.0 }.y, { edge.1 }.y) <= point.y
      && point.y <= int.max({ edge.0 }.y, { edge.1 }.y)
    })

  is_point_on_horizontal_edge || is_point_on_vertical_edge
}

fn is_horizontal_edge_in_polygon(
  polygon: Polygon,
  edge: #(Point, Point),
) -> Bool {
  let #(left, right) = case { edge.0 }.x < { edge.1 }.x {
    True -> #(edge.0, edge.1)
    False -> #(edge.1, edge.0)
  }

  let count =
    list.count(polygon.vertical_edges, fn(other) {
      left.x < { other.0 }.x
      && { other.0 }.x < right.x
      && int.min({ other.0 }.y, { other.1 }.y) < left.y
      && left.y < int.max({ other.0 }.y, { other.1 }.y)
    })

  count == 0
}

fn is_vertical_edge_in_polygon(polygon: Polygon, edge: #(Point, Point)) -> Bool {
  let #(up, down) = case { edge.0 }.y < { edge.1 }.y {
    True -> #(edge.0, edge.1)
    False -> #(edge.1, edge.0)
  }

  let count =
    list.count(polygon.horizontal_edges, fn(other) {
      up.y < { other.0 }.y
      && { other.0 }.y < down.y
      && int.min({ other.0 }.x, { other.1 }.x) < up.x
      && up.x < int.max({ other.0 }.x, { other.1 }.x)
    })

  count == 0
}
