#!/bin/sh

cd `dirname $0`
tmpdir=../tmp/watch
rm -fr $tmpdir
mkdir -p $tmpdir
while true; do
  ./run.sh > $tmpdir/next.txt 2>&1
  testresult=$?
  if ! cmp $tmpdir/previous.txt $tmpdir/next.txt; then
    echo -ne "\033c" # clear screen
    cat $tmpdir/next.txt
    cp $tmpdir/next.txt $tmpdir/previous.txt
    if [ $testresult -eq 0 ]; then
        echo -e "\nSUCCEED"
    fi
  fi
  sleep 1
done
