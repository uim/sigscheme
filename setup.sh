#!/bin/sh

set -eux

if type sudo > /dev/null 2>&1; then
  SUDO=sudo
else
  SUDO=
fi

function setup_with_apt () {
  ${SUDO} apt update
  ${SUDO} apt install -y -V \
    asciidoc \
    autoconf \
    autoconf-archive \
    bzip2 \
    gcc \
    libc6-dev \
    libtool \
    make \
    pkg-config \
    ruby \
    tzdata
}

function setup_with_dnf () {
  ${SUDO} dnf install -y \
    asciidoc \
    autoconf \
    autoconf-archive \
    bzip2 \
    gcc \
    libtool \
    make \
    pkg-config \
    ruby \
    tzdata
}

if [ -f /etc/debian_version ]; then
  setup_with_apt
elif type dnf > /dev/null 2>&1; then
  setup_with_dnf
else
  echo "This OS setup is not supported."
  exit 1
fi
