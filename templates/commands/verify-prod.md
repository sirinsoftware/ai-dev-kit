Verify in production: **__ARG__** — a `docs/process/<slug>/` slug for a deployed
feature. Requires `docs/process/<slug>/plan.md` (for the matrices) and the deployment
details from `AGENTS.md` → Real device / environment.

Phase 8 of the delivery process. Question: **is it actually working in production?**

**Hard constraints — read-only.** No migrations, no flag flips, no deploys, no writes
beyond a designated test account named in AGENTS.md. Anything that would mutate real
user data gets SKIPPED and recorded as `not verifiable in prod`. When in doubt, skip
and record — never probe.

**Step 1 — Environment.** Use the AGENTS.md Real-device/environment section
(`REAL_DEVICE_NOTES` / prereqs / script) for how to reach production or the closest
prod-like environment. If prereqs are not met, stop and list them.

**Step 2 — Re-run the e2e test-matrix rows** against production, plus every
failure-matrix row that can be exercised read-only (dependency latency, malformed
input to public endpoints you own, retry behavior). Record pass / fail / skipped per
row, with evidence (response, screenshot, log excerpt).

**Step 3 — New error signals.** Check error rates / logs / monitoring for signals that
did not exist before the deploy, per the plan's side-effects section.

**Step 4 — Journal the fails (the compounding step).** For every `fail`, write a
journal entry (if configured) pairing it with **the plan assumption that produced it**.
This is the only phase whose output compounds: after a few features the journal shows
which parts of planning are systematically wrong — nothing else in the process
provides that.

Write `docs/process/<slug>/prod-verify.md`: the row table, new signals, and follow-ups.
