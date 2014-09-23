#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh
. `dirname $0`/../libexec/archive

test_ignorable_tar_error() {
  HSENV_HOST_OS=mingw32
  f=$HSENV_TEST_TMP_DIR/ignorable_tar_error.txt
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
  HSENV_HOST_OS=linux
  assertFalse "ignorable_tar_error $f"
  HSENV_HOST_OS=mingw64
  assertTrue "ignorable_tar_error $f"
}

test_extract_archive() {
  data_dir=$HSENV_TEST_DATA_DIR/extract_archive
  out_dir=$HSENV_TEST_TMP_DIR/extract_archive
  mkdir -p $out_dir

  assertTrue "extract_archive $data_dir/test.tar.gz $out_dir/gz"
  assertTrue "cmp $data_dir/gz.txt $out_dir/gz/gz.txt"
  assertTrue "extract_archive $data_dir/test.tgz $out_dir/tgz"
  assertTrue "cmp $data_dir/gz.txt $out_dir/tgz/gz.txt"
  assertFalse "extract_archive $data_dir/multi_root.tar.gz $out_dir/mgz"

  assertTrue "extract_archive $data_dir/test.tar.bz2 $out_dir/bz2"
  assertTrue "cmp $data_dir/bz2.txt $out_dir/bz2/bz2.txt"
  assertTrue "extract_archive $data_dir/test.tbz $out_dir/tbz"
  assertTrue "cmp $data_dir/bz2.txt $out_dir/tbz/bz2.txt"
  assertFalse "extract_archive $data_dir/multi_root.tar.bz2 $out_dir/mbz2"

  assertTrue "extract_archive $data_dir/test.tar.xz $out_dir/xz"
  assertTrue "cmp $data_dir/xz.txt $out_dir/xz/xz.txt"
  assertTrue "extract_archive $data_dir/test.txz $out_dir/txz"
  assertTrue "cmp $data_dir/xz.txt $out_dir/txz/xz.txt"
  assertFalse "extract_archive $data_dir/multi_root.tar.xz $out_dir/mxz"

  assertTrue "extract_archive $data_dir/test.tar $out_dir/tar"
  assertTrue "cmp $data_dir/tar.txt $out_dir/tar/tar.txt"
  assertFalse "extract_archive $data_dir/multi_root.tar $out_dir/mtar"

  rm -fr $HSENV_EXTRACT_ARCHIVE_DIR
}

. shunit2/src/shunit2
