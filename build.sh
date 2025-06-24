#!/bin/sh

NAME=beszel
BUILDER=${NAME}-builder
VERSION=0.11.1

cd beszel/beszel
git checkout "v${VERSION}"

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
