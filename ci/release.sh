#!/bin/bash

set -eu

echo "::group::autogen"
set -x
rm -rf ~/source
cp -a /source ~/source
pushd ~/source
pushd libgcroots
./autogen.sh
popd
./autogen.sh
popd
popd
set +x
echo "::endgroup::"

echo "::group::configure"
set -x
~/source/configure \
  --enable-maintainer-mode \
  --prefix=/tmp/local
set +x
echo "::endgroup::"

echo "::group::distcheck"
set -x
make distcheck
set +x
echo "::endgroup::"

echo "::group::sum"
set -x
make sum
set +x
echo "::endgroup::"

echo "::group::dist"
set -x
sudo -H mv *.tar.* *.sum /source/
set +x
echo "::endgroup::"
