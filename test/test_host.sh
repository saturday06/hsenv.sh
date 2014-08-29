#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh

test_is_mingw() {
  HSENV_HOST_OS=mingw32
  assertTrue is_mingw
  HSENV_HOST_OS=mingw64
  assertTrue is_mingw
  HSENV_HOST_OS=linux
  assertFalse is_mingw
}

. shunit2/src/shunit2
