import criterion
import random
import times
import tables

import soa/kv

var cfg = newDefaultConfig()
cfg.brief = true
# cfg.verbose = true
cfg.budget = 1.0
cfg.minSamples = 10

const N = 12_000_000 # 120*20000=10560000
const NT = 15 # 1+2+3+4+5+6+7+8+9+10+11+12+13+14+15=120
const T = 1000

func sum(n: int): int =
  for i in 1..n:
    result.inc i

echo "Tags count: ", sum(15)

iterator testData: (string, string) =
  randomize 10
  for i in 1..N div (sum NT):
    let user = "u" & $i
    for j in 1..NT:
      let tag = "t" & $rand 1..T
      for z in 1..j:
        yield (user, tag)

let db0 = Db0()
let db1 = Db1()
let db2 = Db2()
let dbc = DbC()


var t = cpuTime()
for (u, t) in testData():
  db0.addTag u, t
echo "addTag0 Time (", db0.userstags.ut.len , "): ", cpuTime() - t

t = cpuTime()
for (u, t) in testData():
  db1.addTag u, t
echo "addTag1 Time (", db1.userstags.ut.len , "): ", cpuTime() - t

t = cpuTime()
for (u, t) in testData():
  db2.addTag u, t
echo "addTag2 Time (", db2.userstags.ut.len , "): ", cpuTime() - t

t = cpuTime()
for (u, t) in testData():
  dbc.addTag u, t
echo "addTagC Time (", dbc.userstags.ut.len , "): ", cpuTime() - t

# echo GC_getStatistics()

# ops:
# count by tag for user
# count by user for tag

benchmark cfg:
  proc userStat0Key() {.measure.} =
    doAssert db0.userStat("u500").len == NT

  proc userStat1Key() {.measure.} =
    doAssert db1.userStat("u500").len == NT

  proc userStat2Key() {.measure.} =
    doAssert db2.userStat("u500").len == NT

  proc userStatCT() {.measure.} =
    doAssert dbc.userStat("u500").len == NT

  proc tagStat0Key() {.measure.} =
    doAssert db0.tagStat("t500").len == 1527

  proc tagStat1Key() {.measure.} =
    doAssert db1.tagStat("t500").len == 1527

  proc tagStat2Key() {.measure.} =
    doAssert db2.tagStat("t500").len == 1527

  proc tagStatCT() {.measure.} =
    doAssert dbc.tagStat("t500").len == 1527
