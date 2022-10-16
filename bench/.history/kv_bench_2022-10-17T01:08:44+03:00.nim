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
      db.addTag user, tag

for (u, t) in testData():
  db.addTag "1", "2"

db.userStat "u11"
benchmark cfg:
  echo "ok"
  proc addTag() {.measure.} =
     db.addTag "1", "2"

echo db.userstags.ut.len
