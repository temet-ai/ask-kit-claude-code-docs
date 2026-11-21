#!/usr/bin/env bash
# Download the official Claude Code documentation as Markdown into copy/ next to this script.
# Usage: refresh.sh            (replaces docs/, llms.txt, CHANGELOG.md and FETCHED.txt)
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/copy"
mkdir -p "$HERE"
INDEX_URL="https://code.claude.com/docs/llms.txt"
PAGE_PREFIX="https://code.claude.com/docs/en/"
CHANGELOG_URL="https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md"

work="$(mktemp -d "$HERE/.refresh.XXXXXX")"
trap 'rm -rf "$work"' EXIT

curl -fsSL --retry 3 --max-time 60 "$INDEX_URL" -o "$work/llms.txt"
grep -oE "${PAGE_PREFIX}[^) ]+\.md" "$work/llms.txt" | sort -u > "$work/pages.txt"
total="$(wc -l < "$work/pages.txt")"
if (( total < 50 )); then
  echo "refresh: the index lists only $total pages; keeping the existing copy" >&2
  exit 1
fi

mkdir -p "$work/docs"
export work PAGE_PREFIX
fetch_page() {
  local url="$1" rel="${1#"$PAGE_PREFIX"}"
  mkdir -p "$work/docs/$(dirname -- "$rel")"
  curl -fsSL --retry 3 --max-time 60 "$url" -o "$work/docs/$rel" || echo "$url" >> "$work/failed.txt"
}
export -f fetch_page
xargs -P 6 -I{} bash -c 'fetch_page "$1"' _ {} < "$work/pages.txt"

curl -fsSL --retry 3 --max-time 120 "$CHANGELOG_URL" -o "$work/CHANGELOG.md" || echo "$CHANGELOG_URL" >> "$work/failed.txt"

failed=0
[[ -f "$work/failed.txt" ]] && failed="$(wc -l < "$work/failed.txt")"
got="$(find "$work/docs" -name '*.md' -size +0 | wc -l)"
if (( got * 10 < total * 9 )); then
  echo "refresh: only $got of $total pages downloaded; keeping the existing copy" >&2
  exit 1
fi

rm -rf "$HERE/docs"
mv "$work/docs" "$HERE/docs"
mv "$work/llms.txt" "$HERE/llms.txt"
[[ -f "$work/CHANGELOG.md" ]] && mv "$work/CHANGELOG.md" "$HERE/CHANGELOG.md"
{
  echo "fetched: $(date -u +%Y-%m-%dT%H:%MZ)"
  echo "pages: $got of $total listed in llms.txt"
  echo "claude code installed here: $(claude --version 2>/dev/null || echo unknown)"
  echo "source: $INDEX_URL"
  if (( failed > 0 )); then echo "not downloaded:"; sed 's/^/  /' "$work/failed.txt"; fi
} > "$HERE/FETCHED.txt"
cat "$HERE/FETCHED.txt"
