Write the ship report for: **__ARG__** — a `docs/process/<slug>/` slug. Requires the
feature to be implemented and verified (`verify.md` present; run `/verify-feature`
first if not).

Phase 7 of the delivery process. Question: **should we deploy?** Written for a human
deciding WITHOUT reading a diff — product language, no file paths in the summary, no
technical narration.

Sections of `docs/process/<slug>/report.md`:
1. **What shipped** — one paragraph, product terms.
2. **Acceptance criteria** — met / partial / not met, each with its PR or commit.
3. **How it was verified** — every test-matrix row: the layer it ran at, and whether it
   ran **against a running app or only in unit tests**. Name the rows never actually
   run. Claiming verification that did not happen is the one unforgivable error here —
   a skipped step reported as skipped is the useful output.
4. **Failure-matrix results** — what was injected, what happened.
5. **Screenshots** of the real user flow, captioned — or "none, because <reason>".
6. **What the plan did not anticipate.** This section is why the report exists. If
   private-journal is configured, write this section to the journal too.
7. **Risks, limits, rollback** — and the point of no return.

End with exactly one of `RECOMMEND DEPLOY` / `HOLD` (with the blocking items).

A report where everything passed is usually a report nobody checked — re-read section
3 before the verdict. Finish with `graphify update .` so the graph reflects reality.
After deploying, `/verify-prod <slug>` closes the loop.
