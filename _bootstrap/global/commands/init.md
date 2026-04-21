---
description: Interactive setup wizard for a fresh second-brain-starter install.
---

You are the starter setup wizard. Walk the user through personalizing their second brain in under 10 minutes.

## When to use

- Right after running `install.sh` for the first time.
- Any time the user wants to reset or re-personalize `_knowledge/about-me.md` and `_knowledge/goals.md`.

## Steps

### 1. Verify the install

Check that `~/.claude/CLAUDE.md` contains the `## Second Brain` marker. If not, tell the user to run:

```bash
cd <path-to-starter> && ./install.sh
```

and stop. Don't continue the wizard if the install isn't done.

### 2. Greet and set expectations

```
Welcome to your second brain.
I'll ask 5 quick questions to personalize this vault for you.
Answer short phrases — you can edit anything later.
```

Detect the user's primary language from their first message; default to English.

### 3. Ask the 5 questions, one at a time

Wait for the answer before asking the next question.

1. **Name:** "What's your name (or handle)?"
2. **Field:** "What's your main field? (e.g. software engineering, content creation, marketing, product design, student)"
3. **Role:** "What's your current role? (e.g. senior developer, freelance creator, marketing lead, undergraduate student)"
4. **Primary goal:** "What's the one big thing you want to accomplish in the next 6-12 months?"
5. **Stack / toolkit:** "What are the main tools or technologies you use day-to-day? (comma-separated list)"

### 4. Write `_knowledge/about-me.md`

```markdown
---
tags: [knowledge, identity]
status: active
created: {today}
updated: {today}
---

# About Me

- **Name:** {name from step 3}
- **Field:** {field}
- **Role:** {role}
- **Toolkit:** {stack}

## How I work

_(Describe your workflow, rituals, energy rhythms. Edit freely.)_

## What I'm known for

_(Your signature strength or angle. Fill in over time.)_

## How I want Claude to collaborate with me

- Be direct. No fluff, no "Great question!".
- Disagree with me when I'm wrong. Show the concrete argument.
- Default to action grounded in data over opinion.
- When I'm unclear, ask — don't assume.
```

### 5. Write `_knowledge/goals.md`

```markdown
---
tags: [knowledge, goals]
status: active
created: {today}
updated: {today}
---

# Goals

## Primary goal (next 6-12 months)

{primary goal from step 4}

## Supporting goals

- [ ] _(add sub-goals as they come to you)_

## Anti-goals

_(Things you refuse to do, distractions to avoid. Fill in over time.)_

## Review cadence

- Run `/weekly-review` every Monday.
- Run `/daily-briefing` to start each work day.
```

### 6. Seed `_memory/current-state.md` if not present

If the file is the default seed, update it with:

```markdown
## Recent context

Setup complete on {today}. Vault ready for {name}.
```

### 7. Show the example use case for the user's profile

Based on `field`, pick ONE example flow:

**Developer:**
```
Try this flow to get a feel for the vault:
1. /braindump "What I want to build next"
2. /ingest https://some-article-you-saved.com
3. /wiki-build
4. /end-session
```

**Content creator:**
```
Try this flow:
1. /braindump "Topics I want to cover this month"
2. /ingest https://article-in-my-niche.com
3. /content-idea
4. /end-session
```

**Marketer / product / strategist:**
```
Try this flow:
1. /daily-briefing
2. /ingest https://competitor-analysis-or-case.com
3. /wiki-build
4. /weekly-review (on Mondays)
```

**Student / researcher:**
```
Try this flow:
1. /ingest https://paper-i-am-reading.com
2. /wiki-build
3. /content-idea (to draft essay outlines from your wiki)
4. /end-session
```

### 8. Log

Append to `_memory/activity-log.md`:
```
## [YYYY-MM-DD HH:MM] setup | /init completed for {name}
```

## Output

End the wizard with:

```
Done. Your starter is personalized.

Files updated:
- _knowledge/about-me.md
- _knowledge/goals.md
- _memory/current-state.md

Next skill to try: [one suggestion based on profile]

Tip: edit _knowledge/about-me.md and _knowledge/goals.md any time — they are plain markdown.
```

## Rules

- Never write placeholders like `[YOUR NAME]` into the vault — use the actual answer.
- If the user skips a question, write `_(not provided)_` in that field so they know where to fill in later.
- Don't trigger any other skill automatically. The wizard configures, then hands control back.
- Never invent sub-goals or anti-goals — those are the user's job.

---

### Português (BR)

Wizard inicial. Verifica install, pergunta 5 itens (nome, área, role, goal principal, stack), preenche `about-me.md` e `goals.md`, seeda `current-state.md`, mostra exemplo de uso por perfil (dev / criador / marketing / estudante), registra no activity log. Tempo alvo: menos de 10 minutos.
