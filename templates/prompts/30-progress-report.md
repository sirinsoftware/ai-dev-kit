# Prompt — project progress report

Generates a status report on the project. Replace `{{PERIOD}}` (e.g. "since last
Friday", "this sprint", "since commit abc123").

---

Produce a progress report for this project covering **{{PERIOD}}**.

Gather facts first (don't speculate):
- **Activity:** `git log --since/--oneline`, merged PRs, changed areas. Summarize
  what actually shipped vs. what's in progress.
- **Architecture view:** use `graphify query "..."` or read `graphify-out/GRAPH_REPORT.md`
  for the god-nodes / key modules and any notable new cross-module connections.
- **Quality:** current test status, coverage vs. the target in
  `docs/ai-prompts/00-standards.md`, and outstanding static-analysis findings.
- **Open work:** open issues/PRs, TODO/FIXME added recently, known blockers.

Then output the report in this format:

```
# Progress report — {{PERIOD}}
**Status:** 🟢 on track | 🟡 at risk | 🔴 blocked — <one line why>

## Shipped
- <change> (<PR/commit>)

## In progress
- <item> — <owner/branch> — <% / next step>

## Quality
- Tests: <pass/fail, count> · Coverage: <x%> (target {{TARGET}})
- Static analysis: <open findings by severity>

## Risks & blockers
- <risk> — <impact> — <mitigation/ask>

## Next up
- <prioritized next steps>
```

Keep it factual and skimmable. Prefer the format above unless I gave a custom
`{{REPORT_FORMAT}}` in the standards — if so, use that instead.
