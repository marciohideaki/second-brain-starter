#!/bin/bash
# install.sh — second-brain-starter bootstrap
#
# Reads _bootstrap/ structure and wires up the environment:
#
#   _bootstrap/global/    → ~/.claude/        (active in every Claude Code session)
#   _bootstrap/project/   → manual reference  (template for individual projects)
#   _bootstrap/scripts/   → OS crontab         (run in the background)
#   _bootstrap/adapters/  → other agents      (--agent=cursor|gemini-cli|codex|antigravity)
#
# Usage:
#   bash install.sh                     # default: Claude Code
#   bash install.sh --agent=claude-code # explicit Claude Code
#   bash install.sh --agent=cursor      # Cursor adapter (functional)
#   bash install.sh --agent=gemini-cli  # Gemini CLI adapter (beta)
#   bash install.sh --agent=codex       # Codex CLI adapter (stub)
#   bash install.sh --agent=antigravity # Antigravity adapter (stub)
#
# Idempotent: safe to run multiple times, never duplicates configuration.
#
# Prerequisites:
#   - Claude Code installed (npm install -g @anthropic-ai/claude-code)
#   - jq installed (to merge settings.json; fallback available without it)

set -e

VAULT="$(cd "$(dirname "$0")" && pwd)"
BOOTSTRAP="$VAULT/_bootstrap"

# --- Parse args ---
AGENT="claude-code"
while [ $# -gt 0 ]; do
  case "$1" in
    --agent=*)
      AGENT="${1#*=}"
      shift
      ;;
    --agent)
      AGENT="$2"
      shift 2
      ;;
    -h|--help)
      grep '^# ' "$0" | sed 's/^# //;s/^#//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      echo "Run with --help for usage."
      exit 1
      ;;
  esac
done

# --- Delegate to adapter if not Claude Code ---
if [ "$AGENT" != "claude-code" ]; then
  ADAPTER_SCRIPT="$BOOTSTRAP/adapters/$AGENT/install.sh"
  if [ ! -f "$ADAPTER_SCRIPT" ]; then
    echo "Unknown agent: $AGENT"
    echo "Available adapters:"
    for d in "$BOOTSTRAP"/adapters/*/; do
      [ -d "$d" ] && echo "  - $(basename "$d")"
    done
    echo "  - claude-code (default)"
    exit 1
  fi
  exec bash "$ADAPTER_SCRIPT" "$VAULT"
fi

# --- Claude Code install (default path below) ---
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
GLOBAL_CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"

echo "=== second-brain-starter — Claude Code bootstrap ==="
echo "Vault : $VAULT"
echo "Claude: $CLAUDE_DIR"
echo ""

mkdir -p "$COMMANDS_DIR" "$VAULT/_bootstrap/global/hooks" "$VAULT/.logs"
chmod +x "$VAULT/_bootstrap/global/hooks/"*.sh 2>/dev/null || true
chmod +x "$VAULT/_bootstrap/scripts/"*.sh 2>/dev/null || true

# ---------------------------------------------------------------------------
# STEP 1 — Symlink skills: _bootstrap/global/commands/ → ~/.claude/commands/
# ---------------------------------------------------------------------------
echo "[1/5] Skills symlinks..."

for src in "$BOOTSTRAP/global/commands/"*.md; do
  [ -f "$src" ] || continue
  cmd="$(basename "$src")"
  ln -sf "$src" "$COMMANDS_DIR/$cmd"
  echo "  ✓ /${cmd%.md}"
done

# ---------------------------------------------------------------------------
# STEP 2 — Merge hooks: _bootstrap/global/settings.json → ~/.claude/settings.json
# ---------------------------------------------------------------------------
echo ""
echo "[2/5] Hooks in $SETTINGS_FILE..."

[ ! -f "$SETTINGS_FILE" ] && echo '{}' > "$SETTINGS_FILE"

if ! command -v jq &>/dev/null; then
  echo "  WARNING: jq not found."
  echo "  Configure manually: edit $SETTINGS_FILE"
  echo "  Replace {VAULT} with: $VAULT"
  echo "  Reference: $BOOTSTRAP/global/settings.json"
else
  cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak"

  HOOKS_JSON=$(sed "s|{VAULT}|$VAULT|g" "$BOOTSTRAP/global/settings.json" | jq '.hooks')

  jq --argjson hooks "$HOOKS_JSON" \
    '.hooks = ($hooks + (.hooks // {}))' \
    "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" \
    && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"

  echo "  ✓ Hooks configured (backup: ${SETTINGS_FILE}.bak)"
fi

# ---------------------------------------------------------------------------
# STEP 3 — Global block: _bootstrap/global/CLAUDE.md → append to ~/.claude/CLAUDE.md
# ---------------------------------------------------------------------------
echo ""
echo "[3/5] Global bridge in $GLOBAL_CLAUDE_MD..."

GLOBAL_MARKER="## Second Brain"

if [ -f "$GLOBAL_CLAUDE_MD" ] && grep -q "$GLOBAL_MARKER" "$GLOBAL_CLAUDE_MD"; then
  echo "  - Block already present (skipping)"
else
  printf '\n' >> "$GLOBAL_CLAUDE_MD"
  sed "s|{VAULT}|$VAULT|g" "$BOOTSTRAP/global/CLAUDE.md" >> "$GLOBAL_CLAUDE_MD"
  echo "  ✓ Block injected"
fi

# ---------------------------------------------------------------------------
# STEP 4 — Cron jobs: _bootstrap/scripts/ → OS crontab
# ---------------------------------------------------------------------------
echo ""
echo "[4/5] Cron jobs..."

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
# STEP 5 — Initialize memory
# ---------------------------------------------------------------------------
echo ""
echo "[5/5] Memory..."

ACTIVITY_LOG="$VAULT/_memory/activity-log.md"
if [ ! -f "$ACTIVITY_LOG" ]; then
  cat > "$ACTIVITY_LOG" <<EOF
---
tags: [memory, activity-log]
status: active
created: $(date '+%Y-%m-%d')
updated: $(date '+%Y-%m-%d')
---

# Activity Log

> Append-only. Retention: 90 days. Never edit existing entries.

## [$(date '+%Y-%m-%d %H:%M')] setup | second-brain-starter installed at $VAULT
EOF
  echo "  ✓ activity-log.md created"
else
  echo "  - activity-log.md already exists (kept)"
fi

CURRENT_STATE="$VAULT/_memory/current-state.md"
if [ ! -f "$CURRENT_STATE" ]; then
  cat > "$CURRENT_STATE" <<EOF
---
tags: [memory, state]
status: active
created: $(date '+%Y-%m-%d')
updated: $(date '+%Y-%m-%d')
---

# Current State

## Recent context

_Run /init to set up your brain or /braindump to capture a thought._

### Next Steps

- [ ] Personalize _knowledge/about-me.md
- [ ] Add first source via /ingest
- [ ] Compile wiki via /wiki-build

### Open Questions

_(none yet)_
EOF
  echo "  ✓ current-state.md seeded"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Install complete ==="
echo ""
echo "Three modes of operation now active:"
echo ""
echo "  GLOBAL — any Claude Code session, any project:"
echo "    ~/.claude/CLAUDE.md  tells Claude to read the vault"
echo "    Hooks fire automatically (pending items, session-end, compact)"
echo "    Skills available: /init, /braindump, /ingest, /wiki-build, /focus ..."
echo ""
echo "  VAULT — when you run Claude from inside $VAULT:"
echo "    Full access to knowledge, sources, wiki, learnings, decisions"
echo ""
echo "  PROJECT — when you run Claude from inside another project:"
echo "    Copy and adapt: $BOOTSTRAP/project/CLAUDE.md → {project}/.claude/CLAUDE.md"
echo ""
echo "Next steps:"
echo "  1. Open any directory with 'claude' and run: /init"
echo "  2. Drop your first source in _sources/ and run: /ingest"
echo "  3. Compile your wiki: /wiki-build"
echo ""
echo "Docs: $VAULT/docs/en/getting-started.md"
