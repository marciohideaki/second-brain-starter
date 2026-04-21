#!/bin/bash
# Validate every skill file in _bootstrap/global/commands/ starts with a
# `description:` frontmatter line.

set -e

VAULT="$(cd "$(dirname "$0")/.." && pwd)"

count=0
for f in "$VAULT"/_bootstrap/global/commands/*.md; do
  [ -f "$f" ] || continue
  if ! head -5 "$f" | grep -q "^description:"; then
    echo "MISSING 'description:' frontmatter in: $(basename "$f")"
    exit 1
  fi
  count=$((count + 1))
done

if [ "$count" -lt 12 ]; then
  echo "Expected at least 12 skills, found $count"
  exit 1
fi

exit 0
