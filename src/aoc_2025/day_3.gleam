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
  let parsed =
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

  pt_1(parsed)
  pt_2(parsed)

  parsed
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
  case digit {
    9 -> {
      let bitboard = int.bitwise_and(bank.nines, mask)
      case get_ls1b(bitboard) {
        Ok(index) -> solve(bank, remaining - 1, index, acc * 10 + 9)
        Error(_) -> try_digit(8, bank, remaining, mask, acc)
      }
    }
    8 -> {
      let bitboard = int.bitwise_and(bank.eights, mask)
      case get_ls1b(bitboard) {
        Ok(index) -> solve(bank, remaining - 1, index, acc * 10 + 8)
        Error(_) -> try_digit(7, bank, remaining, mask, acc)
      }
    }
    7 -> {
      let bitboard = int.bitwise_and(bank.sevens, mask)
      case get_ls1b(bitboard) {
        Ok(index) -> solve(bank, remaining - 1, index, acc * 10 + 7)
        Error(_) -> try_digit(6, bank, remaining, mask, acc)
      }
    }
    6 -> {
      let bitboard = int.bitwise_and(bank.sixes, mask)
      case get_ls1b(bitboard) {
        Ok(index) -> solve(bank, remaining - 1, index, acc * 10 + 6)
        Error(_) -> try_digit(5, bank, remaining, mask, acc)
      }
    }
    5 -> {
      let bitboard = int.bitwise_and(bank.fives, mask)
      case get_ls1b(bitboard) {
        Ok(index) -> solve(bank, remaining - 1, index, acc * 10 + 5)
        Error(_) -> try_digit(4, bank, remaining, mask, acc)
      }
    }
    4 -> {
      let bitboard = int.bitwise_and(bank.fours, mask)
      case get_ls1b(bitboard) {
        Ok(index) -> solve(bank, remaining - 1, index, acc * 10 + 4)
        Error(_) -> try_digit(3, bank, remaining, mask, acc)
      }
    }
    3 -> {
      let bitboard = int.bitwise_and(bank.threes, mask)
      case get_ls1b(bitboard) {
        Ok(index) -> solve(bank, remaining - 1, index, acc * 10 + 3)
        Error(_) -> try_digit(2, bank, remaining, mask, acc)
      }
    }
    2 -> {
      let bitboard = int.bitwise_and(bank.twos, mask)
      case get_ls1b(bitboard) {
        Ok(index) -> solve(bank, remaining - 1, index, acc * 10 + 2)
        Error(_) -> try_digit(1, bank, remaining, mask, acc)
      }
    }
    1 -> {
      let bitboard = int.bitwise_and(bank.ones, mask)
      case get_ls1b(bitboard) {
        Ok(index) -> solve(bank, remaining - 1, index, acc * 10 + 1)
        Error(_) -> panic
      }
    }
    _ -> panic
  }
}

fn get_ls1b(bitboard: Int) -> Result(Int, Nil) {
  case bitboard {
    0 -> Error(Nil)
    _ ->
      case int.bitwise_and(bitboard, -bitboard) % 101 {
        1 -> Ok(0)
        2 -> Ok(1)
        3 -> Ok(69)
        4 -> Ok(2)
        5 -> Ok(24)
        6 -> Ok(70)
        7 -> Ok(9)
        8 -> Ok(3)
        9 -> Ok(38)
        10 -> Ok(25)
        11 -> Ok(13)
        12 -> Ok(71)
        13 -> Ok(66)
        14 -> Ok(10)
        15 -> Ok(93)
        16 -> Ok(4)
        17 -> Ok(30)
        18 -> Ok(39)
        19 -> Ok(96)
        20 -> Ok(26)
        21 -> Ok(78)
        22 -> Ok(14)
        23 -> Ok(86)
        24 -> Ok(72)
        25 -> Ok(48)
        26 -> Ok(67)
        27 -> Ok(7)
        28 -> Ok(11)
        29 -> Ok(91)
        30 -> Ok(94)
        31 -> Ok(84)
        32 -> Ok(5)
        33 -> Ok(82)
        34 -> Ok(31)
        35 -> Ok(33)
        36 -> Ok(40)
        37 -> Ok(56)
        38 -> Ok(97)
        39 -> Ok(35)
        40 -> Ok(27)
        41 -> Ok(45)
        42 -> Ok(79)
        43 -> Ok(42)
        44 -> Ok(15)
        45 -> Ok(62)
        46 -> Ok(87)
        47 -> Ok(58)
        48 -> Ok(73)
        49 -> Ok(18)
        50 -> Ok(49)
        51 -> Ok(99)
        52 -> Ok(68)
        53 -> Ok(23)
        54 -> Ok(8)
        55 -> Ok(37)
        56 -> Ok(12)
        57 -> Ok(65)
        58 -> Ok(92)
        59 -> Ok(29)
        60 -> Ok(95)
        61 -> Ok(77)
        62 -> Ok(85)
        63 -> Ok(47)
        64 -> Ok(6)
        65 -> Ok(90)
        66 -> Ok(83)
        67 -> Ok(81)
        68 -> Ok(32)
        69 -> Ok(55)
        70 -> Ok(34)
        71 -> Ok(44)
        72 -> Ok(41)
        73 -> Ok(61)
        74 -> Ok(57)
        75 -> Ok(17)
        76 -> Ok(98)
        77 -> Ok(22)
        78 -> Ok(36)
        79 -> Ok(64)
        80 -> Ok(28)
        81 -> Ok(76)
        82 -> Ok(46)
        83 -> Ok(89)
        84 -> Ok(80)
        85 -> Ok(54)
        86 -> Ok(43)
        87 -> Ok(60)
        88 -> Ok(16)
        89 -> Ok(21)
        90 -> Ok(63)
        91 -> Ok(75)
        92 -> Ok(88)
        93 -> Ok(53)
        94 -> Ok(59)
        95 -> Ok(20)
        96 -> Ok(74)
        97 -> Ok(52)
        98 -> Ok(19)
        99 -> Ok(51)
        100 -> Ok(50)
        _ -> panic
      }
  }
}
