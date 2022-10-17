import db_sqlite
import random
import times
import strutils
import tables
import criterion

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


let db = open(":memory:", "", "", "")

db.exec sql"CREATE TABLE t (u TEXT, t TEXT, url TEXT)"
db.exec sql"CREATE INDEX t_u ON t (u)"
db.exec sql"CREATE INDEX t_t ON t (t)"

var t = cpuTime()
for (u, t) in testData():
  db.exec sql"INSERT INTO t VALUES(?,?,?)", u, t, ""
echo "addTag Time (", N , "): ", cpuTime() - t



proc userStatSQL(user: string): CountTableRef[string] =
  result = newCountTable[string]()
  for x in db.fastRows(sql"SELECT t, COUNT(1) FROM t WHERE u=? GROUP BY t", user):
    result[x[0]] = parseInt(x[1])

proc tagStatSQL(tag: string): CountTableRef[string] =
  result = newCountTable[string]()
  for x in db.fastRows(sql"SELECT u, COUNT(1) FROM t WHERE t=? GROUP BY u", tag):
    result[x[0]] = parseInt(x[1])

var cfg = newDefaultConfig()
cfg.brief = true
# cfg.verbose = true
cfg.budget = 1.0
cfg.minSamples = 10

echo userStatSQL("u500").len

benchmark cfg:
  proc userStat2Key() {.measure.} =
    doAssert userStatSQL("u500").len == NT

  proc tagStat2Key() {.measure.} =
    doAssert tagStatSQL("t500").len == 1527

db.close()