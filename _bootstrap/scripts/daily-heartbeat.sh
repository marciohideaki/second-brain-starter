#!/bin/bash
# Cron: daily-heartbeat
# Suggested schedule: every day at 07:00
# Registered by install.sh:
#   0 7 * * * bash {VAULT}/_bootstrap/scripts/daily-heartbeat.sh >> {VAULT}/.logs/daily-heartbeat.log 2>&1
#
# Computes vault staleness and writes _memory/heartbeat-latest.md.
# No LLM needed — structural file analysis only.

# Auto-detect vault: script lives in _bootstrap/scripts/ — vault is 2 levels up
VAULT="$(cd "$(dirname "$0")/../.." && pwd)"

HEARTBEAT="$VAULT/_memory/heartbeat-latest.md"
CURRENT_STATE="$VAULT/_memory/current-state.md"
LOG="$VAULT/_memory/activity-log.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
TODAY=$(date '+%Y-%m-%d')

mkdir -p "$VAULT/_memory"

# current-state.md staleness
STATE_UPDATED=$(grep "^updated:" "$CURRENT_STATE" 2>/dev/null | sed 's/updated: //' | tr -d ' ')
STATE_TS=$(date -d "${STATE_UPDATED:-2000-01-01}" +%s 2>/dev/null || echo 0)
NOW_TS=$(date +%s)
STATE_AGE=$(( (NOW_TS - STATE_TS) / 86400 ))

# Count active projects
ACTIVE_PROJECTS=0
if [ -d "$VAULT/_knowledge/projects" ]; then
  ACTIVE_PROJECTS=$(grep -rl "^status: active" "$VAULT/_knowledge/projects/" 2>/dev/null | wc -l)
fi

# Count ingested sources
TOTAL_SOURCES=0
[ -d "$VAULT/_sources" ] && TOTAL_SOURCES=$(ls "$VAULT/_sources/"*.md 2>/dev/null | wc -l)

# Count compiled wiki pages
TOTAL_WIKI=0
[ -d "$VAULT/_wiki" ] && TOTAL_WIKI=$(ls "$VAULT/_wiki/"*.md 2>/dev/null | wc -l)

# Pending session flags
NEEDS_END_SESSION=""
[ -f "$VAULT/_memory/.needs-end-session" ] && NEEDS_END_SESSION="true"
[ -f "$VAULT/_memory/.compacted-without-end-session" ] && NEEDS_END_SESSION="true"

# Health score: start at 10, penalize issues
HEALTH_SCORE=10
[ "$STATE_AGE" -gt 7 ]  && HEALTH_SCORE=$((HEALTH_SCORE - 2))
[ "$STATE_AGE" -gt 14 ] && HEALTH_SCORE=$((HEALTH_SCORE - 2))
[ -n "$NEEDS_END_SESSION" ] && HEALTH_SCORE=$((HEALTH_SCORE - 1))
[ "$HEALTH_SCORE" -lt 0 ] && HEALTH_SCORE=0

cat > "$HEARTBEAT" <<EOF
---
tags: [memory, heartbeat]
updated: $TODAY
---

# Vault Heartbeat — $TIMESTAMP

**Health score:** $HEALTH_SCORE/10

## State

| Item | Value | Status |
|------|-------|--------|
| current-state.md | updated ${STATE_AGE} days ago | $([ "$STATE_AGE" -le 3 ] && echo "OK" || echo "STALE") |
| Active projects | $ACTIVE_PROJECTS | — |
| Ingested sources | $TOTAL_SOURCES | — |
| Compiled wiki pages | $TOTAL_WIKI | — |
| Pending session | $([ -n "$NEEDS_END_SESSION" ] && echo "yes" || echo "no") | $([ -z "$NEEDS_END_SESSION" ] && echo "OK" || echo "ATTENTION") |

## Alerts

$([ "$STATE_AGE" -gt 7 ]      && echo "- current-state.md is ${STATE_AGE} days stale — run /end-session")
$([ -n "$NEEDS_END_SESSION" ]  && echo "- Previous session closed without /end-session — vault may be out of sync")
$([ "$HEALTH_SCORE" -ge 9 ]    && echo "- Vault looks healthy, no action needed")

EOF

# Activity log — always append
printf '\n## [%s] heartbeat | score %d/10 — state %d days, %d projects, %d sources, %d wiki pages\n' \
  "$TIMESTAMP" "$HEALTH_SCORE" "$STATE_AGE" "$ACTIVE_PROJECTS" "$TOTAL_SOURCES" "$TOTAL_WIKI" >> "$LOG"

exit 0
