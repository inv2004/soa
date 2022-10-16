import tables

type
  Users = Table[string, bool]

  Tags  = Table[string, bool]

  UserTag = object
    user: string
    tag: string
    url: string

  UsersTags = object
    ut*: seq[UserTag]
    user2idx: Table[string, seq[int]]
    tag2idx*: Table[string,seq[int]]
    user2tag2idx: Table[string, Table[string, seq[int]]]
    tag2user2idx: Table[string, Table[string, seq[int]]]

  Db* = ref object
    users: Users
    tags: Tags
    userstags*: UsersTags

proc addTag*(db: DB, user, tag: string, url = "") =
  db.userstags.ut.add UserTag(user: user, tag: tag, url: url)
  let idx = high db.userstags.ut

  db.userstags.user2idx.mgetOrPut(user, @[]).add idx
  db.userstags.tag2idx.mgetOrPut(tag, @[]).add idx

  db.userstags.user2tag2idx.mgetOrPut(user, initTable[string, seq[int]]()).mgetOrPut(tag, @[]).add idx
  db.userstags.tag2user2idx.mgetOrPut(user, initTable[string, seq[int]]()).mgetOrPut(tag, @[]).add idx

proc userStat2Key*(db: DB, user: string): seq[(string, int)] =
  for tag, idxs in db.userstags.user2tag2idx[user]:
    result.add (tag, len idxs)

proc userStatFlat*(db: DB, user: string): CountTable[string] =
  for idx in db.userstags.user2idx[user]:
    result.inc db.userstags.ut[idx].tag

# db.userStat "u11"

# echo()
# echo GC_getStatistics()
