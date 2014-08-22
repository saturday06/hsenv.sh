#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh
. `dirname $0`/../libexec/downloader

test_url_basename() {
  assertEquals "bar" "`url_basename http://foo/bar`"
  assertEquals "bar.tar.xz" "`url_basename http://foo/bar.tar.xz`"
  assertEquals "bar.tar.xz" "`url_basename http://foo/bar.tar.xz#foo`"
  assertEquals "bar.tar.xz" "`url_basename http://foo/bar.tar.xz?foo`"
  assertEquals "bar.tar.xz" "`url_basename http://foo/bar.tar.xz?foo#foo`"
}

test_downloader() {
  if [ $HSENV_TEST_LEVEL -lt 1 ]; then
    return
  fi

  tmpdir="$_hsenv_test_tmpdir/downloader"
  rm -fr "$tmpdir"
  mkdir -p "$tmpdir"

  url=http://saturday06.github.io/hsenv-teokure/test/cr_lf.bin
  file="$tmpdir/output.bin"
  tested_downloaders=
  ignored_downloaders=
  for tool in curl wget fetch lwp-download; do
    if has_command $tool; then
      tested_downloaders="$tested_downloaders $tool"
      command="downloader_`echo $tool | sed 's/-/_/'`"

      rm -f $file
      $command $url $file
      result=$?
      assertTrue $result

      rm -f $file
      $command $url.not.found $file
      result=$?
      assertFalse $result
    else
      ignored_downloaders="$ignored_downloaders $tool"
    fi
  done

  rm -f $file
  downloader $url $file
  result=$?
  assertTrue $result

  rm -f $file
  downloader $url.not.found $file
  result=$?
  assertFalse $result

  echo tested_downloaders: $tested_downloaders
  echo ignored_downloaders:$ignored_downloaders
}

. shunit2/src/shunit2
