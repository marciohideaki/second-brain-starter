#!/bin/bash
# Codex CLI adapter — stub install.
# Generates AGENTS.md in the vault root and registers cron jobs.

set -e

VAULT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
BOOTSTRAP="$VAULT/_bootstrap"
ADAPTER="$BOOTSTRAP/adapters/codex"

echo "=== second-brain-starter — Codex CLI adapter (stub) ==="
echo "Vault: $VAULT"
echo ""

mkdir -p "$VAULT/.logs"

# ---------------------------------------------------------------------------
# STEP 1 — Generate AGENTS.md
# ---------------------------------------------------------------------------
echo "[1/2] SSOT: AGENTS.md..."

DEST="$VAULT/AGENTS.md"

cat "$ADAPTER/templates/agents.md" > "$DEST"
sed "s|{VAULT}|$VAULT|g" "$VAULT/CLAUDE.md" >> "$DEST"

echo "  ✓ $DEST"

# ---------------------------------------------------------------------------
# STEP 2 — Cron jobs
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

echo ""
echo "=== Codex CLI adapter (stub) installed ==="
echo ""
echo "Installed:"
echo "  - $DEST  (Codex auto-reads AGENTS.md at session start)"
echo "  - 2 cron jobs"
echo ""
echo "Limitations:"
echo "  - No event hooks (Codex CLI has no equivalent system)."
echo "  - No slash commands. Invoke skills via natural language:"
echo "      \"Run the braindump skill: ...\""
echo ""
echo "More: $ADAPTER/README.md"
