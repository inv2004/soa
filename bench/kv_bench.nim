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

const N = 10_560_000 # 528*20000=10560000
const NT = 32 # 1+2+3+4+5+6+7+8+9+10+11+12+13+14+15+16+17+18+19+20+21+22+23+24+25+26+27+28+29+30+31+32=528
const T = 1000

let db = DB()

iterator testData: (string, string) =
  for i in 1..N div 528:
    let user = "u" & $i
    for j in 1..NT:
      let tag = "t" & $rand 1..T
      for z in 1..j:
        yield (user, tag)

let t = cpuTime()
for (u, t) in testData():
  db.addTag u, t
echo "addTag Time (", N , "): ", cpuTime() - t

# echo db.userStat2Key "u500"
# echo db.userStatFlat "u500"

benchmark cfg:
  proc userStat2Key() {.measure.} =
    doAssert db.userStat2Key("u500").len == 32
  echo GC_getStatistics()
  GC_fullCollect()

  proc userStatFlat() {.measure.} =
    doAssert db.userStatFlat("u500").len == 32
  echo GC_getStatistics()
