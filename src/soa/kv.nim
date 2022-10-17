import tables

type
  Users = Table[string, bool]

  Tags  = Table[string, bool]

  UserTag = object
    user: string
    tag: string
    url: string

  UsersTags0 = object
    ut*: seq[UserTag]

  Db0* = ref object
    users: Users
    tags: Tags
    userstags*: UsersTags0

  UsersTags1 = object
    ut*: seq[UserTag]
    user2idx: Table[string, seq[int]]
    tag2idx*: Table[string,seq[int]]

  Db1* = ref object
    users: Users
    tags: Tags
    userstags*: UsersTags1

  UsersTags2 = object
    ut*: seq[UserTag]
    user2tag2idx: Table[string, Table[string, seq[int]]]
    tag2user2idx: Table[string, Table[string, seq[int]]]

  Db2* = ref object
    users: Users
    tags: Tags
    userstags*: UsersTags2

  UsersTagsC = object
    ut*: seq[UserTag]
    user2count: Table[string, CountTableRef[string]]
    tag2count: Table[string, CountTableRef[string]]

  DbC* = ref object
    users: Users
    tags: Tags
    userstags*: UsersTagsC

proc addTag*(db: Db0, user, tag: string, url = "") =
  db.userstags.ut.add UserTag(user: user, tag: tag, url: url)

proc addTag*(db: Db1, user, tag: string, url = "") =
  db.userstags.ut.add UserTag(user: user, tag: tag, url: url)
  let idx = high db.userstags.ut

  db.userstags.user2idx.mgetOrPut(user, @[]).add idx
  db.userstags.tag2idx.mgetOrPut(tag, @[]).add idx

proc addTag*(db: Db2, user, tag: string, url = "") =
  db.userstags.ut.add UserTag(user: user, tag: tag, url: url)
  let idx = high db.userstags.ut

  db.userstags.user2tag2idx.mgetOrPut(user, initTable[string, seq[int]]()).mgetOrPut(tag, @[]).add idx
  db.userstags.tag2user2idx.mgetOrPut(tag, initTable[string, seq[int]]()).mgetOrPut(user, @[]).add idx

proc addTag*(db: DbC, user, tag: string, url = "") =
  db.userstags.ut.add UserTag(user: user, tag: tag, url: url)

  db.userstags.user2count.mgetOrPut(user, newCountTable[string]()).inc tag
  db.userstags.tag2count.mgetOrPut(tag, newCountTable[string]()).inc user

proc userStat*(db: Db2, user: string): CountTable[string] =
  for tag, idxs in db.userstags.user2tag2idx[user]:
    result[tag] = len idxs

proc userStat*(db: Db1, user: string): CountTable[string] =
  for idx in db.userstags.user2idx[user]:
    result.inc db.userstags.ut[idx].tag

proc userStat*(db: Db0, user: string): CountTable[string] =
  for t in db.userstags.ut:
    if t.user == user:
      result.inc t.tag

proc userStat*(db: DbC, user: string): lent CountTableRef[string] =
  db.userstags.user2count[user]

proc tagStat*(db: Db2, tag: string): CountTable[string] =
  for u, v in db.userstags.tag2user2idx[tag]:
    result[u] = len v

proc tagStat*(db: Db1, tag: string): CountTable[string] =
  for idx in db.userstags.tag2idx[tag]:
    result.inc db.userstags.ut[idx].user

proc tagStat*(db: Db0, tag: string): CountTable[string] =
  for t in db.userstags.ut:
    if t.tag == tag:
      result.inc t.user

proc tagStat*(db: DbC, tag: string): lent CountTableRef[string] =
  db.userstags.tag2count[tag]
