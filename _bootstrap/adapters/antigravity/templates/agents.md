# AGENTS.md — Second Brain

> Generated from `CLAUDE.md` by agent adapters.
> Agents that read `AGENTS.md` should treat this as the neutral bridge to the
> operational vault. Agent-specific integrations are installed separately in
> their own runtimes.

## Operational Vault

- Active operational vault: `{VAULT}`.
- If a workflow mentions `$ARGUMENTS`, treat it as the current user input or
  the text following the skill/command invocation.
- Agents without Claude Code-equivalent hooks must run session workflows
  explicitly, especially `end-session`.
