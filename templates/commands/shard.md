Shard the plan for: **__ARG__** — a `docs/process/<slug>/` slug. Requires
`docs/process/<slug>/defense.md` containing `Verdict: READY` (refuse otherwise and
point at `/prepare` or `/defend`).

Phase 5 of the delivery process. Question: **what can run in parallel, and in what
order?** This is bookkeeping — keep it mechanical.

**Step 1 — Check declared dependencies against reality.** For each pair of slices the
plan calls independent:
- Intersect their file lists. Any shared file = NOT independent.
- `graphify query "what depends on <core module of slice>"` — slices whose files sit in
  the same graph neighborhood will conflict on merge even when the plan says otherwise.
  This check is the whole point of the phase: three parallel agents producing three
  conflicting PRs costs a day.
Demote conflicting slices to sequential; record the final order.

**Step 2 — Create workspaces.** One per parallel slice. If the Superpowers
`using-git-worktrees` skill is available, use it (it also verifies a clean test
baseline). Fallback: `git worktree add ../<repo>-<slug>-<slice-id> -b <slug>-<slice-id>`
then run project setup and the test suite to verify a green baseline.

**Step 3 — Write each worktree's `TASK.md`** with ONLY that slice's content:
- the slice's acceptance criteria,
- its test-matrix and failure-matrix rows,
- its file list,
- a link (path) to `docs/process/<slug>/plan.md`.
A slice session that can see the whole plan starts optimizing across slice boundaries
and stops being independently shippable — do not paste the full plan in.

**Step 4 — Hand off.** Implementation runs per worktree via `/execute <slug>` (which
uses subagent-driven development + TDD where available). List the worktrees, their
branch names, and the recommended execution order.
