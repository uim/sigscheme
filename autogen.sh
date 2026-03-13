#!/bin/sh

set -eu

${AUTORECONF:-autoreconf} --force --install "$@"
cd bdwgc
./autogen.sh
cd ../libgcroots
./autogen.sh "$@"
