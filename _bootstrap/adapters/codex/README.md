# Codex CLI adapter

**Status:** functional. Installs `AGENTS.md`, converts each command in `_bootstrap/global/commands/` into a Codex skill, mirrors those skills into the target vault, and registers the same agent-agnostic cron jobs as the Claude Code installer.

## What it does

1. Generates `AGENTS.md` in the target vault if it does not already exist.
2. Installs one Codex skill per command in `~/.codex/skills/<prefix>-<name>`.
3. Mirrors those generated skills into `{target-vault}/.codex/skills/` for auditability.
4. Registers cron jobs for daily heartbeat and weekly lint.

## Source and target vaults

The adapter supports a separate source repository and target vault:

```bash
./install.sh --agent=codex --target-vault ~/my-second-brain --vault-prefix mybrain
```

Without `--target-vault`, the source repository is used as the vault for single-directory installs.

## Limitations

Codex CLI does not expose Claude Code-style event hooks, so session continuity is explicit:

- Run the generated end-session skill at the end of productive sessions.
- Check `_memory/heartbeat-latest.md` and `_memory/lint-latest.md` when returning to the vault.
- Cron jobs still run because they are OS-level, not agent-specific.

## Invocation

Codex skills are installed with the chosen prefix:

```text
Use $mybrain-braindump on this thought: ...
Use $mybrain-end-session with the current session.
```
