# ai-dev-kit — design

## Goal
One repo, cloned or `curl`-bootstrapped into any project, that wires it for
AI-assisted development across **Claude Code** (Claude), **OpenAI Codex** (GPT),
and the **GitHub Copilot** cloud agent (any model) — from a single set of shared,
committed files.

## Principles
1. **One source of truth.** Instructions live once in `AGENTS.md` and propagate to
   all three agents (see `single-source-of-truth.md`). No manual duplication.
2. **Idempotent + reversible.** Re-running updates only the kit's own files (tracked
   in `.ai-dev-kit-manifest`); a pre-existing user file is handled per `--on-conflict`
   (prompt/backup/skip/overwrite). Managed marker blocks (`ai-dev-kit:<id>`) preserve
   surrounding edits; backups go to `*.adk-bak`; `--dry-run` previews. `uninstall.sh`
   reverses everything, restoring backed-up originals.
3. **Explicit separation.** Shared/committed (repo files) vs. user-owned
   (`AGENTS.md`, incl. its Standards section) vs. generated/gitignored (`graphify-out/`).
4. **No invented config.** We only write files each tool actually reads. Where a
   tool has no file (e.g. Copilot's model picker), we print guidance instead.

## Pipeline (`setup.sh`)
detect OS/arch/pkg-mgr → choose agents + models → ask about Superpowers →
verify selected agent CLIs are present (assumed installed) → install Superpowers
(if chosen) → install graphify + build graph → scaffold config + slash commands →
print summary.

## Layout
```
setup.sh / bootstrap.sh        entry points (configure a project)
uninstall.sh                   reverse setup for a project (restore/remove)
lib/*.sh                       helpers + per-agent configure modules + scaffolding
  commands.sh                  the shared command list (used by scaffold + uninstall)
  mcp.sh + mcp_upsert.py       register MCP servers per agent (opt-in tools)
  install_ast_grep.sh          ast-grep CLI installer (opt-in)
  hooks_merge.py               merge Claude guardrail hooks into settings.json (opt-in)
templates/                     files rendered into the target project
  AGENTS.md.tmpl               the source of truth, incl. Standards (with placeholders)
  claude/ codex/ copilot/      per-agent config templates
  claude/hooks/*.py            guardrail hook scripts (deny secrets / dangerous cmds)
  commands/                    reusable command bodies → native slash commands per tool
docs/                          this design, the SoT matrix, Superpowers notes, related-tools
examples/filled/               a worked example

Optional tools (ast-grep, Grep/journal/Serena MCP, Claude hooks) are opt-in via
`--with-*` flags / prompt; MCP additions are tracked in `.ai-dev-kit-mcp` so
uninstall removes exactly the kit's entries (preserving your other MCP servers).
examples/filled/               a worked example
```

## Token conventions in templates
- `@@VAR@@` — substituted by `setup.sh` (model names, reasoning effort, project name, date).
- `{{PLACEHOLDER}}` — left intact for the **user** to fill (standards, formats).

## Requirements coverage
| Req | Where |
|---|---|
| 1. Latest Superpowers | `configure_*.sh` (prompted install) + `docs/superpowers.md` |
| 2. graphify install + run | `lib/install_graphify.sh` |
| 3. Standards (code/commit/PR/tools/tests/device) | `AGENTS.md` → **Standards** section |
| 4. In-depth testing & repeatable tasks | `/deep-test`, `/repeatable-task` (`templates/commands/`) |
| 5. PR review/re-review/report/fix/description | `/pr-review` (`templates/commands/pr-review.md`) |
| 6. Progress report | `/progress-report` (`templates/commands/progress-report.md`) |

## Known constraints
- macOS + Linux (bash). Windows would need WSL or a Node port of `setup.sh`.
- Codex project config loads only after you "trust" the project.
- Copilot model availability is plan/admin-gated.
- The rich graphify build is agent-orchestrated (`/graphify .`); the headless
  `graphify update .` (deterministic AST, no API key) is used for unattended setup.
- Slash commands per tool: Claude `.claude/commands/*.md` (project) and Copilot
  `.github/prompts/*.prompt.md` (project, **IDE chat only** — the Copilot cloud agent
  ignores prompt files and follows `AGENTS.md`). Codex prompts are **user-global**
  (`~/.codex/prompts/`, no project scope), invoked `/prompts:<name>`, and need a
  restart; Codex is migrating prompts → skills.
