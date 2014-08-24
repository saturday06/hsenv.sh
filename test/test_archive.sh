#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh
. `dirname $0`/../libexec/archive

test_extract_archive() {
  data_dir=$_hsenv_test_data_dir/extract_archive
  out_dir=$_hsenv_test_tmp_dir/extract_archive
  mkdir -p $out_dir

  assertTrue "extract_archive $data_dir/test.tar.gz $out_dir/gz"
  assertTrue "cmp $data_dir/gz.txt $out_dir/gz/gz.txt"
  assertFalse "extract_archive $data_dir/multi_root.tar.gz $out_dir/gz"

  assertTrue "extract_archive $data_dir/test.tar.bz2 $out_dir/bz2"
  assertTrue "cmp $data_dir/bz2.txt $out_dir/bz2/bz2.txt"
  assertFalse "extract_archive $data_dir/multi_root.tar.bz2 $out_dir/bz2"

  assertTrue "extract_archive $data_dir/test.tar.xz $out_dir/xz"
  assertTrue "cmp $data_dir/xz.txt $out_dir/xz/xz.txt"
  assertFalse "extract_archive $data_dir/multi_root.tar.xz $out_dir/xz"

  rm -fr $_hsenv_private_extract_archive_tmp_dir
}

. shunit2/src/shunit2
