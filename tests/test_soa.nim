import soa

import unittest
import random
import sequtils
import tables
import sugar

type M = object
  a: int
  b: string

defineST(M, S)

var st = S()

test "add":
  st.add M(a: 1, b: "aaa")
  st.add M(a: 2, b: "bbb")

test "len":
  check st.len == 2

test "[]":
  check st[0] == M(a: 1, b: "aaa")
  check st[1] == M(a: 2, b: "bbb")
  check optFieldsS == ["", ""]
  check st.len == 2

test "opt":
  (proc() =
    optFieldsS.setLen 0
    check st[0].a == 1
    check st[1].b == "bbb"
    check optFieldsS == ["a", "b"]
  )()

test "groupWith":
  type R = object
    ct: uint8
    price: float64
    dist: uint32

  defineST(R, TT)

  const N = 10

  randomize 1

  let t = TTWith(N, rand(0'u8..3'u8), rand(0.0..50.0), rand(0'u32..50'u32))

  proc groupWith[R, T, U](t: R, keys: openArray[T], fn: proc(tt: R): U): Table[T, U] =
    var tmp = initTable[T, R]()
    for i, k in keys:
      if k notin tmp:
        tmp[k] = R()
      tmp[k].add t[i]

    result = initTable[T, U]()
    for k, v in tmp:
      result[k] = fn(v)

  check t.groupWith(t.ct, t => t.dist.foldl(a+b)) == {3'u8: 35'u32, 2'u8: 77'u32, 0'u8: 96'u32, 1'u8: 33'u32}.toTable

  check t.len == N
