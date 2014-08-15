#!/bin/sh

cd `dirname $0`
for sh in *_test.sh; do
  echo "[$sh]"
  /bin/sh $sh
done
