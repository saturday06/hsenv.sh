#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh
. `dirname $0`/../libexec/package

test_dependencies_to_package_name_and_version() {
  deps=`cat <<DEPS
depends: ghc-prim-0.3.1.0-95dc0c72a075ab56f8cdd74470fc7c3d
         integer-gmp-0.5.1.0-d42e6a7874a019e6a0d1c7305ebc83c4 builtin_rts
DEPS`
  assertEquals "ghc-prim-0.3.1.0 integer-gmp-0.5.1.0 rts" "`dependencies_to_package_name_and_version $deps`"

  deps=`cat <<DEPS
depends: Win32-2.3.0.2-698249828064ce7d3e731406aa0b6536
         base-4.7.0.1-7c4827d45272c6220486aa798a981cbc
         old-locale-1.0.0.6-09baf1dbc5be8338e5eba7c5bb515505
DEPS`
  assertEquals "Win32-2.3.0.2 base-4.7.0.1 old-locale-1.0.0.6" "`dependencies_to_package_name_and_version $deps`"
}

test_dependency_to_package_name_and_version() {
  assertEquals "ghc-prim" "`dependency_to_package_name_and_version ghc-prim`"
  assertEquals "ghc-prim-0.3.1.0" "`dependency_to_package_name_and_version ghc-prim-0.3.1.0`"
  assertEquals "ghc-prim-0.3.1.0" "`dependency_to_package_name_and_version ghc-prim-0.3.1.0-95dc0c72a075ab56f8cdd74470fc7c3d`"
  assertEquals "rts" "`dependency_to_package_name_and_version builtin_rts`"
  assertEquals "foo-1a" "`dependency_to_package_name_and_version foo-1a`"
  assertEquals "foo-1a-11.02" "`dependency_to_package_name_and_version foo-1a-11.02`"
  assertEquals "foo-1a-11.02" "`dependency_to_package_name_and_version foo-1a-11.02-95dc0c72a075ab56f8cdd74470fc7c3d`"
}

test_dependency_to_package_name() {
  assertEquals "ghc-prim" "`dependency_to_package_name ghc-prim`"
  assertEquals "ghc-prim" "`dependency_to_package_name ghc-prim-0.3.1.0`"
  assertEquals "ghc-prim" "`dependency_to_package_name ghc-prim-0.3.1.0-95dc0c72a075ab56f8cdd74470fc7c3d`"
  assertEquals "rts" "`dependency_to_package_name builtin_rts`"
  assertEquals "foo-1a" "`dependency_to_package_name foo-1a`"
  assertEquals "foo-1a" "`dependency_to_package_name foo-1a-1.0`"
  assertEquals "foo-1a" "`dependency_to_package_name foo-1a-1.0-95dc0c72a075ab56f8cdd74470fc7c3d`"
}

test_dependency_to_package_version() {
  assertEquals "" "`dependency_to_package_version ghc-prim`"
  assertEquals "0.3.1.0" "`dependency_to_package_version ghc-prim-0.3.1.0`"
  assertEquals "0.3.1.0" "`dependency_to_package_version ghc-prim-0.3.1.0-95dc0c72a075ab56f8cdd74470fc7c3d`"
  assertEquals "" "`dependency_to_package_version builtin_rts`"
  assertEquals "" "`dependency_to_package_version foo-1a`"
  assertEquals "1.0" "`dependency_to_package_version foo-1a-1.0`"
  assertEquals "1.0" "`dependency_to_package_version foo-1a-1.0-95dc0c72a075ab56f8cdd74470fc7c3d`"
}

. shunit2/src/shunit2
