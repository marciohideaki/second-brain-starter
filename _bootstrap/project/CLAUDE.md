# [Project Name]

> **SETUP:** before using this file, replace every occurrence of `{VAULT}` with the absolute path to your starter (for example `/opt/second-brain`).
> Command: `sed -i 's|{VAULT}|/your/path/to/second-brain|g' .claude/CLAUDE.md`

> Project-scoped context for Claude Code.
> Lives at `.claude/CLAUDE.md` inside the project repository.
> Complements (never replaces) the global second-brain instructions.

---

## About the project

- **Name:** [project-name]
- **Domain:** [e.g. fintech, SaaS, e-commerce, internal platform, content studio]
- **Stage:** [e.g. MVP, beta, production, refactor]
- **Main stack:** [e.g. Node.js + React + Postgres, Python + FastAPI, etc.]

## Context for Claude

### What this project does

[Describe in 2-3 sentences the purpose and problem it solves.]

### How it is structured

[Briefly describe the architecture: monorepo or split repos? monolith or microservices? main modules.]

### Where deep knowledge lives

Deep project knowledge is in:
`{VAULT}/_knowledge/projects/{project-name}/`

When starting a session on this project:
1. Read `{VAULT}/_knowledge/projects/{project-name}/index.md` (if it exists).
2. If the work touches specific modules, read `modules.md`.
3. For architectural decisions, consult `decisions.md` and `{VAULT}/_decisions/`.

### Conventions specific to this project

[Naming patterns, folder layout, how PRs are done, etc.]

### What NOT to do in this project

[Anti-patterns, rejected approaches, known pitfalls.]

---

## Dev instructions

### Run locally

```bash
# paste the commands to start the project
```

### Run tests

```bash
# paste the test commands
```

### Deploy

[Describe the process or point to the CI/CD pipeline.]

---

### Portuguese (BR)

Este arquivo é o `.claude/CLAUDE.md` do projeto. Lembre de substituir `{VAULT}` pelo caminho absoluto do seu second-brain antes de usar. Ele complementa as instruções globais do vault e acrescenta contexto específico deste projeto.

*Need more? Check `{VAULT}/_knowledge/projects/{project-name}/` for full context.*
