#!/bin/bash
# Cron: weekly-vault-lint
# Suggested schedule: every Monday at 09:00
# Registered by install.sh:
#   0 9 * * 1 bash {VAULT}/_bootstrap/scripts/weekly-vault-lint.sh >> {VAULT}/.logs/weekly-vault-lint.log 2>&1
#
# Structural lint — no LLM.
# Checks frontmatter consistency and stale notes.

# Auto-detect vault: script lives in _bootstrap/scripts/ — vault is 2 levels up
VAULT="$(cd "$(dirname "$0")/../.." && pwd)"

LINT_REPORT="$VAULT/_memory/lint-latest.md"
HEARTBEAT="$VAULT/_memory/heartbeat-latest.md"
LOG="$VAULT/_memory/activity-log.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
TODAY=$(date '+%Y-%m-%d')

mkdir -p "$VAULT/_memory"

CRITICAL=0
WARNINGS=0
REPORT_BODY=""

# --- 1. Frontmatter required in _learnings/, _decisions/, _pipeline/ ---
MISSING_FRONTMATTER=0
for dir in "$VAULT/_learnings" "$VAULT/_decisions" "$VAULT/_pipeline"; do
  [ -d "$dir" ] || continue
  for f in "$dir"/*.md; do
    [ -f "$f" ] || continue
    # Skip example templates
    [ "$(basename "$f")" = "_example.md" ] && continue
    missing_fields=""
    grep -q "^tags:" "$f"    || missing_fields="tags "
    grep -q "^status:" "$f"  || missing_fields="${missing_fields}status "
    grep -q "^created:" "$f" || missing_fields="${missing_fields}created"
    if [ -n "$missing_fields" ]; then
      REPORT_BODY+="- Frontmatter: $(basename "$dir")/$(basename "$f") — missing: ${missing_fields}\n"
      MISSING_FRONTMATTER=$((MISSING_FRONTMATTER + 1))
      CRITICAL=$((CRITICAL + 1))
    fi
  done
done

# Frontmatter in project notes
if [ -d "$VAULT/_knowledge/projects" ]; then
  for proj_dir in "$VAULT/_knowledge/projects"/*/; do
    [ "$(basename "$proj_dir")" = "_example" ] && continue
    for f in "$proj_dir"*.md; do
      [ -f "$f" ] || continue
      missing_fields=""
      grep -q "^tags:" "$f"    || missing_fields="tags "
      grep -q "^status:" "$f"  || missing_fields="${missing_fields}status "
      grep -q "^created:" "$f" || missing_fields="${missing_fields}created"
      if [ -n "$missing_fields" ]; then
        REPORT_BODY+="- Frontmatter: projects/$(basename "$proj_dir")/$(basename "$f") — missing: ${missing_fields}\n"
        MISSING_FRONTMATTER=$((MISSING_FRONTMATTER + 1))
        CRITICAL=$((CRITICAL + 1))
      fi
    done
  done
fi

# --- 2. Stale notes (status active, updated > 30 days) ---
STALE_NOTES=0
THIRTY_DAYS_AGO=$(date -d "30 days ago" '+%Y-%m-%d' 2>/dev/null || date -v-30d '+%Y-%m-%d' 2>/dev/null || echo "1970-01-01")
for dir in "$VAULT/_learnings" "$VAULT/_decisions" "$VAULT/_pipeline"; do
  [ -d "$dir" ] || continue
  for f in "$dir"/*.md; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" = "_example.md" ] && continue
    updated=$(grep "^updated:" "$f" 2>/dev/null | sed 's/updated: //' | tr -d ' ')
    status=$(grep "^status:" "$f" 2>/dev/null | sed 's/status: //' | tr -d ' ')
    if [ "$status" = "active" ] && [ -n "$updated" ] && [ "$updated" \< "$THIRTY_DAYS_AGO" ]; then
      REPORT_BODY+="- Stale: $(basename "$dir")/$(basename "$f") — last update: $updated\n"
      STALE_NOTES=$((STALE_NOTES + 1))
      WARNINGS=$((WARNINGS + 1))
    fi
  done
done

# --- 3. Wiki cross-references: broken [[links]] ---
BROKEN_LINKS=0
if [ -d "$VAULT/_wiki" ]; then
  for f in "$VAULT/_wiki/"*.md; do
    [ -f "$f" ] || continue
    # Extract [[...]] links, check each target exists in _wiki/
    while IFS= read -r target; do
      [ -z "$target" ] && continue
      if [ ! -f "$VAULT/_wiki/${target}.md" ]; then
        REPORT_BODY+="- Broken link: $(basename "$f") references [[${target}]] (not found in _wiki/)\n"
        BROKEN_LINKS=$((BROKEN_LINKS + 1))
        WARNINGS=$((WARNINGS + 1))
      fi
    done < <(grep -oE '\[\[[^]]+\]\]' "$f" | sed 's/\[\[//;s/\]\]//' | sort -u)
  done
fi

# --- 4. Write report ---
TOTAL=$((CRITICAL + WARNINGS))
SCORE=10
[ "$CRITICAL" -gt 0 ] && SCORE=$((10 - CRITICAL))
[ "$SCORE" -lt 0 ] && SCORE=0

cat > "$LINT_REPORT" <<EOF
---
tags: [memory, lint]
updated: $TODAY
---

# Vault Lint — $TIMESTAMP

**Score:** $SCORE/10 | **Critical defects:** $CRITICAL | **Warnings:** $WARNINGS

| Check | Defects | Status |
|-------|---------|--------|
| Required frontmatter | $MISSING_FRONTMATTER | $([ "$MISSING_FRONTMATTER" -eq 0 ] && echo "OK" || echo "FAIL") |
| Stale active notes | $STALE_NOTES | $([ "$STALE_NOTES" -eq 0 ] && echo "OK" || echo "ATTENTION") |
| Broken wiki links | $BROKEN_LINKS | $([ "$BROKEN_LINKS" -eq 0 ] && echo "OK" || echo "ATTENTION") |

$([ "$TOTAL" -gt 0 ] && printf '## Defects\n\n%b' "$REPORT_BODY")
$([ "$TOTAL" -eq 0 ] && echo "Vault looks healthy — no defects found.")

EOF

# Heartbeat alert if many critical defects
if [ "$CRITICAL" -gt 5 ] && [ -f "$HEARTBEAT" ]; then
  printf '\n## Lint Alert (%s)\n%d critical defects. Run /lint for details.\n' \
    "$TODAY" "$CRITICAL" >> "$HEARTBEAT"
fi

# Activity log
printf '\n## [%s] lint | %d critical, %d warnings (score %d/10)\n' \
  "$TIMESTAMP" "$CRITICAL" "$WARNINGS" "$SCORE" >> "$LOG"

exit 0
