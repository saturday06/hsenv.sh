#!/bin/sh

cd `dirname $0`
for sh in *_test.sh; do
  echo "[$sh]"
  /bin/sh $sh
  if [ $? -ne 0 ]; then
    exit 1
  fi
done
