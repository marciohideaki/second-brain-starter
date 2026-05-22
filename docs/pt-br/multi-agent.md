# Suporte multi-agente

O starter foi desenhado primariamente para Claude Code, que oferece a superfície mais rica de automação (4 hooks de evento + SSOT auto-lido + slash-commands nativos). Outros agentes têm adapters em níveis diferentes de maturidade.

## Matrix de compatibilidade

| Capacidade | [Claude Code](https://docs.anthropic.com/claude-code) | [Cursor](https://cursor.com) | [Gemini CLI](https://github.com/google-gemini/gemini-cli) | [Codex CLI](https://github.com/openai/codex) | Antigravity |
|-----------|-------------|--------|------------|-----------|-------------|
| SSOT auto-lido ao abrir sessão | ✅ `CLAUDE.md` | ✅ `~/.cursor/rules/*.mdc` | ✅ `GEMINI.md` | ✅ `AGENTS.md` | ✅ `AGENTS.md` |
| Skills como slash-commands | ✅ `/braindump` etc. | ❌ linguagem natural | ⚠️ TOML manual | ❌ linguagem natural | ❌ linguagem natural |
| Hook `UserPromptSubmit` | ✅ | ❌ | ⚠️ via MCP | ❌ | ⚠️ via MCP |
| Hook `SessionEnd` | ✅ | ❌ | ⚠️ via MCP | ❌ | ⚠️ via MCP |
| Hook `PreCompact` | ✅ | ❌ | ❌ | ❌ | ❌ |
| Hook `Notification` | ✅ | ❌ | ❌ | ❌ | ❌ |
| Cron jobs (heartbeat + lint) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Status geral | **estável** | **funcional** | **beta** | **funcional** | **leve** |

## Como instalar cada um

```bash
./install.sh                      # default: Claude Code
./install.sh --agent=cursor       # Cursor (funcional)
./install.sh --agent=gemini-cli   # Gemini CLI (beta — SSOT + cron, commands manual)
./install.sh --agent=codex        # Codex CLI (AGENTS.md + skills Codex + cron)
./install.sh --agent=antigravity  # Antigravity (AGENTS.md + cron)
```

Pode instalar múltiplos adapters ao mesmo tempo — cada um escreve em local específico (`~/.claude/`, `~/.cursor/`, `~/.gemini/`, `AGENTS.md`), sem conflito.

## Como cada agente lida com skills

### Claude Code
Slash-commands nativos: `/braindump "meu pensamento"`. Sem atrito.

### Cursor
Rules com `alwaysApply: false` carregadas por match de descrição. Invoque em linguagem natural:
```
Rode a skill braindump: estou empatado entre ideias.
```
Cursor reconhece a rule pela descrição e aplica as instruções da skill.

### Gemini CLI
GEMINI.md é lido no start, mas as skills ainda não foram convertidas para TOML. Por enquanto, referencie manualmente:
```
Siga a abordagem de _bootstrap/global/commands/braindump.md neste texto: ...
```

### Codex CLI
AGENTS.md é lido no start, e cada skill é instalada em `~/.codex/skills/<prefix>-<nome>`. Invoque pelo nome:
```
Use $meubrain-braindump on this thought: ...
```

### Antigravity
AGENTS.md é lido no start. Invoque skills por linguagem natural até existir wrapper MCP nativo.

## Por que hooks só funcionam no Claude Code

Os 4 hooks (`UserPromptSubmit`, `SessionEnd`, `PreCompact`, `Notification`) são feature específica do Claude Code. Disparam em eventos internos do runtime — logar prompts, sinalizar estado não-salvo, preservar snapshot pré-compactação, e pingar ao fim de operações longas.

- **Cursor** não tem hook system.
- **Gemini CLI** tem extensions MCP. Comportamento similar a `UserPromptSubmit`/`SessionEnd` pode ser emulado via servidor MCP, mas não 1:1.
- **Codex CLI** não tem equivalente.
- **Antigravity** expõe capacidades via ferramentas MCP. Um servidor MCP feito pela comunidade cobriria alguns eventos.

**Consequência prática:** em qualquer agente que não seja Claude Code, **você perde continuidade automática de sessão**. Para compensar:

- Rode `/end-session` (ou "rode a skill end-session") explicitamente ao fim de cada sessão.
- Cheque `_memory/heartbeat-latest.md` e `_memory/lint-latest.md` manualmente — ainda são escritos pelo cron do SO.
- Saiba que `_memory/current-state.md` fica obsoleto se você esquecer o `/end-session`.

## Contribuindo novos adapters ou melhorando stubs

Ver [_bootstrap/adapters/README.md](../../_bootstrap/adapters/README.md) para o contrato. Cada adapter tem README listando o que falta e como contribuir.

PRs da comunidade mais esperadas:

1. **Gemini CLI: skills → comandos TOML.** Converter cada um dos 12 `.md` em `~/.gemini/commands/<nome>.toml`.
2. **Gemini CLI: servidor MCP para hooks.** Um MCP server leve expondo `SessionEnd`-like fecharia o gap de continuidade.
3. **Antigravity: wrappers MCP.** Envolver cada skill como ferramenta MCP para aparecer nativamente no tool picker.
4. **Codex CLI: suporte de ciclo de vida parecido com hooks.** O adapter já instala skills Codex; automação de continuidade depende de um futuro mecanismo de hooks.

## Quando não vale se preocupar com multi-agente?

Se Claude Code atende, fique com ele. O suporte multi-agent existe para quem:

- Já está comprometido com outro agente para o trabalho diário.
- Quer testar o pattern sem trocar IDE/CLI.
- Está construindo o próprio agente e quer uma estrutura de vault de referência.

Rodar o mesmo vault em múltiplos agentes é suportado mas cria atrito — cada agente tem forças sutilmente diferentes. Escolha um primário e use os outros para experimentos.
