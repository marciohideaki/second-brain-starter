---
description: Predict the most likely next tasks for a project, ranked by confidence, based on its work-log + roadmap + state.
---

You are the next-task predictor of the second brain. Heuristic-only: read the project files and infer the K most probable next tasks. No LLM-side speculation beyond what the files actually say.

## Arguments

`$ARGUMENTS` may contain a project name and optional `k=N` (e.g. `/predict my-project k=5`).
If empty, ask which project. Default `k=3`.

## Steps

### 1. Read source files (in parallel)

For project `{project}` in `_knowledge/projects/{project}/`:

1. `state.md` — current phase, next step, blockers, branch, PRs.
2. `roadmap.md` — declared next phases and outstanding items.
3. `work-log.md` — full history of work entries (Date | Type | Description | Epic ID | Status).
4. `decisions.md` — recent ADRs (last 3).

If any file is missing, note it and continue with what's available.

### 2. Build a heuristic feature set

From `work-log.md`:

- **Type distribution**: count entries by `type` column. Identify the dominant type (the project's "operating mode").
- **Recent cadence**: gap (in days) between the last 5 entries. If gap > 14 days → flag as "cold".
- **Open epics**: any entry with status `em andamento` or `aberto`.
- **Last status**: did the most recent entry close cleanly or leave something pending?

From `state.md`:

- **Next step** is an explicit prediction signal — weight it highly.
- **Blocker** present → predict a `task` or `chore` to clear it before any feature work.
- **Branch + PRs** → predict a `task: review/merge PR #N` if PR is open.

From `roadmap.md`:

- Items in the **current phase** but not yet in `work-log` → strong candidates.
- Items in the **next phase** flagged as "← atual" → also candidates if current is mostly done.

### 3. Rank predictions

For each candidate, compute a heuristic confidence:

| Signal | Weight |
|--------|--------|
| Item appears literally in `state.md` next-step | +50% |
| Item is in current phase of `roadmap.md` and not in work-log | +25% |
| Type matches the dominant work-log type | +15% |
| Recent cadence is hot (< 7 days between entries) | +10% |
| Blocker mentioned in state | promote unblocking task to top |

Cap total confidence at 95% — never claim certainty about future work.

### 4. Output

Answer in the user's language with:

### Predictions: {project}

**Type distribution (last N entries):**
- {type1}: N entries
- {type2}: N entries

**Cadence:** {hot / warm / cold} ({avg gap} days between recent entries)

**State signals:** {1-line summary of state.md — phase, next step, blocker if any}

**Top {K} predictions for next session:**

| # | Type | Description | Confidence | Source |
|---|------|-------------|------------|--------|
| 1 | {type} | {1-line action} | {N}% | state.md / roadmap.md / cadence |
| 2 | {type} | {1-line action} | {N}% | ... |
| 3 | {type} | {1-line action} | {N}% | ... |

**Caveats:**
- These are heuristic predictions — humans confirm before executing.
- If a prediction repeats across sessions without progress, surface as "stuck signal".

---

## Rules

- Use only what's in the files — never invent items not anchored in `state.md`, `roadmap.md`, or `work-log.md`.
- If `work-log.md` has fewer than 3 entries, say "insufficient history" and suggest a single conservative next step from `state.md` only.
- If `state.md` and `roadmap.md` disagree (e.g., state says Phase 2 in progress, roadmap says Phase 3 active), surface the conflict before predicting.
- Do not call any LLM for ranking — the markdown context + simple counting is enough.
- Output in the user's language.

---

### Português (BR)

Predição de próximas tarefas. Lê work-log + roadmap + state + decisions do projeto. Conta distribuição de tipos, calcula cadência, extrai sinais (next-step, blocker, branch+PRs, fase atual). Ranqueia top-K por heurística (peso maior se aparece em state, depois roadmap, depois match com tipo dominante). Cap em 95% — humano confirma. Saída tabular com tipo, descrição, confiança, fonte.
