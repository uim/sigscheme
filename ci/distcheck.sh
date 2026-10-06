#!/bin/bash

set -eux

/source/configure \
  --enable-conf=uim \
  --enable-maintainer-mode \
  --prefix=/tmp/local

make distcheck DISTCHECK_CONFIGURE_FLAGS="--enable-conf=uim" VERBOSE=1
make sum

sudo -H mv *.tar.* *.sum /source/
