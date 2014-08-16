#!/bin/sh

cd `dirname $0`

run_test() {
  tmpdir=../tmp/run_test
  rm -fr $tmpdir
  mkdir -p $tmpdir
  echo HSENV_TEST_SHELL=$HSENV_TEST_SHELL
  for t in *_test.sh; do
    echo "[$t]"
    error_regexp="shunit2:ERROR"
    esc=`echo -e "\033"`
    rm -f $tmpdir/succeed
    if [ "$HSENV_TEST_COLOR" = "yes" ]; then
      ($HSENV_TEST_SHELL $t 2>&1 && touch $tmpdir/succeed) \
        | sed -e "s/^\(${error_regexp}\)/$esc[31;1m\1$esc[m/" \
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
    if grep -E "$error_regexp" $tmpdir/test_result.txt > /dev/null; then
      if [ "$HSENV_TEST_COLOR" = "yes" ]; then
        echo -e "\n$esc[31;1mFAILED$esc[m"
      else
        echo "FAILED"
      fi
      exit 1
    fi
  done

  if [ "$HSENV_TEST_COLOR" = "yes" ]; then
    echo -e "\n$esc[32;1mSUCCEED$esc[m"
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
