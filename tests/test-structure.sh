#!/bin/bash
# Validate the expected directory and file skeleton is present.

set -e

VAULT="$(cd "$(dirname "$0")/.." && pwd)"

required_dirs=(
  "_bootstrap/global/commands"
  "_bootstrap/global/hooks"
  "_bootstrap/scripts"
  "_bootstrap/project"
  "_bootstrap/adapters/cursor"
  "_bootstrap/adapters/gemini-cli"
  "_bootstrap/adapters/codex"
  "_bootstrap/adapters/antigravity"
  "_knowledge/projects/_example"
  "_memory"
  "_sources"
  "_wiki"
  "_learnings"
  "_decisions"
  "_pipeline"
  "_sessions"
  "docs/en"
  "docs/pt-br"
  "docs/assets/screenshots"
)

for d in "${required_dirs[@]}"; do
  if [ ! -d "$VAULT/$d" ]; then
    echo "MISSING directory: $d"
    exit 1
  fi
done

required_files=(
  "CLAUDE.md"
  "LICENSE"
  "README.md"
  "CHANGELOG.md"
  "CONTRIBUTING.md"
  "install.sh"
  ".gitignore"
  "_bootstrap/global/CLAUDE.md"
  "_bootstrap/global/settings.json"
  "docs/en/getting-started.md"
  "docs/en/skills-reference.md"
  "docs/en/hooks-and-crons.md"
  "docs/en/philosophy.md"
  "docs/en/faq.md"
  "docs/en/troubleshooting.md"
  "docs/en/multi-agent.md"
  "docs/pt-br/getting-started.md"
)

for f in "${required_files[@]}"; do
  if [ ! -f "$VAULT/$f" ]; then
    echo "MISSING file: $f"
    exit 1
  fi
done

exit 0
