# docs/assets/

Visual assets used across the documentation and the main README.

## Directory structure

```
docs/assets/
├── README.md                  (this file)
├── flow-overview.png          (main flow diagram — used in README hero)
├── ingestion-flow.png         (how /ingest → /wiki-build works)
├── session-continuity.png     (how hooks preserve state across sessions)
├── skills-map.png             (visual map of all 12 skills)
├── architecture.png           (global / vault / project operating modes)
├── banner.png                 (optional — hero banner for the README)
└── screenshots/
    ├── daily-briefing.png     (example output of /daily-briefing)
    ├── end-session.png        (example output of /end-session)
    ├── wiki-build.png         (example of the /wiki-build confirmation prompt)
    └── init-wizard.png        (example of /init in action)
```

## Suggested images to create

### Must-have (referenced in README)

| File | Purpose | Shows |
|------|---------|-------|
| `flow-overview.png` | Replace the ASCII diagram in README | Raw sources → `/ingest` → `_sources/` → `/wiki-build` → `_wiki/` with hooks and cron running in background |
| `ingestion-flow.png` | Show in [docs/en/philosophy.md](../en/philosophy.md) | The Karpathy LLM Wiki pattern: single source → discussion → wiki pages with cross-refs |
| `session-continuity.png` | Show in [docs/en/hooks-and-crons.md](../en/hooks-and-crons.md) | Timeline of a day: prompt hook → session end hook → flag creation → next-day daily briefing reads state |
| `architecture.png` | Show in [docs/en/getting-started.md](../en/getting-started.md) | Three operating modes (global, vault, project) and how they relate |

### Nice-to-have

| File | Purpose | Shows |
|------|---------|-------|
| `skills-map.png` | README "12 skills" section | Visual taxonomy: Setup / Capture / Compile / Rhythm / Close / Output / Maintenance |
| `banner.png` | README top | Brand / logo / simple hero art |
| `screenshots/*.png` | FAQ and docs | Real terminal output of skills in action |

## Format and size guidelines

| Type | Format | Max width | Notes |
|------|--------|-----------|-------|
| Diagrams | **SVG preferred**, PNG fallback | Natural | SVG scales on mobile without losing sharpness. If PNG, use 2x resolution (retina). |
| Screenshots | PNG | 1600px | Dark terminal background reads better on GitHub light and dark modes. |
| Banners | PNG (or SVG if flat) | 1200x400px | Keep file size under 300KB. |

**All assets under 500KB** when possible. GitHub compresses images but large files slow initial repo clone.

## Naming conventions

- Lowercase, kebab-case: `flow-overview.png`, not `FlowOverview.PNG`.
- Describe content, not position: `session-continuity.png` is better than `image-02.png`.
- Screenshots go in `screenshots/` and are named after the skill: `daily-briefing.png`, `end-session.png`.

## Accessibility

Every image embedded in markdown must have meaningful `alt` text:

```markdown
![Flow overview: raw sources are ingested, compiled into a cross-linked wiki, and queried through skills while hooks and cron jobs preserve state across sessions](docs/assets/flow-overview.png)
```

Not:

```markdown
![flow](docs/assets/flow-overview.png)
```

Screen readers rely on `alt`. It also renders as fallback text when the image fails to load.

## Color and theme

GitHub has light and dark modes. To look good in both:

- Avoid pure white backgrounds (pick `#f6f8fa` GitHub-light or transparent).
- Test both themes: https://github.com/settings/appearance.
- For diagrams, consider two versions:
  ```markdown
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/flow-overview-dark.png">
    <img alt="..." src="docs/assets/flow-overview.png">
  </picture>
  ```

## Tools to create these

- **Diagrams**: [Excalidraw](https://excalidraw.com/), [tldraw](https://www.tldraw.com/), [Figma](https://figma.com/), [Mermaid](https://mermaid.js.org/) (GitHub renders Mermaid natively in markdown).
- **Screenshots**: native OS tools, or [Carbon](https://carbon.now.sh/), [Ray.so](https://ray.so/) for pretty code/terminal shots.
- **Banners**: Figma, Canva, or the open-source [Tabler Icons](https://tabler-icons.io/) set.

## Mermaid alternative (no images needed)

GitHub renders [Mermaid](https://mermaid.js.org/) diagrams directly from markdown. Example:

````markdown
```mermaid
flowchart LR
    A[Raw Sources] -->|/ingest| B[_sources/]
    B -->|/wiki-build| C[_wiki/]
    C --> D[/focus /content-idea]
```
````

Pros: edit in markdown, no PNG to regenerate.
Cons: less visual polish than a hand-crafted SVG, limited layout control.

Use Mermaid for technical flow diagrams. Use SVG/PNG for hero visuals and screenshots.

---

## Português (BR)

Estrutura para imagens do projeto. Convenções:
- Formatos: SVG para diagramas, PNG para screenshots e banners.
- Nomes em kebab-case descritivo.
- `alt` text descritivo sempre.
- Considere versões light/dark via `<picture>` para acessibilidade.
- Imagens grandes devem ficar abaixo de 500KB.
- Para diagramas técnicos simples, considere usar [Mermaid](https://mermaid.js.org/) direto em markdown — GitHub renderiza nativamente.
