#!/bin/bash
# Validate install.sh argument handling without touching the real ~/.claude.

set -e

VAULT="$(cd "$(dirname "$0")/.." && pwd)"

# --help must exit 0 and print the "Usage:" header.
if ! bash "$VAULT/install.sh" --help 2>&1 | grep -q "Usage:"; then
  echo "install.sh --help does not print usage"
  exit 1
fi

# Unknown --agent must exit non-zero with a meaningful message.
set +e
output=$(bash "$VAULT/install.sh" --agent=does-not-exist 2>&1)
rc=$?
set -e

if [ "$rc" -eq 0 ]; then
  echo "Expected non-zero exit for unknown agent, got $rc"
  exit 1
fi

if ! echo "$output" | grep -q "Unknown agent"; then
  echo "Expected 'Unknown agent' in output, got:"
  echo "$output"
  exit 1
fi

exit 0
