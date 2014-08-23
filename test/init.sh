#!/bin/sh

PATH="`dirname $SHUNIT_PARENT`/../bin:$PATH"
if [ -n "${ZSH_VERSION:-}" ]; then
  setopt shwordsplit
fi

_hsenv_test_tmpdir="`dirname $SHUNIT_PARENT`/../tmp"
_hsenv_test_datadir="`dirname $SHUNIT_PARENT`/data"

if [ -z "$HSENV_TEST_LEVEL" ]; then
  HSENV_TEST_LEVEL=0
fi
