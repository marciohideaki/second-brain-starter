#!/bin/bash
# Hook: PostToolUse — lightweight frontmatter validator for curated vault dirs.
#
# Validates that .md files written by Write/Edit/MultiEdit into curated vault
# dirs have minimal frontmatter (tags + status). Pure bash + jq, no LLM, no
# Python. Designed to surface frontmatter omissions BEFORE they accumulate.
#
# Modes via env:
#   LINT_STRICT=0 -> warnings on stderr, exit 0 (default; non-blocking)
#   LINT_STRICT=1 -> exit 2 if any error; tool call is rejected
#
# Curated dirs (validated):
#   _knowledge/projects/*/   _decisions/   _learnings/   _pipeline/
#   _sources/                _wiki/
#
# Files starting with `_` (e.g., _example.md) are skipped — treated as templates.
#
# Registered in ~/.claude/settings.json by install.sh:
#   "PostToolUse": [{ "matcher": "Write|Edit|MultiEdit", "hooks": [{ "type": "command",
#     "command": "bash {VAULT}/_bootstrap/global/hooks/on-post-tool-use.sh", "timeout": 5 }] }]

# CRITICAL: stdin can be read only once
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // .tool // empty' 2>/dev/null || echo "")
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || echo "")

# Only act on writes to .md files
case "$TOOL_NAME" in
  Write|Edit|MultiEdit) ;;
  *) exit 0 ;;
esac
[ -z "$FILE_PATH" ] && exit 0
case "$FILE_PATH" in
  *.md) ;;
  *) exit 0 ;;
esac
[ ! -f "$FILE_PATH" ] && exit 0

# Auto-detect vault: hook lives in _bootstrap/global/hooks/ — vault is 3 levels up
VAULT="$(cd "$(dirname "$0")/../../.." && pwd)"

# Resolve relative to vault
case "$FILE_PATH" in
  /*) ABS="$FILE_PATH" ;;
  *)  ABS="$(realpath "$FILE_PATH" 2>/dev/null)" ;;
esac
case "$ABS" in
  "$VAULT"/*) REL="${ABS#$VAULT/}" ;;
  *) exit 0 ;;
esac

# Skip files starting with `_` (templates) — e.g. _example.md, _template.md
BASENAME=$(basename "$REL")
case "$BASENAME" in
  _*) exit 0 ;;
esac

# Detect curated dir
CATEGORY=""
case "$REL" in
  _knowledge/projects/*/*) CATEGORY="project" ;;
  _decisions/*)             CATEGORY="decision" ;;
  _learnings/*)             CATEGORY="learning" ;;
  _pipeline/*)              CATEGORY="pipeline" ;;
  _sources/*)               CATEGORY="source" ;;
  _wiki/*)                  CATEGORY="wiki" ;;
  *) exit 0 ;;
esac

# Check 1: frontmatter present (file starts with ---)
FIRST_LINE=$(head -n 1 "$ABS" 2>/dev/null)
if [ "$FIRST_LINE" != "---" ]; then
  echo "[vault-lint] $REL ($CATEGORY, via $TOOL_NAME)" >&2
  echo "  ERROR: frontmatter missing or malformed (first line is not '---')" >&2
  if [ "${LINT_STRICT:-0}" = "1" ]; then
    exit 2
  fi
  exit 0
fi

# Extract frontmatter block (between first --- and second ---)
FRONTMATTER=$(awk '
  NR==1 && /^---$/ { in_fm=1; next }
  in_fm && /^---$/ { exit }
  in_fm { print }
' "$ABS")

# Check 2 & 3: tags and status fields present
WARNINGS=()
if ! echo "$FRONTMATTER" | grep -qE '^[[:space:]]*tags[[:space:]]*:'; then
  WARNINGS+=("frontmatter missing 'tags:' field")
fi
if ! echo "$FRONTMATTER" | grep -qE '^[[:space:]]*status[[:space:]]*:'; then
  WARNINGS+=("frontmatter missing 'status:' field")
fi

if [ ${#WARNINGS[@]} -eq 0 ]; then
  exit 0
fi

echo "[vault-lint] $REL ($CATEGORY, via $TOOL_NAME)" >&2
for w in "${WARNINGS[@]}"; do
  echo "  warn:  $w" >&2
done

if [ "${LINT_STRICT:-0}" = "1" ]; then
  exit 2
fi
exit 0
