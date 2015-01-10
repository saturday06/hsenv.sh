#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh

test_unset_hsenv_envs() {
  export HSENV_FOO=foo
  assertTrue "export | grep HSENV_FOO"
  assertFalse "unset_hsenv_envs; export | grep HSENV_FOO"
}

. shunit2/src/shunit2
