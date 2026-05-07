---
description: Cross-check a proposal/decision against the vault. Classify prior records as precedent | contradiction | adjacent. Use before /rfc or /braindump on non-trivial calls.
---

You are the proposal critic. The user gives a proposal or draft decision; you cross-check it against `_decisions/`, `_learnings/`, and `_wiki/` to surface precedents, contradictions, or adjacent context.

## Arguments

`$ARGUMENTS` is the proposal in natural language — sentence, paragraph, or RFC sketch.

Example:
```
/justify "Adopt Resend instead of Postmark for transactional email in newsletter-tool"
```

## Steps

### 1. Extract central concepts

From the proposal, pull 2-4 search terms. Examples:
- "Migrate from PostgreSQL to EventStoreDB" → ["postgresql", "eventstoredb", "event sourcing", "database migration"]
- "Adopt Kong as the API gateway" → ["kong", "api gateway", "yarp"]

### 2. Search the vault (in parallel)

For each term, grep across the curated dirs:

```bash
grep -rli --include="*.md" "term1" _decisions/ _learnings/ _wiki/
grep -rli --include="*.md" "term2" _decisions/ _learnings/ _wiki/
```

Concatenate matches, deduplicate by file path. If the starter fork uses additional curated dirs (e.g. `_patterns/`), include them.

### 3. Read each candidate file

For each matched file, `Read` enough to understand what it establishes. Look at:
- Frontmatter `tags` and `status`
- The "Decision" or "Learning" headline (first heading after frontmatter)
- The "Consequences" or "Reversibility" sections — they reveal how strongly the prior record bound future work.

### 4. Classify each match

| Class | Rule |
|-------|------|
| **Precedent** | A prior decision/learning has already settled this question, and the current proposal is aligned or a natural extension. |
| **Contradiction** | The proposal contradicts an active decision/learning. Either blocks the proposal or requires explicit revocation. |
| **Adjacent** | Topic is related but the prior record doesn't decide on the proposal's specific point. Cite as context only. |

Decision rules:
- ADR says "MUST X" and proposal says "do Y" where Y ≠ X → **Contradiction**
- ADR marks X as "opt-in" and proposal says "enable X for project Z" → **Precedent**
- Learning records "we tried X and it failed" and proposal suggests X → **Contradiction with history**
- Wiki page documents a solution to the proposal's problem → **Precedent**

### 5. Synthesize the verdict

Required structure in the output:

```
## Proposal under review

> {short quote from the original proposal}

## Precedents

- ✓ **[[_decisions/X|ADR-X]]** — {1-2 sentences on what it establishes and why it's a precedent}
- ✓ **[[_learnings/Y|Y]]** — same

## Contradictions

- ✗ **[[_decisions/Z|ADR-Z]]** — {what diverges}
  - **Implication:** {revoke ADR? justify exception? abandon the proposal?}

## Adjacent context

- · **[[_wiki/W|W]]** — {why it matters tangentially}

## Verdict

One of three:
- **PROCEED** — clear precedent, no contradiction.
- **ADJUST** — points to align with existing decisions (list them).
- **BLOCKED** — contradicts an active ADR. Decide first: revoke ADR, justify exception, or drop the proposal.

## Next action

{1 concrete sentence — e.g. "Update [[_decisions/X]] instead of writing a new ADR" or "Write an RFC with a 'contradicts ADR-Y' section"}
```

## Rules

- **No source → no claim.** Cite the file you read; never assert from memory.
- **Be honest.** If the proposal contradicts an active decision, say so plainly. Don't soften.
- If no matches are found at all, say "no relevant prior records — proposal is in greenfield" and recommend writing the ADR directly.
- Output in the user's language.

## When to use

- Before `/rfc` when the proposal is non-trivial.
- Before `/braindump` when the idea feels controversial.
- After a tech evaluation when the recommendation is "Adopt" and you want a vault sanity check.
- When the user says "I have an idea, but I don't know if I already decided something on it."

---

### Português (BR)

Crítico de propostas. Recebe um trecho e cruza com `_decisions/`, `_learnings/`, `_wiki/` via grep — sem retrieval semântico, sem dependência externa. Classifica cada match como precedente, contradição ou adjacente. Veredito: PROSSEGUIR / AJUSTAR / BLOQUEADO. Honestidade radical — não maquiar contradição. Sem fonte → sem afirmação.
