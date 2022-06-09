import unicode, bits

let beauty = "┌─┬┐└─┴┘├─┼┤│".toRunes()

proc generateBoxLayer(base, size: u32): string =
  let start = beauty[base]
  let pad = beauty[base + 1]
  let midlast = beauty[base + 2]
  let last = beauty[base + 3]

  var data = newSeq[Rune](0)
  data.add start
  for i in 0 .. size - 2:
    data.add [pad, pad, pad, midlast]
  data.add [pad, pad, pad, last]
  return $data

proc renderBox*(data: string; size: u32): seq[string] =
  result.add generateBoxLayer(0, size)
  for i in 0 .. size - 1:
    let bar = $beauty[^1]
    var dz = bar
    for j in 0 .. size - 1:
      let pos = (i * size) + j
      dz &= ' ' & data[pos] & ' ' & bar
    result.add dz
    let base = if i == size - 1: 4'u32 else: 8
    result.add generateBoxLayer(base, size)

when isMainModule:
  let data = "abcdabcdabcdabcd"
  for i in renderBox(data, 4):
    echo i
