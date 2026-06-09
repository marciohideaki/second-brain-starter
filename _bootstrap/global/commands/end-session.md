---
description: Close a session: consolidate work, update vault state, decisions, learnings.
---

You are the session closer. Consolidate what was done, detect the context, and sync with the vault.

## Arguments

`$ARGUMENTS` may contain the project name (e.g. `/end-session my-project`).
If empty, detect the project from the current conversation.

## Steps

### 1. Detect context

a) If `$ARGUMENTS` has a project name, use it.
b) If empty, look at the conversation: which project was discussed? Which codebase was touched?
c) If no project can be identified: run the generic flow without project-specific updates.

### 2. Classify the session

**Type:** pick the dominant type. If the session produced 2+ distinct types (for example, refactor + feature), record one work-log row per type with separate descriptions. Do not collapse distinct work into one generic entry.

| Type | When to use |
|------|-------------|
| `feature` | New functionality implemented (endpoint, module, service) |
| `fix` | Bug fix, behavior patch, hotfix |
| `task` | Setup, scaffolding, technical documentation |
| `chore` | Refactor, cleanup, dependency bump, CI tweak |
| `spike` | Investigation, POC, technical exploration without final implementation |
| `content` | Content creation, writing, publishing, editorial work |
| `review` | Planning, review, strategic conversation |
| `session` | Generic work with no specific type |

**What was done:** concrete actions (files touched, code written, decisions made).
**Gotchas discovered:** bugs, non-obvious behavior, traps found.
**Decisions taken:** architectural, strategic, design-level.
**Open items:** what was left half-done.
**Blockers identified:** anything described as blocked, a blocker, unhealthy, unresolved external dependency, or waiting. These must propagate to `state.md`.
**PRs opened/closed in this session:** list `#NNN — title — [open/merged/closed]`; open PRs must propagate to `state.md`.
**Active feature branch at close:** record it if present; it must propagate to `state.md`.

### 3. Check project registration

If a project was identified in step 1, check if `_knowledge/projects/{project}/` exists.

**If not**, offer to create the minimal structure:
```
_knowledge/projects/{project}/
  index.md     (name, stack, phase, next step)
  work-log.md  (append-only session log)
  gotchas.md   (traps found)
  decisions.md (project-scoped ADRs)
```

Ask the user: "Create this scaffold for {project}? (y/n)"

### 4. Append to work-log

If project folder exists, check `_knowledge/projects/{project}/work-log.md` before appending. If a same-day row with the same type already exists, update that row instead of adding a duplicate.

Append or update:

```
| {YYYY-MM-DD} | {type} | {concise 1-line description} | {status: done / in-progress} |
```

If the session produced 2+ distinct types, record one row per type.

### 5. Update project-level notes

Based on session content:

**Gotchas** → append to `_knowledge/projects/{project}/gotchas.md`:
```
### {Short title}
**Problem:** what breaks if you don't know this
**Solution / context:** how it actually works
```

**Architectural decisions** → append to `_knowledge/projects/{project}/decisions.md`:
```
### {YYYY-MM-DD} — {Decision title}
**Context:** why this decision was needed
**Decision:** what was chosen
**Consequences:** trade-offs and what changed
**Reversibility:** easy / hard / irreversible
```

**Update `roadmap.md` — always** when the session produced code, PRs, decisions, or blockers. Read the current file first, preserve untouched history/planning sections, and update only current status, PRs opened/closed in this session, active blockers, and concrete next steps. Exception: a pure conversational `session` with no code or decision may skip this if the file exists and there is nothing new to record.

### 6. Update project `state.md` and global rollup

#### 6a. Update `_knowledge/projects/{project}/state.md`

Read the current file first if it exists. Preserve fields not touched by this session. Update only fields relevant to the session: Phase, Next step, Blocker, PRs, Active branch. If the file does not exist, create it with this template:

```markdown
---
updated: {today}
---
# State — {project}

**Phase:** {current phase in 1 sentence}
**Next step:** {concrete next action}
**Blocker:** {blockers from step 2 — omit if none}
**PRs:** {open PRs — omit if none}
**Active branch:** {active feature branch — omit if none}
```

Keep it low-noise. Maximum 7 content lines.

#### 6b. Update `_memory/current-state.md`

Update the global `_memory/current-state.md` with a 3-5 line rollup:

```markdown
## Last Update: {today} ({type} — {project})

### Active Projects
| Project | Phase | Next Step |
|---------|-------|-----------|
| {project} | {short phase} | {1-line next step} |
| (keep other projects, update only what changed) |

### Decisions Made
{Cross-project decisions this session — or "No strategic decisions."}

### Open Questions
{Pending questions or decisions}

### Next Steps
- {concrete action 1}
- {concrete action 2}
```

### 7. Create cross-cutting notes if applicable

**Cross-cutting decision** qualifies if it:
- Standardizes something that will be replicated in another project.
- Solves a recurring problem documented in the second brain.
- Changes how agents, skills, or workflows operate.

Does not qualify: a single-story implementation choice, a library choice specific to one project, or a one-off bug fix.

If it qualifies, create `_decisions/{YYYY-MM-DD}-{kebab-description}.md` with frontmatter + context + decision + alternatives + consequences.

**Insight worth beyond this session**:
Create or update `_learnings/{kebab-description}.md`.

Don't create these for single-project debug work.

### 8. Check for un-ingested sources

Scan the conversation for URLs or external references that weren't ingested into `_sources/`.

If candidates exist, list them and suggest:
> "Found {N} un-ingested source(s) in this session. Run `/ingest {url}` for each, or reply 'ingest all' for me to process them now."

If none, omit this section silently.

### 9. Log and clear flags

Append to `_memory/activity-log.md`:
```
## [YYYY-MM-DD] session-end | {project} — {type}: {1-line description}
```

Include HH:MM only if the user or system explicitly provided a time in the conversation. Do not invent it.

Remove the pending-session flags:
```
rm -f _memory/.needs-end-session _memory/.compacted-without-end-session
```

## Output

Answer in the user's language with:

### Session closed — {today}

**Project:** {name} | **Type:** {type(s)}

**What we did:**
{concise list}

**Saved to the vault:**
- work-log: `{type} — {description}` ({N} rows)
- gotchas: {N new} | decisions: {N new} | learnings: {N new}
- state.md: updated (phase: {summary} | blocker: {yes — description / no})
- roadmap.md: updated / not updated (pure conversational session)
- current-state.md: updated
- PRs recorded: {list or "none this session"}
- {if scaffold created: "Project {name} initialized in the vault"}

**Open items:**
{what's left half-done, or "Nothing pending."}

**Next steps:**
{3-5 items ordered by priority}

{If un-ingested sources found:
**Un-ingested sources ({N}):**
- `{url_1}` — {why it's worth ingesting}
- `{url_2}` — {why}
> Run `/ingest {url}` or reply "ingest all".
}

## Rules

- Project progress belongs in `_knowledge/projects/{project}/`, never in a single flat `projects.md`.
- If session was unproductive, record it honestly — don't invent progress.
- Only create cross-cutting `_decisions/` or `_learnings/` if the content has value beyond this session (see step 7 criteria).
- Always update `_memory/current-state.md` — it's the always-on rollup.
- Never overwrite `state.md` without reading the current content first.
- Always clear the `.needs-end-session` and `.compacted-without-end-session` flags at the end.

---

### Português (BR)

Fechamento de sessão. Detecta projeto (arg ou conversa), classifica tipo, cria scaffold do projeto se não existir (com aprovação), append no work-log, atualiza gotchas/decisions/roadmap, atualiza current-state como rollup, cria decisions/learnings cross-project se for o caso. Lista fontes não ingeridas. Remove flags `.needs-end-session` e `.compacted-without-end-session`. Direto, honesto sobre sessões improdutivas.
