# Contributing

Thanks for considering a contribution. This project stays useful by staying small — contributions that cut complexity or clarify behavior are especially welcome.

## Ways to contribute

- **Report a bug** — use the bug report template under [.github/ISSUE_TEMPLATE/](.github/ISSUE_TEMPLATE/bug_report.md).
- **Suggest a feature** — open an issue describing the problem before writing code.
- **Improve docs** — typos, unclear passages, missing examples. Low-friction PRs.
- **Add a skill** — see "Adding a skill" below.
- **Improve a skill** — run `/skill-improve` on it locally and submit the diff with the before/after report.
- **Port a translation** — PT-BR docs exist; other languages welcome.

## Development setup

```bash
git clone https://github.com/<your-fork>/second-brain-starter.git
cd second-brain-starter
./install.sh
```

Shell scripts must pass `shellcheck`:

```bash
shellcheck install.sh _bootstrap/global/hooks/*.sh _bootstrap/scripts/*.sh
```

The CI runs this on every PR.

## Adding a skill

1. Create `_bootstrap/global/commands/my-skill.md` with frontmatter:
   ```yaml
   ---
   description: One-line summary of what the skill does.
   ---
   ```
2. Write the skill body as a plain prompt targeting Claude Code. Follow the style of existing skills (`braindump.md` is a good small example).
3. Update:
   - `CLAUDE.md` — add the skill to section 5 (Available skills).
   - `README.md` — add a row to the "12 skills" table.
   - `docs/en/skills-reference.md` — add a full entry with an example output.
   - `docs/pt-br/skills-reference.md` — same in Portuguese.
4. Re-run `./install.sh` to symlink it.
5. Optionally run `/skill-improve _bootstrap/global/commands/my-skill.md` to tune it before opening the PR.

## Commit style

- Present tense, imperative mood: "add X", "fix Y", "remove Z" — not "added" or "fixing".
- One logical change per commit.
- Reference issues: `add foo (#42)`.

## Pull request checklist

- [ ] Every shell script passes `shellcheck`.
- [ ] Docs updated (README, CLAUDE.md, skills-reference in both languages).
- [ ] No breaking changes to install.sh without a migration note.
- [ ] No Anthropic-proprietary paths, names, or credentials committed.
- [ ] `.gitignore` updated if new generated files are produced.

## Code of conduct

Be direct, be kind, assume good faith. Disagreements are healthy; personal attacks aren't tolerated.

## License

By contributing, you agree that your contributions are licensed under the same MIT license as the project.
