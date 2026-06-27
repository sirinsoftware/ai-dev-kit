# acme-api — Agent instructions

> Single source of truth. Codex and Copilot read this directly; Claude Code reads
> it via the `@AGENTS.md` import in CLAUDE.md. (Example — see ai-dev-kit/examples.)

## Project overview
acme-api is a TypeScript REST service for the Acme billing system. "Done" means:
endpoints documented in OpenAPI, tests green, and no new linter/type errors.

## Tech stack & layout
- Node 22, TypeScript 5, Fastify, Prisma (PostgreSQL), Vitest.
- `src/routes/` HTTP handlers · `src/services/` business logic · `src/db/` Prisma ·
  `test/` mirrors `src/`. Entry point: `src/server.ts`. Package manager: pnpm.

## Standards (read before writing code)
Follow `docs/ai-prompts/00-standards.md`. In brief:
- Strict TypeScript; no `any` without a `// reason:` comment. Errors via the
  `AppError` type, never bare `throw new Error`.
- Conventional Commits. Never commit secrets or `graphify-out/`.

## Development workflow
1. Brainstorm/clarify → 2. Plan small steps → 3. TDD (Vitest) → 4. Debug to root
cause → 5. Self-review the diff → 6. Run `pnpm verify` before declaring done.
Superpowers (if installed) enforces this; the Copilot cloud agent follows it here.

## Codebase knowledge graph (graphify)
Graph in `graphify-out/`. Use `graphify query "how does billing settlement work"`,
`graphify path "InvoiceService" "PrismaClient"`, `graphify explain "AppError"`.
After changes: `graphify update .`.

## Guardrails
- No pushes/PRs/migrations without an explicit ask.
- Ask before adding a dependency or changing a public route contract.
- Treat `src/db/migrations/` as append-only.
