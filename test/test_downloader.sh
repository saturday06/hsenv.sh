#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh
. `dirname $0`/../libexec/downloader

test_source_url() {
  assertEquals "http://www.haskell.org/ghc/dist/1.2.3/ghc-1.2.3-src.tar.bz2" "`source_url 1.2.3`"
}

test_binary_url() {
  _hsenv_private_host_os=linux
  assertEquals "http://www.haskell.org/ghc/dist/7.8.3/ghc-7.8.3-x86_64-unknown-linux-deb7.tar.bz2" "`binary_url 7.8.3`"
  _hsenv_private_host_os=darwin
  assertEquals "http://www.haskell.org/ghc/dist/7.8.3/ghc-7.8.3-x86_64-apple-darwin.tar.bz2" "`binary_url 7.8.3`"
}

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

  tested_downloaders=
  ignored_downloaders=
  for tool in curl wget fetch lwp-download; do
    if has_command $tool; then
      tested_downloaders="$tested_downloaders $tool"
      command="downloader_`echo $tool | sed 's/-/_/g'`"
      dir="$tmpdir/$tool"
      mkdir -p "$dir"

      assertTrue "$command http://saturday06.github.io/hsenv-teokure/test/cr_lf.bin $dir/cr_lf.bin"
      assertTrue "cmp $_hsenv_test_datadir/cr_lf.bin $dir/cr_lf.bin"
      assertTrue "$command http://saturday06.github.io/hsenv-teokure/test/null_0xa5.bin $dir/null_0xa5.bin"
      assertTrue "cmp $_hsenv_test_datadir/null_0xa5.bin $dir/null_0xa5.bin"
      assertFalse "$command http://saturday06.github.io/hsenv-teokure/test/not.found.bin $dir/not.found.bin"
    else
      ignored_downloaders="$ignored_downloaders $tool"
    fi
  done

  dir="$tmpdir/downloader"
  mkdir -p "$dir"

  assertTrue "downloader http://saturday06.github.io/hsenv-teokure/test/cr_lf.bin $dir/cr_lf.bin"
  assertTrue "cmp $_hsenv_test_datadir/cr_lf.bin $dir/cr_lf.bin"
  assertTrue "downloader http://saturday06.github.io/hsenv-teokure/test/null_0xa5.bin $dir/null_0xa5.bin"
  assertTrue "cmp $_hsenv_test_datadir/null_0xa5.bin $dir/null_0xa5.bin"
  assertFalse "downloader http://saturday06.github.io/hsenv-teokure/test/not.found.bin $dir/not.found.bin"

  echo tested_downloaders: $tested_downloaders
  echo ignored_downloaders:$ignored_downloaders
}

. shunit2/src/shunit2
