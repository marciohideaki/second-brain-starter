#!/bin/bash
# Hook: UserPromptSubmit
# 1. Log every prompt to _memory/.prompt-log.txt (gitignored, local only)
# 2. Inject project state.md once per day per project (if it exists)
# 3. Inject pending alerts once per day per project
#
# Registered in ~/.claude/settings.json by install.sh:
#   "UserPromptSubmit": [{ "hooks": [{ "type": "command",
#     "command": "bash {VAULT}/_bootstrap/global/hooks/on-prompt-submit.sh", "timeout": 5 }] }]

# CRITICAL: stdin can be read only once — must be the first operation
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || echo "")
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || echo "$PWD")

# Auto-detect vault: script lives in _bootstrap/global/hooks/ — vault is 3 levels up
VAULT="$(cd "$(dirname "$0")/../../.." && pwd)"
PROMPT_LOG="$VAULT/_memory/.prompt-log.txt"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

mkdir -p "$VAULT/_memory"

# Always log the prompt (dotfile, gitignored)
if [ -n "$PROMPT" ]; then
  printf '[%s|cwd:%s] %s\n' "$TIMESTAMP" "${CWD##*/}" "$PROMPT" >> "$PROMPT_LOG"
fi

# Guard: alerts and state injection run at most once per day per project
PROJECT_NAME="$(basename "$CWD")"
ALERTED_TODAY="/tmp/brain-alerted-$(date +%Y%m%d)-${PROJECT_NAME}"
if [ -f "$ALERTED_TODAY" ]; then
  exit 0
fi
touch "$ALERTED_TODAY"

# Inject project state.md if it exists for this project
STATE_FILE="$VAULT/_knowledge/projects/${PROJECT_NAME}/state.md"
STATE_INJECTED_FLAG="/tmp/brain-state-injected-$(date +%Y%m%d)-${PROJECT_NAME}"

if [ -f "$STATE_FILE" ] && [ ! -f "$STATE_INJECTED_FLAG" ]; then
  touch "$STATE_INJECTED_FLAG"
  STATE_CONTENT=$(grep -v "^---" "$STATE_FILE" | grep -v "^updated:" | sed '/^[[:space:]]*$/d')
  printf '[PROJECT: %s]\n%s\n' "$PROJECT_NAME" "$STATE_CONTENT"
fi

# Detect pending session flags
NEEDS_END="$VAULT/_memory/.needs-end-session"
COMPACTED="$VAULT/_memory/.compacted-without-end-session"
STATE="$VAULT/_memory/current-state.md"
ALERTS=""

[ -f "$NEEDS_END" ] && \
  ALERTS="${ALERTS}\n- Previous session ($(cat "$NEEDS_END" 2>/dev/null)) ended without /end-session."

[ -f "$COMPACTED" ] && \
  ALERTS="${ALERTS}\n- Context was compacted without /end-session: $(cat "$COMPACTED" 2>/dev/null)."

if [ -f "$STATE" ]; then
  LAST=$(grep "^updated:" "$STATE" 2>/dev/null | sed 's/updated: //' | tr -d ' ')
  if [ -n "$LAST" ]; then
    LAST_TS=$(date -d "$LAST" +%s 2>/dev/null || echo 0)
    NOW_TS=$(date +%s)
    DAYS=$(( (NOW_TS - ${LAST_TS:-$NOW_TS}) / 86400 ))
    [ "${DAYS:-0}" -gt 3 ] && \
      ALERTS="${ALERTS}\n- current-state.md is ${DAYS} days stale (last update: ${LAST})."
  fi
fi

[ -z "$ALERTS" ] && exit 0

printf '[BRAIN] Pending items detected:%b\nRun /end-session to sync the vault.\n' "$ALERTS"
