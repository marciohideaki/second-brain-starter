---
description: Build a HANDOFF.md so the next session resumes without context loss.
---

You are the session handoff generator. Build a structured artifact so the next session picks up the work without re-discovery.

---

## Context

Development sessions often end mid-task. Without a structured handoff, the next session has to re-discover context, re-read the same files, and often repeat failed attempts.

This skill creates a `HANDOFF.md` that enables immediate resume with full context.

**Relation to the second brain:** `/end-session` captures vault-level knowledge (ADRs, gotchas, learnings). `HANDOFF.md` captures session-level state (work in progress, what to do next). They complement each other — use both.

---

## When to use

- Before closing any session that left a task unfinished.
- Before a context compaction during a long task.
- Whenever the next action requires context that isn't in the codebase.

---

## Steps

### 1. Check for an existing HANDOFF.md

```bash
ls HANDOFF.md 2>/dev/null && cat HANDOFF.md || echo "No existing handoff"
```

If it exists, read it. Append — never overwrite without reading first.

### 2. Collect session state

```bash
git diff --name-only        # changed files
git branch --show-current   # current branch
git status                  # uncommitted work
git log -1 --oneline        # last commit
```

### 3. Write HANDOFF.md

```markdown
# HANDOFF — <feature or task name>
**Date:** YYYY-MM-DD HH:MM
**Branch:** <branch name>
**Type:** feature | fix | task | spike

## Goal
<one sentence — the specific outcome this session was chasing>

## Current progress

### Done
- [x] <item> — `<file path if relevant>`
- [x] <item>

### In progress (resume here)
- [ ] <item> — `<file>` — <specific next action>

### Not started
- [ ] <item>

## What worked
- **<approach>:** <why it worked, what to replicate>

## What did NOT work (don't retry)
- **<approach>:** <why it failed, what to avoid>

## Decisions made in this session
- <decision> — rationale: <why>
- If it produced an ADR: see `_decisions/<YYYY-MM-DD>-<desc>.md`

## Open questions / Blockers
- [ ] <question needing human decision>
- [ ] <blocker waiting on external dependency>

## Next steps (ordered)
1. `<exact file>` — <exact action>
2. `<exact file>` — <exact action>
3. Run: `<exact command>`

## Non-obvious context
- <gotcha, assumption, or constraint the next session needs to know>
```

### 4. Gitignore

```bash
grep -q "HANDOFF.md" .gitignore || echo "HANDOFF.md" >> .gitignore
```

HANDOFF.md is session state, not a permanent artifact — do not commit.

### 5. Optional SESSION-CHECKPOINT (if the same task will resume)

If the next session will pick up the same task, also create `SESSION-CHECKPOINT.md`:

```markdown
# SESSION-CHECKPOINT — <feature or task>
**Date:** YYYY-MM-DD HH:MM
**Branch:** <branch>
**Checkpoint status:** <one-line summary of where we stopped>

## Decisions this session
- <decision 1> — rationale: <why>

## Still open (not done yet)
- [ ] <item> — <file> — <exact next action>

## Skip (already done)
- <item> — completed in: <file or commit>

## Resume prompt
> "<paste this verbatim to resume at top speed>"
```

```bash
grep -q "SESSION-CHECKPOINT.md" .gitignore || echo "SESSION-CHECKPOINT.md" >> .gitignore
```

### 6. Sync with the vault (if the session was productive)

Per CLAUDE.md §3, also record in the vault:
- Architectural decisions → `_knowledge/projects/{project}/decisions.md`
- Gotchas discovered → `_knowledge/projects/{project}/gotchas.md`
- Activity log → `_memory/activity-log.md`
- Overall state → `_memory/current-state.md`

---

## Anti-patterns

| Anti-pattern | Why it fails |
|--------------|--------------|
| "The context will be in the code" | Code doesn't explain why attempts failed |
| "I'll remember where I stopped" | New session = zero memory |
| Vague entries ("worked on auth") | Useless — next session still has to re-discover |
| Not recording failed attempts | Next session repeats the same mistakes |
| Committing HANDOFF.md | Pollutes git history with ephemeral state |

---

## Definition of done

- [ ] HANDOFF.md created with every section filled.
- [ ] "In progress" includes a specific file and the exact next action.
- [ ] "What did NOT work" records every failed attempt.
- [ ] HANDOFF.md is in `.gitignore`.
- [ ] SESSION-CHECKPOINT.md created if the same task will resume.
- [ ] Vault synced via `/end-session` for any ADR or gotcha discovered.

---

## Rules

- Create the handoff **before** closing the session — after means context is already lost.
- "Short" is not a reason to skip — "unfinished" is the reason to create.
- "What did NOT work" cannot be empty if the session had failed attempts.
- Next steps without a specific file or exact command are useless.
- Always check for an existing HANDOFF.md before creating a new one.

---

### Português (BR)

Gera HANDOFF.md (e opcionalmente SESSION-CHECKPOINT.md) para retomar sessão sem perda de contexto. Captura: objetivo, progresso (feito, em andamento, não iniciado), o que funcionou, o que não funcionou (obrigatório se houve tentativas), decisões, perguntas abertas, próximos passos com arquivo+ação exata, contexto não óbvio. Gitignored (não é artefato permanente). Complementa `/end-session` (vault level).
