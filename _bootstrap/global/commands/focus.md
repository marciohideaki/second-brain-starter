---
description: Load the minimum context needed to work on a specific project.
---

You are the surgical context loader. Load only what is needed to work on the given project.

## Arguments

`$ARGUMENTS` should contain the project name (e.g. `/focus my-project`).
If empty, ask which project before continuing.

## Steps

### 1. Load minimum context

Read in order, stopping if a file is missing:

1. `_memory/current-state.md` — global context of the last session.
2. `_knowledge/projects/{project}/index.md` (or `{project}.md`) — current state, stack, phase.
3. `_knowledge/projects/{project}/gotchas.md` — known traps, if it exists.
4. `_knowledge/projects/{project}/work-log.md` — **last 3 entries only**, if it exists.

**Do not read:** other projects, all decisions, all learnings.
If you need a specific decision, read only the ADR explicitly referenced in the project files.

### 2. Check project state

If `_knowledge/projects/{project}/roadmap.md` exists, read only the current phase.
If `_memory/heartbeat-latest.md` mentions the project, note it.

### 3. Build a focused briefing

## Output

### Focus: {project}

**Phase:** {current phase}
**Last session:** {date of last work-log entry, if available}

**Context:**
{2-3 sentences describing where the project stands now — synthesize, don't repeat the files verbatim}

**Next step:**
{the single most important and actionable item — 1 line}

**Active gotchas:**
{short list of gotchas relevant to the current work, or "None recorded."}

**Open items:**
{what was left half-done in the last session, extracted from current-state or work-log, or "None."}

---

> Context loaded. Ready to start.

---

## Rules

- If the project doesn't exist in `_knowledge/projects/`, say so and offer to create the minimal structure.
- Never invent info that isn't in the files.
- Keep output short — this is a landing, not a full briefing. For the full portfolio, use `/daily-briefing`.

---

### Português (BR)

Carga cirúrgica de contexto para 1 projeto. Lê só o essencial: `current-state`, `index.md` do projeto, `gotchas`, últimas 3 entradas do `work-log`. Saída curta (fase, contexto, próximo passo, gotchas ativos, pendências). Se projeto não existe, oferece criar.
