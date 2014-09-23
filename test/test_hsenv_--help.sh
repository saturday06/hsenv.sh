#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh

test_help() {
  unset_hsenv_envs
  assertTrue "hsenv --help"
}

. shunit2/src/shunit2
