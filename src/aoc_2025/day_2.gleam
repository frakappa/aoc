import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(#(Int, Int)) {
  let parsed =
    input
    |> string.split(",")
    |> list.map(fn(tup) {
      let assert Ok(tup) = string.split_once(tup, "-")
      let assert Ok(a) = int.parse(tup.0)
      let assert Ok(b) = int.parse(tup.1)

      #(a, b)
    })

  pt_1(parsed)
  pt_2(parsed)

  parsed
}

pub fn pt_1(input: List(#(Int, Int))) {
  input
  |> list.fold(0, fn(acc, tup) {
    let #(l, r) = tup

    let dl = count_digits(l)
    let dr = count_digits(r)

    let l = case dl % 2 {
      0 -> l
      _ -> pow_10(dl)
    }
    let r = case dr % 2 {
      0 -> r
      _ -> pow_10(dr - 1) - 1
    }

    let dlo = pow_10(count_digits(l) / 2) + 1
    let lo = { l + dlo - 1 } / dlo

    let dhi = pow_10(count_digits(r) / 2) + 1
    let hi = r / dhi

    case lo > hi {
      True -> acc
      _ -> {
        let sum = {
          list.range(lo, hi)
          |> list.fold(0, fn(acc, x) {
            acc + x * { pow_10(count_digits(x)) + 1 }
          })
        }

        acc + sum
      }
    }
  })
}

pub fn pt_2(input: List(#(Int, Int))) {
  input
  |> list.fold(0, fn(acc, tup) {
    let #(l, r) = tup

    let llen = count_digits(l)
    let rlen = count_digits(r)

    acc
    + {
      list.range(llen, rlen)
      |> list.fold(0, fn(acc, len) {
        acc
        + {
          let #(configs, good_fn) = case len {
            1 -> #([], good)
            2 -> #([#(2, 1)], good)
            3 -> #([#(3, 1)], good)
            4 -> #([#(4, 1), #(2, 2)], good_2)
            5 -> #([#(5, 1)], good)
            6 -> #([#(6, 1), #(3, 2), #(2, 3)], good_2_3)
            7 -> #([#(7, 1)], good)
            8 -> #([#(8, 1), #(4, 2), #(2, 4)], good_2_4)
            9 -> #([#(9, 1), #(3, 3)], good_3)
            10 -> #([#(10, 1), #(5, 2), #(2, 5)], good_2)
            _ -> panic
          }

          configs
          |> list.fold(0, fn(acc, tup) {
            let #(n, m) = tup

            let y =
              { pow_10({ n - 1 } * m) * pow_10(m) - 1 } / { pow_10(m) - 1 }

            let l = case llen % len {
              0 -> l
              _ -> pow_10(len - 1)
            }
            let r = case rlen % len {
              0 -> r
              _ -> pow_10(len) - 1
            }

            let lo = { l + y - 1 } / y
            let hi = r / y

            case lo > hi {
              True -> acc
              False -> {
                acc
                + {
                  list.range(lo, hi)
                  |> list.fold(0, fn(acc, x) {
                    case good_fn(x) {
                      True -> acc + x * y
                      False -> acc
                    }
                  })
                }
              }
            }
          })
        }
      })
    }
  })
}

fn count_digits(n: Int) -> Int {
  case n {
    _ if n < 10 -> 1
    _ if n < 100 -> 2
    _ if n < 1000 -> 3
    _ if n < 10_000 -> 4
    _ if n < 100_000 -> 5
    _ if n < 1_000_000 -> 6
    _ if n < 10_000_000 -> 7
    _ if n < 100_000_000 -> 8
    _ if n < 1_000_000_000 -> 9
    _ if n < 10_000_000_000 -> 10
    _ -> panic
  }
}

fn pow_10(exp: Int) -> Int {
  case exp {
    0 -> 1
    1 -> 10
    2 -> 100
    3 -> 1000
    4 -> 10_000
    5 -> 100_000
    6 -> 1_000_000
    7 -> 10_000_000
    8 -> 100_000_000
    9 -> 1_000_000_000
    _ -> panic
  }
}

fn good(_: Int) -> Bool {
  True
}

fn good_2(n: Int) -> Bool {
  case n {
    11 | 22 | 33 | 44 | 55 | 66 | 77 | 88 | 99 -> False
    _ -> True
  }
}

fn good_3(n: Int) -> Bool {
  case n {
    111 | 222 | 333 | 444 | 555 | 666 | 777 | 888 | 999 -> False
    _ -> True
  }
}

fn good_2_3(n: Int) -> Bool {
  case n {
    11
    | 22
    | 33
    | 44
    | 55
    | 66
    | 77
    | 88
    | 99
    | 111
    | 222
    | 333
    | 444
    | 555
    | 666
    | 777
    | 888
    | 999 -> False
    _ -> True
  }
}

fn good_2_4(n: Int) -> Bool {
  case n {
    11
    | 22
    | 33
    | 44
    | 55
    | 66
    | 77
    | 88
    | 99
    | 1010
    | 1111
    | 1212
    | 1313
    | 1414
    | 1515
    | 1616
    | 1717
    | 1818
    | 1919
    | 2020
    | 2121
    | 2222
    | 2323
    | 2424
    | 2525
    | 2626
    | 2727
    | 2828
    | 2929
    | 3030
    | 3131
    | 3232
    | 3333
    | 3434
    | 3535
    | 3636
    | 3737
    | 3838
    | 3939
    | 4040
    | 4141
    | 4242
    | 4343
    | 4444
    | 4545
    | 4646
    | 4747
    | 4848
    | 4949
    | 5050
    | 5151
    | 5252
    | 5353
    | 5454
    | 5555
    | 5656
    | 5757
    | 5858
    | 5959
    | 6060
    | 6161
    | 6262
    | 6363
    | 6464
    | 6565
    | 6666
    | 6767
    | 6868
    | 6969
    | 7070
    | 7171
    | 7272
    | 7373
    | 7474
    | 7575
    | 7676
    | 7777
    | 7878
    | 7979
    | 8080
    | 8181
    | 8282
    | 8383
    | 8484
    | 8585
    | 8686
    | 8787
    | 8888
    | 8989
    | 9090
    | 9191
    | 9292
    | 9393
    | 9494
    | 9595
    | 9696
    | 9797
    | 9898
    | 9999 -> False
    _ -> True
  }
}
