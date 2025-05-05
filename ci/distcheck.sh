#!/bin/bash

set -eux

/source/configure \
  --enable-conf=uim \
  --enable-maintainer-mode \
  --prefix=/tmp/local

make distcheck
make sum

sudo -H mv *.tar.* *.sum /source/
