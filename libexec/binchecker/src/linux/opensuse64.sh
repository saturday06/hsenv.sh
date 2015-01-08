#!/bin/sh

set -e
export LC_ALL=C

out=ix86-pc-linux-gnu-gmp5
echo === $out ===
gcc -m32 -s -nostartfiles -o ../../$out \
  /lib/libdl.so.2 \
  /lib/libgcc_s.so.1 \
  /lib/libm.so.6 \
  /lib/libpthread.so.0 \
  /lib/librt.so.1 \
  /lib/libtinfo.so.5 \
  /lib/libutil.so.1 \
  /usr/lib/libgmp.so.10 \
  ix86/app.s
objdump -adx ../../$out > $out.info
ldd ../../$out > $out.out.ldd
awk '{print $1}' $out.out.ldd | sort > $out.solist
awk '{print $1}' ix86/gmp5.ghc-7_8_4.ldd | grep -v "^libHS" | grep -v "^libffi\.so\.6$" | sort > gmp5.ghc-7_8_4.solist
diff -u gmp5.ghc-7_8_4.solist $out.solist
../../$out

out=x86_64-unknown-linux-gnu-gmp5
echo === $out ===
gcc -m64 -s -nostartfiles -o ../../$out \
  /lib64/libc.so.6 \
  /lib64/libdl.so.2 \
  /lib64/libgcc_s.so.1 \
  /lib64/libm.so.6 \
  /lib64/libpthread.so.0 \
  /lib64/librt.so.1 \
  /lib64/libtinfo.so.5 \
  /lib64/libutil.so.1 \
  /usr/lib64/libgmp.so.10 \
  x86_64/app.s
objdump -adx ../../$out > $out.info
ldd ../../$out > $out.out.ldd
awk '{print $1}' $out.out.ldd | sort > $out.solist
awk '{print $1}' x86_64/gmp5.ghc-7_8_4.ldd | grep -v "^libHS" | grep -v "^libffi\.so\.6$" | sort > gmp5.ghc-7_8_4.solist
diff -u gmp5.ghc-7_8_4.solist $out.solist
../../$out

echo done
