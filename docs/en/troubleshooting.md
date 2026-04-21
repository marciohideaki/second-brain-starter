# Troubleshooting

When things break, look here first.

## Install problems

### `./install.sh: Permission denied`

```bash
chmod +x install.sh
./install.sh
```

### `jq: command not found`

Install jq:

| OS | Command |
|----|---------|
| Ubuntu / Debian / WSL | `sudo apt install jq` |
| Fedora / RHEL | `sudo dnf install jq` |
| macOS | `brew install jq` |

Then re-run `./install.sh`.

### `crontab: command not found`

- **Linux/macOS:** unusual — `crontab` should be pre-installed. On Linux, try `sudo apt install cron`.
- **WSL:** `crontab` exists but the cron daemon isn't running by default. Start it:
  ```bash
  sudo service cron start
  ```
  To start it automatically on WSL boot, see [this guide](https://askubuntu.com/questions/1405393/why-cron-not-starting-in-wsl).

### `git: command not found`

Install git:

| OS | Command |
|----|---------|
| Ubuntu / Debian / WSL | `sudo apt install git` |
| Fedora / RHEL | `sudo dnf install git` |
| macOS | `brew install git` or install [Xcode Command Line Tools](https://developer.apple.com/xcode/) |

### Install finishes but I don't see any skills in Claude Code

1. Restart your Claude Code session. Skills are loaded from `~/.claude/commands/` at session start.
2. Check the symlinks were created:
   ```bash
   ls -la ~/.claude/commands/ | grep -E "(init|braindump|ingest)"
   ```
3. If nothing shows, re-run `./install.sh`.

### `~/.claude/settings.json` got messed up

`install.sh` creates a backup at `~/.claude/settings.json.bak` before touching it. Restore it:

```bash
cp ~/.claude/settings.json.bak ~/.claude/settings.json
```

Then re-run `./install.sh`.

---

## Hook problems

### "Hooks aren't firing"

1. Check `~/.claude/settings.json` contains the hook entries:
   ```bash
   grep -E "UserPromptSubmit|SessionEnd|PreCompact|Notification" ~/.claude/settings.json
   ```
2. Check the hook scripts are executable:
   ```bash
   chmod +x ~/.claude/../second-brain/_bootstrap/global/hooks/*.sh
   # (adjust the path to where you cloned the repo)
   ```
3. Check the paths in settings.json don't contain literal `{VAULT}` (they should be resolved):
   ```bash
   grep "{VAULT}" ~/.claude/settings.json
   ```
   If this matches anything, re-run `./install.sh` — the placeholder wasn't resolved.

### Hooks are slow / timing out

The default timeout is 5 seconds. If you have a slow disk or a huge vault, extend it in `~/.claude/settings.json`:

```json
"timeout": 10
```

### Prompt log is huge

`_memory/.prompt-log.txt` grows with every prompt. It's gitignored but lives on your disk. Rotate:

```bash
mv _memory/.prompt-log.txt _memory/.prompt-log-$(date +%Y%m%d).txt
```

Or disable the `UserPromptSubmit` hook entirely by removing its entry from `~/.claude/settings.json`.

---

## Cron problems

### `crontab -l` is empty after install

Re-run `./install.sh`. If that still doesn't add the entries, add them manually:

```bash
crontab -e
```

Then paste:
```
0 7 * * * bash /absolute/path/to/second-brain/_bootstrap/scripts/daily-heartbeat.sh >> /absolute/path/to/second-brain/.logs/daily-heartbeat.log 2>&1
0 9 * * 1 bash /absolute/path/to/second-brain/_bootstrap/scripts/weekly-vault-lint.sh >> /absolute/path/to/second-brain/.logs/weekly-vault-lint.log 2>&1
```

Replace `/absolute/path/to/second-brain` with your actual clone path.

### Cron jobs aren't running on WSL

WSL doesn't start cron by default. Either:

- Start it manually: `sudo service cron start`
- Enable auto-start: [WSL cron guide](https://askubuntu.com/questions/1405393/why-cron-not-starting-in-wsl).

### Cron jobs are running but producing errors

Check the logs:

```bash
cat .logs/daily-heartbeat.log
cat .logs/weekly-vault-lint.log
```

Most common error: a path changed after install. Run `./install.sh` again; it's idempotent.

---

## Skill problems

### "Skill not found: /init"

The skill symlink wasn't created, OR you didn't restart your Claude Code session after install.

```bash
# check symlink exists
ls -la ~/.claude/commands/init.md

# if missing, re-install
cd /path/to/second-brain && ./install.sh
```

Then restart Claude Code.

### "Skill ran but didn't do anything"

Read the skill's source file in `_bootstrap/global/commands/{skill}.md`. Every skill is a plain markdown prompt. If the skill requires an argument (e.g. `/focus` needs a project name), it will ask you. Provide the input and try again.

### "Skill produced wrong output"

Two options:
1. Edit the skill's markdown file to tighten the prompt. Changes take effect immediately (the symlink points to your file).
2. Run `/skill-improve <path-to-skill.md>` to run an autoresearch loop that systematically improves it.

### "`/wiki-build` crashed halfway"

The skill creates candidates in `_memory/.skill-improve/` before committing. Check that folder for partial state. You can re-run `/wiki-build` safely — it won't duplicate work.

---

## Vault state problems

### "`/lint` reports many critical defects"

Run `/lint` to see the report. Then:

- **Missing frontmatter:** add `tags`, `status`, `created` to each flagged file. Most skills write this automatically, so it's usually manual files you added.
- **Broken WikiLinks:** either the target file was deleted or the link has a typo. Fix or remove.
- **Stale active notes:** either move to `status: completed` or `status: archived`, or update.

### "current-state.md is very stale"

Run `/end-session` to refresh it. Or `/weekly-review` to get a full re-sync.

### "I lost track of what's in my vault"

Run `/daily-briefing`. Or open the folder in Obsidian and use the graph view.

---

## Uninstall

If you want to remove everything the starter added:

```bash
# 1. Remove skill shortcuts
rm ~/.claude/commands/{braindump,ingest,focus,daily-briefing,weekly-review,end-session,session-handoff,content-idea,lint,init,wiki-build,skill-improve}.md

# 2. Remove hooks from ~/.claude/settings.json
#    (restore the backup: cp ~/.claude/settings.json.bak ~/.claude/settings.json)

# 3. Remove cron jobs
crontab -e
# delete the two lines for daily-heartbeat.sh and weekly-vault-lint.sh

# 4. Remove the "## Second Brain" section from ~/.claude/CLAUDE.md
#    (open in an editor and delete that block)

# 5. (Optional) Delete the vault folder itself if you no longer want your notes
#    rm -rf ~/second-brain
```

---

## Still broken?

- Open an issue on GitHub using the bug report template.
- Include: your OS, Claude Code version (`claude --version`), and the output of the failing command.
