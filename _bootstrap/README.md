# _bootstrap/

Everything `install.sh` needs to wire your environment. Three subfolders, each with a different target.

| Subfolder | Goes to | How |
|-----------|---------|-----|
| `global/commands/` | `~/.claude/commands/` | Symlinks (each skill becomes a `/skill` you can call in any session) |
| `global/hooks/` | stays here | Invoked by `~/.claude/settings.json` (merged by install.sh) |
| `global/CLAUDE.md` | appended to `~/.claude/CLAUDE.md` | Teaches Claude to read the vault in every session |
| `global/settings.json` | merged into `~/.claude/settings.json` | Registers the four hooks |
| `project/CLAUDE.md` | manual | Template to copy into `{other-project}/.claude/CLAUDE.md` |
| `scripts/*.sh` | OS crontab | Background cron jobs (heartbeat + lint) |

## Idempotency

Re-running `install.sh` is safe: symlinks are replaced in place, the `## Second Brain` marker prevents duplicate CLAUDE.md injection, and cron entries are grep-checked before being added.

## Dependencies

- `bash` (POSIX-ish)
- `jq` (for clean settings.json merge; manual fallback shown if absent)
- `crontab`
- Platform detection (Linux / macOS / WSL) inside `on-notification.sh`

## Extending

- New skill → drop a `.md` into `global/commands/` and re-run `install.sh` (symlink is created automatically).
- New hook → add a script in `global/hooks/` and register it in `global/settings.json`.
- New cron → add a script in `scripts/` and register it in `install.sh` via `add_cron`.

## Portuguese (BR)

Resumo: `install.sh` lê tudo que está em `_bootstrap/` e publica para o `~/.claude/` do usuário. Os scripts são idempotentes, portáveis (Linux/macOS/WSL) e dependem só de bash, jq e crontab.
