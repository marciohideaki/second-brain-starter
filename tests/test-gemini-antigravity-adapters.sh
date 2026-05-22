#!/bin/bash
# Smoke-test beta/stub adapters in isolated HOME and target vaults.

set -e

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TMP_ROOT="$(mktemp -d)"
TEST_SOURCE="$TMP_ROOT/source"
GEMINI_TARGET="$TMP_ROOT/gemini-vault"
ANTIGRAVITY_TARGET="$TMP_ROOT/antigravity-vault"
TEST_HOME="$TMP_ROOT/home"

cleanup() { rm -rf "$TMP_ROOT"; }
trap cleanup EXIT

mkdir -p "$TEST_HOME" "$GEMINI_TARGET" "$ANTIGRAVITY_TARGET"
cp -R "$REPO" "$TEST_SOURCE"

HOME="$TEST_HOME" SECOND_BRAIN_SKIP_CRON=1 bash "$TEST_SOURCE/install.sh" \
  --agent=gemini-cli \
  --target-vault "$GEMINI_TARGET" \
  --vault-prefix alpha >/dev/null 2>&1

HOME="$TEST_HOME" SECOND_BRAIN_SKIP_CRON=1 bash "$TEST_SOURCE/install.sh" \
  --agent=gemini-cli \
  --target-vault "$GEMINI_TARGET" \
  --vault-prefix beta >/dev/null 2>&1

if [ ! -f "$TEST_HOME/.gemini/beta-GEMINI.md" ]; then
  echo "MISSING: beta Gemini SSOT"
  exit 1
fi

if [ -f "$TEST_HOME/.gemini/alpha-GEMINI.md" ]; then
  echo "Old alpha-prefixed Gemini SSOT was not removed after prefix change"
  exit 1
fi

if ! grep -q "$GEMINI_TARGET" "$TEST_HOME/.gemini/beta-GEMINI.md"; then
  echo "Gemini SSOT does not reference target vault"
  exit 1
fi

if ! grep -q "$TEST_HOME/.gemini/beta-GEMINI.md" "$TEST_HOME/.gemini/GEMINI.md"; then
  echo "Gemini managed index does not point to beta SSOT"
  exit 1
fi

HOME="$TEST_HOME" SECOND_BRAIN_SKIP_CRON=1 bash "$TEST_SOURCE/install.sh" \
  --agent=antigravity \
  --target-vault "$ANTIGRAVITY_TARGET" \
  --vault-prefix beta >/dev/null 2>&1

if [ ! -f "$ANTIGRAVITY_TARGET/AGENTS.md" ]; then
  echo "MISSING: Antigravity target AGENTS.md"
  exit 1
fi

if [ -f "$TEST_SOURCE/AGENTS.md" ]; then
  echo "Antigravity AGENTS.md should be generated in target vault, not source root"
  exit 1
fi

if ! grep -q "$ANTIGRAVITY_TARGET" "$ANTIGRAVITY_TARGET/AGENTS.md"; then
  echo "Antigravity AGENTS.md does not reference target vault"
  exit 1
fi

exit 0
