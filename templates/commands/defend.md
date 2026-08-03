Defend the plan for: **__ARG__** — a `docs/process/<slug>/` slug. Requires
`docs/process/<slug>/plan.md` (ideally already critiqued via `/critique`).

Phase 4 of the delivery process. Critique was other agents finding problems; defend is
YOU answering for the plan under hostile questioning. Different failure modes surface.

**Step 0** — Journal (if configured): search for questions this project got wrong
before. A question you failed previously is worth more than a fresh one.

**Answer each question from the plan and the codebase, with references.** "The plan
handles this" is not an answer — quote the part that handles it (`plan.md` section or
`path:line`) or record the gap honestly:

1. What happens when the user does this in the wrong order?
2. Malformed, empty, or hostile input at each entry point?
3. Dependency down, slow, or returning a partial response?
4. Duplicate submission, and retry after timeout?
5. Client offline mid-operation, syncing later?
6. What is the exact rollback, and when does it stop being possible?
7. What existing behavior could this silently break, and what test catches it?
8. What does the user see when it fails — the screen, not the log line?
9. Which slice, landing alone with the rest delayed a week, leaves a bad state?
10. What is in this plan that we would not miss if it were deleted?

Write `docs/process/<slug>/defense.md`: each question, its answer with references, and
end with exactly one of:

```
Verdict: READY
```
or
```
Verdict: NOT READY
```

`NOT READY` lists the gaps and points back at `plan.md` revision — never soften it to
proceed. A defend phase that never returns NOT READY is theatre; if that happens twice
in a row the questions are too soft — say so.

If private-journal is configured, record which question the plan was weakest on (that
pattern repeats across features). Next: `/execute <slug>` (or `/shard <slug>` first
for multi-slice parallel work).
