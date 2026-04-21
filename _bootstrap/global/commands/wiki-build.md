---
description: Compile ingested sources into a cross-linked wiki (LLM Wiki pattern). Discuss before persisting.
---

You are the wiki librarian. Compile notes in `_sources/` into a cross-linked knowledge base in `_wiki/`, following the Karpathy LLM Wiki pattern.

**Core principle:** knowledge is compiled **once at ingestion time**, then answered from the wiki — not re-read on every query. Ingest and compile incrementally, discuss before persisting, flag contradictions automatically.

## Arguments

`$ARGUMENTS` can be:
- empty → compile all new sources since the last build (use `_wiki/log.md` to find the cutoff)
- a single source slug → compile only that one
- `--rebuild` → recompile the entire wiki from `_sources/`

## Steps

### 1. Identify sources to process

- Check `_wiki/log.md` — the append-only log tracks which sources were last compiled and when.
- If empty or missing, consider all `_sources/*.md` as new.
- If `$ARGUMENTS` names a slug, process only that one.
- If `--rebuild`, process everything and clear the wiki first (ask the user to confirm).

### 2. For each source, extract wiki-ready units

For every source file, extract:
- **Entities** — the named things (technologies, people, tools, methods).
- **Concepts** — the abstract ideas (principles, patterns, techniques).
- **Claims** — the author's assertions with provenance.
- **Relationships** — "X depends on Y", "X is an alternative to Y", "X contradicts Y".

### 3. Plan wiki pages (before writing)

Group extracted units. Propose pages:
- One page per major entity or concept that recurs (cross-linking is key).
- One-off entities get a bullet inside a broader page — no empty stub pages.
- For every proposed page, identify which sources support it.

Show the user:
```
Ready to build from: {source 1}, {source 2}, ...

Proposed wiki pages (new or updated):
- _wiki/{concept-a}.md  (new) — from {source 1}, {source 2}
- _wiki/{entity-b}.md   (update) — add section from {source 1}

Cross-references planned:
- [[concept-a]] ↔ [[entity-b]]
- [[concept-a]] → [[existing-page]]

Contradictions flagged:
- {source 1} contradicts _learnings/x.md on ...

Proceed? (y/n, or propose edits)
```

Wait for confirmation.

### 4. Write wiki pages

After approval, for each page write:

```markdown
---
tags: [wiki, {category}]
status: active
created: {today-if-new, else existing}
updated: {today}
sources: [{source-slug-1}, {source-slug-2}]
---

# {Page Title}

## Summary
{2-4 sentences that stand on their own — the core meaning of this page}

## Key claims
- {claim} — source: [[{source-slug}]]
- {claim} — source: [[{source-slug}]]

## Related
- [[{related-page-1}]] — {1-line relationship}
- [[{related-page-2}]] — {1-line relationship}

## Open questions
- {question the sources don't resolve}

## Sources
- [[{source-slug-1}]]
- [[{source-slug-2}]]
```

Never drop existing content silently — when updating, merge and note the addition.

### 5. Maintain the index

Update `_wiki/index.md`:

```markdown
---
tags: [wiki, index]
updated: {today}
---

# Wiki Index

Pages in `_wiki/` grouped by category.

## Concepts
- [[{page-name}]] — {1-line summary}

## Entities
- [[{page-name}]] — {1-line summary}

## Open questions
- [[{page-with-open-question}]]: {the question}
```

### 6. Append to the compile log

Append to `_wiki/log.md`:

```markdown
## [YYYY-MM-DD HH:MM] — compiled {N} source(s)
- Sources processed: {list}
- Pages created: {list}
- Pages updated: {list}
- Contradictions flagged: {count}
```

### 7. Record contradictions

If any source contradicts an existing page, an ADR, or a learning, append to `_wiki/contradictions.md`:

```markdown
## {YYYY-MM-DD} — {topic}
- **Source:** [[{source-slug}]]
- **Contradicts:** [[{page-or-decision}]]
- **Summary:** {the actual contradiction in 1-2 lines}
- **Resolution status:** unresolved | resolved (see [[{ref}]])
```

Don't resolve contradictions silently. Surface them.

### 8. Log the activity

Append to `_memory/activity-log.md`:

```
## [YYYY-MM-DD HH:MM] wiki-build | {N} sources → {M} pages created, {K} updated
```

## Output

Answer in the user's language with:

### Wiki build complete

**Sources processed:** {N}
**Wiki pages created:** {M}
**Wiki pages updated:** {K}
**Cross-references added:** {total}
**Contradictions flagged:** {count} (see `_wiki/contradictions.md`)

**New pages:**
- `[[{page-name}]]` — {1-line summary}

**Updated pages:**
- `[[{page-name}]]` — {what was added}

**Open questions surfaced:**
- {question} — in `[[{page}]]`

**Next:**
- Browse the wiki starting at `_wiki/index.md`.
- Run `/lint` to verify no broken links.

## Rules

- **Always discuss the plan before persisting.** Never silently overwrite existing pages.
- Never invent claims not supported by the sources.
- Cross-references must point to real files — check before writing `[[...]]`.
- Contradictions must be flagged in `_wiki/contradictions.md`, never swept under the rug.
- Every wiki page must cite its sources. No unsourced claims.
- When rebuilding (`--rebuild`), confirm explicitly — this wipes the existing wiki.

---

### Português (BR)

Compila `_sources/` em `_wiki/` no padrão Karpathy LLM Wiki: extrai entidades/conceitos/claims/relações, propõe páginas e cross-refs, pede confirmação, escreve com frontmatter + Sources, mantém `_wiki/index.md`, loga em `_wiki/log.md`, registra contradições em `_wiki/contradictions.md`. Incremental por padrão, `--rebuild` pede confirmação explícita.
