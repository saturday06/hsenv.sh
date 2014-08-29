#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh
. `dirname $0`/../libexec/option

test_parse() {
  parse
  assertEquals "" "$HSENV_NAME"
  assertEquals "" "$HSENV_GHC"
  assertEquals "3" "$HSENV_LOG_LEVEL"
  assertEquals "hsenv_main" "$HSENV_COMMAND"

  parse --verbose
  assertEquals "" "$HSENV_NAME"
  assertEquals "" "$HSENV_GHC"
  assertEquals "4" "$HSENV_LOG_LEVEL"

  parse --very-verbose
  assertEquals "" "$HSENV_NAME"
  assertEquals "" "$HSENV_GHC"
  assertEquals "5" "$HSENV_LOG_LEVEL"

  parse --very-verbose --verbose
  assertEquals "" "$HSENV_NAME"
  assertEquals "" "$HSENV_GHC"
  assertEquals "5" "$HSENV_LOG_LEVEL"

  parse --verbose --very-verbose
  assertEquals "" "$HSENV_NAME"
  assertEquals "" "$HSENV_GHC"
  assertEquals "5" "$HSENV_LOG_LEVEL"

  parse --name=foo
  assertEquals "foo" "$HSENV_NAME"
  assertEquals "" "$HSENV_GHC"
  assertEquals "3" "$HSENV_LOG_LEVEL"

  parse --ghc=source
  assertEquals "" "$HSENV_NAME"
  assertEquals "source" "$HSENV_GHC"
  assertEquals "3" "$HSENV_LOG_LEVEL"

  parse --name=bar --ghc=http://example.com/foo.tar.gz --verbose
  assertEquals "bar" "$HSENV_NAME"
  assertEquals "http://example.com/foo.tar.gz" "$HSENV_GHC"
  assertEquals "4" "$HSENV_LOG_LEVEL"

  parse --version
  assertEquals "hsenv_version" "$HSENV_COMMAND"

  parse --help
  assertEquals "hsenv_help" "$HSENV_COMMAND"
}

test_is_version() {
  assertTrue  "is_version 1"
  assertTrue  "is_version 11"
  assertFalse "is_version 11."
  assertTrue  "is_version 11.1"
  assertFalse "is_version 11x1"
  assertFalse "is_version .1.1"
  assertTrue  "is_version 1.12"
  assertFalse "is_version 1.12."
  assertTrue  "is_version 1.1.2"
  assertFalse "is_version 1.1 2"
}

test_is_url() {
  assertTrue  "is_url http://a"
  assertTrue  "is_url https://bb"
  assertFalse "is_url ttps://bb"
  assertFalse "is_url ttp://bb"
}

test_installation_of() {
  assertEquals "transplant_local_executable" "`installation_of`"
  assertEquals "transplant_local_executable" "`installation_of ''`"
  assertEquals "install_remote_source" "`installation_of 7.8.3`"
  assertEquals "install_remote_source" "`installation_of 1.2`"
  assertEquals "install_remote" "`installation_of http://aa`"
  assertEquals "install_remote" "`installation_of https://x/y.tar.xz`"
  assertEquals "install_remote" "`installation_of http://a.b/c.tar.bz2`"
  assertEquals "install_local" "`installation_of foo`"
  assertEquals "install_local" "`installation_of foo-1.0.tar.xz`"
}

. shunit2/src/shunit2
