#!/bin/sh

. "`dirname $0`/init.sh"

testVersion() {
  v=`hsenv --version`
  echo $v | grep -E "^[.0-9]+$" > /dev/null
  assertEquals "version=$v" 0 $?
}

. shunit2/src/shunit2
