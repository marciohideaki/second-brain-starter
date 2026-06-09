# Multi-agent support

The starter is primarily designed for Claude Code, which offers the richest automation surface (4 event hooks + auto-read SSOT + native slash-commands). Other agents have adapters at different maturity levels.

## Compatibility matrix

| Capability | [Claude Code](https://docs.anthropic.com/claude-code) | [Cursor](https://cursor.com) | [Gemini CLI](https://github.com/google-gemini/gemini-cli) | [Codex CLI](https://github.com/openai/codex) | Antigravity |
|-----------|-------------|--------|------------|-----------|-------------|
| SSOT auto-read at session start | ✅ `CLAUDE.md` | ✅ `~/.cursor/rules/*.mdc` | ✅ `GEMINI.md` | ✅ `AGENTS.md` | ✅ `AGENTS.md` |
| Skills invocable as slash-commands | ✅ `/braindump` etc. | ❌ use natural language | ⚠️ manual TOML | ❌ natural language | ❌ natural language |
| `UserPromptSubmit` hook | ✅ | ❌ | ⚠️ via MCP | ❌ | ⚠️ via MCP |
| `SessionEnd` hook | ✅ | ❌ | ⚠️ via MCP | ❌ | ⚠️ via MCP |
| `PreCompact` hook | ✅ | ❌ | ❌ | ❌ | ❌ |
| `Notification` hook | ✅ | ❌ | ❌ | ❌ | ❌ |
| Cron jobs (heartbeat + lint) | ✅ | ✅ | ✅ | ✅ | ✅ |
<<<<<<< Updated upstream
| Overall status | **stable** | **functional** | **beta** | **functional** | **lightweight** |
=======
| Overall status | **stable** | **functional** | **beta** | **functional** | **stub** |
>>>>>>> Stashed changes

## How to install

Each agent has its own `--agent` flag for the installer:

```bash
./install.sh                      # default: Claude Code
./install.sh --agent=cursor       # Cursor (functional)
./install.sh --agent=gemini-cli   # Gemini CLI (beta — SSOT + cron only, commands manual)
<<<<<<< Updated upstream
./install.sh --agent=codex        # Codex CLI (AGENTS.md + Codex skills + cron)
./install.sh --agent=antigravity  # Antigravity (AGENTS.md + cron)
=======
./install.sh --agent=codex        # Codex CLI (AGENTS.md + global skills + cron)
./install.sh --agent=antigravity  # Antigravity (stub — SSOT + cron only)
./install.sh --agent=codex --target-vault /path/to/vault
./install.sh --agents=claude-code,codex --vault-prefix work
>>>>>>> Stashed changes
```

You can install multiple adapters simultaneously. Each writes to its own agent-specific location (`~/.claude/`, `~/.cursor/`, `~/.gemini/`, `AGENTS.md`), so they don't conflict. Use `--target-vault` or `SECOND_BRAIN_VAULT` when the repository source and operational vault are separate directories.

## How each agent handles skills

### Claude Code
Native slash-commands: `/braindump "my thought"`. No friction.

### Cursor
Rules with `alwaysApply: false` loaded by description match. Invoke in plain language:
```
Run the braindump skill: I keep bouncing between ideas.
```
Cursor matches the rule via its description and applies the skill's instructions.

### Gemini CLI
GEMINI.md is read at session start, but the skills are not yet converted to TOML. For now, reference them manually:
```
Follow the approach from _bootstrap/global/commands/braindump.md on this text: ...
```

### Codex CLI
<<<<<<< Updated upstream
AGENTS.md is read at session start, and each skill is installed under `~/.codex/skills/<prefix>-<name>`. Invoke by name:
```
Use $mybrain-braindump on this thought: ...
```

### Antigravity
AGENTS.md is read at session start. Invoke skills via natural language until a native MCP wrapper exists.
=======
AGENTS.md is read at session start, and each `_bootstrap/global/commands/*.md` file is installed as a global Codex skill under `~/.codex/skills`. Invoke with skill names:
```
Use $work-braindump on this thought: ...
```

### Antigravity
AGENTS.md is read at session start. Skills are described inside. Invoke via natural language.
>>>>>>> Stashed changes

## Why hooks only work in Claude Code

The 4 hooks (`UserPromptSubmit`, `SessionEnd`, `PreCompact`, `Notification`) are a Claude-Code-specific feature. They fire on events internal to the Claude Code runtime — logging prompts, flagging unsaved state, preserving pre-compaction snapshots, and pinging you when long operations finish.

- **Cursor** has no hook system.
- **Gemini CLI** has MCP-based extensions. `UserPromptSubmit`-like and `SessionEnd`-like behavior can be emulated via an MCP server, but not 1:1.
- **Codex CLI** has no hook equivalent.
- **Antigravity** exposes capabilities via MCP tools. A community-built MCP server could cover some events.

**Practical consequence:** when running in any agent besides Claude Code, **you lose automatic session continuity**. To compensate:

- Run `/end-session` (or "run the end-session skill") explicitly at the end of every work session.
- Check `_memory/heartbeat-latest.md` and `_memory/lint-latest.md` manually — they're still written by the OS cron jobs.
- Be mindful that `_memory/current-state.md` goes stale if you forget `/end-session`.

## Contributing new adapters or upgrading stubs

See [_bootstrap/adapters/README.md](../../_bootstrap/adapters/README.md) for the adapter contract. Each adapter has a per-agent README listing what's missing and how to contribute.

Community PRs most wanted:

1. **Gemini CLI: skills → TOML commands.** Convert each of the 12 `.md` files into `~/.gemini/commands/<name>.toml`.
2. **Gemini CLI: MCP hook server.** A lightweight MCP server exposing `SessionEnd`-like behavior would close the continuity gap.
3. **Antigravity: MCP tool wrappers.** Wrap each skill as an MCP tool so they show up natively in the agent's tool picker.
<<<<<<< Updated upstream
4. **Codex CLI: hook-like lifecycle support.** The adapter already installs Codex skills; continuity automation would need a future Codex hook mechanism.
=======
4. **Codex CLI: hook equivalents if they emerge.** The current adapter covers AGENTS.md, global skills, and cron; event hooks remain explicit.
>>>>>>> Stashed changes

## When should I not bother with multi-agent?

If Claude Code meets your needs, stick with it. The multi-agent support exists for people who:

- Are already committed to another agent for their day job.
- Want to try the second-brain pattern without switching IDE/CLI.
- Are building their own agent and want a reference vault structure.

Running the same vault across multiple agents is supported but creates friction — each agent has subtly different strengths. Pick one primary agent and use the others for experiments.
