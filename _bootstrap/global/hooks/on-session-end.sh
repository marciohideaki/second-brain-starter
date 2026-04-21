#!/bin/bash
# Hook: SessionEnd
# 1. Log session-end to activity-log.md
# 2. Update `updated:` field in current-state.md
# 3. Create .needs-end-session flag if /end-session wasn't run
#
# Registered in ~/.claude/settings.json by install.sh:
#   "SessionEnd": [{ "hooks": [{ "type": "command",
#     "command": "bash {VAULT}/_bootstrap/global/hooks/on-session-end.sh", "timeout": 5 }] }]

# Auto-detect vault: script lives in _bootstrap/global/hooks/ — vault is 3 levels up
VAULT="$(cd "$(dirname "$0")/../../.." && pwd)"

LOG="$VAULT/_memory/activity-log.md"
STATE="$VAULT/_memory/current-state.md"
FLAG="$VAULT/_memory/.needs-end-session"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
TODAY=$(date '+%Y-%m-%d')

mkdir -p "$VAULT/_memory"

# Log session-end (only once per session)
if [ -f "$LOG" ] && ! grep -q "\[$(date '+%Y-%m-%d')" "$LOG" | grep -q "session-end"; then
  printf '\n## [%s] session-end | vault\n' "$TIMESTAMP" >> "$LOG"
fi

# Update `updated:` in current-state.md
if [ -f "$STATE" ]; then
  sed -i.bak "s/^updated: .*/updated: $TODAY/" "$STATE" 2>/dev/null
  rm -f "${STATE}.bak"
fi

# If /end-session didn't run, leave a flag so next session knows
END_SESSION_RAN=$(grep -c "end-session | " "$LOG" 2>/dev/null | tr -d '[:space:]')
if [ "${END_SESSION_RAN:-0}" -eq 0 ]; then
  printf '%s\n' "$TODAY" > "$FLAG"
fi

exit 0
