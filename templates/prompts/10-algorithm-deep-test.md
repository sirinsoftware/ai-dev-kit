# Prompt — design an in-depth testing algorithm

Use this when you want the agent to build a *thorough* test strategy for a feature
or module, not just a couple of happy-path tests. Paste it into any agent and
replace `{{TARGET}}`.

---

You are designing an in-depth testing algorithm for **{{TARGET}}** in this repo.

First read `docs/ai-prompts/00-standards.md` (sections 5 and 6) so your tests use
the project's real test commands and real-device/environment script.

**Step 1 — Map the surface.** Use `graphify query "what does {{TARGET}} interact
with"` (or read the code) to enumerate: public inputs/outputs, side effects,
dependencies, error paths, and state it mutates. List them.

**Step 2 — Enumerate cases.** Produce a table of test cases covering:
- happy paths and representative valid inputs;
- boundary/edge values (empty, zero, max, off-by-one, unicode, very large);
- invalid inputs and expected error handling;
- concurrency / ordering / idempotency, if relevant;
- failure injection (dependency timeouts, partial failures, malformed responses);
- security-relevant inputs (injection, auth bypass, overflow) if applicable.
Mark each case: unit / integration / property-based / real-device.

**Step 3 — Decide the technique per case.** Choose example-based, property-based
(fuzz over generated inputs with invariants), golden/snapshot, or end-to-end on
the real environment. Justify briefly.

**Step 4 — State invariants & oracles.** For property tests, write the invariants
that must always hold. Define how each test knows it passed (the oracle).

**Step 5 — Implement.** Write the tests using the project's framework and
conventions. Keep them deterministic; isolate external systems unless the case is
explicitly a real-device/integration case.

**Step 6 — Run & report.** Run the test command from section 5 of
`docs/ai-prompts/00-standards.md`. For real-device cases, run the script from
section 6 of the standards. Report coverage vs. the target, any gaps you chose
not to cover, and why.

Do not declare done until the suite passes and the coverage/critical paths are
justified.
