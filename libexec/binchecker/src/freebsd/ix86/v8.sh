#!/bin/sh

set -e
export LC_ALL=C

out=ix86-unknown-freebsd8
echo === $out ===
gcc -s -o $out \
  /lib/libgcc_s.so.1 \
  /lib/libm.so.5 \
  /lib/libncurses.so.8 \
  /lib/libthr.so.3 \
  /lib/libutil.so.8 \
  /usr/lib/librt.so.1 \
  /usr/local/lib/libcharset.so.1 \
  /usr/local/lib/libgmp.so.10 \
  /usr/local/lib/libiconv.so.3 \
  app.s
sed -i.bak -e 's/libiconv\.so\.2/libiconv.so.3/' $out
rm $out.bak
objdump -adx $out > $out.info
ldd $out > $out.out.ldd
tail -n +2 $out.out.ldd | awk '{print $1}' | sort > $out.solist
tail -n +2 ghc-7_8_3.ldd  | awk '{print $1}' | grep -v "^libHS" | grep -v "^libffi\.so\.6$" | sort > ghc-7_8_3.solist
diff -u ghc-7_8_3.solist $out.solist
./$out
mv $out ../../../

echo done
