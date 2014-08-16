#!/bin/sh

cd `dirname $0`

if [ "$HSENV_TEST_SHELL" = "" ]; then
  HSENV_TEST_SHELL=/bin/sh
fi

for sh in *_test.sh; do
  echo "[$sh]"
  $HSENV_TEST_SHELL $sh
  if [ $? -ne 0 ]; then
    exit 1
  fi
done
