Prepare a feature end-to-end: **__ARG__** — a feature description. If empty, ask.
This is the combo command for phases 1–4: research → plan → critique → defend.
Happy path: `/prepare` → `/execute` → `/verify-feature` (guide:
`docs/guides/develop-a-feature.md`).

Derive a kebab-case `<slug>` (it becomes the branch name). Artifacts:
`docs/process/<slug>/`.

**1. Research** — run the `/research` steps (journal → graphify → Grep MCP → targeted
reads; NO solutions) → `context.md`. **Gate:** if any Unknown is blocking, STOP and ask
me; continue only when answered. In Claude Code, delegate this stage to a cheaper
subagent (it is retrieval, not reasoning).

**2. Plan** — run the `/plan-feature` steps (Superpowers writing-plans if available,
then slices + test matrix + failure matrix + operational sections + minimalism pass)
→ `plan.md`.

**3. Critique** — run the `/critique` steps: deterministic checks, then the critics IN
PARALLEL in one message (`critic-edge-cases` + `critic-rollback` subagents; minimalism
via ponytail's `/ponytail-review` if installed, else the `critic-minimalism` subagent;
`codex exec` cross-vendor in the background if installed; paths only, no narrative).
Adjudicate by `file:line` grouping; revise `plan.md`; write `critique.md`.

**4. Defend** — run the `/defend` steps: the 10 hostile questions answered with
quotes/references → `defense.md` ending `Verdict: READY` or `Verdict: NOT READY`.

**End state:**
- `READY` → say so and hand off: "run `/execute <slug>`".
- `NOT READY` → list the gaps, apply what is fixable to `plan.md`, and re-defend ONCE.
  Still `NOT READY` → stop and bring me the open gaps. Never soften a verdict to
  proceed.

Keep me posted at each phase boundary (one line each). Do not write any production
code — that is `/execute`'s job, and it is gated on the READY verdict.
