#!/bin/sh

MAKE=make

UIM_REPOSITORY="http://anonsvn.freedesktop.org/svn/uim"
SSCM_REPOSITORY="${UIM_REPOSITORY}/sigscheme-trunk"
TAGS_REPOSITORY="${UIM_REPOSITORY}/tags"
LIBGCROOTS_URL="${TAGS_REPOSITORY}/libgcroots-0.1.2"

svn export $LIBGCROOTS_URL libgcroots
(cd libgcroots && ./autogen.sh) && ./autogen.sh
./configure --enable-maintainer-mode --enable-conf=full
$MAKE distcheck sum
