#!/bin/sh

PATH="`dirname $0`/../bin:$PATH"
if [ -n "${ZSH_VERSION:-}" ]; then
  setopt shwordsplit
  SHUNIT_PARENT=$0
fi
