#!/bin/sh

VERSION=0.11.1

if [ ! -d "beszel" ]; then
    git clone https://github.com/henrygd/beszel
fi

cd beszel
git fetch
git reset --hard
git checkout "v${VERSION}"
git apply ../enable-proxy.diff

cd beszel
make build-web-ui
