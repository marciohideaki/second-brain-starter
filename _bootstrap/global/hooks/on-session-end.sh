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

# Check whether the latest session close today was a real /end-session.
LATEST_SESSION_END=""
[ -f "$LOG" ] && LATEST_SESSION_END=$(grep "^\## \[$TODAY.*session-end | " "$LOG" 2>/dev/null | tail -1)

# Update `updated:` in current-state.md
if [ -f "$STATE" ]; then
  sed -i.bak "s/^updated: .*/updated: $TODAY/" "$STATE" 2>/dev/null
  rm -f "${STATE}.bak"
fi

# If /end-session didn't run since the previous session close, leave a flag.
if ! printf '%s' "$LATEST_SESSION_END" | grep -q "session-end | .*—"; then
  printf '%s\n' "$TODAY" > "$FLAG"
fi

# Record this vault session close. The next session is pending until a new
# /end-session writes a project line.
printf '\n## [%s] session-end | vault\n' "$TIMESTAMP" >> "$LOG"

exit 0
