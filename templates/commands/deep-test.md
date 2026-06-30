Design and run an in-depth testing algorithm for: **__ARG__** — a file, module, or
feature in this repo. If empty, ask me what to target.

Read this repo's `AGENTS.md` (Standards → Tests and Real device/environment) so your
tests use the project's real test commands and device/environment script.

**Step 1 — Map the surface.** Use `graphify query "what does __ARG__ interact with"`
(or read the code) to enumerate inputs/outputs, side effects, dependencies, error
paths, and mutated state. List them.

**Step 2 — Enumerate cases.** Produce a table covering: happy paths; boundary/edge
values (empty, zero, max, off-by-one, unicode, very large); invalid inputs & expected
errors; concurrency/ordering/idempotency if relevant; failure injection (timeouts,
partial failures, malformed responses); security-relevant inputs if applicable. Tag
each: unit / integration / property-based / real-device.

**Step 3 — Technique per case.** Choose example-based, property-based (fuzz with
invariants), golden/snapshot, or end-to-end on the real environment. Justify briefly.

**Step 4 — Invariants & oracles.** State the invariants that must always hold and how
each test decides pass/fail.

**Step 5 — Implement.** Write the tests in the project's framework and conventions.
Keep them deterministic; isolate external systems unless the case is explicitly
integration/real-device.

**Step 6 — Run & report.** Run the test command from `AGENTS.md`; for real-device
cases run the device/environment script there. Report coverage vs. the target and any
gaps you chose not to cover, and why.

Don't declare done until the suite passes and the critical paths are justified.

> **HTML option:** if I ask for HTML, also emit the plan (surface map, case table, coverage)
> as a self-contained `.html` per **Output formats** in `AGENTS.md`, saved under `docs/reports/`
> (or run `/report-html`).
