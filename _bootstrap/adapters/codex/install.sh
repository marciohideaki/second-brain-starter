#!/bin/bash
# Codex CLI adapter.
<<<<<<< Updated upstream
# Generates AGENTS.md, converts global commands into Codex skills, and registers cron jobs.
=======
# Generates AGENTS.md, installs Codex skills, and registers cron jobs.
>>>>>>> Stashed changes

set -e

SOURCE_ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
TARGET_VAULT="${2:-${SECOND_BRAIN_VAULT:-$SOURCE_ROOT}}"
VAULT_NAME="${3:-$(basename "$TARGET_VAULT")}"
VAULT_PREFIX="${4:-second-brain}"
SOURCE_ROOT="$(cd "$SOURCE_ROOT" && pwd)"
TARGET_VAULT="$(mkdir -p "$TARGET_VAULT" && cd "$TARGET_VAULT" && pwd)"
BOOTSTRAP="$SOURCE_ROOT/_bootstrap"
ADAPTER="$BOOTSTRAP/adapters/codex"
CODEX_DIR="$HOME/.codex"
<<<<<<< Updated upstream
GLOBAL_SKILLS_DIR="$CODEX_DIR/skills"
TARGET_CODEX_DIR="$TARGET_VAULT/.codex"
TARGET_SKILLS_DIR="$TARGET_CODEX_DIR/skills"
TARGET_SCRIPTS_DIR="$TARGET_VAULT/_bootstrap/scripts"
=======
SKILLS_DIR="$CODEX_DIR/skills"
TARGET_RUNTIME="$TARGET_VAULT/.claude"
TARGET_SCRIPTS_DIR="$TARGET_RUNTIME/scripts"
>>>>>>> Stashed changes

echo "=== second-brain-starter — Codex CLI adapter ==="
echo "Source   : $SOURCE_ROOT"
echo "Vault    : $TARGET_VAULT"
echo "Name     : $VAULT_NAME"
echo "Prefix   : $VAULT_PREFIX"
echo "Codex dir: $CODEX_DIR"
echo ""

<<<<<<< Updated upstream
mkdir -p "$GLOBAL_SKILLS_DIR" "$TARGET_SKILLS_DIR" "$TARGET_VAULT/.logs"

yaml_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
=======
mkdir -p "$SKILLS_DIR" "$TARGET_VAULT/.logs" "$TARGET_SCRIPTS_DIR"

yaml_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

sanitize_description() {
  printf '%s' "$1" | tr '<>' ' ' | sed 's/[[:space:]][[:space:]]*/ /g; s/^ //; s/ $//' | cut -c 1-1000
}

human_title() {
  printf '%s' "$1" | sed 's/-/ /g; s/\b\(.\)/\u\1/g'
}

command_description() {
  local file="$1"
  local desc

  desc=$(awk '
    BEGIN { in_fm=0 }
    NR == 1 && $0 == "---" { in_fm=1; next }
    in_fm && $0 == "---" { exit }
    in_fm && /^description:[[:space:]]*/ {
      sub(/^description:[[:space:]]*/, "")
      gsub(/^"|"$/, "")
      gsub(/^'\''|'\''$/, "")
      print
      exit
    }
  ' "$file")

  if [ -n "$desc" ]; then
    printf '%s' "$desc"
    return
  fi

  awk '
    NF && $0 !~ /^---$/ && $0 !~ /^#/ && $0 !~ /^>/ {
      line=$0
      gsub(/^Você é /, "Use when ")
      gsub(/^You are /, "Use when ")
      print line
      exit
    }
  ' "$file"
}

strip_frontmatter() {
  local file="$1"
  awk '
    NR == 1 && $0 == "---" { in_fm=1; next }
    in_fm && $0 == "---" { in_fm=0; next }
    !in_fm { print }
  ' "$file"
}

install_skill() {
  local src="$1"
  local name
  local base_name
  local dest
  local desc
  local title

  base_name="$(basename "$src" .md)"
  name="${VAULT_PREFIX}-${base_name}"
  dest="$SKILLS_DIR/$name"
  desc="$(command_description "$src")"
  [ -n "$desc" ] || desc="Use when running the second-brain $base_name workflow from the vault."
  desc="$(sanitize_description "$desc")"
  title="$(human_title "$name")"

  mkdir -p "$dest/agents"

  {
    printf '%s\n' '---'
    printf 'name: %s\n' "$name"
    printf 'description: "%s"\n' "$(yaml_escape "$desc")"
    printf '%s\n' 'license: Apache-2.0'
    printf '%s\n' 'metadata:'
    printf '%s\n' '  owner: second-brain-starter'
    printf '  vault: "%s"\n' "$(yaml_escape "$TARGET_VAULT")"
    printf '  vault_name: "%s"\n' "$(yaml_escape "$VAULT_NAME")"
    printf '  vault_prefix: "%s"\n' "$(yaml_escape "$VAULT_PREFIX")"
    printf '  source_root: "%s"\n' "$(yaml_escape "$SOURCE_ROOT")"
    printf '  source_command: "%s"\n' "$(yaml_escape "${src#$SOURCE_ROOT/}")"
    printf '%s\n' '---'
    printf '\n# %s\n\n' "$title"
    printf 'This is the Codex port of `%s` from `%s`.\n\n' "$base_name" "${src#$SOURCE_ROOT/}"
    printf 'When the original command mentions `$ARGUMENTS`, treat it as the current user input or the text following the skill invocation.\n\n'
    printf 'Use `%s` as the vault root for all relative paths unless the user provides another path.\n\n' "$TARGET_VAULT"
    strip_frontmatter "$src"
  } > "$dest/SKILL.md"

  {
    printf '%s\n' 'interface:'
    printf '  display_name: "%s"\n' "$(yaml_escape "$title")"
    printf '  short_description: "%s"\n' "$(yaml_escape "$desc" | cut -c 1-64)"
    printf '  default_prompt: "Use $%s with the current task input."\n' "$name"
  } > "$dest/agents/openai.yaml"

  echo "  ✓ $name"
}

# ---------------------------------------------------------------------------
# STEP 1 — Generate AGENTS.md
# ---------------------------------------------------------------------------
echo "[1/3] SSOT: AGENTS.md..."

DEST="$TARGET_VAULT/AGENTS.md"

sed "s|{VAULT}|$TARGET_VAULT|g" "$ADAPTER/templates/agents.md" > "$DEST"
printf '\n' >> "$DEST"
if [ -f "$TARGET_VAULT/CLAUDE.md" ]; then
  sed "s|{VAULT}|$TARGET_VAULT|g" "$TARGET_VAULT/CLAUDE.md" >> "$DEST"
else
  sed "s|{VAULT}|$TARGET_VAULT|g" "$SOURCE_ROOT/CLAUDE.md" >> "$DEST"
fi

echo "  ✓ $DEST"

# ---------------------------------------------------------------------------
# STEP 2 — Codex skills
# ---------------------------------------------------------------------------
echo ""
echo "[2/3] Codex skills..."

for managed in "$SKILLS_DIR"/*; do
  [ -d "$managed" ] || continue
  skill_file="$managed/SKILL.md"
  [ -f "$skill_file" ] || continue
  if grep -q "vault: \"$TARGET_VAULT\"" "$skill_file" && grep -q "source_root: \"$SOURCE_ROOT\"" "$skill_file"; then
    rm -rf "$managed"
  fi
done

count=0
for src in "$BOOTSTRAP/global/commands/"*.md; do
  [ -f "$src" ] || continue
  install_skill "$src"
  count=$((count + 1))
done

echo "  Installed: $count skills in $SKILLS_DIR"

# ---------------------------------------------------------------------------
# STEP 3 — Cron jobs
# ---------------------------------------------------------------------------
echo ""
echo "[3/3] Cron jobs..."

for src in "$BOOTSTRAP/scripts/"*.sh "$BOOTSTRAP/global/hooks/"*.sh; do
  [ -f "$src" ] || continue
  dest="$TARGET_SCRIPTS_DIR/$(basename "$src")"
  cp "$src" "$dest"
  sed -i "s|^VAULT=.*|VAULT=\"$TARGET_VAULT\"|" "$dest"
  chmod +x "$dest"
done

if [ "${SECOND_BRAIN_SKIP_CRON:-}" = "1" ]; then
  echo "  - skipped (SECOND_BRAIN_SKIP_CRON=1)"
  ADDED=0
else

CRON_CURRENT=$(crontab -l 2>/dev/null || echo "")
CRON_UPDATED="$CRON_CURRENT"
ADDED=0

add_cron() {
  local schedule="$1"
  local script="$2"
  local label="$3"
  local logfile="$TARGET_VAULT/.logs/${script%.sh}.log"
  local script_path="$TARGET_SCRIPTS_DIR/$script"
  local line="$schedule bash $script_path >> $logfile 2>&1"
  if echo "$CRON_CURRENT" | grep -q "$script_path"; then
    echo "  - $label (already present)"
  else
    CRON_UPDATED="${CRON_UPDATED}"$'\n'"$line"
    ADDED=$((ADDED + 1))
    echo "  ✓ $label"
  fi
>>>>>>> Stashed changes
}

sanitize_description() {
  printf '%s' "$1" | tr '<>' ' ' | sed 's/[[:space:]][[:space:]]*/ /g; s/^ //; s/ $//' | cut -c 1-1000
}

human_title() {
  printf '%s' "$1" | sed 's/-/ /g; s/\b\(.\)/\u\1/g'
}

command_description() {
  local file="$1"
  local desc

  desc=$(awk '
    BEGIN { in_fm=0 }
    NR == 1 && $0 == "---" { in_fm=1; next }
    in_fm && $0 == "---" { exit }
    in_fm && /^description:[[:space:]]*/ {
      sub(/^description:[[:space:]]*/, "")
      gsub(/^"|"$/, "")
      gsub(/^'\''|'\''$/, "")
      print
      exit
    }
  ' "$file")

  if [ -n "$desc" ]; then
    printf '%s' "$desc"
    return
  fi

  awk '
    NF && $0 !~ /^---$/ && $0 !~ /^#/ && $0 !~ /^>/ {
      line=$0
      gsub(/^You are /, "Use when ")
      gsub(/^Você é /, "Use when ")
      print line
      exit
    }
  ' "$file"
}

strip_frontmatter() {
  local file="$1"
  awk '
    NR == 1 && $0 == "---" { in_fm=1; next }
    in_fm && $0 == "---" { in_fm=0; next }
    !in_fm { print }
  ' "$file"
}

install_skill() {
  local src="$1"
  local root="$2"
  local base_name
  local name
  local dest
  local desc
  local title

  base_name="$(basename "$src" .md)"
  name="${VAULT_PREFIX}-${base_name}"
  dest="$root/$name"
  desc="$(command_description "$src")"
  [ -n "$desc" ] || desc="Use when running the second-brain $base_name workflow from the vault."
  desc="$(sanitize_description "$desc")"
  title="$(human_title "$name")"

  mkdir -p "$dest/agents"

  {
    printf '%s\n' '---'
    printf 'name: %s\n' "$name"
    printf 'description: "%s"\n' "$(yaml_escape "$desc")"
    printf '%s\n' 'license: MIT'
    printf '%s\n' 'metadata:'
    printf '%s\n' '  owner: second-brain-starter'
    printf '  vault: "%s"\n' "$(yaml_escape "$TARGET_VAULT")"
    printf '  vault_name: "%s"\n' "$(yaml_escape "$VAULT_NAME")"
    printf '  vault_prefix: "%s"\n' "$(yaml_escape "$VAULT_PREFIX")"
    printf '  source_root: "%s"\n' "$(yaml_escape "$SOURCE_ROOT")"
    printf '  source_command: "%s"\n' "$(yaml_escape "${src#$SOURCE_ROOT/}")"
    printf '%s\n' '---'
    printf '\n# %s\n\n' "$title"
    printf 'This is the Codex port of `%s` from `%s`.\n\n' "$base_name" "${src#$SOURCE_ROOT/}"
    printf 'When the original command mentions `$ARGUMENTS`, treat it as the current user input or the text following the skill invocation.\n\n'
    printf 'Use `%s` as the vault root for all relative paths unless the user provides another path.\n\n' "$TARGET_VAULT"
    strip_frontmatter "$src"
  } > "$dest/SKILL.md"

  {
    printf '%s\n' 'interface:'
    printf '  display_name: "%s"\n' "$(yaml_escape "$title")"
    printf '  short_description: "%s"\n' "$(yaml_escape "$desc" | cut -c 1-64)"
    printf '  default_prompt: "Use $%s with the current task input."\n' "$name"
  } > "$dest/agents/openai.yaml"
}

cleanup_managed_skills() {
  local root="$1"
  local managed
  local skill_file

  [ -d "$root" ] || return 0

  for managed in "$root"/*; do
    [ -d "$managed" ] || continue
    skill_file="$managed/SKILL.md"
    [ -f "$skill_file" ] || continue
    if grep -q "owner: second-brain-starter" "$skill_file" && grep -q "vault: \"$TARGET_VAULT\"" "$skill_file"; then
      rm -rf "$managed"
    fi
  done
}

echo "[1/3] SSOT: AGENTS.md..."

DEST="$TARGET_VAULT/AGENTS.md"

if [ -f "$DEST" ]; then
  echo "  - $DEST already exists (kept)"
else
  sed "s|{VAULT}|$TARGET_VAULT|g" "$ADAPTER/templates/agents.md" > "$DEST"
  printf '\n\n<!-- Vault: %s -->\n\n' "$TARGET_VAULT" >> "$DEST"
  if [ -f "$TARGET_VAULT/CLAUDE.md" ]; then
    sed "s|{VAULT}|$TARGET_VAULT|g" "$TARGET_VAULT/CLAUDE.md" >> "$DEST"
  else
    sed "s|{VAULT}|$TARGET_VAULT|g" "$SOURCE_ROOT/CLAUDE.md" >> "$DEST"
  fi
  echo "  ✓ $DEST"
fi

fi

echo ""
<<<<<<< Updated upstream
echo "[2/3] Codex skills..."

cleanup_managed_skills "$GLOBAL_SKILLS_DIR"
cleanup_managed_skills "$TARGET_SKILLS_DIR"

count=0
for src in "$BOOTSTRAP/global/commands/"*.md; do
  [ -f "$src" ] || continue
  install_skill "$src" "$GLOBAL_SKILLS_DIR"
  install_skill "$src" "$TARGET_SKILLS_DIR"
  echo "  ✓ ${VAULT_PREFIX}-$(basename "$src" .md)"
  count=$((count + 1))
done

echo "  Installed: $count skills in $GLOBAL_SKILLS_DIR"
echo "  Mirrored : $count skills in $TARGET_SKILLS_DIR"

echo ""
echo "[3/3] Cron jobs..."

if [ "${SECOND_BRAIN_SKIP_CRON:-}" = "1" ]; then
  echo "  - skipped (SECOND_BRAIN_SKIP_CRON=1)"
  ADDED=0
else
  CRON_CURRENT=$(crontab -l 2>/dev/null || echo "")
  CRON_UPDATED="$CRON_CURRENT"
  ADDED=0

  add_cron() {
    local schedule="$1"
    local script="$2"
    local label="$3"
    local logfile="$TARGET_VAULT/.logs/${script%.sh}.log"
    local script_path="$TARGET_SCRIPTS_DIR/$script"
    local line="$schedule bash $script_path >> $logfile 2>&1"
    if echo "$CRON_CURRENT" | grep -q "$script_path"; then
      echo "  - $label (already present)"
    else
      CRON_UPDATED="${CRON_UPDATED}"$'\n'"$line"
      ADDED=$((ADDED + 1))
      echo "  ✓ $label"
    fi
  }

  add_cron "0 7 * * *" "daily-heartbeat.sh"  "daily-heartbeat (every day 07:00)"
  add_cron "0 9 * * 1" "weekly-vault-lint.sh" "weekly-vault-lint (Monday 09:00)"

  if [ "$ADDED" -gt 0 ]; then
    printf '%s\n' "$CRON_UPDATED" | crontab -
  fi
fi

echo ""
echo "=== Codex CLI adapter installed ==="
echo ""
echo "Installed:"
echo "  - $DEST  (Codex reads AGENTS.md at session start)"
echo "  - $count Codex skills in $GLOBAL_SKILLS_DIR"
echo "  - $count Codex skills mirrored in $TARGET_SKILLS_DIR"
echo "  - $ADDED cron job(s) new"
=======
echo "=== Codex CLI adapter installed ==="
echo ""
echo "Installed:"
echo "  - $DEST  (Codex auto-reads AGENTS.md at session start)"
echo "  - $count Codex skills in $SKILLS_DIR"
echo "  - 2 cron jobs"
>>>>>>> Stashed changes
echo ""
echo "Limitations:"
echo "  - No event hooks (Codex CLI has no equivalent system)."
echo "  - No slash commands. Invoke skills by name:"
<<<<<<< Updated upstream
echo "      \"Use \$${VAULT_PREFIX}-braindump on this thought: ...\""
=======
echo "      \"Use \$$VAULT_PREFIX-braindump on this thought: ...\""
>>>>>>> Stashed changes
echo ""
echo "More: $ADAPTER/README.md"
