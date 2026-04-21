# FAQ

Perguntas comuns, respostas práticas.

## Começando

### "Preciso ser programador para usar isso?"

Não. Você precisa:
1. Copiar-colar 3 comandos no terminal durante a instalação (15 min, uma vez).
2. Digitar slash-commands num chat do Claude Code depois disso.

Sem codar, sem script, sem editar arquivo de config. Se já usou ChatGPT, consegue usar isso.

### "Preciso pagar pelo Claude?"

Sim. Duas opções:
- **API pay-as-you-go** — paga por token usado, a partir de ~$5/mês para uso leve.
- **Assinatura Claude Pro ou Max** — inclui uso do Claude Code. Ver [claude.com/pricing](https://claude.com/pricing).

O starter em si é gratuito e open source (MIT).

### "Quanto tempo leva para instalar?"

- Se já tem Claude Code e `jq` instalados: 2 minutos.
- Do zero (precisa Node.js + Claude Code + `jq`): 15-30 minutos.

### "Posso testar sem instalar nada?"

Não dá. O ponto todo é escrever no seu disco. Leia [docs/pt-br/philosophy.md](philosophy.md) antes para decidir se o modelo faz sentido para você.

---

## Uso

### "Onde ficam minhas notas?"

Na pasta onde você clonou o repo. Estrutura:

- `_sources/` — o que você ingeriu (artigos, PDFs, transcrições).
- `_wiki/` — páginas compiladas do wiki.
- `_learnings/` — insights que você quer lembrar sempre.
- `_decisions/` — decisões com raciocínio.
- `_knowledge/` — pessoal (about-me, goals, projetos).
- `_memory/` — estado do vault + logs.
- `_sessions/` — braindumps brutos.
- `_pipeline/` — tasks e ideias ativas.

Todos arquivos em markdown puro. Abra em qualquer editor.

### "Como o `/ingest` decide o que salvar?"

Mostra resumo + takeaways + conexões primeiro, pede aprovação. Você rejeita, edita, ou aceita. Nada é salvo sem seu OK.

### "E se eu ingerir o mesmo artigo 2 vezes?"

A skill checa por arquivos com mesmo slug e pergunta se quer atualizar ou criar duplicata datada.

### "`/wiki-build` sobrescreve páginas que já existem?"

Não. Propõe mudanças (novas páginas ou updates) e pergunta antes de escrever. Conteúdo existente é mesclado, nunca sobrescrito silenciosamente. `--rebuild` só quando você quer reescrita total (e pede confirmação).

### "Qual a diferença entre `_sources/`, `_wiki/` e `_learnings/`?"

- `_sources/` — o **input bruto**, 1 arquivo por fonte. Tipo: "li este artigo".
- `_wiki/` — o **output compilado**, 1 arquivo por conceito/entidade. Tipo: "tudo que sei sobre X".
- `_learnings/` — **insights acionáveis**, 1 arquivo por "aha moment". Tipo: "a coisa que mudou como trabalho".

### "Como busco no vault?"

Três opções:
1. Perguntar ao Claude: `O que sei sobre X?` — ele lê o `_wiki/` e responde.
2. Usar `grep` / `ripgrep` no terminal: `rg "termo" ~/second-brain`.
3. Abrir a pasta no Obsidian — ganha busca full-text + visão de grafo grátis.

### "Dá para usar com Obsidian?"

Sim. Aponte o Obsidian para a pasta do vault. Obsidian renderiza markdown, visualiza WikiLinks como grafo, dá busca. O starter não usa nenhuma feature específica do Obsidian — é 100% portável.

---

## Automação

### "O que roda automaticamente?"

- **4 hooks** disparam dentro do Claude Code em eventos (prompt, session-end, pre-compact, notification). Só logam e avisam — nunca mexem em conteúdo.
- **2 cron jobs** rodam fora do Claude Code: um diário 07:00 (heartbeat), um semanal segunda 09:00 (lint). Produzem markdown em `_memory/`.

Detalhes em [hooks-and-crons.md](hooks-and-crons.md).

### "Posso desligar a automação?"

Sim, toda ela. Cada hook e cada cron pode ser removido sem quebrar as skills. Ver seção "Desligar partes" em [hooks-and-crons.md](hooks-and-crons.md).

### "Os crons acordam minha máquina às 07:00"

São shell scripts minúsculos (sem LLM, sem rede). Se incomoda, mude o horário via `crontab -e` ou remova.

---

## Privacidade e dados

### "Meu conteúdo vai para a Anthropic?"

Quando você roda uma skill que lê arquivos do vault, esses arquivos são enviados para a API da Anthropic — igual qualquer sessão Claude Code. Quando nada está rodando, nada é enviado.

Os crons rodam localmente e nunca chamam a API.

### "Posso manter arquivos fora do alcance da IA?"

Sim. Coloque fora do vault, ou adicione em `.claude/settings.json` via permissions (ver docs do Claude Code). Ou crie um `_private/` e nunca referencie em prompts.

### "Meus prompts ficam logados?"

Sim, em `_memory/.prompt-log.txt` (local, gitignored). Útil para analisar seus próprios padrões de uso ao longo do tempo. Pode apagar quando quiser ou desligar o hook `UserPromptSubmit`.

---

## Plataforma

### "Funciona no Windows?"

Só via [WSL2](https://learn.microsoft.com/pt-br/windows/wsl/install). Windows nativo não, pois os hooks são scripts bash e os crons usam `crontab` Unix.

WSL2 é gratuito, já vem no Windows 11, 10 minutos para configurar.

### "Funciona no macOS?"

Sim, nativamente. Testado em Apple Silicon e Intel.

### "Funciona no ChromeOS?"

Sim, no container Linux. Ative em Configurações → Desenvolvedores → Linux.

### "E iOS / Android?"

Não. É ferramenta de desktop/laptop. Você pode LER o vault no celular via Obsidian/Dropbox, mas as skills precisam de terminal.

---

## Estendendo

### "Posso adicionar minhas próprias skills?"

Sim. Crie um `.md` em `_bootstrap/global/commands/` e rode `./install.sh`. O symlink é criado e a skill vira `/minha-skill` no Claude Code.

### "Posso customizar os hooks?"

Sim. Edite `_bootstrap/global/hooks/*.sh`. O path do vault é auto-detectado.

### "Posso forkar e fazer meu próprio?"

Por favor. MIT. Atribuição apreciada mas não obrigatória.

### "Como funciona o `/skill-improve`?"

Loop estilo Karpathy de autoresearch:
1. Você gera casos de teste + rubrica juntos com a skill.
2. Ela converte dimensões fracas em checks binários sim/não.
3. Agente muta a skill, testa, mantém melhorias, descarta regressões — limitado por max de iterações (default: 10).
4. Você aprova o diff antes de tocar a skill viva.

Detalhes em [skills-reference.md](skills-reference.md).

---

## Ainda travado?

- [troubleshooting.md](troubleshooting.md) para erros comuns.
- Abra issue no GitHub via template de bug.
- Leia o fonte da skill em `_bootstrap/global/commands/{skill}.md` — é prompt markdown puro, dá para entender e ajustar.
