#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh
. `dirname $0`/../libexec/downloader

prepare_base_system_from_source() (
  version=$1
  tmp_dir=$_hsenv_test_tmp_dir/prepare_base_system
  src_dir=$_hsenv_test_tmp_dir/src
  base_dir=$_hsenv_test_tmp_dir/base_system
  url=`source_url $version`
  file=`url_basename $url`
  mkdir -p $base_dir $tmp_dir $src_dir
  downloader $url $tmp_dir/$file || return 1
  cd $src_dir
  (bzip2 -cd $tmp_dir/$file | tar xf -) && \
    cd ghc-$version && \
    ./configure --prefix=$base_dir && \
    ($HSENV_TEST_MAKE || true) && \
    $HSENV_TEST_MAKE install
)

prepare_base_system_from_binary() (
  version=$1
  tmp_dir=$_hsenv_test_tmp_dir/prepare_base_system
  src_dir=$_hsenv_test_tmp_dir/precompiled
  base_dir=$_hsenv_test_tmp_dir/base_system
  url=`binary_url $version`
  file=`url_basename $url`
  mkdir -p $base_dir $tmp_dir $src_dir
  downloader $url $tmp_dir/$file || return 1
  cd $src_dir
  (bzip2 -cd $tmp_dir/$file | tar xf -) && \
    cd ghc-$version && \
    if [ -e configure ]; then \
      ./configure --prefix=$base_dir && \
      $HSENV_TEST_MAKE install \
    else \
      cp -fr * $base_dir
    fi
)

test_transplant() {
  if ! has_command $_hsenv_test_tmp_dir/base_system/bin/ghc; then
    if has_command ghc; then
      prepare_base_system_from_source 7.8.3
    else
      prepare_base_system_from_binary 7.8.3
    fi
  fi
  assertTrue $?
}

. shunit2/src/shunit2
