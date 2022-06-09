type
  u8* = uint8
  u16* = uint16
  u32* = uint32
  u64* = uint64

func reqArrSize(x, y: u32): u32 =
  if y notin {1, 2, 4, 8}: return 0'u32 - 1
  result = (x * y) shr 3
  if ((x * y) and 7) != 0: inc result

type
  Bitz*[heaps, size: static u32] = object
    base*: array[reqArrSize(heaps, size), u8]
  BitzPos*[l: static u32] = range[0'u32 .. l - 1]

func getBits*(x: Bitz; pos: BitzPos[x.heaps]): u8 =
  when x.size == 8:
    x.base[pos]
  else:
    let inpos = (pos * x.size) and 7
    let data = x.base[(pos * x.size) shr 3]
    let mask = ((1'u8 shl x.size) - 1) shl inpos
    return (data and mask) shr inpos

func setBits*(x: Bitz; pos: BitzPos[x.heaps]; to: u8): typeof(x) =
  result = x
  when x.size == 8:
    result[pos] = to
  else:
    let where = (pos * x.size) shr 3
    let inpos = (pos * x.size) and 7
    let clearMask = not(((1'u8 shl x.size) - 1) shl inpos)
    let data = (to and ((1'u8 shl x.size) - 1)) shl inpos
    result.base[where] = (result.base[where] and clearMask) or data

when isMainModule:
  var some: Bitz[3, 4]
  echo some
  some = some.setBits(0, 1).setBits(2, 3)
  echo some
  echo some.getBits(2)
