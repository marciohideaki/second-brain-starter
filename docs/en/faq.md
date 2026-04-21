# FAQ

Common questions, practical answers.

## Getting started

### "Do I need to be a developer to use this?"

No. You need to:
1. Copy-paste 3 commands into a terminal during install (15 minutes, one time).
2. Type slash-commands into a Claude Code chat after that.

No coding, no scripting, no config files to edit. If you've ever used ChatGPT, you can use this.

### "Do I need to pay for Claude?"

Yes. Claude Code needs an Anthropic account. Two options:
- **Pay-as-you-go API credits** — you pay per token used, starting around $5/month for light usage.
- **Claude Pro or Max subscription** — includes Claude Code usage. See [claude.com/pricing](https://claude.com/pricing).

The starter itself is free and open source (MIT).

### "How long does the install take?"

- If you already have Claude Code and `jq` installed: 2 minutes.
- If you're starting from zero (need Node.js + Claude Code + `jq`): 15-30 minutes.

### "Can I try it without installing anything?"

No, not really. The whole point is that it writes to your disk. You can read [docs/en/philosophy.md](philosophy.md) to decide if the model works for you first.

---

## Usage

### "Where are my notes stored?"

In the folder where you cloned this repo. By default, files are organized into:

- `_sources/` — things you've ingested (articles, PDFs, transcripts).
- `_wiki/` — compiled wiki pages (cross-linked knowledge).
- `_learnings/` — insights you want to remember across contexts.
- `_decisions/` — decisions you made, with reasoning.
- `_knowledge/` — personal stuff (about-me, goals, projects).
- `_memory/` — vault state and logs.
- `_sessions/` — raw braindumps.
- `_pipeline/` — active tasks and ideas.

Every file is plain markdown. Open them in any editor.

### "How does `/ingest` know what to save?"

It shows you a summary + key takeaways + connections first, then asks for approval. You can reject, edit, or accept. Nothing is saved without your green light.

### "What if I ingest the same article twice?"

The skill checks for existing files with the same slug and asks whether to update or create a dated duplicate.

### "Does `/wiki-build` overwrite my existing wiki pages?"

No. It proposes changes (new pages or updates) and asks before writing. Existing content is merged, never silently overwritten. Use `--rebuild` only when you want a full rewrite (and it asks to confirm).

### "What's the difference between `_sources/`, `_wiki/`, and `_learnings/`?"

- `_sources/` — the **raw input**, one file per thing you ingested. Think: "I read this article".
- `_wiki/` — the **compiled output**, one file per concept or entity. Think: "Everything I know about X".
- `_learnings/` — **actionable insights**, one file per "aha moment" you want to carry between contexts. Think: "The thing that changed how I work".

### "How do I search my vault?"

Three options:
1. Ask Claude: `What do I know about X?` — it will read `_wiki/` and tell you.
2. Use `grep` / `ripgrep` from the terminal: `rg "search term" ~/second-brain`.
3. Open the folder in Obsidian — you get a full-text search UI + graph view for free.

### "Can I use this with Obsidian?"

Yes. Point Obsidian at your vault folder. Obsidian will render the markdown, visualize WikiLinks as a graph, and give you search. The starter doesn't use any Obsidian-specific feature, so it's 100% portable.

---

## Automation

### "What runs automatically?"

- **4 hooks** fire inside Claude Code when you submit a prompt, end a session, before context compaction, or when a long operation finishes. They log and warn — never modify content on their own.
- **2 cron jobs** run outside Claude Code: one daily at 07:00 (health check), one weekly on Monday at 09:00 (lint). Both produce a markdown report in `_memory/`.

Full details in [hooks-and-crons.md](hooks-and-crons.md).

### "Can I disable the automation?"

Yes, all of it. Every hook and every cron can be removed without breaking the skills. See the "Disabling pieces" section in [hooks-and-crons.md](hooks-and-crons.md).

### "The cron jobs are waking my machine up at 07:00"

They're tiny shell scripts (no LLM, no network). If they bother you, change the time via `crontab -e` or remove them.

---

## Privacy and data

### "Is my content sent to Anthropic?"

When you run a skill that reads vault files, those files are sent to Anthropic's API — same as any Claude Code session. When no skill is running and no chat is active, nothing is sent.

The cron jobs run locally and never call the API.

### "Can I keep some files out of the AI's reach?"

Yes. Put them outside the vault, or add them to `.claude/settings.json` permissions (see Claude Code docs). Or use a pattern like `_private/` and never reference it in prompts.

### "Are my prompts logged somewhere?"

Yes, to `_memory/.prompt-log.txt` (local only, gitignored). It's useful for analyzing your own usage patterns over time. You can delete it anytime or disable the `UserPromptSubmit` hook to stop logging.

---

## Platform

### "Does this work on Windows?"

Only through [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install). Native Windows is not supported because the hooks are bash scripts and the cron jobs use Unix `crontab`.

WSL2 is free, pre-installed on Windows 11, and takes 10 minutes to set up.

### "Does this work on macOS?"

Yes, natively. Tested on Apple Silicon and Intel.

### "Does this work on ChromeOS?"

Yes, inside the Linux container. Enable it via Settings → Developers → Linux development environment.

### "What about iOS / Android?"

No. This is a desktop / laptop tool. You can read your vault on mobile through Obsidian, Dropbox, etc., but the skills need a terminal.

---

## Extending

### "Can I add my own skills?"

Yes. Drop a `.md` file into `_bootstrap/global/commands/` and re-run `./install.sh`. The symlink is created automatically and the skill becomes `/my-new-skill` in Claude Code.

### "Can I customize the hooks?"

Yes. Edit `_bootstrap/global/hooks/*.sh`. The vault path is auto-detected, so your changes won't break the install.

### "Can I fork this and make it my own?"

Please do. It's MIT licensed. Attribution appreciated but not required.

### "How does `/skill-improve` work?"

It runs a [Karpathy-style autoresearch loop](https://aimaker.substack.com/p/how-i-built-skill-improves-all-skills-karpathy-autoresearch-loop) on a target skill:
1. You generate test cases + a rubric together.
2. The skill converts weak rubric dimensions into binary yes/no checks.
3. An agent mutates the skill, tests it, keeps improvements, drops regressions — bounded by a max iteration count (default: 10).
4. You approve the final diff before it touches the live skill.

Details in [docs/en/skills-reference.md#skill-improve](skills-reference.md).

---

## Still stuck?

- Check [troubleshooting.md](troubleshooting.md) for common errors.
- Open an issue on GitHub using the bug report template.
- Read the skill's source file in `_bootstrap/global/commands/{skill}.md` — every skill is a plain markdown prompt you can read and adjust.
