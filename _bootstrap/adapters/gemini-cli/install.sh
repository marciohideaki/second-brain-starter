#!/bin/bash
# Gemini CLI adapter.
# Creates a managed GEMINI.md bridge and registers cron jobs.

set -e

SOURCE_ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
TARGET_VAULT="${2:-${SECOND_BRAIN_VAULT:-$SOURCE_ROOT}}"
VAULT_NAME="${3:-$(basename "$TARGET_VAULT")}"
VAULT_PREFIX="${4:-second-brain}"
SOURCE_ROOT="$(cd "$SOURCE_ROOT" && pwd)"
TARGET_VAULT="$(mkdir -p "$TARGET_VAULT" && cd "$TARGET_VAULT" && pwd)"
BOOTSTRAP="$SOURCE_ROOT/_bootstrap"
ADAPTER="$BOOTSTRAP/adapters/gemini-cli"
GEMINI_DIR="$HOME/.gemini"
<<<<<<< Updated upstream
TARGET_SCRIPTS_DIR="$TARGET_VAULT/_bootstrap/scripts"

echo "=== second-brain-starter — Gemini CLI adapter ==="
echo "Source    : $SOURCE_ROOT"
echo "Vault     : $TARGET_VAULT"
echo "Name      : $VAULT_NAME"
echo "Prefix    : $VAULT_PREFIX"
echo "Gemini dir: $GEMINI_DIR"
echo ""

mkdir -p "$GEMINI_DIR" "$TARGET_VAULT/.logs"
=======
TARGET_SCRIPTS_DIR="$TARGET_VAULT/.claude/scripts"

echo "=== second-brain-starter — Gemini CLI adapter (beta) ==="
echo "Source     : $SOURCE_ROOT"
echo "Vault      : $TARGET_VAULT"
echo "Name       : $VAULT_NAME"
echo "Prefix     : $VAULT_PREFIX"
echo "Gemini dir : $GEMINI_DIR"
echo ""

mkdir -p "$GEMINI_DIR" "$TARGET_VAULT/.logs" "$TARGET_SCRIPTS_DIR"
>>>>>>> Stashed changes

echo "[1/2] SSOT: GEMINI.md..."

DEST="$GEMINI_DIR/${VAULT_PREFIX}-GEMINI.md"
<<<<<<< Updated upstream

for old in "$GEMINI_DIR"/*-GEMINI.md; do
  [ -f "$old" ] || continue
  if grep -q "$TARGET_VAULT" "$old"; then
    rm -f "$old"
  fi
done

sed "s|{VAULT}|$TARGET_VAULT|g" "$ADAPTER/templates/gemini.md" > "$DEST"
printf '\n\n<!-- Vault: %s -->\n\n' "$TARGET_VAULT" >> "$DEST"
=======
INDEX="$GEMINI_DIR/GEMINI.md"

for managed in "$GEMINI_DIR"/*-GEMINI.md; do
  [ -f "$managed" ] || continue
  if grep -q "Second Brain managed file" "$managed" \
    && grep -q "Vault: $TARGET_VAULT" "$managed" \
    && grep -q "Source: $SOURCE_ROOT" "$managed"; then
    rm -f "$managed"
  fi
done

{
  printf '%s\n' '<!-- Second Brain managed file -->'
  printf '<!-- Vault: %s -->\n' "$TARGET_VAULT"
  printf '<!-- Source: %s -->\n\n' "$SOURCE_ROOT"
  cat "$ADAPTER/templates/gemini.md"
} > "$DEST"
>>>>>>> Stashed changes
if [ -f "$TARGET_VAULT/CLAUDE.md" ]; then
  sed "s|{VAULT}|$TARGET_VAULT|g" "$TARGET_VAULT/CLAUDE.md" >> "$DEST"
else
  sed "s|{VAULT}|$TARGET_VAULT|g" "$SOURCE_ROOT/CLAUDE.md" >> "$DEST"
fi

<<<<<<< Updated upstream
cat > "$GEMINI_DIR/GEMINI.md" <<EOF
# Gemini CLI managed index

Use this Second Brain configuration:

$DEST

EOF

echo "  ✓ $DEST"
echo "  ✓ $GEMINI_DIR/GEMINI.md"
=======
if [ ! -f "$INDEX" ] || grep -q "Second Brain managed Gemini index" "$INDEX"; then
  {
    printf '%s\n' '<!-- Second Brain managed Gemini index -->'
    printf '<!-- Vault: %s -->\n' "$TARGET_VAULT"
    printf '<!-- Source: %s -->\n\n' "$SOURCE_ROOT"
    printf '# Gemini CLI Second Brain Index\n\n'
    printf 'Load the vault-specific file for this installation:\n\n'
    printf '%s\n' "- \`$DEST\`"
  } > "$INDEX"
fi

echo "  ✓ $DEST"
echo "  ✓ $INDEX"
>>>>>>> Stashed changes

echo ""
echo "[2/2] Cron jobs..."

if [ "${SECOND_BRAIN_SKIP_CRON:-}" = "1" ]; then
  echo "  - skipped (SECOND_BRAIN_SKIP_CRON=1)"
  ADDED=0
else
<<<<<<< Updated upstream
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
=======

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
>>>>>>> Stashed changes
  fi
fi

<<<<<<< Updated upstream
=======
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
>>>>>>> Stashed changes
echo ""
echo "=== Gemini CLI adapter installed ==="
echo ""
echo "Installed:"
<<<<<<< Updated upstream
echo "  - $DEST"
echo "  - $GEMINI_DIR/GEMINI.md"
echo "  - $ADDED cron job(s) new"
=======
echo "  - $DEST  (SSOT, auto-read by Gemini CLI)"
echo "  - $INDEX  (managed index when no manual GEMINI.md exists)"
echo "  - 2 cron jobs (daily heartbeat + weekly lint)"
>>>>>>> Stashed changes
echo ""
echo "Limitations:"
echo "  - Skills are not converted to TOML commands yet."
echo "  - Event hooks are not mapped 1:1."
echo ""
echo "More: $ADAPTER/README.md"
