# Superpowers

**There is no `Superpowers.md` file to download.** Superpowers
([github.com/obra/superpowers](https://github.com/obra/superpowers), by Jesse
Vincent / "obra", MIT) is a **plugin / skills bundle + development methodology**,
distributed through each agent's plugin marketplace — not a markdown file you
vendor into a repo.

It ships a set of composable skills (brainstorming, writing/executing plans,
test-driven development, systematic debugging, subagent-driven development,
requesting/receiving code review, verification-before-completion, using git
worktrees, and more) plus a `using-superpowers` bootstrap skill that loads them
from the first message of a session. The effect is a disciplined pipeline:
clarify → plan → TDD → debug systematically → review → verify.

## How ai-dev-kit handles it
During `setup.sh` you are **asked** whether to install Superpowers from
`github.com/obra/superpowers`. If you say yes, it is installed per enabled agent:

| Agent | Install |
|---|---|
| **Claude Code** | `claude plugin marketplace add obra/superpowers-marketplace` then `claude plugin install superpowers@superpowers-marketplace` (or the official `/plugin install superpowers@claude-plugins-official`). Run `/reload-plugins` or restart. |
| **Codex** | Interactive only: run `codex`, then `/plugins`, select `superpowers`. |
| **Copilot CLI** | `copilot plugin marketplace add obra/superpowers-marketplace` then `copilot plugin install superpowers@superpowers-marketplace`. |
| **Copilot cloud agent** | Can't run plugins. The methodology is carried by the **"Development workflow"** section baked into `AGENTS.md`. |

## Notes & gotchas
- Updates are agent-dependent and often automatic; in Claude Code, run
  `/reload-plugins` when prompted. There's no dedicated `superpowers update` command.
- Two marketplaces exist with overlapping plugin names
  (`claude-plugins-official` and `obra/superpowers-marketplace`). If
  `/plugin install` hits a name collision, try the other source.
- Superpowers is model-agnostic — it does **not** choose which model your agent
  uses; that stays in each agent's own config.
- It also works with Cursor, Gemini CLI, Antigravity, Kimi Code, OpenCode, Pi,
  and Factory Droid via their own install paths (see the upstream README).
