import std/math

type
  Vnum = distinct uint16
  Regidx = distinct uint16
  Mem = array[2^15, uint16]
  Reg = array[8, Vnum]
  Op = enum
    Halt = 0, Set = 1, Jmp = 6, Jt = 7, Jf = 8, Add = 9, Out = 19, Noop = 21
  VM = ref object
    mem: Mem
    ip: Vnum
    reg: Reg

const NumMax: uint16 = uint16(2^15)

proc `+`[T: SomeInteger](x: Vnum, y: T): Vnum =
  result = Vnum((uint16(x) + uint16(y)) mod NumMax)

proc `+=`[T: SomeInteger](x: var Vnum, y: T) =
  x = x + y

proc `==`[T: SomeInteger](x: Vnum, y: T): bool =
  result = T(x) == y

proc `[]`(m: Mem, i: Vnum): uint16 =
  return m[uint16(i)]

proc `[]`(r: Reg, i: Regidx): Vnum =
  return r[uint16(i)]

proc `[]=`(r: var Reg, i: Regidx, v: Vnum) =
  r[uint16(i)] = v

proc loadCode(v: VM) =
  let f = open("../challenge.bin", )
  defer: f.close()
  let n = readBuffer(f, addr(v.mem), 2 * (2^15))
  echo "Read ", n, " bytes"

proc val(v: VM, offset: uint16 = 0): auto =
  var res = v.mem[v.ip + offset]
  if res >= NumMax + 8:
    raise newException(ValueError, "arg too big")
  if res >= NumMax:
    res = uint16(v.reg[Regidx(res - NumMax)])
  return Vnum(res)

proc arg1(v: VM): auto =
  result = v.val
  v.ip += 1

proc arg2(v: VM): auto =
  result = (v.val, v.val(1))
  v.ip += 2

proc arg3(v: VM): auto =
  result = (v.val, v.val(1), v.val(2))
  v.ip += 3

proc set1(v: VM): auto =
  result = (Regidx(v.mem[v.ip] - NumMax), v.val(1))
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
      let (reg, val) = v.set1
      v.reg[reg] = val
    else:
      echo "\nunknown instruction ", op
      return

var vm = VM()
vm.loadCode()
vm.run()
