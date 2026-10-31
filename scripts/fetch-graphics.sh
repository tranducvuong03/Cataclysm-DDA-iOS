#!/usr/bin/env bash
# Install the official upstream graphics assets missing from the source checkout.
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
    echo "==> Downloading official graphics assets for $CDDA_VERSION_STRING"
    curl -fL --retry 3 --output "$archive" "$url"
    printf '%s  %s\n' "$CDDA_GRAPHICS_SHA256" "$archive" | shasum -a 256 -c
fi

listing="$(unzip -Z1 "$archive")"
if ! grep -Fxq 'gfx/MShockXotto+/tileset.txt' <<<"$listing"; then
    echo "error: verified graphics archive does not contain the expected MShockXotto+ tileset" >&2
    exit 1
fi
for asset in data/font/Terminus.ttf data/shaders/grayscale.frag.msl; do
    if ! grep -Fxq "$asset" <<<"$listing"; then
        echo "error: verified graphics archive does not contain required asset $asset" >&2
        exit 1
    fi
done

extracted="$(mktemp -d)"
trap 'rm -rf "$extracted"' EXIT
unzip -q "$archive" 'gfx/*' 'data/font/*' 'data/shaders/*' -d "$extracted"
if [[ ! -s "$extracted/gfx/MShockXotto+/tileset.txt" ]]; then
    echo "error: failed to extract the MShockXotto+ tileset" >&2
    exit 1
fi
for asset in data/font/Terminus.ttf data/shaders/grayscale.frag.msl; do
    if [[ ! -s "$extracted/$asset" ]]; then
        echo "error: failed to extract required asset $asset" >&2
        exit 1
    fi
done

portrait_config="$extracted/gfx/MShockXotto+_Portraits/tile_config.json"
if [[ -f "$portrait_config" ]]; then
    python3 - "$portrait_config" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
config = json.loads(path.read_text(encoding="utf-8"))
fallbacks = [
    atlas for atlas in config.get("tiles-new", [])
    if atlas.get("file") == "fallback.png"
]
if len(fallbacks) != 1:
    raise SystemExit("error: portrait tileset must define exactly one fallback.png atlas")

fallback = fallbacks[0]
if fallback.get("sprite_width") != 32 or fallback.get("sprite_height") != 32:
    raise SystemExit("error: portrait fallback atlas no longer uses 32x32 glyphs")
tiles = fallback.setdefault("tiles", [])
if not any(tile.get("id") == "unknown" for tile in tiles):
    # Glyph index 32 is the blank ASCII space in this atlas.
    tiles.append({"id": "unknown", "fg": 32})
path.write_text(json.dumps(config, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY
fi

rsync -a --delete "$extracted/gfx/" "$CDDA/gfx/"
mkdir -p "$CDDA/data/font" "$CDDA/data/shaders"
rsync -a --delete "$extracted/data/font/" "$CDDA/data/font/"
rsync -a --delete "$extracted/data/shaders/" "$CDDA/data/shaders/"
echo "==> Installed official graphics assets into $CDDA"
