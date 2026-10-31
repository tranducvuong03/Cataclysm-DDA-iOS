#!/usr/bin/env bash
# Fetch and install the pinned CC-Sounds pack into the generated Cataclysm data.
#
# Usage: bash scripts/fetch-soundpack.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../cdda.env
source "$ROOT/cdda.env"
# shellcheck source=../soundpack.env
source "$ROOT/soundpack.env"
CDDA="${CDDA_DIR:-$ROOT/cdda}"

if [[ ! -d "$CDDA/.git" ]]; then
    echo "error: Cataclysm source checkout not found; run scripts/fetch-cdda.sh first" >&2
    exit 1
fi

archive_dir="$ROOT/build/soundpack"
archive="$archive_dir/CC-Sounds-$SOUNDPACK_RELEASE.zip"
license="$archive_dir/LICENSE-$SOUNDPACK_RELEASE.txt"
archive_url="https://github.com/Fris0uman/CDDA-Soundpacks/releases/download/$SOUNDPACK_RELEASE/CC-Sounds.zip"
license_url="https://raw.githubusercontent.com/Fris0uman/CDDA-Soundpacks/$SOUNDPACK_COMMIT/LICENSE.txt"
mkdir -p "$archive_dir"

if [[ ! -s "$archive" ]] ||
   ! printf '%s  %s\n' "$SOUNDPACK_ARCHIVE_SHA256" "$archive" | shasum -a 256 -c --status; then
    rm -f "$archive"
    echo "==> Downloading CC-Sounds $SOUNDPACK_RELEASE"
    curl -fL --retry 3 --output "$archive" "$archive_url"
    printf '%s  %s\n' "$SOUNDPACK_ARCHIVE_SHA256" "$archive" | shasum -a 256 -c
fi

if [[ ! -s "$license" ]] ||
   ! printf '%s  %s\n' "$SOUNDPACK_LICENSE_SHA256" "$license" | shasum -a 256 -c --status; then
    rm -f "$license"
    echo "==> Downloading the CC-Sounds license"
    curl -fL --retry 3 --output "$license" "$license_url"
    printf '%s  %s\n' "$SOUNDPACK_LICENSE_SHA256" "$license" | shasum -a 256 -c
fi

if ! unzip -tq "$archive" >/dev/null; then
    echo "error: verified CC-Sounds archive is not a valid ZIP file" >&2
    exit 1
fi
listing="$(unzip -Z1 "$archive")"
for asset in CC-Sounds/soundpack.txt CC-Sounds/music/CO.AG_authorisation.txt CC-Sounds/music/LICENSE.txt; do
    if ! grep -Fxq "$asset" <<<"$listing"; then
        echo "error: CC-Sounds archive is missing $asset" >&2
        exit 1
    fi
done

extracted="$(mktemp -d)"
trap 'rm -rf "$extracted"' EXIT
unzip -q "$archive" 'CC-Sounds/*' -d "$extracted"
pack="$extracted/CC-Sounds"
if [[ ! -s "$pack/soundpack.txt" ]] ||
   ! grep -Fxq 'NAME: CC-Sounds' "$pack/soundpack.txt"; then
    echo "error: CC-Sounds archive has an invalid soundpack.txt" >&2
    exit 1
fi
if [[ -z "$(find "$pack" -type f -name '*.ogg' -print -quit)" ]]; then
    echo "error: CC-Sounds archive contains no Ogg audio files" >&2
    exit 1
fi
if [[ -z "$(find "$pack" -type f -name 'credits.md' -print -quit)" ]]; then
    echo "error: CC-Sounds archive contains no per-sound attribution files" >&2
    exit 1
fi

cp "$license" "$pack/LICENSE.txt"
mkdir -p "$CDDA/data/sound"
rsync -a --delete "$pack/" "$CDDA/data/sound/CC-Sounds/"
echo "==> Installed CC-Sounds into $CDDA/data/sound/CC-Sounds"
