#!/bin/sh

set -e
export LC_ALL=C

out=ix86-pc-solaris2.11
echo === $out ===
gcc -m32 -s -nostartfiles -o ../../$out \
  /lib/libdl.so.1 \
  /lib/libpthread.so.1 \
  /lib/librt.so.1 \
  /usr/lib/libffi.so.5 \
  /usr/lib/libgcc_s.so.1 \
  /usr/lib/libgmp.so.3 \
  /usr/lib/libncurses.so.5 \
  ix86/app.s
ldd ../../$out > $out.out.ldd
awk '{print $1}' $out.out.ldd | sort > $out.solist
awk '{print $1}' ix86/v11.ghc-7_8_3.ldd | grep -v "^libHS" | sort > v11.ghc-7_8_3.solist
diff -u v11.ghc-7_8_3.solist $out.solist
../../$out

out=ix86-pc-solaris2.10
echo === $out ===
gcc -m32 -s -nostartfiles -o ../../$out \
  /lib/libcurses.so.1 \
  /lib/libdl.so.1 \
  /lib/libpthread.so.1 \
  /lib/librt.so.1 \
  ix86/app.s
ldd ../../$out > $out.out.ldd
awk '{print $1}' $out.out.ldd | sort > $out.solist
awk '{print $1}' ix86/v10.ghc-7_8_3.ldd | grep -v "^libHS" | sort > v10.ghc-7_8_3.solist
diff -u v10.ghc-7_8_3.solist $out.solist
../../$out

echo done
