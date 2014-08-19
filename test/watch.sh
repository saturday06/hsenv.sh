#!/bin/sh

cd `dirname $0`
tmpdir=../tmp/watch
rm -fr $tmpdir
while true; do
  mkdir -p $tmpdir
  HSENV_TEST_COLOR=yes ./run.sh > $tmpdir/next.txt 2>&1
  testresult=$?
  if ! cmp $tmpdir/previous.txt $tmpdir/next.txt; then
    awk 'BEGIN { printf("%cc", 27) }' # clear screen
    cat $tmpdir/next.txt
    cp $tmpdir/next.txt $tmpdir/previous.txt
  fi
  sleep 1
done
