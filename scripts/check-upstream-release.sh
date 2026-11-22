#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_OUTPUT:?GITHUB_OUTPUT must be set}"

ignore_ios_release=false
case "${1:-}" in
    "")
        ;;
    --ignore-ios-release)
        ignore_ios_release=true
        ;;
    *)
        echo "error: unknown argument: $1" >&2
        exit 2
        ;;
esac

upstream_api="https://api.github.com/repos/CleverRaven/Cataclysm-DDA/releases?per_page=100"
release_json="$(curl -fsSL "$upstream_api")"
release="$(jq -cer '[.[] | select(.draft == false and (.tag_name | test("^cdda-experimental-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{4}$")))][0] // empty' <<<"$release_json")"
if [[ -z "$release" ]]; then
    echo "error: no published cdda-experimental release was found" >&2
    exit 1
fi

ref="$(jq -r '.tag_name' <<<"$release")"
version="${ref#cdda-experimental-}"
graphics_name="cdda-windows-with-graphics-x64-$version.zip"
graphics_digest="$(jq -r --arg name "$graphics_name" '.assets[] | select(.name == $name) | .digest // empty' <<<"$release")"
translations_name="cdda-translations-$version.tar.gz"
translations_digest="$(jq -r --arg name "$translations_name" '.assets[] | select(.name == $name) | .digest // empty' <<<"$release")"

if [[ ! "$graphics_digest" =~ ^sha256:[0-9a-f]{64}$ ]]; then
    echo "Upstream release $ref does not have the expected graphics asset and SHA-256 digest yet; will check again later."
    echo "should_build=false" >> "$GITHUB_OUTPUT"
    exit 0
fi

releases_api="https://api.github.com/repos/$GITHUB_REPOSITORY/releases?per_page=100"
api_headers=(-H "X-GitHub-Api-Version: 2022-11-28")
if [[ -n "${GH_TOKEN:-}" ]]; then
    api_headers+=(-H "Authorization: Bearer $GH_TOKEN")
fi
source cdda.env
if [[ "$CDDA_REF" == "$ref" && "$ignore_ios_release" != "true" ]]; then
    page=1
    published=false
    while true; do
        published_releases="$(curl -fsSL "${releases_api}&page=$page")"
        if jq -e --arg ref "$ref" 'any(.[]; .draft == false and .name == $ref)' \
            <<<"$published_releases" >/dev/null; then
            published=true
            break
        fi
        release_count="$(jq 'length' <<<"$published_releases")"
        if (( release_count < 100 )); then
            break
        fi
        ((page += 1))
    done
    if [[ "$published" == "true" ]]; then
        echo "Upstream $ref is already pinned and has a published iOS release; skipping."
        echo "should_build=false" >> "$GITHUB_OUTPUT"
        exit 0
    fi
    echo "Upstream $ref is pinned but its iOS release is missing; rebuilding."
fi

tag_refs="$(git ls-remote https://github.com/CleverRaven/Cataclysm-DDA.git "refs/tags/$ref" "refs/tags/$ref^{}")"
commit="$(awk '$2 ~ /\^\{\}$/ { print $1; exit }' <<<"$tag_refs")"
if [[ -z "$commit" ]]; then
    commit="$(awk -v ref="refs/tags/$ref" '$2 == ref { print $1; exit }' <<<"$tag_refs")"
fi
if [[ ! "$commit" =~ ^[0-9a-f]{40}$ ]]; then
    echo "error: could not resolve upstream tag $ref to a commit" >&2
    exit 1
fi

{
    echo "should_build=true"
    echo "upstream_ref=$ref"
    echo "upstream_commit=$commit"
    echo "graphics_sha256=${graphics_digest#sha256:}"
    if [[ "$translations_digest" =~ ^sha256:[0-9a-f]{64}$ ]]; then
        echo "translations_sha256=${translations_digest#sha256:}"
    else
        echo "translations_sha256="
    fi
} >> "$GITHUB_OUTPUT"
echo "A new upstream release is ready: $ref ($commit)."
