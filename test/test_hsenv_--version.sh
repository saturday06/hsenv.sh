#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh

test_version() {
  v=`hsenv --version`
  echo $v | grep -E "^[.0-9]+$" > /dev/null
  assertEquals "version=$v" 0 $?
}

. shunit2/src/shunit2
