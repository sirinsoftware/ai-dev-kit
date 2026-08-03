# Guide — develop a feature

The happy path is three commands. Full reference: [../delivery-process.md](../delivery-process.md).

```
/prepare "user can reset password by email"
   → answer the Unknowns it surfaces
   → wait for: Verdict: READY          (artifacts in docs/process/<slug>/)

/execute <slug>
   → implements the defended plan (TDD, one branch — or parallel worktrees for
     multiple independent slices), commits locally per the commit standard

/verify-feature <slug>
   → formats + lints + typechecks + security-scans, then in parallel:
     two fresh-context reviews (different models) + cross-vendor review (if codex
     is installed) + unit/integration tests + real-device/e2e run + docs update
   → on PASS: writes commit-message.md (nothing committed) and pr-description.md
     (no PR opened, nothing pushed)
```

Then read `docs/process/<slug>/pr-description.md`, commit with the prepared message,
and open the PR yourself (or use Superpowers `finishing-a-development-branch`).

## When to drop to the granular commands

| Situation | Use |
|---|---|
| Plan feels off after `/prepare` | `/critique <slug>` again, or `/defend <slug>` after edits |
| Big feature, several independently shippable slices | `/shard <slug>` before `/execute` |
| Review someone else's work / re-review after manual edits | `/review-fresh <ref>` |
| Human deploy decision needed | `/ship-report <slug>` |
| After deploying | `/verify-prod <slug>` |
| Small bug fix | none of this — just fix it |

## Rules the process enforces

- `/execute` refuses to run without `Verdict: READY` in `defense.md` — no code from an
  undefended plan. (With `--with-process-hooks`, a hook enforces this too;
  `ADK_PROCESS_OFF=1` bypasses.)
- Reviews never see the implementer's narrative — fresh context, paths + criteria only.
- The kit never commits the final wrap-up, never pushes, never opens PRs. You do.

## Tips

- Answer `/prepare`'s Unknowns properly — they are the questions that become 3am pages.
- `NOT READY` twice in a row is a real signal: the plan has a hole. Read the gaps in
  `defense.md` rather than re-rolling.
- Fill `AGENTS.md` first (`/fill-agents` helps): every phase reads the Standards, and
  the e2e lane needs the Real-device section.
