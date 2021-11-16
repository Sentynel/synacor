import std/math

type Mem = array[2^15, uint16]

proc loadCode(): Mem =
  var mem: Mem
  let f = open("../challenge.bin", )
  defer: f.close()
  let n = readBuffer(f, addr(mem), 2 * (2^15))
  echo "Read ", n, " bytes"
  return mem

proc run(mem: Mem) =
  var ip: uint16 = 0
  while true:
    let op = mem[ip]
    ip += 1
    case op
    of 0:
      echo "\n<Halt instruction>"
      return
    of 19:
      let arg = mem[ip]
      ip += 1
      write(stdout, char(arg))
    of 21:
      discard
    else:
      echo "\nunknown instruction ", op
      return

let mem = loadCode()
run(mem)
