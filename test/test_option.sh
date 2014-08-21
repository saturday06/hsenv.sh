#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh
. `dirname $0`/../libexec/option

test_is_version() {
  assertTrue  "is_version 1"
  assertTrue  "is_version 11"
  assertFalse "is_version 11."
  assertTrue  "is_version 11.1"
  assertFalse "is_version 11x1"
  assertFalse "is_version .1.1"
  assertTrue  "is_version 1.12"
  assertFalse "is_version 1.12."
  assertTrue  "is_version 1.1.2"
  assertFalse "is_version 1.1 2"
}

. shunit2/src/shunit2
