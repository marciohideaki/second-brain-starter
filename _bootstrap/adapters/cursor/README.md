# Cursor adapter

**Status:** functional. Installs the vault as Cursor rules and cron jobs.

## What it does

1. Converts `CLAUDE.md` into `~/.cursor/rules/00-second-brain.mdc` (the vault SSOT).
2. Converts each of the 12 skills into a `~/.cursor/rules/skill-<name>.mdc` rule with `alwaysApply: false` and a description so Cursor loads the rule when the user invokes it by name.
3. Registers the same cron jobs as the Claude Code setup (they're agent-agnostic — they run in the OS, not in the agent).

## How to use after installing

Cursor doesn't have slash-commands in the Claude Code sense. To invoke a skill, ask Cursor in plain language:

```
Run the braindump skill: I keep bouncing between three project ideas.
```

or

```
Use the ingest skill on https://example.com/article.
```

Cursor matches the skill rule via its description and applies it.

## Limitations compared to Claude Code

| Capability | Claude Code | Cursor |
|-----------|-------------|--------|
| `UserPromptSubmit` hook (prompt log + state injection) | ✅ | ❌ |
| `SessionEnd` hook (auto-flag pending sync) | ✅ | ❌ |
| `PreCompact` hook (state snapshot) | ✅ | ❌ |
| `Notification` hook (toast / bell) | ✅ | ❌ |
| Slash-commands | ✅ | ❌ (use natural language) |
| SSOT auto-read at session start | ✅ (CLAUDE.md) | ✅ (`~/.cursor/rules/*.mdc`) |
| Cron jobs (daily heartbeat, weekly lint) | ✅ | ✅ |
| Skill self-improvement (`/skill-improve`) | ✅ | ⚠️ works but you invoke via natural language |

**What you lose:** automatic session-end detection and state preservation between sessions. You have to ask Cursor to "run the end-session skill" at the end of each work session explicitly — otherwise `current-state.md` goes stale.

**What you keep:** the knowledge structure, the ingestion → wiki flow, the content-idea and daily-briefing skills, and the daily/weekly cron health checks.

## Install

From the vault root:

```bash
./install.sh --agent=cursor
```

## Uninstall

```bash
rm ~/.cursor/rules/00-second-brain.mdc
rm ~/.cursor/rules/skill-*.mdc
crontab -e  # remove the daily-heartbeat and weekly-vault-lint lines
```

## Contributing

Cursor's rule system is evolving. If you find a pattern that restores any of the missing hooks (for example, via workspace-specific `.cursor/rules/*.mdc` with clever `alwaysApply` + `globs`), please open a PR.
