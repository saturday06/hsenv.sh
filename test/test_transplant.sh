#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh
. `dirname $0`/../libexec/downloader

prepare_base_system() (
  version=$1
  tmp_dir=$_hsenv_test_tmp_dir/transplant
  src_dir=$tmp_dir/src
  base_dir=$tmp_dir/base_system
  if has_command $base_dir/bin/ghc; then
    return 0
  fi

  rm -fr $tmp_dir
  mkdir -p $tmp_dir
  if has_command ghc && ! is_mingw; then
    url=`source_url $version`
  else
    url=`binary_url $version`
  fi
  if [ -z "$url" ]; then
    # Oops!
    return 0
  fi
  file=`url_basename $url`
  downloader $url $tmp_dir/$file || return 1
  extract_archive $tmp_dir/$file $src_dir && \
    if [ -e $src_dir/configure ]; then \
      cd $src_dir && \
      ./configure --prefix=$base_dir && \
      ($HSENV_TEST_MAKE || true) && \
      $HSENV_TEST_MAKE install
    else
      mv $src_dir $base_dir
    fi
)

test_transplant() {
  prepare_base_system 7.8.3
  assertTrue $?
}

. shunit2/src/shunit2
