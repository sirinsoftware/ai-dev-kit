# Design: delivery-process commands for ai-dev-kit

Date: 2026-08-03. Status: approved (sections validated interactively), implemented.

## Goal

Ship the 8-phase agentic delivery process (research → plan → critique → defend →
shard → review → report → verify-prod) as cross-agent slash commands, plus combo
commands for the happy path, with per-command model routing, parallel/background
verification, and opt-in enforcement hooks.

## Decisions (user-validated)

1. **Surface:** all 8 granular phase commands + combos. `/implement` was split into
   `/execute` (implementation, gated on a defended plan) and `/verify-feature`
   (post-execution verification + finishing). Happy path:
   `/prepare` → `/execute` → `/verify-feature`.
2. **Combo 2 sizing:** size-adaptive — one slice in place on a feature branch;
   multiple independent slices via worktrees + parallel slice subagents.
3. **ast-grep:** dropped from the process entirely (kit no longer wires it).
   Retrieval rule: graphify → Grep MCP → read files.
4. **`graphify prs --conflicts` does not exist** (article error). Conflict checks =
   slice file-list intersection + `graphify query "what depends on <module>"`.
5. **Enforcement:** opt-in `--with-process-hooks` (Claude-only): PreToolUse plan-gate
   + Stop red-build gate; `ADK_PROCESS_OFF=1` escape hatch; hooks read state files,
   never run tests; fail-open; inert on non-process branches.
6. **Routing (approach A):** `model:` frontmatter on Claude commands
   (opus = plan-feature/critique/defend/review-fresh/prepare/execute/verify-feature;
   sonnet = research/shard/ship-report/verify-prod) + critic subagents with pinned
   models (2× opus, 1× haiku) + `codex exec` as background cross-vendor critic.
   Codex: session-level `codex -m` (documented). Copilot: session model picker.
7. **Reviews inside `/verify-feature` are context-isolated**: fresh subagents receive
   paths + acceptance criteria only — never the implementation narrative. Two models
   (opus + sonnet) + cross-vendor. `/review-fresh` stays standalone.
8. **`/verify-feature` also owns:** stage-0 deterministic checks (format, lint,
   typecheck, security scan), a docs-update lane, e2e via the AGENTS.md
   `REAL_DEVICE_NOTES/TEST_SCRIPT/PREREQS` placeholders (skipped-with-reason when
   unconfigured), and a finishing step: `commit-message.md` (no commit) +
   `pr-description.md` (no PR, no push). One fix round max.
9. **Docs:** `docs/delivery-process.md` (reference incl. right-sizing) +
   `docs/guides/develop-a-feature.md` + `docs/guides/test-a-feature.md`, scaffolded
   into projects and manifest-tracked.

## Architecture

- `templates/commands/{research,plan-feature,critique,defend,shard,review-fresh,ship-report,verify-prod,prepare,execute,verify-feature}.md`
  — shared bodies, `__ARG__` rewritten per agent (existing machinery).
- `templates/claude/agents/critic-{edge-cases,rollback,minimalism}.md` → `.claude/agents/`.
- `templates/claude/hooks/process-{gate,stop}.py` → `.claude/hooks/` (opt-in).
- `lib/hooks_merge.py`: declarative `--guards` / `--process` sets; `Stop` key support;
  `--remove` strips both; back-compat default `--guards`.
- `lib/scaffold.sh`: `_cmd_model()` + model frontmatter (Claude only);
  `scaffold_agents()`, `scaffold_docs()`; `scaffold_hooks()` handles both hook sets.
- `setup.sh`: `--with-process-hooks` (also in `--with-all-extras`).
- Artifacts: `docs/process/<slug>/` = context.md, plan.md, critique.md, defense.md
  (`Verdict: READY|NOT READY`), verify.md, report.md, prod-verify.md,
  commit-message.md, pr-description.md, `.verify-state.json` (hook state).
- Slug = kebab-case feature name = branch name (hooks key on it).

## Error handling

- `/execute` refuses without `Verdict: READY`; `/prepare` re-defends once after gap
  fixes, then stops. `/verify-feature`: one fix round, then `NEEDS_HUMAN`.
- Hooks: fail-open on any unexpected error; loop-guard on `stop_hook_active`;
  docs/ paths always editable; regex `^Verdict:\s*READY$` (not fooled by NOT READY).
- Unconfigured lanes (device, codex, journal, speckit) degrade to skipped-with-reason.

## Testing

Scaffold round-trip asserts: 19 commands per agent, model frontmatter values, agents +
docs files present, process hooks merged into settings.json (PreToolUse + Stop) and
stripped by uninstall, gate/stop hook behavior on fixture repos (block/allow/inert),
`hooks_merge --guards/--process/--remove` matrix, clean uninstall.
