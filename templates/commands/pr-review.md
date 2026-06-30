Handle a pull request review for: **__ARG__** — a PR number, URL, branch, or, if
that is empty, "the current diff".

Read this repo's `AGENTS.md` first — its **Standards** section is the rubric you
review against and defines the PR description format. Get the diff
(e.g. `gh pr diff __ARG__`, or `git diff main...HEAD` for the current branch).

Run the modes I ask for (default: A → B → C).

## Mode A — Review (first pass)
Review the diff in priority order:
1. **Correctness** — bugs, logic errors, race conditions, unhandled errors, edge cases.
2. **Security** — injection, auth, secrets, unsafe input handling.
3. **Standards** — violations of the Standards in `AGENTS.md` (style, naming, tests, commits).
4. **Design / maintainability** — duplication, unclear naming, missing tests.

For each finding record: `file:line`, **severity** (blocker / major / minor / nit),
what's wrong, and a concrete fix. Use `graphify query`/`graphify path` to confirm
how changed code is actually used before flagging.

## Mode B — Re-review (false-positive pass)
Adversarially re-check your *own* Mode A findings. For each, try to refute it:
re-read the surrounding code and call sites — is it actually reachable / actually
wrong / not already handled? Drop or downgrade anything you can't defend. Prefer a
false negative over crying wolf. Output the verified findings and what you discarded.

## Mode C — Issues report (reviewing someone else's PR)
Report only — do not modify their code:
```
## Review of __ARG__
**Summary:** <assessment + recommendation>
**Verdict:** APPROVE | REQUEST CHANGES | BLOCK
### Blockers
- [ ] file:line — <issue> — <fix>
### Major
- [ ] file:line — <issue> — <fix>
### Minor / Nits
- [ ] file:line — <issue>
**Tests:** <ran? results? gaps?>
**Out of scope / follow-ups:** <separate issues>
```

> **HTML option:** if I ask for HTML, emit this report as a self-contained `.html` per
> **Output formats** in `AGENTS.md`, saved under `docs/reports/` (or run `/report-html`).
> (Mode E PR descriptions stay Markdown — GitHub renders them.)

## Mode D — Fix (only if I ask you to fix the issues)
On a new branch, address the verified findings — one logical change per commit,
commit messages per the Standards. After fixing, re-run the formatter, static
analysis, and tests defined in `AGENTS.md`, and report results. Do not push or open
a PR unless I explicitly say so.

## Mode E — PR description
Write/update the PR description using the **PR description format** in `AGENTS.md`,
based on the actual diff (what changed, why, testing done, risks).

End by stating clearly what you did and did not change.
