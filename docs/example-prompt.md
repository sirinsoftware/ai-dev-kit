# Worked example — implement a feature with the full toolchain

A copy-paste prompt that drives **one feature through every tool ai-dev-kit sets up**:
graphify (orient), Grep MCP (prior art), Superpowers /
the `AGENTS.md` workflow (plan + TDD), and private-journal (record decisions).

Works in Claude Code, Codex, or Copilot. Swap the feature in **bold** for your own.

## The prompt

```text
Implement rate limiting for our HTTP API. Use our full toolchain and follow our
workflow — don't jump straight to code.

1. Orient (graphify). Run:
     graphify query "how do incoming HTTP requests flow and where is middleware registered"
     graphify path "<router>" "<handler>"
   to find where a limiter should sit and what it touches. Summarize the integration points.

2. Prior art (Grep MCP). Search public repos via the Grep MCP for real-world rate-limiter
   middleware in our language (token-bucket / sliding-window). Show 2-3 concrete examples
   and their trade-offs — ground the design in how others actually do it.

3. Decide + record (private-journal). Choose an algorithm and config (limit, window,
   storage, per-key strategy). Record the decision AND the rationale in your journal so
   future sessions know why — e.g. "chose token-bucket backed by Redis because ...;
   rejected sliding-window-log because ...".

4. Plan + build (workflow). Write a failing test for the limiter first, implement it, wire
   it into the integration points from step 1, then run the test / lint / typecheck commands from
   AGENTS.md. Self-review the diff against the Standards (including Code review).

5. Wrap up. Summarize what changed, run `graphify update .` to refresh the graph, and tell
   me what you recorded in the journal. Don't push or open a PR.
```

## What each tool does here

| Step | Tool | Role |
|---|---|---|
| 1 | **graphify** | Map the codebase — where the feature plugs in and what it touches (recall, not grep) |
| 2 | **Grep MCP** | Ground the design in real implementations across ~1M public repos |
| 3 | **private-journal** | Persist the design decision + rationale across sessions |
| 4 | **Superpowers** / `AGENTS.md` workflow | Enforce plan -> failing test -> implement -> verify |
| 5 | **graphify update .** | Keep the graph current after the change |

## Notes

- **Tool availability.** graphify is on by default; Grep MCP needs `--with-grep`,
  private-journal needs `--with-journal`. If a tool isn't installed, the agent
  will just skip that step.
- **Superpowers** enforces the brainstorm -> plan -> TDD -> review flow in **Claude Code**.
  Codex and the Copilot cloud agent can't run the plugin, so they follow the same flow from
  the **Development workflow** section of `AGENTS.md`.
- **Want an HTML write-up of the result?** Add "...and give me an HTML report of the change"
  or run `/report-html` afterward (see `AGENTS.md` -> Output formats).
- **Adapt freely.** This is one ordering that uses every tool; on a real task the agent may
  loop (e.g. re-query graphify after finding prior art). The point is the habit: orient ->
  prior art -> decide+record -> TDD -> verify.
