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
#   bash install.sh
#   bash install.sh --target-vault /path/to/vault
#   bash install.sh --agent=claude-code
#   bash install.sh --agent=codex
#   bash install.sh --agents=claude-code,codex
#   bash install.sh --vault-name "My Second Brain" --vault-prefix mybrain
#
# Idempotent: safe to run multiple times, never duplicates configuration.
#
# Prerequisites:
#   - Claude Code installed (npm install -g @anthropic-ai/claude-code)
#   - jq installed (to merge settings.json; fallback available without it)

set -e

SOURCE_ROOT="$(cd "$(dirname "$0")" && pwd)"
TARGET_VAULT="${SECOND_BRAIN_VAULT:-$SOURCE_ROOT}"
BOOTSTRAP="$SOURCE_ROOT/_bootstrap"

AGENT="claude-code"
AGENTS=""
FORCE_SINGLE_AGENT=0
AGENTS_EXPLICIT=0
VAULT_NAME=""
VAULT_PREFIX=""

while [ $# -gt 0 ]; do
  case "$1" in
    --agents=*)
      AGENTS="${1#*=}"
      AGENTS_EXPLICIT=1
      shift
      ;;
    --agents)
      AGENTS="$2"
      AGENTS_EXPLICIT=1
      shift 2
      ;;
    --agent=*)
      AGENT="${1#*=}"
      FORCE_SINGLE_AGENT=1
      shift
      ;;
    --agent)
      AGENT="$2"
      FORCE_SINGLE_AGENT=1
      shift 2
      ;;
    --target-vault=*)
      TARGET_VAULT="${1#*=}"
      shift
      ;;
    --target-vault)
      TARGET_VAULT="$2"
      shift 2
      ;;
    --vault-name=*)
      VAULT_NAME="${1#*=}"
      shift
      ;;
    --vault-name)
      VAULT_NAME="$2"
      shift 2
      ;;
    --vault-prefix=*)
      VAULT_PREFIX="${1#*=}"
      shift
      ;;
    --vault-prefix)
      VAULT_PREFIX="$2"
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

TARGET_VAULT="$(mkdir -p "$TARGET_VAULT" && cd "$TARGET_VAULT" && pwd)"
TARGET_BOOTSTRAP="$TARGET_VAULT/_bootstrap"
TARGET_COMMANDS_DIR="$TARGET_BOOTSTRAP/global/commands"
TARGET_HOOKS_DIR="$TARGET_BOOTSTRAP/global/hooks"
TARGET_SCRIPTS_DIR="$TARGET_BOOTSTRAP/scripts"
INSTALL_CONFIG_DIR="$TARGET_VAULT/.second-brain"
INSTALL_CONFIG="$INSTALL_CONFIG_DIR/install.env"

sanitize_prefix() {
  printf '%s' "$1" | tr '[:upper:] _' '[:lower:]--' | sed 's/[^a-z0-9-]//g; s/--*/-/g; s/^-//; s/-$//'
}

quote_config_value() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

read_install_config() {
  [ -f "$INSTALL_CONFIG" ] || return 0
  while IFS='=' read -r key value; do
    case "$key" in
      SECOND_BRAIN_VAULT_NAME|SECOND_BRAIN_VAULT_PREFIX|SECOND_BRAIN_AGENTS)
        value="${value%\"}"
        value="${value#\"}"
        case "$key" in
          SECOND_BRAIN_VAULT_NAME) SECOND_BRAIN_VAULT_NAME="$value" ;;
          SECOND_BRAIN_VAULT_PREFIX) SECOND_BRAIN_VAULT_PREFIX="$value" ;;
          SECOND_BRAIN_AGENTS) SECOND_BRAIN_AGENTS="$value" ;;
        esac
        ;;
    esac
  done < "$INSTALL_CONFIG"
}

copy_if_missing() {
  local src="$1"
  local dest="$2"
  if [ -f "$src" ] && [ ! -e "$dest" ]; then
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
  fi
}

copy_runtime_file() {
  local src="$1"
  local dest="$2"
  [ -f "$src" ] || return 0
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ "$(readlink -f "$src")" = "$(readlink -f "$dest")" ]; then
    return 1
  fi
  cp "$src" "$dest"
}

materialize_target_runtime() {
  mkdir -p \
    "$TARGET_COMMANDS_DIR" \
    "$TARGET_HOOKS_DIR" \
    "$TARGET_SCRIPTS_DIR" \
    "$TARGET_VAULT/.logs" \
    "$TARGET_VAULT/_knowledge/projects" \
    "$TARGET_VAULT/_memory" \
    "$TARGET_VAULT/_sources" \
    "$TARGET_VAULT/_wiki" \
    "$TARGET_VAULT/_learnings" \
    "$TARGET_VAULT/_decisions" \
    "$TARGET_VAULT/_pipeline" \
    "$TARGET_VAULT/_sessions"

  for src in "$BOOTSTRAP/global/commands/"*.md; do
    [ -f "$src" ] || continue
    copy_runtime_file "$src" "$TARGET_COMMANDS_DIR/$(basename "$src")" || true
  done

  for src in "$BOOTSTRAP/global/hooks/"*.sh; do
    [ -f "$src" ] || continue
    dest="$TARGET_HOOKS_DIR/$(basename "$src")"
    copy_runtime_file "$src" "$dest" || continue
    sed -i "s|{VAULT}|$TARGET_VAULT|g" "$dest"
    chmod +x "$dest"
  done

  for src in "$BOOTSTRAP/scripts/"*.sh "$BOOTSTRAP/scripts/"*.py; do
    [ -f "$src" ] || continue
    dest="$TARGET_SCRIPTS_DIR/$(basename "$src")"
    copy_runtime_file "$src" "$dest" || continue
    sed -i "s|{VAULT}|$TARGET_VAULT|g" "$dest"
    case "$dest" in
      *.sh) chmod +x "$dest" ;;
    esac
  done

  copy_if_missing "$SOURCE_ROOT/CLAUDE.md" "$TARGET_VAULT/CLAUDE.md"
  copy_if_missing "$BOOTSTRAP/global/settings.json" "$TARGET_BOOTSTRAP/global/settings.json"
  copy_if_missing "$BOOTSTRAP/global/CLAUDE.md" "$TARGET_BOOTSTRAP/global/CLAUDE.md"
  copy_if_missing "$BOOTSTRAP/project/CLAUDE.md" "$TARGET_BOOTSTRAP/project/CLAUDE.md"
  copy_if_missing "$SOURCE_ROOT/_knowledge/about-me.md" "$TARGET_VAULT/_knowledge/about-me.md"
  copy_if_missing "$SOURCE_ROOT/_knowledge/goals.md" "$TARGET_VAULT/_knowledge/goals.md"
  copy_if_missing "$SOURCE_ROOT/_knowledge/references.md" "$TARGET_VAULT/_knowledge/references.md"
  copy_if_missing "$SOURCE_ROOT/_decisions/_example.md" "$TARGET_VAULT/_decisions/_example.md"
  copy_if_missing "$SOURCE_ROOT/_learnings/_example.md" "$TARGET_VAULT/_learnings/_example.md"
  copy_if_missing "$SOURCE_ROOT/_pipeline/_example.md" "$TARGET_VAULT/_pipeline/_example.md"
}

if [ -f "$INSTALL_CONFIG" ]; then
  read_install_config
  [ -n "$VAULT_NAME" ] || VAULT_NAME="${SECOND_BRAIN_VAULT_NAME:-}"
  [ -n "$VAULT_PREFIX" ] || VAULT_PREFIX="${SECOND_BRAIN_VAULT_PREFIX:-}"
  if [ "$FORCE_SINGLE_AGENT" -eq 0 ] && [ "$AGENTS_EXPLICIT" -eq 0 ] && { [ ! -t 0 ] || [ ! -t 1 ]; }; then
    [ -n "$AGENTS" ] || AGENTS="${SECOND_BRAIN_AGENTS:-}"
  fi
fi

[ -n "$VAULT_NAME" ] || VAULT_NAME="$(basename "$TARGET_VAULT")"
[ -n "$VAULT_PREFIX" ] || VAULT_PREFIX="$(sanitize_prefix "$VAULT_NAME")"
[ -n "$VAULT_PREFIX" ] || VAULT_PREFIX="second-brain"
if [ "$FORCE_SINGLE_AGENT" -eq 1 ] && [ "$AGENTS_EXPLICIT" -eq 0 ]; then
  AGENTS="$AGENT"
else
  [ -n "$AGENTS" ] || AGENTS="${SECOND_BRAIN_AGENTS:-$AGENT}"
fi

OLD_IFS="$IFS"
IFS=','
for selected_agent in $AGENTS; do
  if [ "$selected_agent" != "claude-code" ] && [ ! -f "$BOOTSTRAP/adapters/$selected_agent/install.sh" ]; then
    echo "Unknown agent: $selected_agent"
    echo "Available adapters:"
    for d in "$BOOTSTRAP"/adapters/*/; do
      [ -d "$d" ] && echo "  - $(basename "$d")"
    done
    echo "  - claude-code (default)"
    IFS="$OLD_IFS"
    exit 1
  fi
done
IFS="$OLD_IFS"

mkdir -p "$INSTALL_CONFIG_DIR"
if [ -n "${SECOND_BRAIN_PARENT_AGENTS:-}" ]; then
  CONFIG_AGENTS="$SECOND_BRAIN_PARENT_AGENTS"
elif [ "$FORCE_SINGLE_AGENT" -eq 1 ] && [ "$AGENTS_EXPLICIT" -eq 0 ] && [ -n "${SECOND_BRAIN_AGENTS:-}" ]; then
  CONFIG_AGENTS="$SECOND_BRAIN_AGENTS"
else
  CONFIG_AGENTS="$AGENTS"
fi
cat > "$INSTALL_CONFIG" <<EOF
SECOND_BRAIN_VAULT_NAME="$(quote_config_value "$VAULT_NAME")"
SECOND_BRAIN_VAULT_PREFIX="$(quote_config_value "$VAULT_PREFIX")"
SECOND_BRAIN_AGENTS="$(quote_config_value "$CONFIG_AGENTS")"
EOF

materialize_target_runtime

if [ "$FORCE_SINGLE_AGENT" -eq 0 ] && [ -n "$AGENTS" ] && [ "$AGENTS" != "claude-code" ]; then
  OLD_IFS="$IFS"
  IFS=','
  for selected_agent in $AGENTS; do
    IFS="$OLD_IFS"
    if [ "$selected_agent" = "claude-code" ]; then
      SECOND_BRAIN_PARENT_AGENTS="$AGENTS" bash "$0" --agent=claude-code --target-vault "$TARGET_VAULT" --vault-name "$VAULT_NAME" --vault-prefix "$VAULT_PREFIX"
    else
      SECOND_BRAIN_PARENT_AGENTS="$AGENTS" bash "$BOOTSTRAP/adapters/$selected_agent/install.sh" "$SOURCE_ROOT" "$TARGET_VAULT" "$VAULT_NAME" "$VAULT_PREFIX"
    fi
    IFS=','
  done
  IFS="$OLD_IFS"
  exit 0
fi

if [ "$AGENT" != "claude-code" ]; then
  exec bash "$BOOTSTRAP/adapters/$AGENT/install.sh" "$SOURCE_ROOT" "$TARGET_VAULT" "$VAULT_NAME" "$VAULT_PREFIX"
fi

CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
GLOBAL_CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"

echo "=== second-brain-starter — Claude Code bootstrap ==="
echo "Source: $SOURCE_ROOT"
echo "Vault : $TARGET_VAULT"
echo "Name  : $VAULT_NAME"
echo "Prefix: $VAULT_PREFIX"
echo "Claude: $CLAUDE_DIR"
echo ""

mkdir -p "$COMMANDS_DIR"
chmod +x "$TARGET_HOOKS_DIR/"*.sh 2>/dev/null || true
chmod +x "$TARGET_SCRIPTS_DIR/"*.sh 2>/dev/null || true

echo "[1/5] Skills symlinks..."
for src in "$TARGET_COMMANDS_DIR/"*.md; do
  [ -f "$src" ] || continue
  cmd="$(basename "$src")"
  ln -sf "$src" "$COMMANDS_DIR/${COMMAND_PREFIX}$cmd"
  echo "  ✓ /${COMMAND_PREFIX}${cmd%.md}"
done

echo ""
echo "[2/5] Hooks in $SETTINGS_FILE..."

[ ! -f "$SETTINGS_FILE" ] && echo '{}' > "$SETTINGS_FILE"

if ! command -v jq &>/dev/null; then
  echo "  WARNING: jq not found."
  echo "  Configure manually: edit $SETTINGS_FILE"
  echo "  Replace {VAULT} with: $TARGET_VAULT"
  echo "  Reference: $TARGET_BOOTSTRAP/global/settings.json"
else
  cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak"

  HOOKS_JSON=$(sed "s|{VAULT}|$TARGET_VAULT|g" "$TARGET_BOOTSTRAP/global/settings.json" | jq '.hooks')

  jq --argjson hooks "$HOOKS_JSON" '
    def managed_second_brain_hook:
      ([.hooks[]?.command // ""] | join(" "))
      | test("(/second-brain/|/\\.claude/scripts/|/\\.claude/hooks/).*(on-prompt-submit|on-session-end|on-pre-compact|on-notification)\\.sh");
    .hooks = (.hooks // {}) |
    reduce ($hooks | keys[]) as $event (.;
      .hooks[$event] = ([ (.hooks[$event] // [])[] | select(managed_second_brain_hook | not) ] + $hooks[$event])
    )
  ' \
    "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" \
    && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"

  echo "  ✓ Hooks configured (backup: ${SETTINGS_FILE}.bak)"
fi

echo ""
echo "[3/5] Global bridge in $GLOBAL_CLAUDE_MD..."

GLOBAL_MARKER="## Second Brain"

if [ -f "$GLOBAL_CLAUDE_MD" ] && grep -q "$GLOBAL_MARKER" "$GLOBAL_CLAUDE_MD"; then
  echo "  - Block already present (skipping)"
else
  printf '\n' >> "$GLOBAL_CLAUDE_MD"
  sed "s|{VAULT}|$TARGET_VAULT|g" "$TARGET_BOOTSTRAP/global/CLAUDE.md" >> "$GLOBAL_CLAUDE_MD"
  echo "  ✓ Block injected"
fi

echo ""
echo "[4/5] Cron jobs..."

if [ "${SECOND_BRAIN_SKIP_CRON:-}" = "1" ]; then
  echo "  - skipped (SECOND_BRAIN_SKIP_CRON=1)"
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
echo "[5/5] Memory..."

ACTIVITY_LOG="$TARGET_VAULT/_memory/activity-log.md"
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

## [$(date '+%Y-%m-%d %H:%M')] setup | second-brain-starter installed at $TARGET_VAULT
EOF
  echo "  ✓ activity-log.md created"
else
  echo "  - activity-log.md already exists (kept)"
fi

CURRENT_STATE="$TARGET_VAULT/_memory/current-state.md"
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
else
  echo "  - current-state.md already exists (kept)"
fi

echo ""
echo "=== Install complete ==="
echo ""
echo "Three modes of operation now active:"
echo ""
echo "  GLOBAL — any Claude Code session, any project:"
echo "    ~/.claude/CLAUDE.md  tells Claude to read the vault"
echo "    Hooks fire automatically (pending items, session-end, compact)"
echo "    Skills available: /${COMMAND_PREFIX}init, /${COMMAND_PREFIX}braindump, /${COMMAND_PREFIX}ingest, /${COMMAND_PREFIX}wiki-build, /${COMMAND_PREFIX}focus ..."
echo ""
echo "  VAULT — when you run Claude from inside $TARGET_VAULT:"
echo "    Full access to knowledge, sources, wiki, learnings, decisions"
echo ""
echo "  PROJECT — when you run Claude from inside another project:"
echo "    Copy and adapt: $TARGET_BOOTSTRAP/project/CLAUDE.md → {project}/.claude/CLAUDE.md"
echo ""
echo "Next steps:"
echo "  1. Open any directory with 'claude' and run: /${COMMAND_PREFIX}init"
echo "  2. Drop your first source in _sources/ and run: /${COMMAND_PREFIX}ingest"
echo "  3. Compile your wiki: /${COMMAND_PREFIX}wiki-build"
echo ""
echo "Docs: $SOURCE_ROOT/docs/en/getting-started.md"
