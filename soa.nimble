# Package

version       = "0.1.0"
author        = "inv2004"
description   = "SoA structs wrapper"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.2"
requires "zero_functional"
requires "xxhash"

task bench, "bench":
  exec """nim c -d:release --gc:arc -r bench/kv_bench.nim"""
  # exec """nim c --opt:speed --passC:'-flto -march=native -Ofast' --passL:'-flto -march=native -Ofast' -d:danger --gc:arc -r bench/kv_bench.nim"""
  # exec """nim c -d:release --gc:arc -r bench/kv_sqlite.nim"""
