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

**Type (pick one):**

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

If project folder exists, append to `_knowledge/projects/{project}/work-log.md`:

```
| {YYYY-MM-DD} | {type} | {concise 1-line description} | {status: done / in-progress} |
```

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

### 6. Update `current-state.md`

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

**Cross-cutting decision** (affects 2+ projects or sets a pattern):
Create `_decisions/{YYYY-MM-DD}-{kebab-description}.md` with frontmatter + context + decision + alternatives + consequences.

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
## [YYYY-MM-DD HH:MM] session-end | {project} — {type}: {1-line description}
```

Remove the pending-session flags:
```
rm -f _memory/.needs-end-session _memory/.compacted-without-end-session
```

## Output

Answer in the user's language with:

### Session closed — {today}

**Project:** {name} | **Type:** {type}

**What we did:**
{concise list}

**Saved to the vault:**
- work-log: `{type} — {description}`
- gotchas: {N new} | decisions: {N new} | learnings: {N new}
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
- Only create cross-cutting `_decisions/` or `_learnings/` if the content has value beyond this session.
- Always update `_memory/current-state.md` — it's the always-on rollup.
- Always clear the `.needs-end-session` and `.compacted-without-end-session` flags at the end.

---

### Português (BR)

Fechamento de sessão. Detecta projeto (arg ou conversa), classifica tipo, cria scaffold do projeto se não existir (com aprovação), append no work-log, atualiza gotchas/decisions/roadmap, atualiza current-state como rollup, cria decisions/learnings cross-project se for o caso. Lista fontes não ingeridas. Remove flags `.needs-end-session` e `.compacted-without-end-session`. Direto, honesto sobre sessões improdutivas.
