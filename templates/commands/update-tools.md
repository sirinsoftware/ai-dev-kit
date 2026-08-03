Update ai-dev-kit's installed tools and rebuild this repo's code graph. Target: **__ARG__**
(default: the current repo).

1. **Run the updater.** Execute the kit's script (omit the path argument to default to the
   current repo):
   ```
   bash "$HOME/.ai-dev-kit/update.sh" __ARG__
   ```
   It upgrades graphify and spec-kit (via `uv`), rebuilds `graphify-out/` if a graph already
   exists, and prints notes for the tools it can't touch. Show me its output. If the script
   isn't found, tell me to (re)install ai-dev-kit — it lives at `~/.ai-dev-kit`.

2. **Agent plugins.** A shell can't drive `/plugin`, so the script only prints instructions.
   Surface them, and for Claude Code offer to walk me through updating **Superpowers** and
   **ponytail** via `/plugin`.

3. **Report** what was upgraded (with versions if the output shows them), what was skipped
   (not installed), and the manual plugin step still pending. Don't install anything the
   script didn't, and don't push.
