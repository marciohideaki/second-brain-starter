#!/bin/bash
# Smoke-test the Codex adapter in an isolated HOME. Verifies it creates
# AGENTS.md and converts every global command into a valid Codex skill.

set -e

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TMP_ROOT="$(mktemp -d)"
TEST_SOURCE="$TMP_ROOT/source"
TEST_TARGET="$TMP_ROOT/target-vault"
TEST_HOME="$TMP_ROOT/home"
VALIDATOR="/home/annonymous/.codex/skills/.system/skill-creator/scripts/quick_validate.py"

cleanup() { rm -rf "$TMP_ROOT"; }
trap cleanup EXIT

mkdir -p "$TEST_HOME" "$TEST_TARGET"
cp -R "$REPO" "$TEST_SOURCE"
rm -f "$TEST_SOURCE/AGENTS.md"

HOME="$TEST_HOME" SECOND_BRAIN_SKIP_CRON=1 bash "$TEST_SOURCE/install.sh" \
  --agents=claude-code,codex \
  --target-vault "$TEST_TARGET" \
  --vault-name "Test Brain" \
  --vault-prefix alpha >/dev/null 2>&1

HOME="$TEST_HOME" SECOND_BRAIN_SKIP_CRON=1 bash "$TEST_SOURCE/install.sh" \
  --agents=claude-code,codex \
  --target-vault "$TEST_TARGET" \
  --vault-name "Test Brain" \
  --vault-prefix beta >/dev/null 2>&1

HOME="$TEST_HOME" SECOND_BRAIN_SKIP_CRON=1 bash "$TEST_SOURCE/install.sh" \
  --agent=codex \
  --target-vault "$TEST_TARGET" >/dev/null 2>&1

if [ ! -f "$TEST_TARGET/AGENTS.md" ]; then
  echo "MISSING: target vault AGENTS.md"
  exit 1
fi

if [ -f "$TEST_SOURCE/AGENTS.md" ]; then
  echo "AGENTS.md should be generated in target vault, not source root"
  exit 1
fi

if ! grep -q "$TEST_TARGET" "$TEST_TARGET/AGENTS.md"; then
  echo "AGENTS.md does not reference target vault"
  exit 1
fi

count=$(find "$TEST_HOME/.codex/skills" -mindepth 2 -maxdepth 2 -name "SKILL.md" | wc -l)
expected=$(find "$TEST_SOURCE/_bootstrap/global/commands" -maxdepth 1 -name "*.md" | wc -l)

if [ "$count" -lt "$expected" ]; then
  echo "Expected at least $expected Codex skills, got $count"
  exit 1
fi

if find "$TEST_HOME/.codex/skills" -maxdepth 1 -type d -name "alpha-*" | grep -q .; then
  echo "Old alpha-prefixed Codex skills were not removed after prefix change"
  exit 1
fi

if [ "$(find "$TEST_HOME/.codex/skills" -maxdepth 1 -type d -name "beta-*" | wc -l)" -lt "$expected" ]; then
  echo "Expected beta-prefixed Codex skills after prefix change"
  exit 1
fi

if ! grep -q 'SECOND_BRAIN_AGENTS="claude-code,codex"' "$TEST_TARGET/.second-brain/install.env"; then
  echo "--agent=codex should not overwrite persisted --agents selection"
  exit 1
fi

for skill_dir in "$TEST_HOME"/.codex/skills/*; do
  [ -d "$skill_dir" ] || continue
  case "$(basename "$skill_dir")" in
    beta-*) ;;
    *) continue ;;
  esac
  if ! grep -q "vault: \"$TEST_TARGET\"" "$skill_dir/SKILL.md"; then
    echo "Skill $(basename "$skill_dir") does not point to target vault"
    exit 1
  fi
  if grep -q "vault: \"$TEST_SOURCE\"" "$skill_dir/SKILL.md"; then
    echo "Skill $(basename "$skill_dir") incorrectly points to source as vault"
    exit 1
  fi
  if [ -x "$VALIDATOR" ]; then
    python3 "$VALIDATOR" "$skill_dir" >/dev/null
  else
    test -f "$skill_dir/SKILL.md"
    head -20 "$skill_dir/SKILL.md" | grep -q "^name:"
    head -20 "$skill_dir/SKILL.md" | grep -q "^description:"
  fi
done

exit 0
