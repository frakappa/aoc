import gleam/int
import gleam/list
import gleam/string

pub type Bank {
  Bank(
    size: Int,
    ones: Int,
    twos: Int,
    threes: Int,
    fours: Int,
    fives: Int,
    sixes: Int,
    sevens: Int,
    eights: Int,
    nines: Int,
  )
}

pub fn parse(input: String) {
  let p =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      let bank = Bank(string.length(line), 0, 0, 0, 0, 0, 0, 0, 0, 0)

      line
      |> string.to_graphemes
      |> list.index_fold(bank, fn(acc, grapheme, index) {
        case grapheme {
          "1" -> Bank(..acc, ones: set_bit(acc.ones, index))
          "2" -> Bank(..acc, twos: set_bit(acc.twos, index))
          "3" -> Bank(..acc, threes: set_bit(acc.threes, index))
          "4" -> Bank(..acc, fours: set_bit(acc.fours, index))
          "5" -> Bank(..acc, fives: set_bit(acc.fives, index))
          "6" -> Bank(..acc, sixes: set_bit(acc.sixes, index))
          "7" -> Bank(..acc, sevens: set_bit(acc.sevens, index))
          "8" -> Bank(..acc, eights: set_bit(acc.eights, index))
          "9" -> Bank(..acc, nines: set_bit(acc.nines, index))
          _ -> panic
        }
      })
    })

  pt_1(p)
  pt_2(p)

  p
}

fn set_bit(bitboard: Int, index: Int) -> Int {
  int.bitwise_or(bitboard, int.bitwise_shift_left(1, index))
}

pub fn pt_1(input: List(Bank)) {
  list.fold(input, 0, fn(acc, bank) { acc + solve(bank, 2, -1, 0) })
}

pub fn pt_2(input: List(Bank)) {
  list.fold(input, 0, fn(acc, bank) { acc + solve(bank, 12, -1, 0) })
}

fn solve(bank: Bank, remaining: Int, pos: Int, acc: Int) -> Int {
  case remaining {
    0 -> acc
    _ -> {
      let l = pos + 1
      let r = bank.size - remaining
      let mask =
        int.bitwise_shift_left(int.bitwise_shift_left(1, r - l + 1) - 1, l)

      try_digit(9, bank, remaining, mask, acc)
    }
  }
}

fn try_digit(digit: Int, bank: Bank, remaining: Int, mask: Int, acc: Int) {
  let bitboard =
    case digit {
      1 -> bank.ones
      2 -> bank.twos
      3 -> bank.threes
      4 -> bank.fours
      5 -> bank.fives
      6 -> bank.sixes
      7 -> bank.sevens
      8 -> bank.eights
      9 -> bank.nines
      _ -> panic
    }
    |> int.bitwise_and(mask)

  case get_ls1b(bitboard) {
    Ok(index) -> solve(bank, remaining - 1, index, acc * 10 + digit)
    Error(_) -> try_digit(digit - 1, bank, remaining, mask, acc)
  }
}

fn get_ls1b(bitboard: Int) -> Result(Int, Nil) {
  case bitboard {
    0 -> Error(Nil)
    _ ->
      case int.bitwise_and(bitboard, -bitboard) % 101 {
        1 -> 0
        2 -> 1
        3 -> 69
        4 -> 2
        5 -> 24
        6 -> 70
        7 -> 9
        8 -> 3
        9 -> 38
        10 -> 25
        11 -> 13
        12 -> 71
        13 -> 66
        14 -> 10
        15 -> 93
        16 -> 4
        17 -> 30
        18 -> 39
        19 -> 96
        20 -> 26
        21 -> 78
        22 -> 14
        23 -> 86
        24 -> 72
        25 -> 48
        26 -> 67
        27 -> 7
        28 -> 11
        29 -> 91
        30 -> 94
        31 -> 84
        32 -> 5
        33 -> 82
        34 -> 31
        35 -> 33
        36 -> 40
        37 -> 56
        38 -> 97
        39 -> 35
        40 -> 27
        41 -> 45
        42 -> 79
        43 -> 42
        44 -> 15
        45 -> 62
        46 -> 87
        47 -> 58
        48 -> 73
        49 -> 18
        50 -> 49
        51 -> 99
        52 -> 68
        53 -> 23
        54 -> 8
        55 -> 37
        56 -> 12
        57 -> 65
        58 -> 92
        59 -> 29
        60 -> 95
        61 -> 77
        62 -> 85
        63 -> 47
        64 -> 6
        65 -> 90
        66 -> 83
        67 -> 81
        68 -> 32
        69 -> 55
        70 -> 34
        71 -> 44
        72 -> 41
        73 -> 61
        74 -> 57
        75 -> 17
        76 -> 98
        77 -> 22
        78 -> 36
        79 -> 64
        80 -> 28
        81 -> 76
        82 -> 46
        83 -> 89
        84 -> 80
        85 -> 54
        86 -> 43
        87 -> 60
        88 -> 16
        89 -> 21
        90 -> 63
        91 -> 75
        92 -> 88
        93 -> 53
        94 -> 59
        95 -> 20
        96 -> 74
        97 -> 52
        98 -> 19
        99 -> 51
        100 -> 50
        _ -> panic
      }
      |> Ok
  }
}
