# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import soa

suite "main":
  setup:
    type M = object
      a: int
      b: string

    defineST(M, S)

    var st = S()
    st.add M(a: 1, b: "aaa")
    st.add M(a: 2, b: "bbb")

  test "add":
    st.add M(a: 3, b: "ccc")
    st.add M(a: 3, b: "ddd")
    check st.len == 4

  test "len":
    check st.len == 2

  test "[]":
    check st[0] == M(a: 1, b: "aaa")
    check st[1] == M(a: 2, b: "bbb")
    check optFields == ["", ""]
    check st.len == 2

  test "opt":
    (proc() =
      check st[0].a == 1
      check st[1].b == "bbb"
      check optFields == ["a", "b"]
    )()
