Verify the implemented feature: **__ARG__** — a `docs/process/<slug>/` slug with
implementation done (`/execute`). Read `AGENTS.md` first: Standards (all subsections)
and Real device / environment. Guide: `docs/guides/test-a-feature.md`.

**Stage 0 — deterministic, before any model lane (cheap, sequential):**
1. Run the formatter (AGENTS.md Format command) and apply the result.
2. Run lint, type check, and the security scan (AGENTS.md Static analysis). Their
   failures become findings for free — no model time on what a tool catches.

**Stage 1 — parallel lanes.** In Claude Code: tests/device as background shell, the
reviews as parallel fresh subagents, all in one message. In Codex/Copilot: run the
same lanes sequentially, and collapse reviews B/C into one extra self-contained pass.

| Lane | What |
|---|---|
| Review A | Fresh context, top-tier model: the full `/review-fresh` procedure. Input: paths + acceptance criteria ONLY — never the implementation narrative. |
| Review B | Second independent fresh review, mid-tier model — different model, different blind spots. Same paths-only input. |
| Review C | Cross-vendor (if `codex` CLI installed): background `codex exec` review of the diff vs the criteria. |
| Slop | If the ponytail plugin is installed: `/ponytail-review` on the diff — it owns over-engineering findings entirely (reviews A/B then skip that dimension). Not installed: reviews A/B cover it. |
| Tests | The AGENTS.md test command + any other suites it names (unit/integration). Update `.verify-state.json` (`"tests": "green"|"red"`) when done. |
| Device / e2e | Check the AGENTS.md Real-device prereqs; if met, run the real-device/e2e script for the plan's e2e matrix rows. If not configured or prereqs unmet: record the lane as `skipped (<reason>)` — never silently pass it. |
| Docs | Fresh mid-tier context: diff → find affected docs (README, docs/, API refs, AGENTS.md tech-stack) → apply the updates. |

**Stage 2 — join.** Merge review findings mechanically: group by `file:line`; findings
hit by ≥2 independent reviewers rank first; cross-vendor disagreement flagged as most
informative. Attach test + device results to their test-matrix rows, naming per row
whether it ran against a running app or only in unit tests. Write
`docs/process/<slug>/verify.md` ending `PASS` / `FIX NEEDED` / `NEEDS_HUMAN`.

- `FIX NEEDED` → apply ONE fix round (TDD, per the findings), then re-run stage 0 +
  the affected lanes once. Still failing → `NEEDS_HUMAN` with the open findings.

**Stage 3 — finishing (only on PASS):**
1. **Commit message, no commit:** for anything uncommitted (formatting, doc updates,
   fix round), write `docs/process/<slug>/commit-message.md` per the AGENTS.md commit
   standard and leave the changes staged. Tell me the message is ready — do NOT run
   `git commit`.
2. **PR description:** write `docs/process/<slug>/pr-description.md` per the AGENTS.md
   PR description format, from the actual diff: what changed, why, testing done (which
   matrix rows ran, at which layer), risks. Do NOT open a PR, do NOT push.

Merge/PR mechanics stay with me (or Superpowers `finishing-a-development-branch`).
End with: verdict, lane summary table, and where the commit message + PR description
files are.
