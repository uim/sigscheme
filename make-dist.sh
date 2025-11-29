#!/bin/sh

set -eu

MAKE=make

git submodule update --init
./autogen.sh

./configure --enable-maintainer-mode --enable-conf=full
$MAKE distcheck sum
