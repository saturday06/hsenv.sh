#!/bin/sh

. "`dirname $0`/init.sh"

testDefaultOutput() {
  assertEquals "dummy!" `hsenv`
}

. shunit2/src/shunit2
