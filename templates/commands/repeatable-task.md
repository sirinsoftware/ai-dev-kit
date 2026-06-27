Codify this recurring task as a deterministic, repeatable runbook for this repo:
**__ARG__**. If empty, ask me which task to codify.

Read this repo's `AGENTS.md` so the steps respect the project's standards and tooling.

**Step 1 — Capture the current process.** Describe how the task is done today,
including tribal knowledge, manual checks, and failure points. Ask me to fill gaps
rather than guessing.

**Step 2 — Preconditions & inputs.** What must be true before starting; the
inputs/parameters and how to obtain them.

**Step 3 — Write the algorithm.** An ordered, numbered list of steps. Each step must be
**deterministic** (same inputs → same result), **idempotent where possible** (safe to
re-run after a partial failure), and **verifiable** (the exact check/command that
confirms success). Include the exact commands, not descriptions.

**Step 4 — Handle failure.** For each step that can fail, give the detection signal and
the rollback/recovery action.

**Step 5 — Define "done".** A final checklist proving the whole task completed correctly.

**Step 6 — Package it.** Save the runbook to `docs/runbooks/<task-slug>.md`. Where it
makes sense, propose codifying it further as a script, a Makefile target, a Claude Code
command/skill, or a Codex/Copilot prompt so future runs are one command.

Output the runbook now, then ask if I want the script/command version.
