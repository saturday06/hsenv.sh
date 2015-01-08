#!/bin/sh

set -e
export LC_ALL=C

out=x86_64-apple-darwin11.0.0
echo === $out ===
gcc -nostartfiles -o ../../$out \
  /usr/lib/libiconv.2.dylib \
  /usr/lib/libncurses.5.4.dylib \
  x86_64/app.s
otool -tv ../../$out > $out.info
otool -L ../../$out > $out.out.ldd
tail -n +2 $out.out.ldd | awk '{print $1" "$2" "$3" "$4" "$5}' | sort > $out.solist
tail -n +2 x86_64/ghc-7_8_3.ldd | awk '{print $1" "$2" "$3" "$4" "$5}' | grep -v "^@rpath/" | sort > ghc-7_8_3.solist
diff -u ghc-7_8_3.solist $out.solist
../../$out

echo done
