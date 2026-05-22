#!/bin/bash
# Cursor adapter — installs second-brain-starter for Cursor.
#
# Invoked by the root install.sh with --agent=cursor.
# Reads source and target vault paths from the root script.

set -e

SOURCE_ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
TARGET_VAULT="${2:-${SECOND_BRAIN_VAULT:-$SOURCE_ROOT}}"
VAULT_NAME="${3:-$(basename "$TARGET_VAULT")}"
VAULT_PREFIX="${4:-second-brain}"
SOURCE_ROOT="$(cd "$SOURCE_ROOT" && pwd)"
TARGET_VAULT="$(mkdir -p "$TARGET_VAULT" && cd "$TARGET_VAULT" && pwd)"
BOOTSTRAP="$SOURCE_ROOT/_bootstrap"
ADAPTER="$BOOTSTRAP/adapters/cursor"
CURSOR_RULES="$HOME/.cursor/rules"
TARGET_BOOTSTRAP="$TARGET_VAULT/_bootstrap"
TARGET_COMMANDS_DIR="$TARGET_BOOTSTRAP/global/commands"
TARGET_SCRIPTS_DIR="$TARGET_BOOTSTRAP/scripts"

echo "=== second-brain-starter — Cursor adapter ==="
echo "Source       : $SOURCE_ROOT"
echo "Vault        : $TARGET_VAULT"
echo "Name         : $VAULT_NAME"
echo "Prefix       : $VAULT_PREFIX"
echo "Cursor rules : $CURSOR_RULES"
echo ""

mkdir -p "$CURSOR_RULES" "$TARGET_VAULT/.logs"

# ---------------------------------------------------------------------------
# STEP 1 — SSOT rule (always applied): the CLAUDE.md content
# ---------------------------------------------------------------------------
echo "[1/3] SSOT rule..."

SSOT_DEST="$CURSOR_RULES/00-second-brain.mdc"

# Header with frontmatter
sed "s|{VAULT}|$TARGET_VAULT|g" "$ADAPTER/templates/cursorrules-header.mdc" > "$SSOT_DEST"

# Append CLAUDE.md body (strip its H1 since the header already has the title)
awk 'NR > 1 || !/^# /' "$TARGET_VAULT/CLAUDE.md" | sed "s|{VAULT}|$TARGET_VAULT|g" >> "$SSOT_DEST"

echo "  ✓ $SSOT_DEST"

# ---------------------------------------------------------------------------
# STEP 2 — Skills as description-matched rules
# ---------------------------------------------------------------------------
echo ""
echo "[2/3] Skill rules..."

for src in "$TARGET_COMMANDS_DIR/"*.md; do
  [ -f "$src" ] || continue
  name=$(basename "$src" .md)
  dst="$CURSOR_RULES/skill-$name.mdc"

  # Extract the one-line description from the source frontmatter
  desc=$(awk '/^description:/ { sub(/^description: */, ""); print; exit }' "$src")
  [ -z "$desc" ] && desc="Second Brain skill: $name"

  cat > "$dst" <<EOF
---
description: "Second Brain skill — $name. $desc Invoke by asking: run the $name skill on <input>."
alwaysApply: false
---

# /$name skill

$(sed '/^---$/,/^---$/d' "$src" | sed "s|{VAULT}|$TARGET_VAULT|g")
EOF

  echo "  ✓ skill-$name.mdc"
done

# ---------------------------------------------------------------------------
# STEP 3 — Cron jobs (agent-agnostic: same as Claude Code install)
# ---------------------------------------------------------------------------
echo ""
echo "[3/3] Cron jobs..."

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

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Cursor adapter installed ==="
echo ""
echo "Rules installed at: $CURSOR_RULES"
echo "  - 00-second-brain.mdc       (SSOT, always active)"
echo "  - skill-<name>.mdc          (skills, loaded on demand)"
echo ""
echo "How to invoke a skill:"
echo "  Open Cursor, then type in the chat:"
echo "    \"Run the braindump skill: I need to capture a thought.\""
echo "    \"Use the ingest skill on https://example.com/article.\""
echo "    \"Run the daily-briefing skill.\""
echo ""
echo "Cursor matches the skill rule by its description."
echo ""
echo "Limitations vs Claude Code:"
echo "  - No event hooks: run /end-session explicitly at end of day."
echo "  - No auto state-injection: current-state.md is not auto-loaded each prompt."
echo "  - Cron jobs still run (daily heartbeat 07:00, weekly lint Mon 09:00)."
echo ""
echo "More: $BOOTSTRAP/adapters/cursor/README.md"
