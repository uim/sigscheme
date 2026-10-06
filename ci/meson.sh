#!/bin/bash

set -eux

meson setup \
  --prefix=/tmp/local \
  -Dconf=uim \
  /tmp/meson-build \
  /source
meson compile -C /tmp/meson-build
meson test -C /tmp/meson-build --print-errorlogs
meson install -C /tmp/meson-build
