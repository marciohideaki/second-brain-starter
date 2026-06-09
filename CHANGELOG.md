# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] — 2026-04-21

Initial public release.

### Added

- **Bootstrap installer** — idempotent `install.sh` that wires Claude Code with a single command: symlinks 12 skills, merges 4 hooks into `~/.claude/settings.json`, appends a "Second Brain" block to `~/.claude/CLAUDE.md`, and registers 2 cron jobs in the OS crontab.
- **12 vault skills** (`_bootstrap/global/commands/*.md`): `/init`, `/braindump`, `/ingest`, `/wiki-build`, `/focus`, `/daily-briefing`, `/weekly-review`, `/end-session`, `/session-handoff`, `/content-idea`, `/lint`, `/skill-improve`.
- **4 event hooks** (`_bootstrap/global/hooks/*.sh`): `UserPromptSubmit`, `SessionEnd`, `PreCompact`, `Notification`. Keep state alive between sessions.
- **2 cron jobs** (`_bootstrap/scripts/*.sh`): daily-heartbeat (vault health score 0-10 at 07:00), weekly-vault-lint (structural audit Monday 09:00). No LLM required — pure bash.
- **Knowledge graph structure**: `_knowledge/` (personal + per-project), `_sources/` (raw inbox), `_wiki/` (compiled cross-linked pages), `_learnings/`, `_decisions/`, `_pipeline/`, `_sessions/`, `_memory/` (current-state, activity-log, heartbeat, lint).
- **Vault templates**: `about-me.md`, `goals.md`, `references.md`, project example folder with index/modules/work-log/gotchas/decisions, plus `_example.md` across every layer.
- **Bilingual documentation** (EN + PT-BR, 14 files total): getting-started, skills-reference, hooks-and-crons, philosophy, FAQ, troubleshooting, multi-agent.
- **Multi-agent adapters** (`_bootstrap/adapters/`): Cursor (functional), Gemini CLI (beta), Codex CLI (functional), Antigravity (stub). Single installer entry point: `./install.sh --agent=<agent-name>`.
- **Autoresearch loop** (`/skill-improve`): three-phase systematic improvement pipeline for any skill — human-in-the-loop setup with binary evals, bounded autonomous mutation loop, before/after debrief with applied patch.
- **LLM Wiki pattern** (`/ingest` + `/wiki-build`): single-source-at-a-time ingestion with user approval before persistence, then compilation into cross-linked wiki pages with contradictions flagging.
- **Visual assets**: 6 diagrams (banner, flow-overview, architecture, ingestion-flow, session-continuity, skills-map) and 4 terminal screenshots (init-wizard, daily-briefing, wiki-build, end-session).
- **Test suite** (`tests/`): shell syntax validation, directory structure check, frontmatter validation, install smoke test, cursor-adapter smoke test, proprietary-term scanner. Runnable via `bash tests/run-all.sh`.
- **CI pipeline** (`.github/workflows/ci.yml`): ShellCheck on every `.sh`, plus the full test suite on push and pull request.
- **Contribution guide**: `CONTRIBUTING.md`, pull-request template, bug-report and feature-request issue templates.

[Unreleased]: https://github.com/marciohideaki/second-brain-starter/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/marciohideaki/second-brain-starter/releases/tag/v0.1.0
