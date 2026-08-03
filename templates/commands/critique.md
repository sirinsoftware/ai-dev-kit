Critique the plan for: **__ARG__** — a `docs/process/<slug>/` slug. Requires
`docs/process/<slug>/plan.md`.

Phase 3 of the delivery process. Question: **what is wrong with this plan?** Other
minds attack it; you merge mechanically.

**Step 1 — Deterministic checks first** (no model opinion involved):
- Intersect the file lists of the plan's slices — any overlap between "independent"
  slices is a conflict finding.
- `graphify query "what depends on <module>"` for each slice's core modules — slices
  whose files share a graph neighborhood will conflict on merge even if the plan calls
  them independent.
- `/speckit.analyze` if spec-kit is initialized (read-only cross-artifact consistency).

**Step 2 — Fan out critics in parallel, in ONE message** (sequential dispatch makes
reviews correlated, which defeats the point). In Claude Code, dispatch these subagents;
elsewhere run the same lenses as separate self-contained passes:
- `critic-edge-cases` (top-tier): inputs and sequences that break the plan.
- `critic-rollback` (top-tier): point of no return, migration reversibility, deploy order.
- `critic-minimalism` (cheapest): structure with no requirement behind it.
- **Cross-vendor** (if the `codex` CLI is installed): run in the background
  `codex exec "Critique the plan at docs/process/<slug>/plan.md against docs/process/<slug>/context.md. Findings as file:line + severity."`
  Same-vendor critics share blind spots; this one disagrees for different reasons.

**Anchoring rule:** delegation messages contain PATHS ONLY (plan.md, context.md, the
code paths). Never describe the approach — "I planned X using Y" anchors the critic
before it reads a line.

**Step 3 — Adjudicate mechanically.** Group findings by `file:line`, not by judgement:
- Two critics landing on the same location independently → rank first.
- Cross-vendor disagreement with same-vendor critics → the most informative line; flag it.
- You are the correlated party: you may NOT overrule a critic you disagree with — mark
  the disagreement for me instead.
- Zero blockers on a first pass usually means the critics got too little context, not
  that the plan is good — rerun with more paths.

**Step 4 — Revise.** Apply accepted findings to `plan.md` in place. Write the merged,
ranked findings table + what was rejected (and why) to `docs/process/<slug>/critique.md`.
Next: `/defend <slug>`.
