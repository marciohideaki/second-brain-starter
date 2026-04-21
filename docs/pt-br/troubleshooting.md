# Troubleshooting

Quando algo quebra, veja aqui primeiro.

## Problemas de instalação

### `./install.sh: Permission denied`

```bash
chmod +x install.sh
./install.sh
```

### `jq: command not found`

Instale:

| SO | Comando |
|----|---------|
| Ubuntu / Debian / WSL | `sudo apt install jq` |
| Fedora / RHEL | `sudo dnf install jq` |
| macOS | `brew install jq` |

Re-rode `./install.sh`.

### `crontab: command not found`

- **Linux/macOS:** geralmente já vem. No Linux: `sudo apt install cron`.
- **WSL:** `crontab` existe mas o daemon não sobe por default. Inicie:
  ```bash
  sudo service cron start
  ```
  Para subir automático no WSL: [guia](https://askubuntu.com/questions/1405393/why-cron-not-starting-in-wsl).

### `git: command not found`

| SO | Comando |
|----|---------|
| Ubuntu / Debian / WSL | `sudo apt install git` |
| Fedora / RHEL | `sudo dnf install git` |
| macOS | `brew install git` ou instalar [Xcode Command Line Tools](https://developer.apple.com/xcode/) |

### Instalação terminou mas não vejo skills no Claude Code

1. Reinicie a sessão do Claude Code. Skills carregam no start.
2. Verifique os symlinks:
   ```bash
   ls -la ~/.claude/commands/ | grep -E "(init|braindump|ingest)"
   ```
3. Se nada aparece, re-rode `./install.sh`.

### `~/.claude/settings.json` ficou bagunçado

`install.sh` faz backup em `~/.claude/settings.json.bak`. Restaure:

```bash
cp ~/.claude/settings.json.bak ~/.claude/settings.json
```

Depois re-rode `./install.sh`.

---

## Problemas com hooks

### "Hooks não disparam"

1. Checar entradas em `~/.claude/settings.json`:
   ```bash
   grep -E "UserPromptSubmit|SessionEnd|PreCompact|Notification" ~/.claude/settings.json
   ```
2. Scripts executáveis:
   ```bash
   chmod +x /caminho/para/second-brain/_bootstrap/global/hooks/*.sh
   ```
3. Paths resolvidos (sem `{VAULT}` literal):
   ```bash
   grep "{VAULT}" ~/.claude/settings.json
   ```
   Se match, re-rode `./install.sh`.

### Hooks lentos / timeout

Timeout padrão é 5s. Se disco lento ou vault grande, aumente em `~/.claude/settings.json`:

```json
"timeout": 10
```

### Prompt log enorme

`_memory/.prompt-log.txt` cresce com cada prompt. Gitignored mas ocupa disco. Rotacione:

```bash
mv _memory/.prompt-log.txt _memory/.prompt-log-$(date +%Y%m%d).txt
```

Ou desligue o `UserPromptSubmit` hook em `~/.claude/settings.json`.

---

## Problemas com cron

### `crontab -l` vazio após instalação

Re-rode `./install.sh`. Se ainda falhar, adicione manual:

```bash
crontab -e
```

Cole:
```
0 7 * * * bash /caminho/absoluto/second-brain/_bootstrap/scripts/daily-heartbeat.sh >> /caminho/absoluto/second-brain/.logs/daily-heartbeat.log 2>&1
0 9 * * 1 bash /caminho/absoluto/second-brain/_bootstrap/scripts/weekly-vault-lint.sh >> /caminho/absoluto/second-brain/.logs/weekly-vault-lint.log 2>&1
```

Substitua `/caminho/absoluto/second-brain` pelo path real.

### Cron não roda no WSL

WSL não sobe cron por default. Ou:
- Manual: `sudo service cron start`
- Automático: [guia WSL cron](https://askubuntu.com/questions/1405393/why-cron-not-starting-in-wsl).

### Cron roda mas com erro

Ver logs:

```bash
cat .logs/daily-heartbeat.log
cat .logs/weekly-vault-lint.log
```

Erro mais comum: path mudou depois do install. Re-rode `./install.sh` (idempotente).

---

## Problemas com skills

### "Skill not found: /init"

Symlink não foi criado, OU você não reiniciou a sessão do Claude Code.

```bash
ls -la ~/.claude/commands/init.md
# se não existe:
cd /caminho/para/second-brain && ./install.sh
```

Depois reinicie o Claude Code.

### "Skill rodou mas não fez nada"

Leia o fonte em `_bootstrap/global/commands/{skill}.md`. Toda skill é prompt markdown. Se exige argumento (ex: `/focus` precisa nome de projeto), ela pergunta. Responda e tente de novo.

### "Output da skill saiu errado"

Duas opções:
1. Edite o markdown da skill para afinar. Mudança entra imediatamente (symlink aponta pro seu arquivo).
2. Rode `/skill-improve <caminho>` para loop sistemático de melhoria.

### "`/wiki-build` travou no meio"

A skill grava candidatos em `_memory/.skill-improve/` antes de commit. Checa essa pasta para estado parcial. Pode re-rodar `/wiki-build` — não duplica.

---

## Problemas de estado do vault

### "`/lint` reporta muitos defeitos críticos"

Rode `/lint` para ver. Então:
- **Frontmatter ausente:** adicione `tags`, `status`, `created`. A maioria das skills escreve automático; casos manuais precisam ajuste.
- **WikiLinks quebrados:** arquivo alvo deletado ou typo. Corrija ou remova.
- **Notas obsoletas (active + updated > 30 dias):** mude `status: completed` ou `archived`, ou atualize.

### "current-state.md muito desatualizado"

Rode `/end-session` para refrescar. Ou `/weekly-review` para re-sync completo.

### "Perdi o rumo do que tem no vault"

Rode `/daily-briefing`. Ou abra a pasta no Obsidian e use o grafo.

---

## Desinstalar

```bash
# 1. Remove symlinks de skills
rm ~/.claude/commands/{braindump,ingest,focus,daily-briefing,weekly-review,end-session,session-handoff,content-idea,lint,init,wiki-build,skill-improve}.md

# 2. Hooks de ~/.claude/settings.json
#    (ou restaure o backup: cp ~/.claude/settings.json.bak ~/.claude/settings.json)

# 3. Crons
crontab -e
# apague as 2 linhas do heartbeat e lint

# 4. Bloco "## Second Brain" de ~/.claude/CLAUDE.md
#    (abra no editor e apague)

# 5. (Opcional) Apague a pasta do vault
#    rm -rf ~/second-brain
```

---

## Ainda quebrado?

- Abra issue no GitHub usando o template.
- Inclua: SO, versão Claude Code (`claude --version`), output do comando que falha.
