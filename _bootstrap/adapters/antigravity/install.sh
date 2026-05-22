#!/bin/bash
# Antigravity adapter.
# Generates AGENTS.md in the target vault and registers cron jobs.

set -e

SOURCE_ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
TARGET_VAULT="${2:-${SECOND_BRAIN_VAULT:-$SOURCE_ROOT}}"
VAULT_NAME="${3:-$(basename "$TARGET_VAULT")}"
VAULT_PREFIX="${4:-second-brain}"
SOURCE_ROOT="$(cd "$SOURCE_ROOT" && pwd)"
TARGET_VAULT="$(mkdir -p "$TARGET_VAULT" && cd "$TARGET_VAULT" && pwd)"
BOOTSTRAP="$SOURCE_ROOT/_bootstrap"
ADAPTER="$BOOTSTRAP/adapters/antigravity"
TARGET_SCRIPTS_DIR="$TARGET_VAULT/_bootstrap/scripts"

echo "=== second-brain-starter — Antigravity adapter ==="
echo "Source: $SOURCE_ROOT"
echo "Vault : $TARGET_VAULT"
echo "Name  : $VAULT_NAME"
echo "Prefix: $VAULT_PREFIX"
echo ""

mkdir -p "$TARGET_VAULT/.logs"

echo "[1/2] SSOT: AGENTS.md..."

DEST="$TARGET_VAULT/AGENTS.md"

if [ -f "$DEST" ]; then
  echo "  - $DEST already exists (kept)"
else
  sed "s|{VAULT}|$TARGET_VAULT|g" "$ADAPTER/templates/agents.md" > "$DEST"
  printf '\n\n<!-- Vault: %s -->\n\n' "$TARGET_VAULT" >> "$DEST"
  if [ -f "$TARGET_VAULT/CLAUDE.md" ]; then
    sed "s|{VAULT}|$TARGET_VAULT|g" "$TARGET_VAULT/CLAUDE.md" >> "$DEST"
  else
    sed "s|{VAULT}|$TARGET_VAULT|g" "$SOURCE_ROOT/CLAUDE.md" >> "$DEST"
  fi
  echo "  ✓ $DEST"
fi

echo ""
echo "[2/2] Cron jobs..."

if [ "${SECOND_BRAIN_SKIP_CRON:-}" = "1" ]; then
  echo "  - skipped (SECOND_BRAIN_SKIP_CRON=1)"
  ADDED=0
else
  CRON_CURRENT=$(crontab -l 2>/dev/null || echo "")
  CRON_UPDATED="$CRON_CURRENT"
  ADDED=0

  add_cron() {
    local schedule="$1"
    local script="$2"
    local label="$3"
    local logfile="$TARGET_VAULT/.logs/${script%.sh}.log"
    local script_path="$TARGET_SCRIPTS_DIR/$script"
    local line="$schedule bash $script_path >> $logfile 2>&1"
    if echo "$CRON_CURRENT" | grep -q "$script_path"; then
      echo "  - $label (already present)"
    else
      CRON_UPDATED="${CRON_UPDATED}"$'\n'"$line"
      ADDED=$((ADDED + 1))
      echo "  ✓ $label"
    fi
  }

  add_cron "0 7 * * *" "daily-heartbeat.sh"  "daily-heartbeat (every day 07:00)"
  add_cron "0 9 * * 1" "weekly-vault-lint.sh" "weekly-vault-lint (Monday 09:00)"

  if [ "$ADDED" -gt 0 ]; then
    printf '%s\n' "$CRON_UPDATED" | crontab -
  fi
fi

echo ""
echo "=== Antigravity adapter installed ==="
echo ""
echo "Installed:"
echo "  - $DEST"
echo "  - $ADDED cron job(s) new"
echo ""
echo "Limitations:"
echo "  - No MCP tool wrappers yet. Invoke skills via natural language."
echo ""
echo "More: $ADAPTER/README.md"
