#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_OUTPUT:?GITHUB_OUTPUT must be set}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY must be set}"

upstream_api="https://api.github.com/repos/CleverRaven/Cataclysm-DDA/releases?per_page=100"
release_json="$(curl -fsSL "$upstream_api")"
release="$(jq -cer '[.[] | select(.draft == false and (.tag_name | test("^cdda-experimental-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{4}$")))][0] // empty' <<<"$release_json")"
if [[ -z "$release" ]]; then
    echo "error: no published cdda-experimental release was found" >&2
    exit 1
fi

ref="$(jq -r '.tag_name' <<<"$release")"
version="${ref#cdda-experimental-}"
translations_name="cdda-translations-$version.tar.gz"
graphics_name="cdda-windows-with-graphics-x64-$version.zip"
translations_digest="$(jq -r --arg name "$translations_name" '.assets[] | select(.name == $name) | .digest // empty' <<<"$release")"
graphics_digest="$(jq -r --arg name "$graphics_name" '.assets[] | select(.name == $name) | .digest // empty' <<<"$release")"

if [[ ! "$translations_digest" =~ ^sha256:[0-9a-f]{64}$ ||
      ! "$graphics_digest" =~ ^sha256:[0-9a-f]{64}$ ]]; then
    echo "Upstream release $ref does not have both expected assets and SHA-256 digests yet; will check again later."
    echo "should_build=false" >> "$GITHUB_OUTPUT"
    exit 0
fi

releases_api="https://api.github.com/repos/$GITHUB_REPOSITORY/releases?per_page=100"
api_headers=(-H "X-GitHub-Api-Version: 2022-11-28")
if [[ -n "${GH_TOKEN:-}" ]]; then
    api_headers+=(-H "Authorization: Bearer $GH_TOKEN")
fi
source cdda.env
if [[ "$CDDA_REF" == "$ref" ]]; then
    echo "Upstream $ref is already pinned after a successful iOS build; skipping."
    echo "should_build=false" >> "$GITHUB_OUTPUT"
    exit 0
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
    echo "translations_sha256=${translations_digest#sha256:}"
    echo "graphics_sha256=${graphics_digest#sha256:}"
} >> "$GITHUB_OUTPUT"
echo "A new upstream release is ready: $ref ($commit)."
