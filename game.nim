import boardfuns, bits, tables, bitops

using
  board: Board

proc maxxMove(board; table: var Table[typeof(board), u8]): u8 =
  # if table.hasKey(board): return table[board]

  var favours: array[board.players, u8]
  var hasDraw = false

  var winner = board.checkWin()
  if winner != 0:
    let w = (fastLog2(winner) + 1).u8
    table[board] = w
    return w
  let choices = board.generateChoices()
  if choices.len == 0:
    table[board] = 0
    return 0

  let turn = board.checkTurn() + 1
  for i in choices:
    let maxx = maxxMove(board.playMove(i), table)
    if maxx == turn:
      result = maxx
      break
    if maxx != 0:
      inc favours[maxx - 1]
    else:
      hasDraw = true

  if (result == 0) and (not hasDraw):
    var best = 0'u8
    var bestScore = 0'u8
    for i in 0 .. favours.high:
      if favours[i] > bestScore:
        bestScore = favours[i]
        best = (i + 1).u8
    result = best

  # table[board] = result

proc selectMove(board; table: var Table[typeof(board), u8]): u32 =
  let choices = board.generateChoices()
  let turn = board.checkTurn() + 1
  for i in choices:
    let score = maxxMove(board.playMove(i), table)
    echo i, " ", score
    if score == turn:
      return i
    if score == 0:
      result = i
  if result == 0: return choices[0]

when isMainModule:
  var board: BoardType(4, 3)
  import sugar
  var table = initTable[typeof(board), u8]()
  board.playGame((board) => selectMove(board, table))
