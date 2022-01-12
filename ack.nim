import std/tables
import std/math

var r7: uint16 = 1

type
  Arg = tuple[a: uint16, b: uint16]

var memo = initTable[Arg,uint16]()

proc ack(a: uint16, b: uint16): uint16 =
  let arg: Arg = (a, b)
  if memo.hasKey(arg):
    return memo[arg]
  if a == 0:
    result = (b+1) and 0x7fff
  elif b == 0:
    result = ack(a-1, r7)
  else:
    result = ack(a-1, ack(a, b-1))
  memo[arg] = result

for i in 0..<2^15:
  memo.clear()
  r7 = uint16(i)
  let res = ack(4,1)
  echo i, "->", res
  if res == 6:
    echo "done"
    break
