Render a polished, self-contained HTML document for: **__ARG__** — a topic, a
report/plan you produced earlier in this session, or a path to a Markdown/text file.
If empty, ask me what to render.

Follow this repo's `AGENTS.md` -> **Output formats** for the required look and rules
(Catppuccin Mocha, fully self-contained, semantic HTML only where it helps). Match it exactly.

**Step 1 - Get the content.** If __ARG__ is a file, read it. If it's a topic
(e.g. "architecture overview", "this week's progress", "release notes"), gather facts
first - `git log`, `graphify query "..."`, the code - and don't speculate. If it refers
to a report/plan you already produced this session, reuse that content.

**Step 2 - Pick structure that fits.** From the Output-formats toolbox use only what aids
comprehension: sticky table of contents / anchors for multi-section docs; zebra tables with
a sticky header for comparisons; `<progress>` or styled meters for metrics, scores, or
completion; inline SVG for flows / architecture / relationships; collapsible `<details>`,
tabs, copy-to-clipboard on code blocks; callout/admonition boxes for notes and warnings.

**Step 3 - Emit one file.** Write a single self-contained `.html` (inline `<style>` +
vanilla `<script>`, no external deps, works offline) to `docs/reports/<slug>.html`. The
file's contents are raw HTML only - no Markdown and no prose outside the file.

**Step 4 - Report the path.** Tell me where you saved it and an open hint
(`open docs/reports/<slug>.html`).
