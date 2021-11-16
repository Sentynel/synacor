import std/math

type
  Vnum = distinct uint16
  Regidx = distinct uint16
  Mem = array[2^15, uint16]
  Reg = array[8, Vnum]
  Op = enum
    Halt = 0, Set = 1, Push = 2, Pop = 3, Eq = 4, Gt = 5, Jmp = 6, Jt = 7, Jf = 8, Add = 9, Mult = 10, Mod = 11, And = 12, Or = 13, Not = 14, Rmem = 15, Wmem = 16, Call = 17, Ret = 18, Out = 19, In = 20, Noop = 21
  VM = ref object
    mem: Mem
    ip: Vnum
    reg: Reg
    stack: seq[Vnum]

const NumMax: uint16 = uint16(2^15)

proc `+`[T](x: Vnum, y: T): Vnum =
  return Vnum((uint16(x) + uint16(y)) mod NumMax)

proc `+=`[T](x: var Vnum, y: T) =
  x = x + y

proc `*`(x: Vnum, y: Vnum): Vnum =
  return Vnum((uint16(x) * uint16(y)) mod NumMax)

proc `mod`(x: Vnum, y: Vnum): Vnum =
  return Vnum(uint16(x) mod uint16(y))

proc `>`(x: Vnum, y: Vnum): bool =
  return uint16(x) > uint16(y)

proc `and`(x: Vnum, y: Vnum): Vnum =
  return Vnum(uint16(x) and uint16(y))

proc `or`(x: Vnum, y: Vnum): Vnum =
  return Vnum(uint16(x) or uint16(y))

proc `not`(x: Vnum): Vnum =
  return Vnum(uint16(x) xor uint16((2^15)-1))

proc `==`[T](x: Vnum, y: T): bool =
  return uint16(x) == uint16(y)

proc `[]`(m: Mem, i: Vnum): uint16 =
  return m[uint16(i)]

proc `[]=`(m: var Mem, i: Vnum, v: Vnum) =
  m[uint16(i)] = uint16(v)

proc `[]`(r: Reg, i: Regidx): Vnum =
  return r[uint16(i)]

proc `[]=`[T](r: var Reg, i: Regidx, v: T) =
  r[uint16(i)] = Vnum(v)

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

proc set(v: VM): auto =
  result = Regidx(v.mem[v.ip] - NumMax)
  v.ip += 1

proc set1(v: VM): auto =
  result = (Regidx(v.mem[v.ip] - NumMax), v.val(1))
  v.ip += 2

proc set2(v: VM): auto =
  result = (Regidx(v.mem[v.ip] - NumMax), v.val(1), v.val(2))
  v.ip += 3

proc run(v: VM) =
  while true:
    let ov = v.mem[v.ip]
    if ov > 21:
      echo "Bad instruction ", ov
      return
    let op = Op(ov)
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
    of Add:
      let (reg, x, y) = v.set2
      v.reg[reg] = x + y
    of Eq:
      let (reg, x, y) = v.set2
      if x == y:
        v.reg[reg] = 1
      else:
        v.reg[reg] = 0
    of Push:
      let val = v.arg1
      v.stack.add(val)
    of Pop:
      let reg = v.set
      v.reg[reg] = v.stack.pop
    of Gt:
      let (reg, x, y) = v.set2
      if x > y:
        v.reg[reg] = 1
      else:
        v.reg[reg] = 0
    of And:
      let (reg, x, y) = v.set2
      v.reg[reg] = x and y
    of Or:
      let (reg, x, y) = v.set2
      v.reg[reg] = x or y
    of Not:
      let (reg, x) = v.set1
      v.reg[reg] = not x
    of Call:
      let dest = v.arg1
      let next = v.ip
      v.stack.add(next)
      v.ip = dest
    of Mult:
      let (reg, x, y) = v.set2
      v.reg[reg] = x * y
    of Mod:
      let (reg, x, y) = v.set2
      v.reg[reg] = x mod y
    of Rmem:
      let (reg, x) = v.set1
      v.reg[reg] = v.mem[x]
    of Wmem:
      let (dest, x) = v.arg2
      v.mem[dest] = x
    of Ret:
      if v.stack.len == 0:
        echo "\nRet on empty stack, exiting"
        return
      v.ip = v.stack.pop

    else:
      echo "\nUnhandled op ", op
      return

var vm = VM()
vm.loadCode()
vm.run()
