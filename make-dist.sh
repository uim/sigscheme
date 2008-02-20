#!/bin/sh

MAKE=make

UIM_REPOSITORY="http://uim.googlecode.com/svn"
TAGS_REPOSITORY="${UIM_REPOSITORY}/tags"
#SSCM_REPOSITORY="${UIM_REPOSITORY}/branches/sigscheme-0.7"
SSCM_REPOSITORY="${TAGS_REPOSITORY}/sigscheme-0.7.6"
#LIBGCROOTS_URL="${UIM_REPOSITORY}/libgcroots-trunk"
LIBGCROOTS_URL="${TAGS_REPOSITORY}/libgcroots-0.2.1"

svn export $LIBGCROOTS_URL libgcroots
(cd libgcroots && ./autogen.sh) \
&& ./autogen.sh \
|| { echo 'autogen failed.' && exit 1; }

./configure --enable-maintainer-mode --enable-conf=full && $MAKE distcheck sum
