#!/bin/sh

. `dirname $SHUNIT_PARENT`/../libexec/init

PATH="$_hsenv_private_root_dir/bin:$PATH"
if [ -n "${ZSH_VERSION:-}" ]; then
  setopt shwordsplit
fi

_hsenv_test_tmpdir="$_hsenv_private_root_dir/tmp"
_hsenv_test_datadir="$_hsenv_private_root_dir/data"

if [ -z "$HSENV_TEST_LEVEL" ]; then
  HSENV_TEST_LEVEL=0
fi

if [ -z "$HSENV_TEST_MAKE" ]; then
  if [ which gmake > /dev/null 2> /dev/null ]; then
    HSENV_TEST_MAKE=gmake
  else
    HSENV_TEST_MAKE=make
  fi
fi
