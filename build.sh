#!/bin/sh

NAME=beszel
BUILDER=${NAME}-builder
VERSION=0.18.7

if [ ! -d "beszel" ]; then
    git clone https://github.com/henrygd/beszel
fi

cd beszel
git fetch
git reset --hard
git checkout "v${VERSION}"
git apply ../enable-proxy.diff

make build-web-ui

docker buildx rm "$BUILDER" >/dev/null 2>&1 || true

set -- docker buildx create --use --name "$BUILDER"

if [ -n "${http_proxy:-${HTTP_PROXY:-}}" ]; then
    set -- "$@" --driver-opt "env.http_proxy=${http_proxy:-$HTTP_PROXY}"
    set -- "$@" --driver-opt "env.HTTP_PROXY=${HTTP_PROXY:-$http_proxy}"
fi

if [ -n "${https_proxy:-${HTTPS_PROXY:-}}" ]; then
    set -- "$@" --driver-opt "env.https_proxy=${https_proxy:-$HTTPS_PROXY}"
    set -- "$@" --driver-opt "env.HTTPS_PROXY=${HTTPS_PROXY:-$https_proxy}"
fi

if [ -n "${no_proxy:-${NO_PROXY:-}}" ]; then
    set -- "$@" --driver-opt "env.no_proxy=${no_proxy:-$NO_PROXY}"
    set -- "$@" --driver-opt "env.NO_PROXY=${NO_PROXY:-$no_proxy}"
fi

"$@"
docker buildx inspect --bootstrap

set -- docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --pull \
    --tag "ripples/$NAME:$VERSION" \
    --build-arg "VERSION=$VERSION" \
    --builder "$BUILDER" . \
    -f internal/dockerfile_hub

if [ -n "${http_proxy:-${HTTP_PROXY:-}}" ]; then
    set -- "$@" --build-arg "http_proxy=${http_proxy:-$HTTP_PROXY}"
    set -- "$@" --build-arg "HTTP_PROXY=${HTTP_PROXY:-$http_proxy}"
fi

if [ -n "${https_proxy:-${HTTPS_PROXY:-}}" ]; then
    set -- "$@" --build-arg "https_proxy=${https_proxy:-$HTTPS_PROXY}"
    set -- "$@" --build-arg "HTTPS_PROXY=${HTTPS_PROXY:-$https_proxy}"
fi

if [ -n "${no_proxy:-${NO_PROXY:-}}" ]; then
    set -- "$@" --build-arg "no_proxy=${no_proxy:-$NO_PROXY}"
    set -- "$@" --build-arg "NO_PROXY=${NO_PROXY:-$no_proxy}"
fi

"$@"

docker buildx stop "$BUILDER"
docker buildx rm "$BUILDER"
