# Antigravity adapter

**Status:** stub. Installs `AGENTS.md` in the vault root and registers cron jobs. Full MCP-based integration is community-welcome.

## What the stub does

1. Generates `AGENTS.md` in the vault root from `CLAUDE.md`.
2. Registers the cron jobs (agent-agnostic).

## Why it's a stub

Antigravity (Google) uses `AGENTS.md` as the primary instruction file and exposes capabilities via MCP (Model Context Protocol) tools. The hooks model differs from Claude Code's — you register MCP servers that provide tools, not file-based event hooks.

A complete Antigravity adapter would:

1. Wrap each of the 12 skills as an MCP tool, or convert them into `.agents/commands/` (if that convention exists in your Antigravity version).
2. Expose a hook-like MCP server that observes session events and writes to `_memory/`.
3. Provide an Antigravity-specific set of tool descriptions.

If you build one, please open a PR.

## Install

```bash
./install.sh --agent=antigravity
```
