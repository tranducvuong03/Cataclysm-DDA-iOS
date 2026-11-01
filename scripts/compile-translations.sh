#!/usr/bin/env bash
# Compile the upstream .po translations into cdda/lang/mo, which build-app.sh
# bundles into the app. Fetches the official translation archive when the
# pinned source checkout does not contain the .po files. Requires msgfmt.
#
# Usage: scripts/compile-translations.sh [language...]   (default: all)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../cdda.env
source "$ROOT/cdda.env"
CDDA="${CDDA_DIR:-$ROOT/cdda}"
: "${CDDA_TRANSLATIONS_REF:?CDDA_TRANSLATIONS_REF is not set in cdda.env}"

if ! command -v msgfmt >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1 && [[ -x "$(brew --prefix gettext 2>/dev/null)/bin/msgfmt" ]]; then
        PATH="$(brew --prefix gettext)/bin:$PATH"
    else
        echo "error: msgfmt not found; install gettext (brew install gettext)" >&2
        exit 1
    fi
fi

count_po_catalogs() {
    local file count=0
    for file in "$1"/*.po; do
        [[ -f "$file" && "${file##*/}" != placeholder.po ]] || continue
        count=$(( count + 1 ))
    done
    printf '%s' "$count"
}

mkdir -p "$CDDA/lang/po"
po_count="$(count_po_catalogs "$CDDA/lang/po")"
if [[ "$po_count" == 0 || ! -s "$CDDA/lang/po/vi.po" ]]; then
    if [[ -z "${CDDA_TRANSLATIONS_SHA256:-}" ]]; then
        echo "error: CDDA_TRANSLATIONS_SHA256 is not set in cdda.env" >&2
        exit 1
    fi

    archive_dir="$ROOT/build/translations"
    translations_version="${CDDA_TRANSLATIONS_REF#cdda-experimental-}"
    archive="$archive_dir/cdda-translations-$translations_version.tar.gz"
    mkdir -p "$archive_dir"

    if [[ ! -f "$archive" ]] ||
       ! printf '%s  %s\n' "$CDDA_TRANSLATIONS_SHA256" "$archive" | shasum -a 256 -c --status; then
        rm -f "$archive"
        url="https://github.com/CleverRaven/Cataclysm-DDA/releases/download/$CDDA_TRANSLATIONS_REF/cdda-translations-$translations_version.tar.gz"
        echo "==> Downloading official translations for $CDDA_TRANSLATIONS_REF"
        curl -fL --retry 3 --output "$archive" "$url"
        printf '%s  %s\n' "$CDDA_TRANSLATIONS_SHA256" "$archive" | shasum -a 256 -c
    fi

    extracted="$(mktemp -d)"
    trap 'rm -rf "$extracted"' EXIT
    tar -xzf "$archive" -C "$extracted" lang/po data/credits data/motd
    po_count="$(count_po_catalogs "$extracted/lang/po")"
    if [[ "$po_count" == 0 || ! -s "$extracted/lang/po/vi.po" ]]; then
        echo "error: official translation archive has no usable Vietnamese catalog (lang/po/vi.po)" >&2
        exit 1
    fi

    rsync -a --delete "$extracted/lang/po/" "$CDDA/lang/po/"
    rsync -a "$extracted/data/credits/" "$CDDA/data/credits/"
    rsync -a "$extracted/data/motd/" "$CDDA/data/motd/"
    echo "==> Installed $po_count official .po catalogs"
fi

cd "$CDDA"
if (( $# )); then
    languages=( "$@" )
    has_vietnamese=0
    for language in "${languages[@]}"; do
        if [[ "$language" == vi ]]; then
            has_vietnamese=1
            break
        fi
    done
    if (( ! has_vietnamese )) && [[ "${languages[0]}" != all ]]; then
        languages=( vi "${languages[@]}" )
    fi
    sh lang/compile_mo.sh "${languages[@]}" >/dev/null
else
    sh lang/compile_mo.sh all >/dev/null
fi

compiled_count="$(find lang/mo -type f -path '*/LC_MESSAGES/cataclysm-dda.mo' ! -path '*/placeholder/*' | wc -l | tr -d '[:space:]')"
if [[ "$compiled_count" == 0 ]]; then
    echo "error: no Cataclysm translation catalogs were compiled" >&2
    exit 1
fi
if [[ ! -s lang/mo/vi/LC_MESSAGES/cataclysm-dda.mo ]]; then
    echo "error: Vietnamese catalog was not compiled to lang/mo/vi/LC_MESSAGES/cataclysm-dda.mo" >&2
    exit 1
fi
echo "==> Compiled $compiled_count translation(s) into $CDDA/lang/mo"
