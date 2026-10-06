#!/bin/sh

set -eu

${AUTORECONF:-autoreconf} --force --install "$@"
cd subprojects/libgcroots
./autogen.sh "$@"
