# Referência de Skills

Cada skill com comando e exemplo de output real, para você saber o que esperar.

Toda skill é um arquivo markdown em `_bootstrap/global/commands/`. Você pode ler, editar ou melhorar — mudança entra imediatamente.

---

## Setup

### `/init`

Wizard. Personaliza `_knowledge/about-me.md` e `_knowledge/goals.md` em menos de 10 minutos.

**Quando usar:** primeira vez, ou para resetar identidade.

```
/init
```

**Exemplo de output:**

<p align="center">
  <img src="../assets/screenshots/init-wizard.png" alt="Exemplo de output do /init: 5 perguntas interativas que personalizam about-me.md, goals.md e current-state.md" width="720">
</p>

```
Bem-vindo ao seu segundo cérebro.
5 perguntas rápidas para personalizar.

Qual seu nome (ou handle)?
> Alex

Qual sua área principal?
> Criação de conteúdo e marketing

... (3 perguntas a mais)

Pronto. Starter personalizado.

Arquivos atualizados:
- _knowledge/about-me.md
- _knowledge/goals.md
- _memory/current-state.md

Próxima skill para experimentar: /braindump pra capturar o primeiro pensamento.
```

---

## Captura

### `/braindump [texto]`

Captura pensamentos soltos, categoriza, conecta via WikiLinks, desafia inconsistências.

**Quando usar:** pensamento na cabeça que você não quer perder.

```
/braindump Considerando sair de freelance pra fundar agência, mas risco de cashflow me assusta.
```

**Exemplo de output:**
```
Resumo: Tensão entre evolução de carreira (agência) e estabilidade financeira (cashflow de freelance).

Itens acionáveis:
- Alta: quantifique o risco — projeção de cashflow de 6 meses para os 2 caminhos.
- Média: converse com 3 fundadores de agência sobre os primeiros 12 meses.
- Baixa: pesquise modelos agency-as-a-service (pegada de risco menor).

Notas criadas:
- _sessions/2026-04-21-braindump.md (tags #idea, #decision, #career)

Conexões: [[goals]], [[about-me]]

Provocação: Seu goals.md fala "construir fonte de renda sustentável". "Agência vs freelance" não mapeia direto — a pergunta real é sobre volatilidade ou autonomia? Considere reformular.
```

---

### `/ingest [fonte]`

Ingere **uma fonte por vez**. Busca, resume, mostra takeaways, pede aprovação, salva em `_sources/`.

**Quando usar:** leu um artigo, assistiu vídeo, ou escreveu algo longo que quer preservar.

```
/ingest https://www.exemplo.com/artigo-sobre-arquitetura
```

**Exemplo de output:**
```
Ingerindo: "O monolito contra-ataca" — exemplo.com
Fonte: https://www.exemplo.com/artigo-sobre-arquitetura

Resumo (5 linhas):
Autor argumenta que microsserviços adicionaram complexidade sem valor
proporcional para times pequenos. Apresenta 3 casos de volta ao monolito.
Destaca overhead específico do Kubernetes. Posiciona "modular monolith"
como meio-termo. Tom pragmático.

Claims principais:
- Times com menos de 20 engenheiros raramente precisam de microsserviços.
- Monolitos modulares dão 80% do benefício organizacional a 20% do custo.
- Kubernetes é imposto de overhead para startups pré-PMF.

Takeaways acionáveis:
- Auditar arquitetura atual em busca de escolhas "microsserviço por default".
- Considerar modular monolith no próximo greenfield.

Salvar em _sources/? (s/n, ou sugira edições)
> s

Salvo: _sources/2026-04-21-o-monolito-contra-ataca.md

Quer extrair o insight acionável em _learnings/? (s/n)
> s

Salvo: _learnings/modular-monolith-como-default.md
```

---

## Compilação

### `/wiki-build [--rebuild]`

Compila `_sources/` num wiki cruzado em `_wiki/`. Mostra plano, pede aprovação, escreve. Sinaliza contradições.

**Quando usar:** 3+ fontes em tópicos relacionados, quer base consultável.

```
/wiki-build
```

**Exemplo de output:**

<p align="center">
  <img src="../assets/screenshots/wiki-build.png" alt="Exemplo de /wiki-build mostrando páginas propostas, cross-references, contradições sinalizadas — e pedindo aprovação antes de escrever" width="720">
</p>

```
Pronto para compilar: monolito-contra-ataca, microsservicos-anti-padroes,
limites-modulares-go

Páginas wiki propostas (novas):
- _wiki/modular-monolith.md        (de 3 fontes)
- _wiki/microservice-overhead.md   (de 2 fontes)

Atualizações propostas:
- _wiki/kubernetes.md              (adicionar seção sobre overhead em times pequenos)

Cross-refs:
- [[modular-monolith]] ↔ [[microservice-overhead]]
- [[microservice-overhead]] → [[kubernetes]]

Contradições sinalizadas:
- monolito-contra-ataca vs _decisions/2026-03-split-services.md.
  Logado em _wiki/contradictions.md.

Prosseguir? (s/n)
> s

Wiki build completo.
Fontes processadas: 3
Páginas criadas: 2
Páginas atualizadas: 1
Contradições sinalizadas: 1

Próximo:
- Começar pela _wiki/index.md
- Rode /lint para verificar links
```

---

## Ritmo diário

### `/daily-briefing`

Resumo matinal. Projetos ativos, decisões recentes, prioridades, saúde do vault.

**Quando usar:** começo de cada dia.

```
/daily-briefing
```

**Exemplo de output:**
```
Briefing — 2026-04-21

Estado atual:
Foco principal da semana é lançar v1 da ferramenta de newsletter.
Secundário: fechar projeto de cliente X.

Trabalho ativo:
| Projeto          | Fase  | Próximo passo                     | Bloqueio |
|------------------|-------|-----------------------------------|----------|
| newsletter-tool  | MVP   | Fluxo de assinatura Stripe        | nenhum   |
| client-x-site    | QA    | Auditoria de performance          | nenhum   |

Decisões recentes (7 dias):
- 2026-04-19: Resend ao invés de Postmark para emails (custo).
- 2026-04-18: Adiar i18n até ter 50 clientes pagantes.

Prioridades do dia:
1. Wire Stripe — newsletter-tool — trava beta pago
2. Auditoria — client-x — entrega sexta
3. Update semanal — outreach — hábito

Saúde do vault: 9/10.

Alerta direto: newsletter-tool sem commits há 3 dias. Pausa proposital ou drift?
```

---

### `/weekly-review`

Reflexão semanal. Progresso por projeto, padrões, ajustes, top 3 da semana seguinte.

**Quando usar:** toda segunda, ou no fim de semana.

```
/weekly-review
```

**Exemplo de output (resumido):**
```
Revisão Semanal — 2026-04-21

Resumo: sólido em newsletter-tool. Perdi 2 dias com scope creep do client-x.

Portfólio:
| Projeto         | Fase | O que avançou                      | No prazo? |
|-----------------|------|------------------------------------|-----------|
| newsletter-tool | MVP  | Auth + signup prontos              | sim       |
| client-x-site   | QA   | 70% da auditoria, travada no LCP   | atrasado  |

Decisões: Resend, adiar i18n.
Learnings: Modular monolith como default.

O que funcionou: dias de deep work na Ter/Qui + /daily-briefing todo dia.
O que não: scope creep do client-x sem tratamento por 4 dias.

Ajustes: 1h segunda pra escopar restante do client-x.

Top 3 próxima semana:
1. Enviar newsletter-tool MVP para lista beta (8 testadores).
2. Fechar auditoria client-x e entregar.
3. Uma sessão /content-idea pro lançamento.

Alerta direto: pipeline de conteúdo vazio. Nenhum draft pro lançamento em 14 dias.
```

---

### `/focus [projeto]`

Carga cirúrgica de contexto. Leitura mínima, máximo sinal.

**Quando usar:** vai trabalhar num projeto específico, quer Claude orientado rápido.

```
/focus newsletter-tool
```

**Exemplo de output:**
```
Foco: newsletter-tool

Fase: MVP
Última sessão: 2026-04-19

Contexto:
Auth e signup shipados. Wire do Stripe é o próximo — porteiro do beta pago.
Sem bloqueios, mas retry logic do webhook precisa teste cuidadoso.

Próximo passo:
Implementar handler de webhook Stripe em /api/stripe/webhook com verificação de assinatura.

Gotchas ativos:
- Domínio do Resend precisa estar verificado antes de entregar.
- Test clock do Stripe precisa offset de 1 hora para reproduzir renewals.

Pendências:
- Finalizar UI de billing (da sessão de sexta).

Contexto carregado. Pode começar.
```

---

## Fechar / Retomar

### `/end-session [projeto]`

Fecha sessão. Classifica trabalho, atualiza work-log, salva gotchas, decisions, current-state, limpa flags.

**Quando usar:** fim de toda sessão.

```
/end-session newsletter-tool
```

**Exemplo de output:**

<p align="center">
  <img src="../assets/screenshots/end-session.png" alt="Exemplo de output do /end-session: fechamento mostrando o que foi feito, o que foi salvo no vault, pendências, próximos passos, e fontes não ingeridas" width="720">
</p>

```
Sessão fechada — 2026-04-21

Projeto: newsletter-tool | Tipo: feature

O que fizemos:
- Wire do handler de webhook Stripe com verificação de assinatura.
- Retry logic com exponential backoff.
- Testado contra eventos do Stripe CLI.

Salvo no vault:
- work-log: feature — handler de webhook completo
- gotchas: 1 novo (offset do test clock do Stripe)
- decisions: 0 novas
- learnings: 0 novos

Pendências:
- UI de billing em 70%.

Próximos passos:
- Completar billing.tsx.
- Convidar 8 beta testers.
- Escrever draft do tweet de lançamento.

Fontes não ingeridas (1):
- https://stripe.com/docs/webhooks/signatures — você consultou 2x hoje.
> Rode /ingest ou responda "ingerir tudo".
```

---

### `/session-handoff`

Escreve `HANDOFF.md` (e `SESSION-CHECKPOINT.md` opcional) para retomar sem re-descoberta.

**Quando usar:** parando no meio de task e amanhã precisa do contexto exato.

```
/session-handoff
```

**Exemplo de output:**
```
HANDOFF.md criado em /home/voce/second-brain.

Objetivo: Completar UI de billing para MVP do newsletter-tool.

Feito:
- Handler de webhook Stripe com verificação de assinatura.
- Retry com exponential backoff.

Em andamento (retome aqui):
- billing.tsx: card 3 de 5 completo. Próximo: componente CancelSubscription (linhas 120-180).

O que NÃO funcionou:
- Tentei redirect para customer portal server-side — bloqueado por portal Stripe não configurado em test mode. Configure antes ou use session redirect client-side.

Próximos passos:
1. billing.tsx linha 120 — implementar CancelSubscription
2. billing.tsx linha 180 — conectar em Stripe billing_portal.sessions.create
3. Rodar: npm test

Gitignored: HANDOFF.md adicionado ao .gitignore.
```

---

## Output

### `/content-idea [tema]`

Gera 3-7 ideias de conteúdo ancoradas no SEU material real do vault.

**Quando usar:** precisa postar, escrever, ou produzir conteúdo com raízes no que você realmente fez.

```
/content-idea Post LinkedIn sobre aprendizados construindo newsletter-tool
```

**Exemplo de output (resumido):**
```
Ideias de conteúdo — 2026-04-21

Contexto usado:
Lido: _learnings/modular-monolith-como-default.md,
      _knowledge/projects/newsletter-tool/work-log.md (últimas 5),
      _decisions/2026-04-19-resend-over-postmark.md

Ideia 1: "A decisão de $300 em email que me poupou 20 horas"
| Formato   | Post LinkedIn |
| Plataforma| LinkedIn      |
| Ângulo    | A matemática de custo/tempo de Resend vs Postmark — números concretos do newsletter-tool |
| Por que funciona | Devs adoram matemática específica em dólar/hora |

Outline:
1. Hook: "Quase paguei 3x mais por email transacional."
2. Contexto: Construindo newsletter-tool, precisava de delivery transacional.
3. Aprendi: Modelos de preço diferem — o free tier do Resend cobriu meu caso 4 meses a mais.
4. Insight: Preço de API de email raramente é comparado porque é chato. Não deveria ser.
5. CTA: Qual a escolha chata que você está pagando caro?

Fonte no vault: [[2026-04-19-resend-over-postmark]]

---

Ideia 2: "O erro de webhook Stripe que custou um fim de semana"
... (resumido)

Qual quer desenvolver? Posso expandir o outline ou escrever o rascunho.
```

---

## Manutenção

### `/lint`

Audita saúde do vault: frontmatter, notas obsoletas, links quebrados, órfãos, integridade do wiki.

**Quando usar:** vault parece bagunçado; após refactors grandes; a cada semanas.

```
/lint
```

**Exemplo de output:**
```
Relatório de lint — 2026-04-21

Score geral: 8/10

| Check                  | Defeitos | Avisos | Status     |
|------------------------|----------|--------|------------|
| Frontmatter obrigatório| 2        | —      | FALHOU     |
| Notas active obsoletas | —        | 3      | ATENÇÃO    |
| WikiLinks quebrados    | 1        | —      | FALHOU     |
| Arquivos órfãos        | —        | 4      | ATENÇÃO    |
| Integridade do wiki    | 0        | 0      | OK         |

Defeitos críticos:
1. _learnings/early-pricing-signals.md — campo `status` ausente
2. _decisions/2026-03-split-services.md — campo `created` ausente
3. _wiki/modular-monolith.md — link quebrado [[pagina-inexistente]]

Ações prioritizadas:
1. Adicionar frontmatter em 2 arquivos (5 min).
2. Corrigir WikiLink em _wiki/modular-monolith.md.
3. Revisar 3 notas active obsoletas — atualizar ou marcar completed.
```

---

### `/justify [proposta]`

Cruza uma proposta/decisão contra o vault. Classifica registros anteriores como **precedente**, **contradição** ou **adjacente** e emite veredicto (PROSSEGUIR / AJUSTAR / BLOQUEADO). Grep puro sobre `_decisions/`, `_learnings/`, `_wiki/` — sem retrieval semântico, sem dependência externa.

**Quando usar:** antes de `/rfc`, antes de `/braindump` em decisões não-triviais, ou sempre que suspeitar que uma ideia colide com ADR existente.

**Comando:**
```
/justify "Adotar Resend no lugar de Postmark para emails transacionais no newsletter-tool"
```

**Exemplo de output:**
```
Proposta sob análise

> Adotar Resend no lugar de Postmark para emails transacionais no newsletter-tool.

Precedentes
- ✓ ADR 2026-04-19-resend-over-postmark — já escolheu Resend por custo.

Contradições
- (nenhuma)

Contexto adjacente
- · _learnings/email-deliverability-baseline.md — fixa métricas-alvo independente do provider.

Veredicto: PROSSEGUIR — precedente direto, nenhum ADR ativo contradiz.

Próxima ação: linkar a nova implementação ao ADR existente; sem novo arquivo de decisão.
```

---

### `/predict [projeto] [k=N]`

Prediz as próximas tarefas mais prováveis de um projeto, ranqueadas por confiança, com base no `work-log` + `roadmap` + `state`. Heurística pura — sem especulação além do que os arquivos dizem.

**Quando usar:** planejando uma sessão e querendo sinal sobre o que o próprio projeto implica que deve vir.

**Comando:**
```
/predict newsletter-tool k=5
```

**Exemplo de output:**
```
Predictions: newsletter-tool

Distribuição de tipos (últimas 12 entradas):
- feature: 5 entries
- fix: 3 entries
- chore: 2 entries
- task: 2 entries

Cadência: hot (4 dias entre entradas recentes)

Sinais do state: Fase 2 — POC; next step "wire Resend webhook"; sem blocker.

Top 3 predições para a próxima sessão:

| # | Tipo | Descrição | Confiança | Fonte |
|---|------|-----------|-----------|-------|
| 1 | feature | Wire Resend webhook ponta-a-ponta | 85% | state.md next-step |
| 2 | task | Review/merge PR #14 aberta | 60% | state.md PRs |
| 3 | fix | Reproduzir sender-id 422 do log de ontem | 40% | work-log recent fix pattern |

Caveats: heurística — humano confirma antes de executar.
```

---

### `/skill-improve [caminho]`

Loop de autoresearch estilo Karpathy: muta, testa, pontua, mantém ganhos.

**Quando usar:** skill parece abaixo do potencial; suspeita que falta cobrir edge cases.

```
/skill-improve _bootstrap/global/commands/content-idea.md
```

**Exemplo de output (resumido nas 3 fases):**
```
# Fase 1 — Setup
Lido: content-idea.md
Gerados 8 casos de teste (arg vazio, tema específico, multi-plataforma, check de dados sensíveis, etc.)
Rubrica (1-5): concretude, veracidade, unicidade-de-ângulo, ancoragem-no-vault, adequação-ao-formato

Baseline:
- concretude: 3.2 / 5
- veracidade: 4.8 / 5
- unicidade-de-ângulo: 2.9 / 5     ← fraca
- ancoragem-no-vault: 3.4 / 5
- adequação-ao-formato: 4.1 / 5

Dimensão fraca convertida em binário:
- unicidade-de-ângulo → "Cada ideia referencia um fato/decisão específico do vault, não um claim genérico?"

Limites: max 10 iterações, para se 3 sem melhoria, dry-run ligado.

Prosseguir para Fase 2? (s/n)
> s

# Fase 2 — Loop (autônomo, limitado)
Iter 1: adicionou requisito de "citação de fonte" em cada ideia → mantido (binário 60% → 75%)
Iter 2: hook mais apertado → mantido (75% → 82%)
Iter 3: exemplo negativo ("não 'Neste post vou falar...'") → mantido (82% → 88%)
Iter 4: sem melhoria, descartado
...
Parou após 6 iterações.

# Fase 3 — Debrief
Re-scored na rubrica original:
- concretude: 3.2 → 4.1 (+0.9)
- unicidade-de-ângulo: 2.9 → 4.3 (+1.4)  ← maior ganho
- taxa binária: 60% → 92%

Diff mostrado. Aplicar na skill viva? (s/n)
> s

Relatório: _learnings/skill-improve-content-idea-2026-04-21.md
```

---

## Fonte completa

Toda skill é prompt markdown puro. Para entender exatamente o que faz:

```bash
cat _bootstrap/global/commands/<nome-da-skill>.md
```

Você pode editar qualquer uma — muda entra na próxima invocação.
