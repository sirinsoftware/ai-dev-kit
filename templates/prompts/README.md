# Prompt library

Reusable prompts for AI-assisted development. They are agent-agnostic — use them
with Claude Code, Codex, or GitHub Copilot.

| File | Use it to… |
|---|---|
| `00-standards.md`          | Define your code / commit / PR standards, static-analysis tools, tests, and the real-device test script. **Fill this in first** — the others reference it. |
| `10-algorithm-deep-test.md`| Have the agent design a thorough testing algorithm for a feature/module. |
| `11-repeatable-task.md`    | Turn a recurring chore into a deterministic, repeatable runbook. |
| `20-pr-review.md`          | Review a PR, re-review for false positives, write an issues report, optionally fix, and write the PR description. |
| `30-progress-report.md`    | Generate a project progress report. |

## How to invoke per agent

- **Claude Code:** reference the file in your message, e.g.
  `Follow @docs/ai-prompts/20-pr-review.md for PR #42, modes A→B→C`.
- **Codex:** paste the prompt body, or `@docs/ai-prompts/20-pr-review.md`, and add
  the specifics (PR ref, target, period).
- **GitHub Copilot:** paste the prompt into the issue/PR you assign to the agent,
  or into Copilot Chat; the cloud agent also has `AGENTS.md` in context.

## Filling placeholders
- `{{...}}` placeholders are for **you** to fill (standards, formats, targets).
- `00-standards.md` is the contract; the other prompts point back at it so you set
  rules in one place.
