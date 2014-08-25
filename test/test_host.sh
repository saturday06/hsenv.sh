#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh

test_is_mingw() {
  _hsenv_private_host_os=mingw32
  assertTrue is_mingw
  _hsenv_private_host_os=mingw64
  assertTrue is_mingw
  _hsenv_private_host_os=linux
  assertFalse is_mingw
}

. shunit2/src/shunit2
