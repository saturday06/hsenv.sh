#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh
. `dirname $0`/../libexec/downloader

prepare_base_system_from_source() (
  version=$1
  tmpdir=$_hsenv_test_tmpdir/prepare_base_system
  srcdir=$_hsenv_test_tmpdir/src
  basedir=$_hsenv_test_tmpdir/base_system
  url=`source_url $version`
  file=`url_basename $url`
  mkdir -p $basedir $tmpdir $srcdir
  downloader $url $tmpdir/$file || return 1
  cd $srcdir
  (bzip2 -cd $tmpdir/$file | tar xf -) && \
    cd ghc-$version && \
    ./configure --prefix=$basedir && \
    $HSENV_TEST_MAKE && \
    $HSENV_TEST_MAKE install
)

prepare_base_system_from_binary() (
  version=$1
  tmpdir=$_hsenv_test_tmpdir/prepare_base_system
  srcdir=$_hsenv_test_tmpdir/precompiled
  basedir=$_hsenv_test_tmpdir/base_system
  url=`binary_url $version`
  file=`url_basename $url`
  mkdir -p $basedir $tmpdir $srcdir
  downloader $url $tmpdir/$file || return 1
  cd $srcdir
  (bzip2 -cd $tmpdir/$file | tar xf -) && \
    cd ghc-$version && \
    if [ -e configure ]; then \
      ./configure --prefix=$basedir && \
      $HSENV_TEST_MAKE install \
    else \
      cp -fr * $basedir
    fi
)

test_transplant() {
  if ! has_command $_hsenv_test_tmpdir/base_system/bin/ghc; then
    if has_command ghc; then
      prepare_base_system_from_source 7.8.3
    else
      prepare_base_system_from_binary 7.8.3
    fi
  fi
  assertTrue $?
}

. shunit2/src/shunit2
