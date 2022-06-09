import bits, bitops, math

type Board*[size, players, heaps, insize: static u32] = object
  base: Bitz[heaps, insize]

using
  board: Board

const players = " OX#$@+-*"

template BoardType*(a, b: SomeNumber): untyped = Board[a, b, a*a,
    nextPowerOfTwo(b).u32]

func getSign(x: u8): char = players[x]

func getAtPos(board; x, y: u32): u8 =
  board.base.getBits(x + y * board.size)

func getSign(board; x, y: u32): char =
  board.getAtPos(x, y).getSign()

func checkEqu(board; start, jump: u32): u8 =
  var p = start
  let init = board.base.getBits(p)
  if init == 0:
    return 0
  for i in 1 .. board.size - 1:
    p += jump
    if board.base.getBits(p) != init:
      return 0
  return init

func checkRow(board): u8 =
  for row in 0'u8 .. board.size - 1:
    result = board.checkEqu(row * board.size, 1)
    if result != 0: return

func checkCol(board): u8 =
  for col in 0'u8 .. board.size - 1:
    result = board.checkEqu(col, board.size)
    if result != 0: return

func checkDiag(board): u8 =
  let a = checkEqu(board, 0, board.size + 1)
  if a != 0: return a
  return board.checkEqu(board.size - 1, board.size - 1)

func checkWin*(board): u8 =
  result = board.checkRow()
  if result != 0: return
  result = board.checkCol()
  if result != 0: return
  return board.checkDiag()

func checkTurn*(board): u8 =
  for i in board.base.base:
    result += i.countSetBits().u8
  result = result mod board.players

func playMove*(board; pos: u32): typeof(board) =
  result = board
  let turn = board.checkTurn()
  # let pos = x + (board.size * y)
  assert result.base.getBits(pos) == 0
  result.base = result.base.setBits(pos, 1'u8 shl turn)

func generateChoices*(board): seq[u32] =
  for i in 0'u32 ..< board.heaps:
    if board.base.getBits(i) == 0:
      result.add(i)

import strutils, render

proc dumpBoard*(board): string =
  let nums = "0123456789"
  let boxSize = (board.size + 1).u32
  result.setLen boxSize ^ 2
  result[0] = ' '
  for i in 0'u32 ..< board.size:
    result[i + 1] = nums[i]
  for i in 0'u32 ..< board.size:
    result[(i + 1) * boxSize] = nums[i]
    for j in 0'u32 ..< board.size:
      let pos = (j + 1) + boxSize * (i + 1)
      result[pos] = board.getSign(j, i)
  let data = result
  result = ""
  for i in renderBox(data, boxSize):
    result &= i & "\n"

proc takeInput(board): typeof(board) =
  stdout.write "Give Input 0-" & $board.heaps & ": "
  let data = stdin.readLine()
  try:
    let d = cast[u32](data.parseInt()) mod board.heaps
    if board.base.getBits(d) == 0:
      board.playMove(d)
    else:
      takeInput(board)
  except:
    takeInput(board)

import terminal, sugar

proc playGame*(board: var Board; fun: (typeof(board)) -> u8) =
  var choices = board.generateChoices()
  while choices.len > 0:
    # stdout.eraseScreen()
    let turn = board.checkTurn
    if turn == 0:
      echo board.dumpBoard()
      board = takeInput(board)
    else:
      board = board.playMove fun(board)
    let winner = board.checkWin()
    if winner != 0:
      stdout.eraseScreen()
      echo board.dumpBoard()
      echo (fastLog2(winner) + 1).u8.getSign(), " Won"
      break
    choices = board.generateChoices()
  if board.checkWin() == 0:
    echo "Draw;"


when isMainModule:
  import random
  var board: BoardType(4, 2)
  board.playGame(sample)
