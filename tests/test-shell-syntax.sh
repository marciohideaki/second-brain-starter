#!/bin/bash
# Validate every bash script parses cleanly (no syntax errors).

set -e

VAULT="$(cd "$(dirname "$0")/.." && pwd)"

# Check tracked documentation too: valid shell alone cannot detect every bad merge.
if git -C "$VAULT" grep -n -I -E '^(<<<<<<< |>>>>>>> |\|\|\|\|\|\|\| )' -- .; then
  echo "Unresolved merge conflict markers in tracked files"
  exit 1
else
  status=$?
  [ "$status" -eq 1 ] || exit "$status"
fi

checked=0
for f in \
  "$VAULT"/install.sh \
  "$VAULT"/_bootstrap/global/hooks/*.sh \
  "$VAULT"/_bootstrap/scripts/*.sh \
  "$VAULT"/_bootstrap/adapters/*/install.sh \
  "$VAULT"/tests/*.sh
do
  [ -f "$f" ] || continue
  if ! bash -n "$f" 2>/dev/null; then
    echo "SYNTAX ERROR: $f"
    bash -n "$f"
    exit 1
  fi
  checked=$((checked + 1))
done

if [ "$checked" -lt 10 ]; then
  echo "Expected at least 10 shell scripts, checked $checked"
  exit 1
fi

exit 0
