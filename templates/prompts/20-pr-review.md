# Prompt — PR review, re-review, report, fix, and description

A single prompt for the whole PR lifecycle. Pick the mode(s) you need; they
compose. All modes use the standards in `docs/ai-prompts/00-standards.md` as the
rubric. Replace `{{PR_REF}}` (a PR number/URL, branch, or "the current diff").

---

You are handling **{{PR_REF}}** for this repo. Read `AGENTS.md` and
`docs/ai-prompts/00-standards.md` first — those define the rules you review
against and the PR description format. Get the diff (e.g. `gh pr diff {{PR_REF}}`
or `git diff main...HEAD`).

## Mode A — Review (first pass)
Review the diff for, in priority order:
1. **Correctness** — bugs, logic errors, race conditions, unhandled errors, edge cases.
2. **Security** — injection, auth, secrets, unsafe input handling.
3. **Standards** — violations of `00-standards.md` (style, naming, tests, commits).
4. **Design / maintainability** — duplication, unclear naming, missing tests.

For each finding, record: file:line, **severity** (blocker / major / minor / nit),
what's wrong, and a concrete suggested fix. Use `graphify query`/`graphify path`
to confirm how changed code is actually used before flagging.

## Mode B — Re-review (false-positive pass)
Now adversarially re-check your *own* findings from Mode A. For each one, try to
**refute it**: re-read the surrounding code and call sites and ask "is this
actually reachable / actually wrong / already handled elsewhere?" Drop or
downgrade anything you cannot defend. Output the final, verified findings and note
which ones you discarded and why. Prefer false negatives over crying wolf.

## Mode C — Issues report (reviewing someone else's PR)
Produce a report someone can act on, in this format:

```
## Review of {{PR_REF}}
**Summary:** <1–3 sentences: overall assessment + recommendation (approve / changes / block)>
**Verdict:** APPROVE | REQUEST CHANGES | BLOCK

### Blockers
- [ ] file:line — <issue> — <suggested fix>
### Major
- [ ] file:line — <issue> — <suggested fix>
### Minor / Nits
- [ ] file:line — <issue>

**Tests:** <ran? results? gaps?>
**Out of scope / follow-ups:** <things worth a separate issue>
```

Do **not** modify their code in this mode — report only.

## Mode D — Fix (only if I ask you to fix the issues)
On a new branch, address the verified findings from Mode B/C. One logical change
per commit, commit messages per the standards. After fixing, re-run the formatter
(section 1), static analysis (section 4), and tests (section 5) from
`00-standards.md` and report results. Do not push or open a PR unless I
explicitly say so.

## Mode E — PR description
Write/update the PR description using the **PR description format** defined in
`00-standards.md` (section 3). Base it on the actual diff — summarize what changed
and why, testing done, and risks. If that format placeholder is unfilled, ask me
for the format before writing.

---
**Tell me which modes to run** (default: A → B → C). End by stating clearly what
you did and did not change.
