#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh
. `dirname $0`/../libexec/option

test_version() {
  assertTrue "is_version `unset_hsenv_envs && hsenv --version`"
}

. shunit2/src/shunit2
