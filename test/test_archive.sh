#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh
. `dirname $0`/../libexec/archive

test_ignorable_tar_error() {
  _hsenv_private_host_os=mingw32
  f=$_hsenv_test_tmp_dir/ignorable_tar_error.txt
  echo > $f

  assertFalse "ignorable_tar_error $f"

  cat <<EOF > $f
/usr/bin/tar: Archive value 197108 is out of uid_t range 00065535
/usr/bin/tar: Archive value 197121 is out of gid_t range 0..65535
/usr/bin/tar: Archive value 197108 is out of uid_t range 0..65535
tar Exiting with failure status due to previous errors
EOF
  assertFalse "ignorable_tar_error $f"

  cat <<EOF > $f
/usr/bin/tar: Archive value 197108 is out of uid_t range 0..65535
/usr/bin/tar: Archive value 197121 is out of gid_t range 0..65535
/usr/bin/tar: Archive value 197108 is out of uid_t range 0..65535
tar Exiting with failure status due to previous errors
EOF
  assertTrue "ignorable_tar_error $f"
  _hsenv_private_host_os=linux
  assertFalse "ignorable_tar_error $f"
  _hsenv_private_host_os=mingw64
  assertTrue "ignorable_tar_error $f"
}

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
