Write the implementation plan for: **__ARG__** — a `docs/process/<slug>/` slug.
Requires `docs/process/<slug>/context.md` (run `/research` first if missing; if
Unknowns there are unanswered, stop and ask me).

Phase 2 of the delivery process. Question: **what exactly are we building, and how
will we know it works?** Read `AGENTS.md` (Standards) first — the plan must respect it.

**Step 1 — Task breakdown.** If the Superpowers `writing-plans` skill is available,
use it: bite-sized tasks with exact file paths, complete code, verification steps.
Otherwise produce the same by hand. Then add the three things it does not produce:

**Step 2 — Slices.** Regroup tasks into independently shippable PRs. Each slice gets:
id, files touched, dependencies on other slices, and its own acceptance criteria.
Target 30–200 lines of production diff. A slice that cannot ship alone is not a slice.

**Step 3 — Test matrix.** Designed NOW, before the code exists, as observable behavior:

| Given (state) | When (user action, UI/API terms) | Then (user-observable) | Layer (unit/integration/e2e) | Owner slice |

A criterion that cannot be written this way is not an acceptance criterion — rewrite it
or drop it. e2e rows run on the real environment defined in AGENTS.md → Real device
(`REAL_DEVICE_*`).

**Step 4 — Failure matrix.** For each surface: malformed input, dependency down,
duplicate request, offline client, retry after timeout — expected behavior for each.

**Step 5 — Operational sections.** Side effects (API responses, DB writes, analytics,
cache keys, background jobs, client state); migration + rollout (flag name, deploy
order); rollback per slice and the point at which it stops being possible.

**Step 6 — Minimalism pass.** Delete every layer no requirement asks for (YAGNI —
apply ponytail if installed). A layer is far cheaper to delete in a plan than after
it is built.

Write `docs/process/<slug>/plan.md`. Next: `/critique <slug>`.
