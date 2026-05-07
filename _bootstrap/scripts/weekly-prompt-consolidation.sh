#!/bin/bash
# Cron: weekly-prompt-consolidation
# Suggested schedule: every Sunday at 23:00
# Registered by install.sh:
#   0 23 * * 0 bash {VAULT}/_bootstrap/scripts/weekly-prompt-consolidation.sh >> {VAULT}/.logs/weekly-prompt-consolidation.log 2>&1
#
# Checks whether enough prompts have accumulated to warrant analysis.
# If yes, creates the .consolidation-ready flag — the on-prompt-submit hook
# will surface a notice on the next prompt. The actual analysis (LLM-driven)
# happens when you invoke the prompt-pattern analysis skill of your choice.

# Auto-detect vault: script lives in _bootstrap/scripts/ — vault is 2 levels up
VAULT="$(cd "$(dirname "$0")/../.." && pwd)"

PROMPT_LOG="$VAULT/_memory/.prompt-log.txt"
FLAG="$VAULT/_memory/.consolidation-ready"
LOG="$VAULT/_memory/activity-log.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
THRESHOLD=30  # minimum prompts to make analysis worthwhile

mkdir -p "$VAULT/_memory"

# No log yet — nothing to do
if [ ! -f "$PROMPT_LOG" ]; then
  echo "[$TIMESTAMP] weekly-prompt-consolidation: no prompt log yet, skipping."
  exit 0
fi

PROMPT_COUNT=$(wc -l < "$PROMPT_LOG" | tr -d ' ')

if [ "${PROMPT_COUNT:-0}" -lt "$THRESHOLD" ]; then
  echo "[$TIMESTAMP] weekly-prompt-consolidation: $PROMPT_COUNT prompts accumulated (threshold: $THRESHOLD). Waiting for more data."
  exit 0
fi

# Generate basic statistics (no LLM) to enrich the analysis context
SLASH_COUNT=$(grep -cE '^\[.*\] /' "$PROMPT_LOG" 2>/dev/null || echo 0)
TOP_CMDS=$(grep -oE '^\[.*\] /[a-z-]+' "$PROMPT_LOG" 2>/dev/null | \
           grep -oE '/[a-z-]+' | sort | uniq -c | sort -rn | head -5 | \
           awk '{printf "  %s × %s\n", $1, $2}')
UNIQUE_CWDS=$(grep -oE 'cwd:[^]]+' "$PROMPT_LOG" 2>/dev/null | sort -u | wc -l | tr -d ' ')

# Save structural summary alongside the log for the skill to consume
STATS_FILE="$VAULT/_memory/.prompt-log-stats.txt"
cat > "$STATS_FILE" << EOF
Generated: $TIMESTAMP
Total prompts: $PROMPT_COUNT
Slash commands: $SLASH_COUNT
Distinct projects (cwd): $UNIQUE_CWDS
Top slash commands:
$TOP_CMDS
EOF

# Create flag — hook will display a notice on the next prompt
touch "$FLAG"

# Log to activity log
[ -f "$LOG" ] && \
  printf '\n## [%s] cron | weekly-prompt-consolidation — %s prompts ready for analysis\n' \
    "$TIMESTAMP" "$PROMPT_COUNT" >> "$LOG"

echo "[$TIMESTAMP] weekly-prompt-consolidation: $PROMPT_COUNT prompts accumulated. Flag created — notice will appear on next prompt."
