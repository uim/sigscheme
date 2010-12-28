#!/bin/sh

MAKE=make

UIM_REPOSITORY="http://uim.googlecode.com/svn"
TAGS_REPOSITORY="${UIM_REPOSITORY}/tags"
SSCM_REPOSITORY="${UIM_REPOSITORY}/sigscheme-trunk"
#SSCM_REPOSITORY="${TAGS_REPOSITORY}/sigscheme-0.9.0"
LIBGCROOTS_URL="${UIM_REPOSITORY}/libgcroots-trunk"
#LIBGCROOTS_URL="${TAGS_REPOSITORY}/libgcroots-0.2.3"

svn export $LIBGCROOTS_URL libgcroots
(cd libgcroots && ./autogen.sh) \
&& ./autogen.sh \
|| { echo 'autogen failed.' && exit 1; }

./configure --enable-maintainer-mode --enable-conf=full && $MAKE distcheck sum
