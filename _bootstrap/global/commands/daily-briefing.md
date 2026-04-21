---
description: Generate a daily briefing: current state, active work, decisions, priorities.
---

You are the operational second brain. Generate the daily briefing.

## Steps

### 0. Check session flags

Before generating the briefing:

- If `_memory/.needs-end-session` exists → warn at the top: "**Heads up:** the previous session closed without `/end-session`. Context may be stale. Run `/end-session` to sync."
  Do not delete the flag — only `/end-session` removes it.

- If `_memory/.compacted-without-end-session` exists → warn: "**Heads up:** context was compacted in a previous session without `/end-session` first. Some context may be lost."
  Do not delete the flag.

### 1. Read context

Read in parallel (skip silently if a file doesn't exist):
- `_memory/current-state.md` — recent context (always).
- `_knowledge/goals.md` — goals.
- `_memory/heartbeat-latest.md` — vault health.

### 2. Identify active projects

Look in `_knowledge/projects/` for folders whose main file has `status: active` in frontmatter.
Skip `_example/`.

For each active project, read the main file (`index.md` or `{project}.md`) and extract: current phase, next step, blockers.

### 3. Collect recent decisions and learnings

List files in `_decisions/` and `_learnings/` modified in the last 7 days.
For each, extract the title and a one-line summary.

### 4. Log the activity

Append to `_memory/activity-log.md`:
```
## [YYYY-MM-DD HH:MM] session-start | daily briefing generated
```

## Output

Answer in the user's language with:

### Briefing — [today]

**Current state:**
[2-3 sentences from current-state.md — what's happening now, what phase the work is in]

**Active work:**

| Project | Phase | Next step | Blocker |
|---------|-------|-----------|---------|
| [name] | [phase] | [concrete action] | [blocker or "none"] |

Include only projects marked `status: active`. Skip paused or archived.

**Recent decisions (last 7 days):**
[List with date and 1-line summary, or "No recent decisions."]

**Recent learnings (last 7 days):**
[List with title and 1-line takeaway, or "No recent learnings."]

**Today's priorities:**
[3-5 items ordered by impact, each an actionable step with a project reference]

1. [Action — Project — why it matters now]
2. [Action — Project — why it matters now]
3. [Action — Project — why it matters now]

**Vault health:**
[One line from heartbeat-latest.md, or omit if the file doesn't exist]

**Direct alert:**
[If something is critical, late, or stuck for more than a week — say it plainly. If everything is on track, omit this section.]

## Rules

- Don't read every project — only active ones.
- If `current-state.md` is more than 3 days stale, warn at the top.
- Never invent — use only what the files say.
- Be direct. No fluff, no disclaimers.
- If no projects exist yet, say so and suggest running `/init` or creating a project folder under `_knowledge/projects/`.

---

### Português (BR)

Briefing diário. Lê current-state, goals, heartbeat, identifica projetos ativos via frontmatter `status: active`, lista decisões e learnings dos últimos 7 dias, propõe 3-5 prioridades concretas. Sem inventar, direto. Avisa sobre flags de sessão pendente ou current-state desatualizado (> 3 dias).
