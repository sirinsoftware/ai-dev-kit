# ai-dev-kit

Bootstrap any project for AI-assisted development across **Claude Code** (Claude
models), **OpenAI Codex** (GPT models), and the **GitHub Copilot** cloud agent
(any model) — from one shared set of files.

One `AGENTS.md` drives all three agents. The setup script verifies the agent CLIs
you choose are present, optionally installs [Superpowers](docs/superpowers.md) per
agent, installs [graphify](https://pypi.org/project/graphifyy/) and builds a code
knowledge graph, and scaffolds each agent's native config plus a reusable prompt
library.

> **Prerequisites:** the Claude Code, Codex, and/or Copilot CLIs you plan to use
> are assumed already installed — the script verifies them and warns if one is
> missing, but does not install them. It *does* install graphify (+ `uv`) and the
> Superpowers plugins.

## Quickstart

**From inside the project you want to configure:**

```bash
# Option A — clone and run
git clone https://github.com/VM-development/ai-dev-kit ~/.ai-dev-kit
~/.ai-dev-kit/setup.sh .

# Option B — one-liner (clones to ~/.ai-dev-kit, then configures the current dir)
curl -fsSL https://raw.githubusercontent.com/VM-development/ai-dev-kit/main/bootstrap.sh | bash
```

You'll be asked which agents to enable, which models to default to, and whether to
install Superpowers and build the graph. Non-interactive:

```bash
~/.ai-dev-kit/setup.sh . --yes --agents=claude,codex,copilot \
  --claude-model=claude-opus-4-8 --codex-model=gpt-5.5 --no-graphify
```

> Update `VM-development/ai-dev-kit` to your own fork/repo, and adjust the model
> defaults in `setup.sh` as model lineups change.

## What it writes into your project

| File | For | Purpose |
|---|---|---|
| `AGENTS.md`                                   | all      | **Single source of truth** (you fill it in) |
| `CLAUDE.md`                                   | Claude   | `@AGENTS.md` import + managed notes |
| `.claude/settings.json`                       | Claude   | model + schema |
| `.codex/config.toml`                          | Codex    | model + reasoning effort |
| `.github/copilot-instructions.md`             | Copilot  | pointer to `AGENTS.md` |
| `.github/workflows/copilot-setup-steps.yml`   | Copilot  | cloud-agent environment |
| `docs/ai-prompts/*`                           | all      | reusable prompt library |
| `.gitignore` (appended)                       | —        | ignores `graphify-out/`, `*.local.*`, backups |

See [`docs/single-source-of-truth.md`](docs/single-source-of-truth.md) for exactly
how each agent reads its config, and [`docs/DESIGN.md`](docs/DESIGN.md) for the
full design.

## After setup
1. Fill in `AGENTS.md` and `docs/ai-prompts/00-standards.md`.
2. Codex: open the project once and **trust** it so `.codex/config.toml` loads.
3. Copilot: commit `copilot-setup-steps.yml` to the **default branch**; pick the
   model in the task model-picker.
4. After code changes: `graphify update .`

## Options
`setup.sh [TARGET_DIR] [--agents=…] [--claude-model=…] [--codex-model=…]
[--codex-reasoning=…] [--superpowers|--no-superpowers] [--no-graphify]
[--graphify-backend=…] [-y|--yes] [--quiet] [--dry-run]`. Run `./setup.sh --help`.

## Safe to re-run
Installs are gated on `command -v`; generated content lives in marker blocks that
are replaced (not duplicated); any pre-existing file is backed up once to
`*.adk-bak`. Try `./setup.sh . --dry-run` to preview.
