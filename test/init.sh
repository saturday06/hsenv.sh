#!/bin/sh

export _hsenv_private_root_dir=$(cd `dirname $SHUNIT_PARENT`/..; pwd)
. $_hsenv_private_root_dir/libexec/init

PATH="$_hsenv_private_root_dir/bin:$PATH"
if [ -n "${ZSH_VERSION:-}" ]; then
  setopt shwordsplit
fi

_hsenv_test_tmp_dir="$_hsenv_private_root_dir/tmp/test"
_hsenv_test_data_dir="$_hsenv_private_root_dir/test/data"

mkdir -p $_hsenv_test_tmp_dir

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
