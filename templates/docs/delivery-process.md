# Delivery process — reference

Eight phases for agentic feature development, installed by
[ai-dev-kit](https://github.com/VM-development/ai-dev-kit) as slash commands.
This is a reference, not a prescription — see "Right-sizing" at the end for what to
skip. Task-oriented guides: [develop a feature](guides/develop-a-feature.md) ·
[test a feature](guides/test-a-feature.md).

## Why phases

A coding agent left in one mode does all the jobs badly at once: it plans while
implementing, reviews the code it just wrote, and declares success from the context
that produced the work. Phases buy three things:

- **Different cognitive modes** — planning and review are different tasks; one pass
  either rubber-stamps or drowns.
- **Different contexts** — a reviewer that shares the implementer's context is not a
  reviewer. Phase boundaries are where context gets thrown away on purpose.
- **Different models** — enumerating failure modes deserves a frontier model; finding
  filler is pattern-matching for the cheapest one. You can only route by model at a
  boundary.

`critique` and `review` carry most of the weight; `shard` and `report` are
conveniences.

## The commands

Happy path (three commands): **`/prepare` → `/execute` → `/verify-feature`**.
Artifacts live in `docs/process/<slug>/`; `<slug>` is the kebab-case feature name and
the branch name.

| Command | Phase | Exit artifact / verdict |
|---|---|---|
| `/research <feature>` | what is true today? | `context.md` + Unknowns for a human |
| `/plan-feature <slug>` | what are we building? | `plan.md` — tasks + slices + test matrix + failure matrix |
| `/critique <slug>` | what is wrong with the plan? | `critique.md`; plan revised |
| `/defend <slug>` | does it survive hostile questioning? | `defense.md` → `Verdict: READY` / `NOT READY` |
| `/shard <slug>` | what runs in parallel? | worktrees + per-slice `TASK.md` |
| `/review-fresh <slug>` | does the diff do what was asked? | `review.md` → APPROVE / REQUEST_CHANGES / NEEDS_HUMAN |
| `/ship-report <slug>` | should we deploy? | `report.md` → RECOMMEND DEPLOY / HOLD |
| `/verify-prod <slug>` | does it work in production? | `prod-verify.md` (read-only) |
| `/prepare <feature>` | combo: research→plan→critique→defend | defended plan, READY/NOT READY |
| `/execute <slug>` | implement (gated on READY) | code + green unit tests, committed locally |
| `/verify-feature <slug>` | combo: verify + finish | `verify.md`, `commit-message.md`, `pr-description.md` |

## The retrieval rule

Before reading files, in order: **graphify** ("what connects A to B" without opening
40 files) → **Grep MCP** (how it's done outside this repo) → only what survives those
→ read files, then reason. A text grep that misses a differently-formatted call site
produces a confidently wrong plan; the structural graph does not have that failure mode.

## Model routing

Route by task difficulty, not phase importance. In Claude Code the kit bakes this into
each command's `model:` frontmatter (edit the files under `.claude/commands/` to
retune); Codex has no per-prompt routing — start the session with `codex -m <model>`;
Copilot picks the model in the session picker.

| Tier | Commands | Why |
|---|---|---|
| top (opus) | plan-feature, critique, defend, review-fresh, prepare, execute, verify-feature | long-horizon reasoning; edge-case enumeration is the largest capability gap |
| mid (sonnet) | research, shard, ship-report, verify-prod | retrieval and bookkeeping |
| cheapest (haiku) | critic-minimalism subagent | slop detection is pattern-matching |

Same-vendor critics disagree less than they appear to. The one genuinely uncorrelated
reviewer is cross-vendor: `/critique` and `/verify-feature` shell out to `codex exec`
in the background when the Codex CLI is installed.

## Enforcement (optional)

Prose is advice; hooks are rules. `setup.sh --with-process-hooks` (Claude-only) adds:

- **process-gate** (PreToolUse): blocks production-code edits on a branch whose
  `docs/process/<branch>/defense.md` lacks `Verdict: READY`. Inert on branches without
  a process dir; `docs/` always editable.
- **process-stop** (Stop): refuses to end the session while
  `docs/process/<branch>/.verify-state.json` says `"tests": "red"`. Reads state written
  by `/execute`/`/verify-feature`; never runs tests itself.

Escape hatch for both: `ADK_PROCESS_OFF=1`. Both fail open on unexpected errors.

## Right-sizing (where this process is wrong)

Eight phases is too many for most changes. The honest minimum is
**research → plan (with test matrix) → review (fresh context)** — which is `/prepare`
with critique/defend kept light, then `/execute`, then `/verify-feature`.

- Add full `critique` + `defend` weight when a change touches more than one service or
  writes data that cannot be regenerated.
- Add `/shard` only when the work genuinely parallelizes.
- Add `/verify-prod` when you have production users.
- A bug fix needs none of this — fix it.

The bottleneck is usually planning quality, not review quantity: before adding a
critic, check that the acceptance criteria are actually observable (Given/When/Then).
Journal writes are the only compounding part of the whole process — a three-phase run
that writes the journal beats an eight-phase run that doesn't. Test the process like
code: after a real feature, ask which phase caught something; cut the ones that
didn't, two features running.
