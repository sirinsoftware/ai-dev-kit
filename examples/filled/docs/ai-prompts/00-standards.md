# Project standards — acme-api (example)

A worked example of a filled-in standards file.

## 1. Code standards
Strict TypeScript (`strict: true`). No `any` without `// reason:`. Pure functions in
`src/services`; side effects only in routes/db. Errors as `AppError`. Named exports.

**Formatter / style command(s):**
```bash
pnpm format        # prettier --write . && eslint --fix
```

## 2. Commit message standards
Conventional Commits: `type(scope): summary` (feat, fix, chore, refactor, test, docs).
Imperative mood, ≤72-char summary, body explains *why*.

**Example:**
```
fix(billing): round settlement amounts to 2 decimals

Floating-point drift produced 3-decimal totals on multi-currency invoices.
Closes #412.
```

## 3. Pull request standards
One concern per PR, < ~400 changed lines. Title = Conventional Commit summary.
CI (lint + types + tests) must pass. Link the issue.

**PR description format:**
```
## What & why
## Changes
## Testing
## Risks / rollout
Closes #<id>
```

## 4. Static analysis tools
| Purpose | Command |
|---|---|
| Lint        | `pnpm eslint .` |
| Type check  | `pnpm tsc --noEmit` |
| Security    | `pnpm audit --prod` |
| Other       | `pnpm prettier --check .` |

## 5. Tests
```bash
pnpm test          # vitest run --coverage
```
**Coverage target:** 85% lines on `src/services/**`.

## 6. Testing on a real device / environment
Validate against the staging Postgres + a seeded tenant before merge.

**Run on real device/environment:**
```bash
./scripts/test-on-staging.sh
```
**Prerequisites:** `STAGING_DATABASE_URL` set; VPN connected; `pnpm db:seed:staging` run once.
