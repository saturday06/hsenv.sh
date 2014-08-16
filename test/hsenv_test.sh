#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh

testDefaultOutput() {
  assertEquals "dummy!" `hsenv`
}

. shunit2/src/shunit2
