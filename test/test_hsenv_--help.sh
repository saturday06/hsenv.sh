#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh

test_help() {
  assertTrue "unset_hsenv_envs && hsenv --help"
}

. shunit2/src/shunit2
