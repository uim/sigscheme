#!/bin/sh

MAKE=make

git submodule update --init 
(cd libgcroots && git checkout master && ./autogen.sh) \
&& ./autogen.sh \
|| { echo 'autogen failed.' && exit 1; }

./configure --enable-maintainer-mode --enable-conf=full && $MAKE distcheck sum
