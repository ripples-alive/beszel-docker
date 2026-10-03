# Beszel Docker

This repository builds a patched Beszel Hub image. The build clones
[`henrygd/beszel`](https://github.com/henrygd/beszel) at `v0.18.7`, applies
[`enable-proxy.diff`](enable-proxy.diff), builds the web UI, and then builds a
multi-arch Docker image from Beszel's `internal/dockerfile_hub`.

The patch enables SOCKS5 proxy support for Hub SSH connections when
`PROXY_HOST` and `PROXY_PORT` are set.

## Image

GitHub Actions publishes the image to:

```text
ghcr.io/ripples-alive/beszel:0.18.7
ghcr.io/ripples-alive/beszel:latest
```

Supported platforms:

```text
linux/amd64
linux/arm64
```

## Usage

```sh
docker run -d \
  --name beszel \
  -p 8090:8090 \
  -v beszel_data:/beszel_data \
  ghcr.io/ripples-alive/beszel:0.18.7
```

To route Hub SSH connections through a SOCKS5 proxy:

```sh
docker run -d \
  --name beszel \
  -p 8090:8090 \
  -v beszel_data:/beszel_data \
  -e PROXY_HOST=proxy.example.com \
  -e PROXY_PORT=1080 \
  ghcr.io/ripples-alive/beszel:0.18.7
```

## GitHub Actions

The Docker workflow runs on:

- pushes to `main`
- tags matching `v*`
- pull requests
- manual `workflow_dispatch`

Pull requests build the patched multi-arch image for validation but do not push
to the registry. Pushes to `main`, `v*` tags, and manual release runs push both
the version tag and `latest` to GitHub Container Registry.

The default Beszel version is stored in `beszel-version.txt`. Manual runs can
override the version input; tag builds use the tag name without the leading
`v` when no manual version is supplied. Automated version commits change only
the version file and README, so the built-in `GITHUB_TOKEN` can push them.

The `Update Beszel stable release` workflow checks the upstream stable release
every day and validates a patched candidate image before opening an exact
version PR. If the upstream tree makes `enable-proxy.diff` fail to apply, the
candidate build fails and leaves the version unchanged for investigation.

## Local Build

The existing local workflow is still available:

```sh
./build.sh
```

It clones Beszel, applies the patch, builds the web UI, and pushes the
multi-arch image using Docker Buildx.
