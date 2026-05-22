# Gemini CLI adapter

**Status:** beta. Installs the vault's SSOT as a managed `~/.gemini/<prefix>-GEMINI.md`, points `~/.gemini/GEMINI.md` at it, and registers the cron jobs. Custom commands and MCP-based hooks are not yet converted — contributions welcome.

## What it does

1. Copies `CLAUDE.md` to `~/.gemini/<prefix>-GEMINI.md` (the Gemini CLI SSOT for this vault).
2. Registers the cron jobs (agent-agnostic — same as Claude Code).

## What is NOT converted yet

| Capability | Status | Notes |
|-----------|--------|-------|
| Slash-like custom commands | ⚠️ not converted | Gemini CLI supports custom commands via TOML in `~/.gemini/commands/`. The skills would need to be wrapped in TOML. |
| Event hooks | ❌ no direct equivalent | Gemini CLI supports MCP-based extensions, not exactly equivalent to Claude Code's 4 hooks. Some partial continuity can be achieved via MCP servers. |
| Auto-read of SSOT at session start | ✅ works | GEMINI.md is read automatically. |
| Cron jobs | ✅ works | OS-level, agent-agnostic. |

## Install

```bash
./install.sh --agent=gemini-cli
```

After install, drop the skill markdown files into your workflow by asking Gemini natural-language questions like "use the braindump approach on this text..." — the skill bodies in `_bootstrap/global/commands/` are markdown prompts, Gemini can follow them.

## How to contribute a full adapter

A complete Gemini CLI adapter would:

1. Convert each skill in `_bootstrap/global/commands/*.md` to a TOML file in `~/.gemini/commands/` with `description`, `prompt`, and argument schema.
2. Investigate Gemini CLI's MCP extension system to see which of the 4 hooks (UserPromptSubmit, SessionEnd, PreCompact, Notification) can be emulated.
3. Update this README with a full compatibility table.

If you build this, please open a PR.
