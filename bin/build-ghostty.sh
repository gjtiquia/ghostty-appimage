#!/bin/sh

set -eux

ARCH="$(uname -m)"
GHOSTTY_VERSION="$(cat VERSION)"
GHOSTTY_REPO="$(cat GITHUB_REPO)"
GHOSTTY_BRANCH="$(cat GITHUB_BRANCH)"
GHOSTTY_DIR="ghostty-${GHOSTTY_VERSION}"

rm -rf AppDir dist "${GHOSTTY_DIR}"

BUILD_ARGS="
	-Dcpu=baseline \
	-Doptimize=ReleaseFast \
	-Dpie=true \
    --system /tmp/offline-cache/p \
    -Dgtk-wayland=true \
    -Dgtk-x11=true \
    -Demit-docs=false \
    -Dstrip=true"

# Clone the repository and checkout the specific branch
git clone --depth 1 --branch "${GHOSTTY_BRANCH}" "${GHOSTTY_REPO}" "${GHOSTTY_DIR}"

BUILD_ARGS="${BUILD_ARGS} -Dversion-string=${GHOSTTY_VERSION}"

(
    cd "${GHOSTTY_DIR}"
    ZIG_GLOBAL_CACHE_DIR=/tmp/offline-cache ./nix/build-support/fetch-zig-cache.sh
    zig build ${BUILD_ARGS}
)
