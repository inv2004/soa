import criterion
import random

import soa/kv

var cfg = newDefaultConfig()
# cfg.brief = true
# cfg.verbose = true
cfg.budget = 1.0
cfg.minSamples = 10

const N = 10_000
const NT = 10

let db = DB()

iterator testData: (string, string) =
  for i in 1..N div NT:
    let user = "u" & $i
    for j in 1..NT:
      let tag = "t" & $rand 1000
      yield (user, tag)

benchmark cfg:
  proc addTagBench(u, t: string) {.measure: testData.} =
     db.addTag u, t

db.userStat "u11"
echo db.userstags.ut.len
