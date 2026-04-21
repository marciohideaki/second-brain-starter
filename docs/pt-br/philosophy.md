# Filosofia

Por que isso existe, e por que funciona?

## Três problemas que o starter resolve

### 1. Conhecimento que reseta a cada sessão

Memória de chat desaparece quando você fecha a aba. Ferramentas de documento (NotebookLM, uploads do ChatGPT, Notion AI) releem o material bruto a cada query — não compõem. Você aprende algo hoje e perde amanhã.

A solução, emprestada do [LLM Wiki do Karpathy](https://x.com/karpathy): **compilar conhecimento uma vez na ingestão**, depois responder a partir do wiki compilado. Cada nova fonte se soma a uma estrutura persistente e cross-linkada que sobrevive entre sessões.

`/ingest` captura; `/wiki-build` compila.

<p align="center">
  <img src="../assets/ingestion-flow.png" alt="Fluxo de ingestão: cada fonte é discutida com o usuário, aprovada, e então persistida com cross-references às páginas wiki existentes" width="720">
</p>

<details>
<summary>📐 Diagrama em texto</summary>

```mermaid
flowchart TD
    A[Usuário compartilha fonte<br/>URL · arquivo · texto] --> B[/ingest]
    B --> C[Buscar + extrair<br/>claims, entidades, takeaways]
    C --> D{Discussão:<br/>salvar assim?}
    D -->|edições pedidas| C
    D -->|aprovado| E[Escreve _sources/YYYY-MM-DD-slug.md]
    E --> F{Extrair learning?}
    F -->|sim| G[Escreve _learnings/slug.md]
    F -->|não| H[Concluído]
    G --> H
    H -.depois.-> I[/wiki-build]
    I --> J[Compila _sources/ em<br/>páginas _wiki/ cruzadas]
    J --> K[_wiki/index.md<br/>_wiki/log.md<br/>_wiki/contradictions.md]
```

</details>

### 2. Contexto que evapora entre sessões

Você gasta 20 minutos carregando contexto no início de cada sessão — relendo os mesmos arquivos, reconstruindo onde parou. Sem handoff estruturado, a próxima sessão redescobre o que a anterior já tinha descoberto.

A solução: **continuidade de sessão como infraestrutura**. Quatro hooks do Claude Code mantêm estado:
- `UserPromptSubmit` loga prompts e injeta state do projeto 1x/dia.
- `SessionEnd` registra o que aconteceu e sinaliza trabalho não sincronizado.
- `PreCompact` salva Next Steps e Open Questions antes do contexto ser comprimido.
- `Notification` avisa quando operação longa termina.

Mais dois crons (heartbeat e lint) que rodam fora do Claude Code, mantendo o vault saudável enquanto você dorme.

Resultado: contexto nunca "se perde entre sessões" porque nada importante vive só dentro da sessão.

### 3. Skills que ficam no nível da primeira versão

Uma skill escrita há 2 meses talvez esteja 70% efetiva. Você nunca rodaria testes A/B sistemáticos manualmente — overhead alto. Então fica a 70% para sempre.

A solução, emprestada do [autoresearch loop do Karpathy](https://aimaker.substack.com/p/how-i-built-skill-improves-all-skills-karpathy-autoresearch-loop): **converter a rubrica qualitativa 1-5 em evals binários sim/não**, deixar um agente mutar, testar, pontuar, manter ou descartar — limitado por max de iterações.

`/skill-improve` roda esse loop em qualquer skill. Três fases: humano monta baseline, agente roda autonomamente dentro dos limites, humano aprova o diff. Você termina com uma skill que passou por testes que você jamais teria paciência de fazer à mão.

---

## Quatro primitivos

### Log append-only

`_memory/activity-log.md` nunca é editado, só recebe append. Toda operação do vault — session-start, session-end, braindump, ingest, wiki-build, lint, heartbeat, compact — entra aqui com timestamp. Retenção: 90 dias. É sua trilha forense se algo der errado.

### Single source of truth

`CLAUDE.md` na raiz é lei. Toda skill lê, segue, e se estiver desatualizado, atualiza. Um arquivo, sem configs divergentes.

### WikiLinks

`[[nota-nome]]` em todo lugar. Knowledge graph é markdown plano com cross-references explícitos. Sem formato proprietário, sem lock-in. Funciona no Obsidian, Logseq, grep puro ou terminal.

### Discutir antes de persistir

Toda skill que escreve no vault mostra o plano antes de agir. `/ingest` mostra o resumo e pergunta. `/wiki-build` mostra as páginas propostas. `/skill-improve` mostra cada mutação em dry-run. O vault é seu — você aprova tudo que entra.

---

## O que isso NÃO é

### Não é plugin do Obsidian

Vault é markdown puro. Funciona no Obsidian — você ganha a visão de grafo de graça. Mas sem feature específica do Obsidian, sem plugin a instalar. Se Obsidian morrer amanhã, seu vault continua igual.

### Não é substituto do Notion

Notion é um banco de dados com UI markdown-ish. Isto é markdown com compilador. Se você quer planilhas e databases, use Notion. Se quer conhecimento de longo prazo que compõe, use isto.

### Não é mágica automática

Nada aqui acontece sem você. Hooks reagem a ações suas; crons rodam em horários fixos; skills só fazem o que você pede. O vault fica mais inteligente na velocidade que você alimenta. Ingeriu 1 artigo no mês, tem vault de 1 artigo no mês.

---

## Como pensar no uso diário

Imagine um dia:

- **07:00** — cron escreve `heartbeat-latest.md`. Você nem viu.
- **09:00** — `/daily-briefing`. Lê heartbeat, current-state, projetos ativos. Você vê prioridades.
- **09:15** — `/focus side-project`. Carga mínima para o trabalho específico.
- **11:00** — artigo do Hacker News interessante. `/ingest <url>`. Aprova o resumo; entra em `_sources/`.
- **12:00** — você percebe um padrão nos últimos ingests. `/wiki-build` compila em páginas cross-linkadas.
- **15:00** — decisão de arquitetura. `/braindump Vamos trocar REST por gRPC no serviço A. Trade-offs: X, Y, Z`. Skill sinaliza como candidato a ADR.
- **18:00** — `/end-session`. Work-log atualizado, gotchas salvos, current-state renovado, flags limpas.

No dia seguinte, `/daily-briefing` pega exatamente onde você parou.

---

## Créditos

- [LLM Wiki do Andrej Karpathy](https://x.com/karpathy) — compilar uma vez na ingestão, não por query.
- [Autoresearch pattern](https://aimaker.substack.com/p/how-i-built-skill-improves-all-skills-karpathy-autoresearch-loop) — skills que se melhoram via loops limitados.
- [NicholasSpisak/second-brain](https://github.com/NicholasSpisak/second-brain) — implementação de referência em Obsidian que provou o fluxo de ingest-to-wiki.
- [Tiago Forte — Building a Second Brain](https://www.buildingasecondbrain.com/) — livro de 2022 que nomeou a categoria.

O que há de novo aqui: hooks + memória + cron integrados ao Claude Code de forma nativa, e `/skill-improve` como skill de primeira classe.
