#!/bin/sh

set -eu

${AUTORECONF:-autoreconf} --force --install "$@"
cd libgcroots
./autogen.sh "$@"
