#!/bin/bash
# Cursor adapter — installs second-brain-starter for Cursor.
#
# Invoked by the root install.sh with --agent=cursor.
<<<<<<< Updated upstream
# Reads source and target vault paths from the root script.
=======
# Reads source root from $1 and target vault from $2 (passed by the root script).
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
TARGET_BOOTSTRAP="$TARGET_VAULT/_bootstrap"
TARGET_COMMANDS_DIR="$TARGET_BOOTSTRAP/global/commands"
TARGET_SCRIPTS_DIR="$TARGET_BOOTSTRAP/scripts"
=======
TARGET_SCRIPTS_DIR="$TARGET_VAULT/.claude/scripts"
>>>>>>> Stashed changes

echo "=== second-brain-starter — Cursor adapter ==="
echo "Source       : $SOURCE_ROOT"
echo "Vault        : $TARGET_VAULT"
echo "Name         : $VAULT_NAME"
echo "Prefix       : $VAULT_PREFIX"
echo "Cursor rules : $CURSOR_RULES"
echo ""

<<<<<<< Updated upstream
mkdir -p "$CURSOR_RULES" "$TARGET_VAULT/.logs"
=======
mkdir -p "$CURSOR_RULES" "$TARGET_VAULT/.logs" "$TARGET_SCRIPTS_DIR"
>>>>>>> Stashed changes

# ---------------------------------------------------------------------------
# STEP 1 — SSOT rule (always applied): the CLAUDE.md content
# ---------------------------------------------------------------------------
echo "[1/3] SSOT rule..."

for managed in "$CURSOR_RULES"/*.mdc; do
  [ -f "$managed" ] || continue
  if grep -q "Second Brain managed rule" "$managed" \
    && grep -q "Vault: $TARGET_VAULT" "$managed" \
    && grep -q "Source: $SOURCE_ROOT" "$managed"; then
    rm -f "$managed"
  fi
done

SSOT_DEST="$CURSOR_RULES/${VAULT_PREFIX}-00-second-brain.mdc"

# Header with frontmatter
<<<<<<< Updated upstream
sed "s|{VAULT}|$TARGET_VAULT|g" "$ADAPTER/templates/cursorrules-header.mdc" > "$SSOT_DEST"

# Append CLAUDE.md body (strip its H1 since the header already has the title)
awk 'NR > 1 || !/^# /' "$TARGET_VAULT/CLAUDE.md" | sed "s|{VAULT}|$TARGET_VAULT|g" >> "$SSOT_DEST"
=======
{
  printf '%s\n' '<!-- Second Brain managed rule -->'
  printf '<!-- Vault: %s -->\n' "$TARGET_VAULT"
  printf '<!-- Source: %s -->\n\n' "$SOURCE_ROOT"
  sed "s|{VAULT}|$TARGET_VAULT|g" "$ADAPTER/templates/cursorrules-header.mdc"
} > "$SSOT_DEST"

# Append CLAUDE.md body (strip its H1 since the header already has the title)
if [ -f "$TARGET_VAULT/CLAUDE.md" ]; then
  awk 'NR > 1 || !/^# /' "$TARGET_VAULT/CLAUDE.md" | sed "s|{VAULT}|$TARGET_VAULT|g" >> "$SSOT_DEST"
else
  awk 'NR > 1 || !/^# /' "$SOURCE_ROOT/CLAUDE.md" | sed "s|{VAULT}|$TARGET_VAULT|g" >> "$SSOT_DEST"
fi
>>>>>>> Stashed changes

echo "  ✓ $SSOT_DEST"

# ---------------------------------------------------------------------------
# STEP 2 — Skills as description-matched rules
# ---------------------------------------------------------------------------
echo ""
echo "[2/3] Skill rules..."

for src in "$TARGET_COMMANDS_DIR/"*.md; do
  [ -f "$src" ] || continue
  name=$(basename "$src" .md)
  dst="$CURSOR_RULES/${VAULT_PREFIX}-skill-$name.mdc"

  # Extract the one-line description from the source frontmatter
  desc=$(awk '/^description:/ { sub(/^description: */, ""); print; exit }' "$src")
  [ -z "$desc" ] && desc="Second Brain skill: $name"

  cat > "$dst" <<EOF
<!-- Second Brain managed rule -->
<!-- Vault: $TARGET_VAULT -->
<!-- Source: $SOURCE_ROOT -->

---
description: "Second Brain skill — $name. $desc Invoke by asking: run the $name skill on <input>."
alwaysApply: false
---

# /$name skill

$(sed '/^---$/,/^---$/d' "$src" | sed "s|{VAULT}|$TARGET_VAULT|g")
EOF

  echo "  ✓ ${VAULT_PREFIX}-skill-$name.mdc"
done

# ---------------------------------------------------------------------------
# STEP 3 — Cron jobs (agent-agnostic: same as Claude Code install)
# ---------------------------------------------------------------------------
echo ""
echo "[3/3] Cron jobs..."

if [ "${SECOND_BRAIN_SKIP_CRON:-}" = "1" ]; then
  echo "  - skipped (SECOND_BRAIN_SKIP_CRON=1)"
else

for src in "$BOOTSTRAP/scripts/"*.sh; do
  [ -f "$src" ] || continue
  dest="$TARGET_SCRIPTS_DIR/$(basename "$src")"
  cp "$src" "$dest"
  sed -i "s|^VAULT=.*|VAULT=\"$TARGET_VAULT\"|" "$dest"
  chmod +x "$dest"
done

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

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Cursor adapter installed ==="
echo ""
echo "Rules installed at: $CURSOR_RULES"
<<<<<<< Updated upstream
echo "  - 00-second-brain.mdc       (SSOT, always active)"
echo "  - skill-<name>.mdc          (skills, loaded on demand)"
=======
echo "  - ${VAULT_PREFIX}-00-second-brain.mdc       (SSOT, always active)"
echo "  - ${VAULT_PREFIX}-skill-<name>.mdc          (12 skills, loaded on demand)"
>>>>>>> Stashed changes
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
echo "  - Cron jobs still run unless SECOND_BRAIN_SKIP_CRON=1 was set."
echo ""
echo "More: $BOOTSTRAP/adapters/cursor/README.md"
