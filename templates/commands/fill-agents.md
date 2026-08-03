Fill every `{{PLACEHOLDER}}` in this repo's `AGENTS.md` with real values inferred from the
existing codebase — its code, git history, and config. Target repo: **__ARG__** (default:
the current repo).

## 0. Preflight
- Find `AGENTS.md` at the repo root. If it doesn't exist, stop and say so.
- If it has no `{{` tokens left, report "AGENTS.md is already filled" and skip to step 4 —
  the Copilot YAML may still need filling.
- Read-only until step 3. Never commit, push, or add dependencies.

## 1. Gather evidence (read-only)
Prefer hard evidence (a real command in CI, a config file, actual commit history) over
assumption.
- **Stack & layout:** package manifests + lockfiles (`package.json`, `pyproject.toml`,
  `requirements.txt`, `Cargo.toml`, `go.mod`, `Gemfile`, `composer.json`, `pom.xml`,
  `build.gradle`, `mix.exs`, `pubspec.yaml`), the directory tree, entry points. If a graphify
  graph exists: `graphify query "what is this project and how is it structured"`.
- **Commands (strongest signal is CI):** `.github/workflows/*`, `Makefile`, `justfile`,
  `Taskfile*`, and `package.json` `scripts`. These give the real lint / type-check / test /
  build / format commands the project actually runs.
- **Lint/format/type config:** `.eslintrc*`, `biome.json`, `.prettierrc*`, `ruff.toml`,
  `.flake8`, `setup.cfg`, `mypy.ini`, `tsconfig.json`, `.editorconfig`, `.rubocop.yml`.
- **Test/coverage config:** jest/vitest/pytest config; coverage thresholds
  (`coverageThreshold`, `.coveragerc`, `--cov-fail-under`).
- **Security scanners present:** bandit, semgrep, gosec, trivy, `npm audit`, `pip-audit`.
- **Conventions:** `git log --oneline -100` (Conventional Commits or another pattern?),
  `.github/PULL_REQUEST_TEMPLATE.md`, `CONTRIBUTING.md`, `CODEOWNERS`, `README`.
- **Real device / env:** `Dockerfile`, `docker-compose*`, `fastlane/`, an Xcode/Android/
  Flutter project, `.env.example`, staging config.

## 2. Fill every placeholder — best guess, no gaps
Replace each `{{...}}` below with a concrete value. If evidence is thin, still write your best
inference (the ecosystem's conventional default) and remember it for the step-5 report — do
NOT leave a `{{...}}` or a `TODO` marker in the file.

| Placeholder | Fill from |
|---|---|
| `{{PROJECT_OVERVIEW}}` | README, graphify summary, repo description |
| `{{TECH_STACK}}` | manifests, dir layout, entry points |
| `{{CODE_STANDARDS}}` | lint/format config, `.editorconfig`, language version, observed style |
| `{{FORMAT_COMMAND}}` | prettier/biome/ruff-format/gofmt/rustfmt script or CI step |
| `{{COMMIT_STANDARDS}}` | git-log pattern (Conventional Commits? prefixes?) — give an example |
| `{{PR_STANDARDS}}` | CONTRIBUTING, PR template, branch protection |
| `{{PR_DESCRIPTION_FORMAT}}` | `.github/PULL_REQUEST_TEMPLATE.md` verbatim if present, else a sensible default |
| `{{REVIEW_STANDARDS}}` | CONTRIBUTING / CODEOWNERS, else a default rubric |
| `{{REVIEW_MERGE_GATES}}` | required CI checks (from workflows), required approvals / CODEOWNERS |
| `{{LINT_COMMAND}}` | lint config + scripts + CI |
| `{{TYPECHECK_COMMAND}}` | tsc/mypy/etc. config + scripts + CI (or "N/A" for untyped langs) |
| `{{SECURITY_SCAN_COMMAND}}` | scanner config if present, else the ecosystem default (`npm audit`, `pip-audit`) |
| `{{TEST_COMMAND}}` | test config + scripts + CI |
| `{{COVERAGE_TARGET}}` | coverage threshold config, else "none set" |
| `{{REAL_DEVICE_NOTES}}` | Docker/compose/fastlane/mobile project — or "N/A (pure library/CLI)" |
| `{{REAL_DEVICE_TEST_SCRIPT}}` | the command to run there, else "N/A" |
| `{{REAL_DEVICE_PREREQS}}` | required SDKs/emulators/env, else "N/A" |
| `{{EXTRA_GUARDRAILS}}` | repo-specific (generated dirs, migrations, don't-touch paths), else a minimal default |

Keep each value tight and factual — every agent reads this file on every task. Do not touch
already-filled text or the `@@…@@` tokens (setup fills those).

## 3. Edit AGENTS.md in place
Apply all replacements. Only the `{{...}}` tokens change.

## 4. Fill the Copilot cloud-agent YAML too (if present)
If `.github/workflows/copilot-setup-steps.yml` exists and still has its `TODO`, replace it with
the real toolchain setup — the install step plus the lint/test commands from step 1. Skip
silently if the file is absent.

## 5. Report — clean file, honest summary
Print a table: each placeholder → the value you wrote → its evidence source (a file / CI step)
or `guess`. Then list explicitly the ones filled with a **low-confidence guess** and ask me to
verify them. Finally, remind me to review `git diff AGENTS.md` and commit. Do not commit or push.
