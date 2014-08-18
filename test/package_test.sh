#!/bin/sh

SHUNIT_PARENT=$0
. `dirname $0`/init.sh
. `dirname $0`/../libexec/package

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
