#!/bin/bash
# Hook: PreCompact
# Runs before Claude Code compacts context.
# 1. Auto-snapshot critical state (next steps + open questions)
# 2. Append to activity log
# 3. Preserve .pre-compact-notes.md (manual or auto-generated)
# 4. Create .compacted-without-end-session flag if /end-session didn't run
#
# Registered in ~/.claude/settings.json by install.sh:
#   "PreCompact": [{ "hooks": [{ "type": "command",
#     "command": "bash {VAULT}/_bootstrap/global/hooks/on-pre-compact.sh", "timeout": 5 }] }]

# Auto-detect vault: script lives in _bootstrap/global/hooks/ — vault is 3 levels up
VAULT="$(cd "$(dirname "$0")/../../.." && pwd)"

LOG="$VAULT/_memory/activity-log.md"
NOTES="$VAULT/_memory/.pre-compact-notes.md"
FLAG="$VAULT/_memory/.compacted-without-end-session"
STATE="$VAULT/_memory/current-state.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
TODAY=$(date '+%Y-%m-%d')

mkdir -p "$VAULT/_memory"

# Auto-snapshot: extract Next Steps and Open Questions from current-state if no manual notes
if [ ! -f "$NOTES" ] && [ -f "$STATE" ]; then
  NEXT_STEPS=$(awk '/^### Next Steps/{found=1; next} found && /^###/{exit} found{print}' "$STATE" | grep -v '^$' | head -5)
  OPEN_Q=$(awk '/^### Open Questions/{found=1; next} found && /^###/{exit} found{print}' "$STATE" | grep -v '^$' | head -3)
  if [ -n "$NEXT_STEPS" ] || [ -n "$OPEN_Q" ]; then
    {
      echo "# Pre-compact snapshot — $TIMESTAMP"
      echo ""
      [ -n "$NEXT_STEPS" ] && printf "## Next Steps\n%s\n\n" "$NEXT_STEPS"
      [ -n "$OPEN_Q" ]    && printf "## Open Questions\n%s\n\n" "$OPEN_Q"
    } > "$NOTES"
  fi
fi

# Log compaction event
printf '\n## [%s] compact | context compacted\n' "$TIMESTAMP" >> "$LOG"

# Preserve notes (manual or auto) into the log, then remove the file
if [ -f "$NOTES" ]; then
  CONTENT=$(cat "$NOTES")
  printf '\n### Pre-compact notes\n%s\n' "$CONTENT" >> "$LOG"
  rm -f "$NOTES"
fi

# Flag if /end-session didn't run before this compaction
if ! grep -q "end-session | " "$LOG" 2>/dev/null; then
  printf '%s\n' "$TODAY" > "$FLAG"
fi

exit 0
