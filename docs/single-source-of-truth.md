# Single source of truth: one `AGENTS.md`, three agents

You write agent instructions **once** in `AGENTS.md`. Here is exactly how each tool
picks them up (verified against current docs, mid-2026):

| Agent | File it reads | How `AGENTS.md` reaches it |
|---|---|---|
| **OpenAI Codex** | `AGENTS.md` (native) | Read directly. Codex walks from the git root down to the cwd, concatenating `AGENTS.md` files (deeper files win). Loads up to `project_doc_max_bytes` (32 KiB default). |
| **GitHub Copilot** (cloud agent) | `AGENTS.md` + `.github/copilot-instructions.md` | `AGENTS.md` read directly (root or nested; nearest wins). We also write a thin `.github/copilot-instructions.md` that points to it so Copilot chat / code review (which key off that file) stay aligned. Copilot also honors path-scoped `.github/instructions/*.instructions.md` (most specific path wins); ai-dev-kit doesn't scaffold those by default. |
| **Claude Code** | `CLAUDE.md` (does **not** read `AGENTS.md`) | `CLAUDE.md`'s first line is `@AGENTS.md` — an eager import. ai-dev-kit then appends a small managed "Claude notes" block below it. |

## Why `@AGENTS.md` import (not a symlink) for Claude
Both work. ai-dev-kit defaults to the import because:
- it is cross-platform (a `CLAUDE.md → AGENTS.md` symlink needs Admin/Developer
  Mode on Windows), and
- it lets us append Claude-only notes *under* the shared content.

To prefer a symlink instead, replace `CLAUDE.md` with `ln -s AGENTS.md CLAUDE.md`.

## What's generated vs. what you own
- **You own:** `AGENTS.md`, including its **Standards** section (the commands read it).
- **Generated (safe to commit, regenerated on re-run):** the one-line `CLAUDE.md`
  import + managed notes block, `.github/copilot-instructions.md`, the model lines
  in `.claude/settings.json` and `.codex/config.toml`, and the slash commands
  (`.claude/commands/*.md`, `.github/prompts/*.prompt.md`, and the user-global
  `~/.codex/prompts/*.md`).
- **Generated, gitignored:** `graphify-out/`, `*.local.*`, `.claude/settings.local.json`.

Re-running `setup.sh` only touches its own managed blocks (marked
`ai-dev-kit:<id>`) and backs up any pre-existing file once to `*.adk-bak`.

## Model selection per agent
| Agent | Where |
|---|---|
| Claude Code | `.claude/settings.json` → `"model"` (repo default; restart to apply). |
| Codex | `.codex/config.toml` → `model` + `model_reasoning_effort` (loads when project is trusted). |
| Copilot | No repo setting — chosen per task in the model picker (plan/admin-gated). |
