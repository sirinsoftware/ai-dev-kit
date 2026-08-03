Execute the defended plan for: **__ARG__** — a `docs/process/<slug>/` slug.

**Gate:** `docs/process/<slug>/defense.md` must contain `Verdict: READY`. If it does
not exist or says `NOT READY`, refuse and point at `/prepare <feature>` (or `/defend
<slug>`). Do not implement from an undefended plan.

Implementation only — no review, no device runs here (that is `/verify-feature`).

**Size-adaptive execution:**
- **One slice** → create branch `<slug>` and implement in place.
- **Multiple independent slices** → run the `/shard` steps first (conflict-check via
  file intersection + graphify, worktree per slice, slice-only `TASK.md`), then
  implement each worktree — in Claude Code dispatch one subagent per slice in parallel
  (each sees ONLY its `TASK.md`); elsewhere implement them sequentially.

**Per slice:**
1. TDD, strictly (Superpowers `test-driven-development` if available): failing test →
   watch it fail → minimal code → watch it pass → refactor. Follow the AGENTS.md code
   standards.
2. Commit per the AGENTS.md commit-message standard — one logical change per commit.
   Local commits only; never push.
3. After each test run, update `docs/process/<slug>/.verify-state.json`:
   `{"tests": "green"|"red", "updated": "<ISO timestamp>"}` (the kit's optional Stop
   hook reads this).

**Done when:** every slice's tasks are implemented and its OWN unit tests pass locally.
End with: status per slice (branch/worktree, tests green?), files touched, and the
hand-off line: "run `/verify-feature <slug>`".
