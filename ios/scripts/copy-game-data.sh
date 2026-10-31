#!/bin/sh
# Copy Cataclysm's game data into the app bundle. Runs as an Xcode build
# phase (see ios/CMakeLists.txt), which provides TARGET_BUILD_DIR and
# CONTENTS_FOLDER_PATH for the bundle being built.
#
# Usage: copy-game-data.sh <cdda checkout>
set -eu

CDDA="$1"
DEST="${TARGET_BUILD_DIR:?not run from Xcode}/${CONTENTS_FOLDER_PATH:?not run from Xcode}"

if [ ! -d "$CDDA/data/json" ]; then
    echo "error: Cataclysm data is missing from $CDDA" >&2
    exit 1
fi
if [ ! -s "$CDDA/gfx/MShockXotto+/tileset.txt" ]; then
    echo "error: official graphical assets are missing; run scripts/fetch-graphics.sh" >&2
    exit 1
fi
for asset in data/font/Terminus.ttf data/shaders/grayscale.frag.msl; do
    if [ ! -s "$CDDA/$asset" ]; then
        echo "error: required graphics asset $asset is missing; run scripts/fetch-graphics.sh" >&2
        exit 1
    fi
done
if [ ! -s "$CDDA/lang/mo/vi/LC_MESSAGES/cataclysm-dda.mo" ]; then
    echo "error: Vietnamese translation is missing; run scripts/compile-translations.sh" >&2
    exit 1
fi

rsync -a --delete \
    --exclude CMakeLists.txt --exclude application_manifest.xml \
    --exclude cataicon.ico --exclude xdg --exclude screenshots --exclude cache \
    "$CDDA/data/" "$DEST/data/"
rsync -a --delete --exclude CMakeLists.txt "$CDDA/gfx/" "$DEST/gfx/"

mkdir -p "$DEST/lang"
rsync -a --delete "$CDDA/lang/mo/" "$DEST/lang/mo/"

echo "Copied game data into $DEST"
