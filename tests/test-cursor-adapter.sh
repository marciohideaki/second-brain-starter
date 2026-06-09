#!/bin/bash
# Smoke-test the Cursor adapter in an isolated HOME. Verifies it creates the
# SSOT rule and skill rules without touching the real ~/.cursor.

set -e

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TMP_ROOT="$(mktemp -d)"
TEST_SOURCE="$TMP_ROOT/source"
TEST_TARGET="$TMP_ROOT/target-vault"
TEST_HOME="$TMP_ROOT/home"

cleanup() { rm -rf "$TMP_ROOT"; }
trap cleanup EXIT

mkdir -p "$TEST_HOME" "$TEST_TARGET"
cp -R "$REPO" "$TEST_SOURCE"

HOME="$TEST_HOME" SECOND_BRAIN_SKIP_CRON=1 bash "$TEST_SOURCE/install.sh" \
  --agent=cursor \
  --target-vault "$TEST_TARGET" \
  --vault-prefix alpha >/dev/null 2>&1

HOME="$TEST_HOME" SECOND_BRAIN_SKIP_CRON=1 bash "$TEST_SOURCE/install.sh" \
  --agent=cursor \
  --target-vault "$TEST_TARGET" \
  --vault-prefix beta >/dev/null 2>&1

# SSOT rule exists
if [ ! -f "$TEST_HOME/.cursor/rules/beta-00-second-brain.mdc" ]; then
  echo "MISSING: SSOT rule beta-00-second-brain.mdc"
  exit 1
fi

<<<<<<< Updated upstream
# Skill rules exist
count=$(find "$TEST_HOME/.cursor/rules" -maxdepth 1 -name "skill-*.mdc" | wc -l)
=======
# 12 skill rules exist
count=$(find "$TEST_HOME/.cursor/rules" -maxdepth 1 -name "beta-skill-*.mdc" | wc -l)
>>>>>>> Stashed changes
if [ "$count" -lt 12 ]; then
  echo "Expected at least 12 skill rules, got $count"
  exit 1
fi

if find "$TEST_HOME/.cursor/rules" -maxdepth 1 -name "alpha-*.mdc" | grep -q .; then
  echo "Old alpha-prefixed Cursor rules were not removed after prefix change"
  exit 1
fi

# SSOT rule has correct frontmatter
if ! head -10 "$TEST_HOME/.cursor/rules/beta-00-second-brain.mdc" | grep -q "alwaysApply: true"; then
  echo "SSOT rule missing 'alwaysApply: true' frontmatter"
  exit 1
fi

if ! grep -q "$TEST_TARGET" "$TEST_HOME/.cursor/rules/beta-00-second-brain.mdc"; then
  echo "Cursor SSOT rule does not reference target vault"
  exit 1
fi

exit 0
