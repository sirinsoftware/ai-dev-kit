Research the codebase for: **__ARG__** — a feature idea or an existing
`docs/process/<slug>/` slug. If empty, ask me what we're researching.

Phase 1 of the delivery process (see `docs/delivery-process.md`). Answer the question
**"what is true today?"** — this is retrieval, not reasoning, and produces NO solutions.
A design appearing in this phase means the phase was skipped.

Derive a kebab-case `<slug>` from the feature name (it will become the branch name).
All artifacts go to `docs/process/<slug>/`.

**Retrieval order (do not skip ahead to reading files):**
1. **Journal** (if private-journal is configured): search for this area. Prior failed
   approaches are the highest-value input available and cost one call.
2. **graphify**: `graphify query "how does <area> work"`, `graphify explain "<Symbol>"`,
   `graphify path "<A>" "<B>"` to establish the real call flow.
3. **Grep MCP** — only if the problem is genuinely unfamiliar: how do public repos do it?
4. **Read the files** the steps above pointed at. Nothing else.

Write `docs/process/<slug>/context.md`:
- **Goal** in product terms (one paragraph).
- **How it works today** — every claim with a `path:line` reference.
- **Existing patterns worth following** — name the exemplar files.
- **Touched surfaces** and ordering constraints.
- **Risks** with blast radius.
- **Unknowns** — anything unverified goes HERE, not stated softly in prose. These are
  questions for a human.

End by listing the Unknowns and asking me to answer the blocking ones. Do not proceed
to planning; that is `/plan-feature <slug>`.
