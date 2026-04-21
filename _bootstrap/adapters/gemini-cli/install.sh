#!/bin/bash
# Gemini CLI adapter — stub install.
# Creates ~/.gemini/GEMINI.md mirror of CLAUDE.md and registers cron jobs.
# Custom commands (TOML) and MCP hooks are community-welcome.

set -e

VAULT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
BOOTSTRAP="$VAULT/_bootstrap"
ADAPTER="$BOOTSTRAP/adapters/gemini-cli"
GEMINI_DIR="$HOME/.gemini"

echo "=== second-brain-starter — Gemini CLI adapter (beta) ==="
echo "Vault      : $VAULT"
echo "Gemini dir : $GEMINI_DIR"
echo ""

mkdir -p "$GEMINI_DIR" "$VAULT/.logs"

# ---------------------------------------------------------------------------
# STEP 1 — SSOT file (GEMINI.md)
# ---------------------------------------------------------------------------
echo "[1/2] SSOT: GEMINI.md..."

DEST="$GEMINI_DIR/GEMINI.md"

cat "$ADAPTER/templates/gemini.md" > "$DEST"
sed "s|{VAULT}|$VAULT|g" "$VAULT/CLAUDE.md" >> "$DEST"

echo "  ✓ $DEST"

# ---------------------------------------------------------------------------
# STEP 2 — Cron jobs (agent-agnostic)
# ---------------------------------------------------------------------------
echo ""
echo "[2/2] Cron jobs..."

CRON_CURRENT=$(crontab -l 2>/dev/null || echo "")
CRON_UPDATED="$CRON_CURRENT"
ADDED=0

add_cron() {
  local schedule="$1"
  local script="$2"
  local label="$3"
  local logfile="$VAULT/.logs/${script%.sh}.log"
  local line="$schedule bash $BOOTSTRAP/scripts/$script >> $logfile 2>&1"
  if echo "$CRON_CURRENT" | grep -q "$BOOTSTRAP/scripts/$script"; then
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

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Gemini CLI adapter (beta) installed ==="
echo ""
echo "Installed:"
echo "  - $DEST  (SSOT, auto-read by Gemini CLI)"
echo "  - 2 cron jobs (daily heartbeat + weekly lint)"
echo ""
echo "Not yet converted (community PR welcome):"
echo "  - Skills as TOML commands in ~/.gemini/commands/"
echo "  - MCP-based hook equivalents"
echo ""
echo "For now, invoke skills in natural language:"
echo "  \"Follow the braindump approach from the vault on this: ...\""
echo "  \"Use the ingest skill from _bootstrap/global/commands/ingest.md\""
echo ""
echo "More: $ADAPTER/README.md"
