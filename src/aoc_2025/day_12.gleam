import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) {
  let assert Ok(regions) = list.last(string.split(input, "\n\n"))

  regions
  |> string.split("\n")
  |> list.map(fn(region) {
    let assert Ok(#(size, quantities)) = string.split_once(region, ": ")

    let assert Ok(#(width, height)) = string.split_once(size, "x")
    let assert Ok(width) = int.parse(width)
    let assert Ok(height) = int.parse(height)

    let quantities =
      quantities
      |> string.split(" ")
      |> list.map(fn(quantity) {
        let assert Ok(quantity) = int.parse(quantity)

        quantity
      })

    #(width, height, quantities)
  })
}

pub fn pt_1(input: List(#(Int, Int, List(Int)))) {
  list.count(input, fn(region) {
    let #(width, height, quantities) = region

    width * height >= int.sum(quantities) * 9
  })
}

pub fn pt_2(_input: List(#(Int, Int, List(Int)))) {
  "Merry Christmas!"
}
