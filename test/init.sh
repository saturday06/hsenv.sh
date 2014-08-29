#!/bin/sh

export HSENV_ROOT_DIR=$(cd `dirname $SHUNIT_PARENT`/..; pwd)
. $HSENV_ROOT_DIR/libexec/init

PATH="$HSENV_ROOT_DIR/bin:$PATH"
if [ -n "${ZSH_VERSION:-}" ]; then
  setopt shwordsplit
fi

HSENV_TEST_TMP_DIR="$HSENV_ROOT_DIR/tmp/test"
HSENV_TEST_DATA_DIR="$HSENV_ROOT_DIR/test/data"

mkdir -p $HSENV_TEST_TMP_DIR

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
