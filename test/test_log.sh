#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh

test_early_log() {
  dir=$HSENV_TEST_TMP_DIR/early_log
  mkdir -p $dir
  cd $dir
  (
    unset_hsenv_envs
    export HSENV_COMMAND=$dir/test_early_log
    export HSENV_EARLY_LOG_FILE=$dir/early_log.txt
    cat <<EOF > $HSENV_COMMAND
      echo stdout
      echo stderr >&2
      sleep 0.2
      hsenv_trace trace
      hsenv_debug debug
      hsenv_info info
      hsenv_warn warn
      hsenv_error error
      hsenv_fatal fatal
EOF
    hsenv > stdout 2> stderr
  )

  assertEquals "\
stdout
stderr
info
warn
error
fatal\
" "`cat $dir/stdout`"
  assertEquals "" "`cat $dir/stderr`"
  assertEquals "\
Options:
stdout
stderr
trace
debug
info
warn
error
fatal\
" "`cat $dir/early_log.txt`"
}

test_early_log_v() {
  dir=$HSENV_TEST_TMP_DIR/early_log_v
  mkdir -p $dir
  cd $dir
  (
    unset_hsenv_envs
    export HSENV_COMMAND=$dir/test_early_log
    export HSENV_EARLY_LOG_FILE=$dir/early_log.txt
    cat <<EOF > $HSENV_COMMAND
      echo stdout
      echo stderr >&2
      sleep 0.2
      hsenv_trace trace
      hsenv_debug debug
      hsenv_info info
      hsenv_warn warn
      hsenv_error error
      hsenv_fatal fatal
EOF
    hsenv -v > stdout 2> stderr
  )

  assertEquals "\
stdout
stderr
debug
info
warn
error
fatal\
" "`cat $dir/stdout`"
  assertEquals "" "`cat $dir/stderr`"
  assertEquals "\
Options: -v
stdout
stderr
trace
debug
info
warn
error
fatal\
" "`cat $dir/early_log.txt`"
}

test_early_log_vv() {
  dir=$HSENV_TEST_TMP_DIR/early_log_vv
  mkdir -p $dir
  cd $dir
  (
    unset_hsenv_envs
    export HSENV_COMMAND=$dir/test_early_log
    export HSENV_EARLY_LOG_FILE=$dir/early_log.txt
    cat <<EOF > $HSENV_COMMAND
      echo stdout
      echo stderr >&2
      sleep 0.2
      hsenv_trace trace
      hsenv_debug debug
      hsenv_info info
      hsenv_warn warn
      hsenv_error error
      hsenv_fatal fatal
EOF
    hsenv --very-verbose > stdout 2> stderr
  )

  assertEquals "\
Options: --very-verbose
stdout
stderr
trace
debug
info
warn
error
fatal\
" "`cat $dir/stdout`"
  assertEquals "" "`cat $dir/stderr`"
  assertEquals "\
Options: --very-verbose
stdout
stderr
trace
debug
info
warn
error
fatal\
" "`cat $dir/early_log.txt`"
}

test_log() {
  dir=$HSENV_TEST_TMP_DIR/log
  mkdir -p $dir
  cd $dir
  (
    unset_hsenv_envs
    export HSENV_COMMAND=$dir/test_log
    export HSENV_EARLY_LOG_FILE=$dir/early_log.txt
    cat <<EOF > $HSENV_COMMAND
      echo stdout
      echo stderr >&2
      sleep 0.2
      hsenv_trace trace
      hsenv_debug debug
      hsenv_info info
      hsenv_warn warn
      hsenv_error error
      hsenv_fatal fatal
      move_log_to_install_dir
      echo stdout2
      echo stderr2 >&2
      sleep 0.2
      hsenv_trace trace2
      hsenv_debug debug2
      hsenv_info info2
      hsenv_warn warn2
      hsenv_error error2
      hsenv_fatal fatal2
EOF
    hsenv > stdout 2> stderr
  )

  assertEquals "\
stdout
stderr
info
warn
error
fatal
stdout2
stderr2
info2
warn2
error2
fatal2\
" "`cat $dir/stdout`"
  assertEquals "" "`cat $dir/stderr`"
  assertFalse "test -e $dir/early_log.txt"
  assertEquals "\
Options:
stdout
stderr
trace
debug
info
warn
error
fatal
stdout2
stderr2
trace2
debug2
info2
warn2
error2
fatal2\
" "`cat $dir/.hsenv/hsenv.log`"
}

. shunit2/src/shunit2
