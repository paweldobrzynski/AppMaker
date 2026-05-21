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

## Reuse / Refactor-First Decision

Before proposing new modules, helpers, routes, statuses, UI components, lint guards, or parallel code paths, identify existing code that already owns adjacent behavior.

For each candidate, decide:
- **reuse** — call the existing function/component unchanged
- **extend** — add a parameter/branch to the existing owner because the new behavior is the same concept
- **extract** — factor a shared helper because two real call sites now exist
- **replace** — migrate old special-case code to the more general owner
- **add-new** — only when the existing owner would become less clear or the concept is genuinely distinct

`add-new` requires a written rationale in the audit. "Faster" is not enough; explain why reuse/extend/extract would make the old code worse or violate ownership.

## Visual System / CSS Reuse

For UI work, visual elements must be reusable and CSS-defined. Do not hardcode visual styling in markup or inline JavaScript unless it is layout-only state that cannot reasonably live in CSS.

Before adding or changing UI:
- find existing design tokens, CSS primitives, component classes, and local variants
- search for existing visual families (`button`, `card`, `row`, `modal`, `badge`, `tab`, `input`, `empty`, `toast`, etc.)
- prefer reusing an existing class/component
- add a documented variant only when the existing primitive cannot express the new state clearly
- forbid new hand-rolled `style=`, `element.style.cssText`, inline colors, inline spacing, one-off shadows, one-off radii, and feature-specific visual class families without rationale

Acceptable inline style exceptions must be documented as layout/state-only, for example `display:none`, measured dimensions from runtime geometry, or position coordinates. Color, typography, spacing, border, radius, shadow, and hover/focus visuals belong in CSS.

## Design Standards Compliance

For every touched or newly introduced visual element, check it against existing project standards before implementation:
- design tokens and theme variables
- existing component primitives and variants
- UI pattern docs / component inventory
- size, radius, spacing, typography, color, icon, and density conventions
- states: default, hover, focus, active/selected, disabled, loading, error, empty, responsive/mobile
- accessibility basics: keyboard focus visibility, semantic element, contrast, target size

If the element does not match an existing standard, either adapt it to the standard or propose a new documented primitive/variant. Do not ship a one-off visual because it "looks fine" in one screen.

## Required Angles

1. **Reuse / refactor-first decision** — existing owners/helpers/components, whether to reuse/extend/extract/replace/add-new, and the rationale for any new parallel code.
2. **Visual system / CSS reuse** — existing design tokens/classes/components, no hardcoded visual styling, CSS-defined variants for new visual states.
3. **Design standards compliance** — every touched visual element follows existing standards for tokens, components, states, accessibility, and responsive behavior.
4. **Canonical values / hardcoded contracts** — statuses, enum-ish strings, template keys, column names, CSS class names, ScriptProperties, route/action names, magic constants. Include exact-value and likely alias/case searches.
5. **Data model and read/write paths** — readers, writers, derivations, migrations, caches, validators, renderers.
6. **API / caller graph** — public entrypoints, wrappers, scheduled jobs, web endpoints, agent/tool schemas, external integrations.
7. **UI / client mirrors** — inline JS, duplicated validators, disabled-state mirrors, selectors, dynamic `className` / `cssText`, docs examples used as copy/paste source.
8. **Side-effect order** — guards before Drive/Sheets/DB/Calendar/email/audit/cache effects; idempotency, locks, rollback, cache invalidation.
9. **Tests / lint / docs / memory** — existing tests that encode the contract, new guards to add, docs/wiki/glossary updates, smoke checks.
10. **Backward compatibility / rollout** — legacy aliases, existing data, old clients, deployment/version pins, browser/App Script cache, manual smoke surfaces.

## TDD Contract

Every non-deferred dependency found here must appear in the TDD plan as:
- a RED/GREEN cycle,
- an added/updated guard,
- a reuse/extend/extract/replace refactor step,
- a CSS primitive/variant instead of inline visual styling,
- a design-standard compliance fix for every touched visual element,
- a manual smoke item,
- or an explicit deferred item with reason and risk.

Unexplained "not touched" is not allowed.
