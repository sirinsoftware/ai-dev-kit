Run a fresh-context verdict review of: **__ARG__** — a `docs/process/<slug>/` slug,
a branch, or a diff ref. If empty, use the current branch against `main`.

Phase 6 of the delivery process. **This review must NOT share context with the session
that wrote the code.** If you are the implementing session, dispatch this whole command
to a fresh subagent (give it ONLY paths and this instruction — no narrative of how the
code was written); in Codex/Copilot, run it in a new session. A reviewer that shares
the implementer's context is a checklist, not a reviewer — Superpowers
`requesting-code-review` covers that pre-submit checklist role; this command produces
the verdict.

Read `AGENTS.md` Standards first (Code review rubric, Code standards).

**Step 1 — Criteria before diff.** Read the acceptance criteria + test-matrix rows for
the slice(s) (`docs/process/<slug>/plan.md`, or ask for criteria if no process dir).
Form your own expectation of what the change should look like. Only THEN read the diff,
and compare it against that expectation — not against what the diff makes convenient
to believe. This ordering is most of the value of the phase.

**Step 2 — Review the diff** in priority order: correctness (bugs, races, unhandled
errors, edge cases) → security → AGENTS.md standards (naming, style, error handling,
commits) → design/maintainability. Use `graphify query`/`path` to confirm how changed
code is actually used before flagging.

**Step 3 — Map every acceptance criterion** to the code satisfying it, or mark it
unmet. An unmet criterion is a blocker regardless of code quality.

**Step 4 — Findings discipline.** Every finding needs `path:line` and a concrete
triggering case. "Consider adding validation" is not a finding; "line 42 accepts a
negative quantity, which reaches the ledger and produces a negative balance" is.

Write `docs/process/<slug>/review.md` (or print, if no process dir): findings by
severity per the AGENTS.md scale, criterion map, and end with exactly one of
`APPROVE` / `REQUEST_CHANGES` / `NEEDS_HUMAN`. Do not modify code.
