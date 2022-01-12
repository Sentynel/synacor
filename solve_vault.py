#! /usr/bin/env python3
current_states = [([(0,0)],22)]
seen_states = {(0,0,22)}

class Grid:
    def __init__(self, g):
        # reverse because that's the way up I did my coordinate system, oops
        self.g = g[::-1]
    def __getitem__(self, c):
        return self.g[c[1]][c[0]]

grid = Grid([
    ['*', 8, '-', 1],
    [4, '*', 11, '*'],
    ['+', 4, '-', 18],
    [22, '-', 9, '*'],
    ])

assert grid[(0,0)] == 22
assert grid[(3,3)] == 1
assert grid[(0,1)] == '+'

def get_adj(pos):
    x,y = pos
    if x > 0:
        yield x-1,y
    if x < 3:
        yield x+1,y
    if y > 0:
        yield x,y-1
    if y < 3:
        yield x,y+1

resolve = False
while True:
    new_states = []
    for hist,tot in current_states:
        moves = get_adj(hist[-1])
        if resolve:
            op = grid[hist[-1]]
        for nx,ny in moves:
            if (nx,ny) == (0,0):
                continue
            if resolve:
                val = grid[(nx,ny)]
                if op == '+':
                    ntot = tot + val
                elif op == '*':
                    ntot = tot * val
                else:
                    ntot = tot - val
                if (val < 0) or (val >= (2**15)):
                    continue
            else:
                ntot = tot
            ns = (nx,ny,ntot)
            if ns in seen_states:
                continue
            seen_states.add(ns)
            nhist = hist.copy() + [(nx,ny)]
            if (nx, ny) == (3,3):
                if ntot != 30:
                    continue
                else:
                    print("done, moves:")
                    print(nhist)
                    raise SystemExit(0)
            new_states.append((nhist, ntot))
    current_states = new_states
    resolve = not resolve
    print("completed step", len(current_states), "states")
    print(current_states)
