#! /usr/bin/env python3
import os
import time

def r(start, end, low, high):
    if low <= start < high:
        if low < end <= high:
            return True
    return False

def diff(prev, cur):
    print("CHANGES:")
    changed = []
    inchange = False
    start = 0
    for i in range(0, len(prev), 2):
        v1 = prev[i:i+1]
        v2 = cur[i:i+1]
        if v1 != v2:
            if not inchange:
                inchange = True
                start = i
        else:
            if inchange:
                inchange = False
                changed.append((start, i))
    if not changed:
        if prev != cur:
            print("diffing algo not working..")
    for start, end in changed:
        a = prev[start:end]
        b = cur[start:end]
        if r(start, end, 0xcaec, 0xcb2e):
            # line read buffer
            continue
        if r(start, end, 0x1558, 0x155c):
            print("location code", a.hex(), "->", b.hex())
            continue
        if r(start, end, 0x1d1c, 0x1d1e):
            print("twisty passage", a.hex(), "->", b.hex())
            continue
        print("change at", hex(start), ":", hex(end))
        print("old:", a.hex())
        print("new:", b.hex())
        print("old:", a[::2])
        print("new:", b[::2])
    print()

lastlast = []
while True:
    time.sleep(1)
    files = os.listdir("memsnap")
    files.sort()
    last = files[-2:]
    if len(last) < 2:
        continue
    if lastlast == last:
        continue
    lastlast = last
    prev = open("memsnap/" + last[0], "rb").read(2*2**15)
    cur = open("memsnap/" + last[1], "rb").read(2*2**15)
    diff(prev, cur)
