# Brownfield Impact Audit

Use before TDD on existing systems. The goal is to find dependency surfaces before implementation, not after review.

## Gate

If `project_mode: brownfield`, or the backlog item touches existing production code, `## Brownfield Impact Audit` must be complete before the first RED test.

Determine mode:

```bash
PROJECT_MODE=$(grep '^project_mode:' appmaker/config.yaml 2>/dev/null | awk '{print $2}')
PROJECT_MODE="${PROJECT_MODE:-brownfield}"
```

Greenfield work may write:

```markdown
**Mode:** greenfield
**Audit status:** not_applicable
```

## Evidence Standard

Use `rg` first. For every value or contract added, changed, renamed, removed, or gated, record:
- exact search query
- files/occurrences found
- owner/consumer/mirror
- decision: migrate, guard, alias, test, lint, docs, defer, or intentionally keep

The audit is not complete if it only contains prose.

## Required Angles

1. **Canonical values / hardcoded contracts** — statuses, enum-ish strings, template keys, column names, CSS class names, ScriptProperties, route/action names, magic constants. Include exact-value and likely alias/case searches.
2. **Data model and read/write paths** — readers, writers, derivations, migrations, caches, validators, renderers.
3. **API / caller graph** — public entrypoints, wrappers, scheduled jobs, web endpoints, agent/tool schemas, external integrations.
4. **UI / client mirrors** — inline JS, duplicated validators, disabled-state mirrors, selectors, dynamic `className` / `cssText`, docs examples used as copy/paste source.
5. **Side-effect order** — guards before Drive/Sheets/DB/Calendar/email/audit/cache effects; idempotency, locks, rollback, cache invalidation.
6. **Tests / lint / docs / memory** — existing tests that encode the contract, new guards to add, docs/wiki/glossary updates, smoke checks.
7. **Backward compatibility / rollout** — legacy aliases, existing data, old clients, deployment/version pins, browser/App Script cache, manual smoke surfaces.

## TDD Contract

Every non-deferred dependency found here must appear in the TDD plan as:
- a RED/GREEN cycle,
- an added/updated guard,
- a manual smoke item,
- or an explicit deferred item with reason and risk.

Unexplained "not touched" is not allowed.
