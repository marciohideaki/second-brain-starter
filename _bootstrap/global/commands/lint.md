---
description: Audit the vault knowledge graph and report structural defects.
---

You are the vault auditor. Check the health of the knowledge graph and produce a defect report.

## Steps

Run every check below. For each, count defects and list the items with problems.

### 1. Required frontmatter (impact: high)

Check all `.md` files in:
- `_learnings/`
- `_decisions/`
- `_pipeline/`
- `_knowledge/projects/*/` (skip `_example/`)
- `_sources/`

Required fields: `tags`, `status`, `created`.
Defect: file missing one or more fields.
**Skip** files named `_example.md` — those are reference templates.

### 2. Stale notes (impact: medium)

Find files with `status: active` whose `updated` is more than 30 days in the past.
Flag as candidates for review.

### 3. Broken WikiLinks (impact: high)

In files across `_learnings/`, `_decisions/`, `_knowledge/projects/`, and `_wiki/`:
- Extract all `[[target]]` patterns.
- For each link, check if the target file exists in the vault (try `_wiki/{target}.md`, or the same folder).
- Defect: link to a non-existent file.

### 4. Orphan files (impact: low)

Check files in `_learnings/` and `_decisions/` that aren't referenced by any other file.
Candidates for removal or additional documentation.

### 5. Wiki integrity (impact: medium)

If `_wiki/` exists:
- Each wiki page should have a `## Sources` section or explicit source link.
- `_wiki/index.md` should exist and list all pages.
- `_wiki/log.md` should exist and be append-only.

### 6. Log the activity

Append to `_memory/activity-log.md`:
```
## [YYYY-MM-DD HH:MM] lint | [N] critical defects, [N] warnings
```

## Output

Answer in the user's language with:

### Lint report — [today]

**Overall score:** [X/10]

| Check | Defects | Warnings | Status |
|-------|---------|----------|--------|
| Required frontmatter | [N] | — | [OK / FAIL] |
| Stale notes | — | [N] | [OK / ATTENTION] |
| Broken WikiLinks | [N] | — | [OK / FAIL] |
| Orphan files | — | [N] | [OK / ATTENTION] |
| Wiki integrity | [N] | [N] | [OK / ATTENTION] |

**Critical defects** (fix before the next session):
[Numbered list: file + problem + fix action]

**Warnings** (fix when you can):
[List: file + situation]

**Prioritized actions:**
1. [Highest-impact action]
2. [Second action]
3. [...]

## Rules

- Don't report OK without actually checking the file contents.
- Log to the activity log regardless of result (even if zero defects).
- Be concrete — lists, not paragraphs.
- Skip `_example.md` in every check.

---

### Português (BR)

Audita o knowledge graph: frontmatter obrigatório (tags, status, created), notas obsoletas (status active + updated > 30 dias), WikiLinks quebrados, arquivos órfãos, integridade do wiki (Sources, index.md, log.md). Reporta score 0-10, defeitos críticos, avisos, ações prioritizadas. Pula `_example.md`. Registra no activity log.
