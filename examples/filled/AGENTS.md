# acme-api — Agent instructions

> A worked, filled-in example. Codex and Copilot read this directly; Claude Code
> reads it via the `@AGENTS.md` import in CLAUDE.md.

## Project overview
acme-api is a TypeScript REST service for the Acme billing system. "Done" means:
endpoints documented in OpenAPI, tests green, no new linter/type errors.

## Tech stack & layout
- Node 22, TypeScript 5, Fastify, Prisma (PostgreSQL), Vitest. Package manager: pnpm.
- `src/routes/` HTTP handlers · `src/services/` logic · `src/db/` Prisma · `test/` mirrors `src/`.

## Standards

### Code
Strict TypeScript (`strict: true`). No `any` without a `// reason:` comment. Pure
functions in `src/services`; side effects only in routes/db. Errors as `AppError`.
- Formatter / style command: `pnpm format`
- Never commit secrets, generated artifacts, or `graphify-out/`.

### Commit messages
Conventional Commits: `type(scope): summary` (feat, fix, chore, refactor, test, docs).
Imperative mood, ≤72-char summary; body explains *why*. Example:
`fix(billing): round settlement amounts to 2 decimals`.

### Pull requests
One concern per PR, < ~400 changed lines. Title = Conventional Commit summary. CI must pass.

PR description format (used by `/pr-review`):
```
## What & why
## Changes
## Testing
## Risks / rollout
Closes #<id>
```

### Static analysis — run and pass before opening a PR
- Lint: `pnpm eslint .`
- Type check: `pnpm tsc --noEmit`
- Security: `pnpm audit --prod`

### Tests
- Run the suite: `pnpm test`
- Coverage target: 85% lines on `src/services/**`

### Real device / environment
Validate against staging Postgres + a seeded tenant before merge.
- Run: `./scripts/test-on-staging.sh`
- Prerequisites: `STAGING_DATABASE_URL` set; VPN connected; `pnpm db:seed:staging` run once.

## Development workflow
1. Brainstorm/clarify → 2. Plan small steps → 3. TDD (Vitest) → 4. Debug to root
cause → 5. Self-review the diff → 6. Run `pnpm verify` before declaring done.

## Reusable commands
`/pr-review <ref>`, `/progress-report <period>`, `/deep-test <target>`,
`/repeatable-task <task>` (Codex: `/prompts:<name>`).

## Codebase knowledge graph (graphify)
Graph in `graphify-out/`. Use `graphify query "how does billing settlement work"`,
`graphify path "InvoiceService" "PrismaClient"`. After changes: `graphify update .`.

## Guardrails
- No pushes/PRs/migrations without an explicit ask. Treat `src/db/migrations/` as append-only.
- Ask before adding a dependency or changing a public route contract.
