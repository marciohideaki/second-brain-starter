# Codex CLI adapter

**Status:** stub. Installs `AGENTS.md` (the emerging industry standard for coding agents) in the vault root. Custom commands and hooks are not implemented — Codex CLI doesn't expose equivalent primitives.

## What the stub does

1. Generates `AGENTS.md` in the vault root from `CLAUDE.md`.
2. Registers the cron jobs (agent-agnostic).

## Why it's a stub

Codex CLI (OpenAI) reads `AGENTS.md` at session start and follows its instructions. It does **not** expose:
- Event hooks (no UserPromptSubmit / SessionEnd / PreCompact / Notification).
- A dedicated slash-command system (skills must be invoked via natural language).

Result: you keep the knowledge structure (_sources, _wiki, _learnings, _decisions) and the daily/weekly crons, but you lose session-continuity automation. You must run `/end-session` (as a prompt) explicitly at day's end.

## Install

```bash
./install.sh --agent=codex
```

## Contributing

If Codex CLI adds hook-like behavior or a custom-command system in the future, please open a PR to extend this adapter.
