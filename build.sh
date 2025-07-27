#!/bin/sh

NAME=beszel
BUILDER=${NAME}-builder
VERSION=0.12.1

if [ ! -d "beszel" ]; then
    git clone https://github.com/henrygd/beszel
fi

cd beszel
git fetch
git reset --hard
git checkout "v${VERSION}"
git apply -3 ../enable-proxy.diff

cd beszel
make build-web-ui

docker buildx create --use --name $BUILDER
docker buildx inspect --bootstrap

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --pull \
    --tag ripples/$NAME:$VERSION \
    --build-arg VERSION=$VERSION \
    --builder $BUILDER . \
    -f dockerfile_Hub

docker buildx stop $BUILDER
docker buildx rm $BUILDER
