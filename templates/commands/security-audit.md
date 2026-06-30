Run a focused security review of: **__ARG__** — a PR ref, a path/area, or, if empty,
the current diff (`git diff main...HEAD`) plus any uncommitted changes.

This runs in *your current agent session* (Claude on your plan, Codex, or Copilot) —
no external API key needed. (In Claude Code the built-in `/security-review` does the
same on your Max plan.)

Read this repo's `AGENTS.md` Standards first for project conventions.

**Step 1 — Scope.** Determine what changed / what to audit. Prefer reviewing a diff
over the whole repo. Use `graphify query "what handles auth / input / secrets"` or
`ast-grep` (if available) to locate sensitive sinks quickly.

**Step 2 — Hunt for real vulnerabilities**, in priority order:
- Injection (SQL/command/template/path traversal), unsafe deserialization, SSRF.
- AuthN/AuthZ gaps: missing checks, IDOR, privilege escalation, broken session/token handling.
- Secrets: hardcoded keys/tokens, secrets logged or committed, weak crypto.
- Input validation / output encoding (XSS), unsafe `eval`/dynamic exec, unsafe file ops.
- Dependency/supply-chain risks introduced by the change.

**Step 3 — Re-review to cut false positives.** For each finding, re-read the
surrounding code and call sites and confirm it is actually reachable/exploitable with
attacker-controlled input. Drop anything you can't substantiate.

**Step 4 — Report.** For each confirmed issue:
```
[SEVERITY: critical|high|medium|low] file:line — <vulnerability class>
  Impact: <what an attacker achieves>
  Trigger: <attacker-controlled path to it>
  Fix: <concrete remediation>
```
End with a one-line verdict (safe to merge / fix required) and note what you did NOT
cover. Do not modify code unless I explicitly ask you to fix the findings.

> **HTML option:** if I ask for HTML, emit this report as a self-contained `.html` per
> **Output formats** in `AGENTS.md`, saved under `docs/reports/` (or run `/report-html`).
