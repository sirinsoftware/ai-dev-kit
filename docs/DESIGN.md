# ai-dev-kit — design

## Goal
One repo, cloned or `curl`-bootstrapped into any project, that wires it for
AI-assisted development across **Claude Code** (Claude), **OpenAI Codex** (GPT),
and the **GitHub Copilot** cloud agent (any model) — from a single set of shared,
committed files.

## Principles
1. **One source of truth.** Instructions live once in `AGENTS.md` and propagate to
   all three agents (see `single-source-of-truth.md`). No manual duplication.
2. **Idempotent setup.** `setup.sh` is safe to re-run: `command -v` gates installs,
   managed marker blocks (`ai-dev-kit:<id>`) preserve user edits, files are backed
   up once to `*.adk-bak`, and `--dry-run` shows planned actions.
3. **Explicit separation.** Shared/committed (repo files) vs. user-owned
   (`AGENTS.md`, `00-standards.md`) vs. generated/gitignored (`graphify-out/`).
4. **No invented config.** We only write files each tool actually reads. Where a
   tool has no file (e.g. Copilot's model picker), we print guidance instead.

## Pipeline (`setup.sh`)
detect OS/arch/pkg-mgr → choose agents + models → ask about Superpowers →
verify selected agent CLIs are present (assumed installed) → install Superpowers
(if chosen) → install graphify + build graph → scaffold config + prompt library →
print summary.

## Layout
```
setup.sh / bootstrap.sh        entry points
lib/*.sh                       helpers + per-agent configure modules + scaffolding
templates/                     files rendered into the target project
  AGENTS.md.tmpl               the source of truth (with placeholders)
  claude/ codex/ copilot/      per-agent config templates
  prompts/                     the reusable prompt library (→ docs/ai-prompts/)
docs/                          this design, the SoT matrix, Superpowers notes
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
| 3. Standards prompts (code/commit/PR/tools/tests/device) | `templates/prompts/00-standards.md.tmpl` |
| 4. In-depth testing & repeatable tasks | `prompts/10-algorithm-deep-test.md`, `11-repeatable-task.md` |
| 5. PR review/re-review/report/fix/description | `prompts/20-pr-review.md` |
| 6. Progress report | `prompts/30-progress-report.md` |

## Known constraints
- macOS + Linux (bash). Windows would need WSL or a Node port of `setup.sh`.
- Codex project config loads only after you "trust" the project.
- Copilot model availability is plan/admin-gated.
- The rich graphify build is agent-orchestrated (`/graphify .`); the headless
  `graphify update .` (deterministic AST, no API key) is used for unattended setup.
