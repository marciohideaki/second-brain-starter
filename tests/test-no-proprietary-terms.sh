#!/bin/bash
# Fail the build if any term that leaks the maintainer's private setup
# shows up in user-facing files.

set -e

VAULT="$(cd "$(dirname "$0")/.." && pwd)"

# Terms that must never appear in shipped files (except LICENSE copyright).
proprietary_terms="hideakisolutions|HSEOS|/opt/hideakisolutions|_cores/|core-session|promotion-backlog|article-draft|post-draft|repo-radar|consolidate-prompts|infra-snapshot|_content/series|PATTERN-MATRIX|FEATURE-CATALOG|MASTER-INDEX"

# LICENSE names the copyright holder legitimately. This very script lists the
# banned terms by nature (that's its job). Skip both when scanning.
matches=$(grep -rE "$proprietary_terms" "$VAULT" \
  --include="*.md" --include="*.sh" --include="*.json" --include="*.yml" \
  --exclude-dir=".git" \
  --exclude="test-no-proprietary-terms.sh" \
  2>/dev/null || true)

if [ -n "$matches" ]; then
  echo "PROPRIETARY TERMS DETECTED:"
  echo "$matches"
  exit 1
fi

exit 0
