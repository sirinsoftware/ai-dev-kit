# Prompt — turn a recurring chore into a repeatable algorithm

Use this to convert a task you do over and over (releases, data migrations, adding
a new endpoint, onboarding a module) into a deterministic, repeatable runbook the
agent can execute the same way every time. Replace `{{TASK}}`.

---

You will codify **{{TASK}}** as a repeatable algorithm for this repo.

First read `AGENTS.md` and `docs/ai-prompts/00-standards.md` so the steps respect
project standards and tooling.

**Step 1 — Capture the current process.** Describe how {{TASK}} is done today,
including any tribal knowledge, manual checks, and failure points. Ask me to fill
gaps rather than guessing.

**Step 2 — Define preconditions & inputs.** List what must be true before
starting, the inputs/parameters, and how to obtain them.

**Step 3 — Write the algorithm.** Produce an ordered, numbered list of steps.
Each step must be:
- **deterministic** — same inputs → same result;
- **idempotent where possible** — safe to re-run after a partial failure;
- **verifiable** — state the exact check/command that confirms the step succeeded.
Include the exact commands (not descriptions) for each step.

**Step 4 — Handle failure.** For each step that can fail, give the detection
signal and the rollback or recovery action.

**Step 5 — Define "done".** A final checklist that proves the whole task
completed correctly (tests pass, artifacts present, etc.).

**Step 6 — Package it.** Save the runbook to `docs/runbooks/{{TASK_SLUG}}.md`.
Where it makes sense, propose codifying it further as a script, a Makefile target,
a Claude Code skill/slash-command, or a Codex prompt so future runs are one
command.

Output the runbook now, then ask if I want the script/skill version.
