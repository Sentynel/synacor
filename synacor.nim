import std/math

type
  Mem = array[2^15, uint16]
  Op = enum
    Halt = 0, Set = 1, Jmp = 6, Jt = 7, Jf = 8, Out = 19, Noop = 21
  VM = ref object
    mem: Mem
    ip: uint16
    reg: array[8, uint16]

const RegStart: uint16 = uint16(2^15)

proc loadCode(v: VM) =
  let f = open("../challenge.bin", )
  defer: f.close()
  let n = readBuffer(f, addr(v.mem), 2 * (2^15))
  echo "Read ", n, " bytes"

proc val(v: VM, offset: uint16 = 0): auto =
  result = v.mem[v.ip + offset]
  #echo "get ", result
  if result >= RegStart + 8:
    raise newException(ValueError, "arg too big")
  if result >= RegStart:
    result = v.reg[result - RegStart]
    #echo "in register ", result

proc arg1(v: VM): auto =
  result = v.val
  v.ip += 1

proc arg2(v: VM): auto =
  result = (v.val, v.val(1))
  v.ip += 2

proc arg3(v: VM): auto =
  result = (v.val, v.val(1), v.val(2))
  v.ip += 3

proc regarg(v: VM): auto =
  result = (v.mem[v.ip] - RegStart, v.val(1))
  v.ip += 2

proc run(v: VM) =
  while true:
    let op = Op(v.mem[v.ip])
    v.ip += 1
    case op
    of Halt:
      echo "\n<Halt instruction>"
      return
    of Out:
      let arg = v.arg1
      write(stdout, char(arg))
    of Noop:
      discard
    of Jmp:
      v.ip = v.arg1
    of Jt:
      let (test, dest) = v.arg2
      if test != 0:
        v.ip = dest
    of Jf:
      let (test, dest) = v.arg2
      if test == 0:
        v.ip = dest
    of Set:
      let (reg, val) = v.regarg
      #echo "set ", reg, " to ", val
      v.reg[reg] = val
    else:
      echo "\nunknown instruction ", op
      return

var vm = VM()
vm.loadCode()
vm.run()
