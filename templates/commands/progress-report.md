Produce a progress report for this project covering: **__ARG__** — e.g. "this
week", "since v1.2", a commit range; if empty, default to recent history since the
last report.

Gather facts first (don't speculate):
- **Activity:** `git log` over the period, merged PRs, changed areas — what shipped vs. in progress.
- **Architecture:** use `graphify query "..."` or read `graphify-out/GRAPH_REPORT.md`
  for the god-nodes / key modules and any notable new cross-module connections.
- **Quality:** test status, coverage vs. the target in `AGENTS.md`, outstanding static-analysis findings.
- **Open work:** open issues/PRs, recently added TODO/FIXME, known blockers.

Then output:
```
# Progress report — __ARG__
**Status:** 🟢 on track | 🟡 at risk | 🔴 blocked — <one line why>

## Shipped
- <change> (<PR/commit>)

## In progress
- <item> — <owner/branch> — <next step>

## Quality
- Tests: <pass/fail> · Coverage: <x%> (target per AGENTS.md)
- Static analysis: <open findings by severity>

## Risks & blockers
- <risk> — <impact> — <mitigation/ask>

## Next up
- <prioritized next steps>
```

Keep it factual and skimmable.

> **HTML option:** if I ask for HTML, emit this report as a self-contained `.html` per
> **Output formats** in `AGENTS.md`, saved under `docs/reports/` (or run `/report-html`) — instead of Markdown.
