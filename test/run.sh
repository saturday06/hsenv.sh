#!/bin/sh

cd `dirname $0`

run_test() {
  tmpdir=../tmp/run_test
  esc=`awk 'BEGIN { printf("%c", 27) }'`
  rm -fr $tmpdir
  mkdir -p $tmpdir
  echo HSENV_TEST_SHELL=$HSENV_TEST_SHELL
  for t in test_*.sh; do
    echo "[$t]"
    error_regexp1="shunit2:ERROR"
    error_regexp2="Ran 0 tests\."
    rm -f $tmpdir/succeed
    if [ "$HSENV_TEST_COLOR" = "yes" ]; then
      ($HSENV_TEST_SHELL $t 2>&1 && touch $tmpdir/succeed) \
        | sed -e "s/${error_regexp1}/$esc[31;1m\0$esc[m/" \
        | sed -e "s/${error_regexp2}/$esc[31;1m\0$esc[m/" \
        | sed -e "s/^\(ASSERT:\)/$esc[31;1m\1$esc[m/" \
        | sed -e "s/^\(FAILED .*\)/$esc[31;1m\1$esc[m/" \
        | tee $tmpdir/test_result.txt
    else
      ($HSENV_TEST_SHELL $t 2>&1 && touch $tmpdir/succeed) \
        | tee $tmpdir/test_result.txt
    fi
    if [ ! -e $tmpdir/succeed ]; then
      exit 1
    fi
    for r in "$error_regexp1" "$error_regexp2"; do
      if grep -E "$r" $tmpdir/test_result.txt > /dev/null; then
        [ "$HSENV_TEST_COLOR" = "yes" ] && echo "$esc[31;1m"
        echo "Error regexp: /$r/ found"
        echo "FAILED"
        [ "$HSENV_TEST_COLOR" = "yes" ] && echo "$esc[m"
        exit 1
      fi
    done
  done

  if [ "$HSENV_TEST_COLOR" = "yes" ]; then
    echo "$esc[32;1mSUCCEED$esc[m"
  else
    echo "SUCCEED"
  fi
}

if [ "$HSENV_TEST_COLOR" = "" ]; then
  if [ -t ]; then
    HSENV_TEST_COLOR=yes
  else
    HSENV_TEST_COLOR=no
  fi
fi

if [ "$1" = "all" ]; then
  tested_shells=
  ignored_shells=
  for sh in ash bash dash ksh mksh posh zsh; do
    which $sh > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      ignored_shells="$ignored_shells $sh"
      continue
    fi
    tested_shells="$tested_shells $sh"
    HSENV_TEST_SHELL=$sh
    run_test
    if [ $? -ne 0 ]; then
      exit 1
    fi
  done
  echo tested shells: $tested_shells
  echo ignored shells:$ignored_shells
  exit
fi

if [ "$HSENV_TEST_SHELL" = "" ]; then
  HSENV_TEST_SHELL=/bin/sh
fi

run_test
