#!/bin/bash
# Smoke-test the Cursor adapter in an isolated HOME. Verifies it creates the
# SSOT rule and skill rules without touching the real ~/.cursor.

set -e

VAULT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_HOME="$(mktemp -d)"

cleanup() { rm -rf "$TEST_HOME"; }
trap cleanup EXIT

HOME="$TEST_HOME" bash "$VAULT/install.sh" --agent=cursor >/dev/null 2>&1

# SSOT rule exists
if [ ! -f "$TEST_HOME/.cursor/rules/00-second-brain.mdc" ]; then
  echo "MISSING: SSOT rule 00-second-brain.mdc"
  exit 1
fi

# Skill rules exist
count=$(find "$TEST_HOME/.cursor/rules" -maxdepth 1 -name "skill-*.mdc" | wc -l)
if [ "$count" -lt 12 ]; then
  echo "Expected at least 12 skill rules, got $count"
  exit 1
fi

# SSOT rule has correct frontmatter
if ! head -5 "$TEST_HOME/.cursor/rules/00-second-brain.mdc" | grep -q "alwaysApply: true"; then
  echo "SSOT rule missing 'alwaysApply: true' frontmatter"
  exit 1
fi

exit 0
