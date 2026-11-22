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

# AddressSanitizer with the bundled libgcroots and the tiny
# substitution of libgcroots. --force-fallback-for=gcroots is for
# using the bundled libgcroots even if system libgcroots exists.
for gc in gcroots tiny-subst; do
  meson setup \
    --force-fallback-for=gcroots \
    -Db_lundef=false \
    -Db_sanitize=address \
    -Dconf=full \
    -Dgc=${gc} \
    /tmp/meson-build-asan-${gc} \
    /source
  meson test -C /tmp/meson-build-asan-${gc} --print-errorlogs
done
