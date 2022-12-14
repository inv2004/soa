import macros
import strformat
import strutils
import sequtils

proc getFieldsRec(t: NimNode): seq[(string, string)] =
  let obj = getImpl(t)[2]

  if obj[1].kind != nnkEmpty:
    result.add getFieldsRec(obj[1][0])

  let typeFields = obj[2]

  for f in typeFields.children:
    assert f.kind == nnkIdentDefs
    var fieldNames = newSeq[string]()
    for ff in f.children:
      case ff.kind
      of nnkIdent: fieldNames.add ff.strVal
      of nnkSym:
        for x in fieldNames:
          result.add (x, ff.strVal)
      of nnkEmpty: discard
      else: raise newException(Exception, "unexpected construction: " & $ff.treeRepr)

proc parseExprs(code: seq[string]): NimNode =
  # echo code.join "\n"
  parseExpr code.join("\n")

macro defineST*(T: typedesc, st: untyped) =
  result = newStmtList()

  let fields = getFieldsRec(getType(T)[1])
  var code = newSeq[string]()

  # debug
  code.add fmt"var optFields{st} = newSeq[string]()"
  result.add parseExprs code

  # type
  code.setLen 0
  code.add fmt"type {st} = object"
  for (f, t) in fields:
    code.add fmt"  {f}: seq[{t}]"
  result.add parseExprs code

  #newTWith
  var params = ""
  for (f, t) in fields:
    params.add fmt"; {f}With: untyped = default {t}"

  code.setLen 0
  code.add fmt"template {st}With(sz: int{params}): {st} ="
  code.add fmt"  {st}("
  for (f, t) in fields:
    code.add fmt"    {f}: newSeqWith(sz, {f}With),"
  code.add fmt"  )"
  result.add parseExprs code

  #len
  code.setLen 0
  code.add fmt"proc len(st: {st}): int ="
  code.add fmt"  st.{fields[0][0]}.len"
  result.add parseExprs code

  # add
  code.setLen 0
  code.add fmt"proc add(st: var {st}, v: {T}) ="
  for (f, t) in fields:
    code.add fmt"  st.{f}.add v.{f}"
  result.add parseExprs code

  # `[]`
  code.setLen 0
  code.add fmt"proc `[]`(st: {st}, i: int): {T} ="
  code.add fmt"""  optFields{st}.add "" """
  code.add fmt"  {T}("
  code.add fields.mapIt(fmt"    {it[0]}: st.{it[0]}[i]").join(",\n")
  code.add "  )"
  result.add parseExprs code

  # optimizations
  for (f, t) in fields:
    code.setLen 0
    code.add fmt"""template opt{f}{{`[]`(st,i).{f}}}(st: S, i: int): {t} ="""
    code.add fmt"""  optFields{st}.add "{f}" """
    code.add fmt"""  st.{f}[i]"""
    result.add parseExprs code

  # echo repr result
