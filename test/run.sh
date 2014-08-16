#!/bin/sh

cd `dirname $0`

run_test() {
  echo HSENV_TEST_SHELL=$HSENV_TEST_SHELL
  for t in *_test.sh; do
    echo "[$t]"
    $HSENV_TEST_SHELL $t
    if [ $? -ne 0 ]; then
      exit 1
    fi
  done
}

if [ "$1" = "all" ]; then
  for sh in ash bash dash ksh mksh posh zsh; do
    which $sh > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo $sh not found
      continue
    fi
    HSENV_TEST_SHELL=$sh
    run_test
    if [ $? -ne 0 ]; then
      exit 1
    fi
  done
  exit
fi

if [ "$HSENV_TEST_SHELL" = "" ]; then
  HSENV_TEST_SHELL=/bin/sh
fi

run_test
