#!/bin/sh

PATH="`dirname $SHUNIT_PARENT`/../bin:$PATH"
if [ -n "${ZSH_VERSION:-}" ]; then
  setopt shwordsplit
fi
