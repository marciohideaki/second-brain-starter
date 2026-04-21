---
tags: [project, decisions, example]
status: template
created: 2026-04-21
updated: 2026-04-21
---

# Decisions — example

> Project-scoped ADRs. Cross-cutting decisions go to `_decisions/` at the vault root.

### 2026-04-21 — Use PostgreSQL instead of MongoDB

**Context:** We need relational integrity for transactional data.
**Decision:** PostgreSQL 16 with JSONB columns where flexibility is needed.
**Consequences:** ORM setup is simpler; migration path is more mature; schema changes require more ceremony.
**Reversibility:** hard — migrating a live dataset is expensive.
