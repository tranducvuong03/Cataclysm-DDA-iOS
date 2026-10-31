#!/usr/bin/env bash
# Install the official upstream tilesets missing from the source checkout.
#
# Usage: scripts/fetch-graphics.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../cdda.env
source "$ROOT/cdda.env"
CDDA="${CDDA_DIR:-$ROOT/cdda}"

if [[ ! -d "$CDDA/.git" ]]; then
    echo "error: Cataclysm source checkout not found; run scripts/fetch-cdda.sh first" >&2
    exit 1
fi
if [[ -z "${CDDA_GRAPHICS_SHA256:-}" ]]; then
    echo "error: CDDA_GRAPHICS_SHA256 is not set in cdda.env" >&2
    exit 1
fi

graphics_version="${CDDA_VERSION_STRING#cdda-experimental-}"
archive_dir="$ROOT/build/graphics"
archive="$archive_dir/cdda-windows-with-graphics-x64-$graphics_version.zip"
url="https://github.com/CleverRaven/Cataclysm-DDA/releases/download/$CDDA_REF/cdda-windows-with-graphics-x64-$graphics_version.zip"
mkdir -p "$archive_dir"

if [[ ! -f "$archive" ]] ||
   ! printf '%s  %s\n' "$CDDA_GRAPHICS_SHA256" "$archive" | shasum -a 256 -c --status; then
    rm -f "$archive"
    echo "==> Downloading official tilesets for $CDDA_VERSION_STRING"
    curl -fL --retry 3 --output "$archive" "$url"
    printf '%s  %s\n' "$CDDA_GRAPHICS_SHA256" "$archive" | shasum -a 256 -c
fi

listing="$(unzip -Z1 "$archive")"
if ! grep -Fxq 'gfx/MShockXotto+/tileset.txt' <<<"$listing"; then
    echo "error: verified graphics archive does not contain the expected MShockXotto+ tileset" >&2
    exit 1
fi

extracted="$(mktemp -d)"
trap 'rm -rf "$extracted"' EXIT
unzip -q "$archive" 'gfx/*' -d "$extracted"
if [[ ! -s "$extracted/gfx/MShockXotto+/tileset.txt" ]]; then
    echo "error: failed to extract the MShockXotto+ tileset" >&2
    exit 1
fi

rsync -a --delete "$extracted/gfx/" "$CDDA/gfx/"
echo "==> Installed official tilesets into $CDDA/gfx"
