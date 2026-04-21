---
description: Ingest a single external source (URL, file, or raw text) into the vault. Discuss before committing.
---

You are the ingestor of external sources. Capture, structure, and connect the source to the vault.

Follow the Karpathy LLM Wiki principle: ingest **one source at a time** and **discuss the takeaways with the user before persisting**. Never batch-ingest without approval.

## Arguments

`$ARGUMENTS` holds the source: URL, local file path, or raw text.

If `$ARGUMENTS` is empty, ask: "Which source do you want to ingest? (URL, file path, or paste the text)"

## Steps

### 1. Fetch the content

- URL → use WebFetch.
- File path → use Read.
- Raw text → use `$ARGUMENTS` directly.

### 2. Extract and discuss (before writing to disk)

Extract from the content:
- **Key claims:** the author's central arguments.
- **Entities:** technologies, patterns, tools, people mentioned.
- **Recommendations:** what the author suggests doing or avoiding.
- **Actionable takeaways:** what would change in the user's workflow if this is true.

Show the user:
```
About to ingest: [title]
Source: [URL / file / raw]

Summary (5 lines):
- ...

Key claims:
- ...

Actionable takeaways:
- ...

Shall I save this to _sources/? (y/n, or suggest edits)
```

Wait for confirmation. If the user suggests edits, revise and show again.

### 3. Create the source note

After approval, create `_sources/[YYYY-MM-DD]-[slug].md` where `slug` is the kebab-cased title.

```yaml
---
tags: [source, ingest, {category}]
source_url: {url or "local" or "raw"}
source_type: {article | video-transcript | docs | paper | book | raw}
author: {author, or "unknown"}
ingested: {today}
status: active
---
```

Note sections:
- `## Summary` — 3-5 lines: what, who, why it matters.
- `## Key Claims` — bullet list of central arguments.
- `## Actionable Takeaways` — what to do differently after reading this.
- `## Vault Connections` — WikiLinks to related notes.
- `## Contradictions` — if any existing decision in `_decisions/` or learning in `_learnings/` contradicts this source, list here with link.

### 4. Cross-link with the vault

For each relevant entity or concept:
- Check `_learnings/` — link if a related insight exists.
- Check `_decisions/` — flag explicitly if the source contradicts an ADR.
- Check `_wiki/` — link if the concept already has a wiki page.

### 5. Offer to extract a learning

Ask: "Do you want to extract the actionable insight into `_learnings/`? (y/n). That makes it available to `/content-idea` and future wiki builds."

If yes, create `_learnings/[slug].md`:
```yaml
---
tags: [learning, source-based, {category}]
source: _sources/[slug].md
ingested: {today}
status: active
---
```
Sections: `## Core Insight` (1-2 sentences), `## What Changes in Practice` (bullets), `## Connections` (WikiLinks).

### 6. Log the activity

Append to `_memory/activity-log.md`:
```
## [YYYY-MM-DD HH:MM] ingest | [slug] — [source in < 60 chars]
```

## Output

Answer in the user's language with:

### Ingested: [title or slug]

- **Source:** [URL or type]
- **File created:** `_sources/[slug].md`
- **Learning extracted:** [yes / no — path if yes]
- **Summary:** [3-5 lines]
- **Key claims:** [bullet list]
- **Vault connections:** [WikiLinks]
- **Contradictions detected:** [if any, detail; otherwise omit]
- **Suggested next action:** [e.g. run `/wiki-build`, open decision X]

## Rules

- Never invent information that isn't in the source.
- If the source is very long, focus on the most relevant parts for the vault's current domain.
- Contradictions with existing decisions must be flagged, never silently ignored.
- File slug: kebab-case, no special chars, max 50 chars.
- **Always discuss before persisting.** If the user rejects the summary, don't save.

---

### Português (BR)

Ingere UMA fonte por vez (padrão Karpathy). Busca o conteúdo, discute os takeaways, pede confirmação, só então salva em `_sources/` com frontmatter e WikiLinks. Oferece extrair um `_learnings/` derivado. Registra no activity log. Nunca inventa, sempre sinaliza contradições com decisões existentes.
