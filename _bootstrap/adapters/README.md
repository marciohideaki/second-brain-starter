# Adapters

Multi-agent layer. Each adapter installs the same vault skills, scripts, and knowledge structure into a specific AI agent's configuration format.

## Compatibility matrix

| Adapter | SSOT file | Custom commands | Event hooks | Cron jobs | Status |
|---------|-----------|-----------------|-------------|-----------|--------|
| **Claude Code** (default) | `CLAUDE.md` | `~/.claude/commands/` | ✅ 4 events | ✅ | stable |
| **Cursor** | `~/.cursor/rules/*.mdc` | via description-matched rules | ❌ | ✅ | **functional** |
| **Gemini CLI** | `GEMINI.md` | TOML custom commands | ⚠️ MCP only | ✅ | beta |
| **Codex CLI** | `AGENTS.md` | inline AGENTS.md | ❌ | ✅ | stub — PR welcome |
| **Antigravity** | `AGENTS.md` | MCP tools | ⚠️ MCP only | ✅ | stub — PR welcome |

## Installing an adapter

From the vault root:

```bash
./install.sh --agent=claude-code     # default
./install.sh --agent=cursor          # Cursor
./install.sh --agent=gemini-cli      # Gemini CLI
./install.sh --agent=codex           # Codex CLI
./install.sh --agent=antigravity     # Antigravity
```

You can install multiple adapters in sequence — each uses its own configuration paths and won't conflict with the others.

## What every adapter does

1. **Converts `CLAUDE.md`** into the agent's SSOT file (GEMINI.md, AGENTS.md, .cursor/rules/).
2. **Exposes the 12 skills** in whatever format the agent uses (slash commands, rules, or inline prompts).
3. **Registers cron jobs** for `daily-heartbeat.sh` and `weekly-vault-lint.sh` (same as Claude Code — OS cron is agent-agnostic).
4. **Documents limitations** specific to that agent (missing hooks, degraded continuity, etc.).

## What varies

| Capability | Why it varies |
|-----------|--------------|
| Event hooks | Only Claude Code exposes UserPromptSubmit, SessionEnd, PreCompact, Notification. Cursor has no hook system. Gemini/Antigravity offer hook-like behavior via MCP, not equivalently. Codex has no hook system. |
| Slash commands | Each agent has its own command format. Cursor uses description-matched rules. Gemini uses TOML. Claude Code uses markdown-in-folder. |
| Context injection | CLAUDE.md is auto-read by Claude Code at session start. Cursor reads `.cursorrules` / `.cursor/rules/`. Gemini reads GEMINI.md. Codex/Antigravity read AGENTS.md. |

## Extending

Add a new adapter by creating `_bootstrap/adapters/<agent-name>/install.sh` that:

1. Reads `$VAULT` from its first argument (passed by the root `install.sh`).
2. Writes whatever files the agent needs.
3. Calls `add_cron` helper from `../../scripts/install-cron.sh` (or duplicates the cron logic — both are fine for now).
4. Documents limitations clearly in `_bootstrap/adapters/<agent-name>/README.md`.

PRs with new adapters are welcome.
