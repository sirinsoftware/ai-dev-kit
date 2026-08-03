# Guide — test a developed feature

`/verify-feature <slug>` is the single entry point after `/execute`. What it runs, in
order:

## Stage 0 — deterministic (before any model)

Formatter, lint, type check, security scan — the commands from `AGENTS.md` → Standards
→ Static analysis. Tool findings are free; no model time is spent on what a linter
catches. Formatting is applied, not just reported.

## Stage 1 — parallel lanes

| Lane | What | Fails when |
|---|---|---|
| Review A | fresh-context review, top-tier model — full `/review-fresh` procedure | unmet criterion or blocker finding |
| Review B | independent fresh review, mid-tier model (different blind spots) | same |
| Review C | cross-vendor `codex exec` review (only if the Codex CLI is installed) | same |
| Tests | the `AGENTS.md` test command + any other suites it names | red suite |
| Device / e2e | the plan's e2e matrix rows on the real environment | red run — see below |
| Docs | finds and applies documentation updates for the diff | — (its edits are re-reviewed in the join) |

Reviews receive **paths + acceptance criteria only** — never how the code was written.
That isolation is why their verdicts mean something.

## The e2e lane is driven by AGENTS.md → Real device / environment

- `REAL_DEVICE_PREREQS` — checked first; unmet prereqs are listed and the lane is
  recorded as `skipped (prereqs unmet)`.
- `REAL_DEVICE_TEST_SCRIPT` — the command actually run for the e2e rows.
- `REAL_DEVICE_NOTES` — how to interpret the environment (device, emulator, staging).

Fill these placeholders (or run `/fill-agents`) before expecting e2e results. An
unconfigured lane reports **skipped, with the reason** — it never silently passes.

## Stage 2 — join and verdict

Review findings merge mechanically: grouped by `file:line`; a finding two independent
reviewers hit ranks first; cross-vendor disagreement is flagged as the most
informative line. Test/device results attach to their test-matrix rows, each labeled
**ran against a running app** vs **unit-only**. Verdict in `verify.md`:

- `PASS` → finishing step runs (below).
- `FIX NEEDED` → one TDD fix round, affected lanes re-run once, then re-verdict.
- `NEEDS_HUMAN` → open findings listed; nothing further happens without you.

## Stage 3 — finishing (PASS only)

- `docs/process/<slug>/commit-message.md` — per the commit standard, for whatever the
  verify stage changed (formatting, docs, fix round). **Nothing is committed.**
- `docs/process/<slug>/pr-description.md` — per the PR format, from the actual diff,
  naming which matrix rows ran at which layer. **No PR is opened, nothing pushed.**

## Other testing commands

- `/deep-test <target>` — design a full testing algorithm for one module (case table,
  invariants, property-based ideas) — deeper than the verify lanes.
- `/verify-prod <slug>` — after deploying: re-run e2e + failure rows read-only against
  production and journal every fail with the plan assumption that produced it.
