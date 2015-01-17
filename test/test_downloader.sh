#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh
. `dirname $0`/../libexec/downloader

test_source_url() {
  assertEquals "http://www.haskell.org/ghc/dist/1.2.3/ghc-1.2.3-src.tar.bz2" "`source_url 1.2.3`"
}

test_binary_url() {
  assertEquals "https://www.haskell.org/ghc/dist/7.8.4/ghc-7.8.4-x86_64-unknown-mingw32.tar.xz" "`binary_url x86_64-pc-msys 7.8.4`"
  assertEquals "https://www.haskell.org/ghc/dist/7.8.3/ghc-7.8.3-x86_64-unknown-mingw32.tar.xz" "`binary_url x86_64-pc-msys 7.8.3`"
  assertEquals "https://www.haskell.org/ghc/dist/7.8.3/ghc-7.8.3-i386-unknown-mingw32.tar.xz" "`binary_url i686-pc-mingw32 7.8.3`"
  assertEquals "" "`binary_url i686-pc-mingw32 1.2.3`"
}

test_url_basename() {
  assertEquals "bar" "`url_basename http://foo/bar`"
  assertEquals "bar.tar.xz" "`url_basename http://foo/bar.tar.xz`"
  assertEquals "bar.tar.xz" "`url_basename http://foo/bar.tar.xz#foo`"
  assertEquals "bar.tar.xz" "`url_basename http://foo/bar.tar.xz?foo`"
  assertEquals "bar.tar.xz" "`url_basename http://foo/bar.tar.xz?foo#foo`"
}

test_url_to_cache_name() {
  assertEquals "http%3A%2F%2Fwww%2Ehaskell%2Eorg%2Ffoo%3Bbar" `url_to_cache_name "http://www.haskell.org/foo;bar"`
}

test_downloader() {
  dir="$HSENV_TEST_TMP_DIR/downloader"

  if [ $HSENV_TEST_LEVEL -ge 1 ]; then
    rm -fr "$dir"
  fi

  mkdir -p "$dir"
  assertTrue "downloader http://saturday06.github.io/hsenv.sh/test/cr_lf.bin $dir/cr_lf.bin"
  assertTrue "cmp $HSENV_TEST_DATA_DIR/cr_lf.bin $dir/cr_lf.bin"
  assertTrue "downloader http://saturday06.github.io/hsenv.sh/test/null_0xa5.bin $dir/null_0xa5.bin"
  assertTrue "cmp $HSENV_TEST_DATA_DIR/null_0xa5.bin $dir/null_0xa5.bin"
  assertFalse "downloader http://saturday06.github.io/hsenv.sh/test/not.found.bin $dir/not.found.bin"
}

test_downloader_tools() {
  if [ $HSENV_TEST_LEVEL -lt 1 ]; then
    return
  fi

  tmp_dir="$HSENV_TEST_TMP_DIR/downloader_tools"
  rm -fr "$tmp_dir"
  mkdir -p "$tmp_dir"

  tested_downloaders=
  ignored_downloaders=
  for tool in curl wget fetch lwp-download; do
    if has_downloader $tool; then
      tested_downloaders="$tested_downloaders $tool"
      command="downloader_`echo $tool | sed 's/-/_/g'`"
      dir="$tmp_dir/$tool"
      mkdir -p "$dir"

      assertTrue "$command http://saturday06.github.io/hsenv.sh/test/cr_lf.bin $dir/cr_lf.bin"
      assertTrue "cmp $HSENV_TEST_DATA_DIR/cr_lf.bin $dir/cr_lf.bin"
      assertTrue "$command http://saturday06.github.io/hsenv.sh/test/null_0xa5.bin $dir/null_0xa5.bin"
      assertTrue "cmp $HSENV_TEST_DATA_DIR/null_0xa5.bin $dir/null_0xa5.bin"
      assertFalse "$command http://saturday06.github.io/hsenv.sh/test/not.found.bin $dir/not.found.bin"
    else
      ignored_downloaders="$ignored_downloaders $tool"
    fi
  done

  echo tested_downloaders: $tested_downloaders
  echo ignored_downloaders:$ignored_downloaders
}

. shunit2/src/shunit2
