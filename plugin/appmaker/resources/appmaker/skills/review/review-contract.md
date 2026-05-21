# Review Contract

## Reviewer checklist

Pass this checklist to the configured reviewer:

1. Code quality: idiomatic, readable, maintainable.
2. Constitution compliance: real integration boundaries and promote-green rule.
3. Glossary consistency: no invented synonyms for canonical terms.
4. AC coverage: every AC has corresponding `test:` or `human-review:`.
5. Plan-vs-actual drift: compare `## Approved TDD Plan`, planned files/tests, actual files/tests, and drift notes.
6. TDD Plan Check: `## TDD Plan Check` is PASS or accepted WARN before first RED; plan covers ACs, dependency audit findings, and verification shape. Missing/FAIL plan check = review FAIL.
7. Architecture Options Research: high-impact architecture/library/vendor/storage/auth/design-system decisions cite local context plus Ref/GitHub/official docs, include an options matrix, rejected options, reversal cost, and Package / dependency legitimacy for new packages. Source-free architecture decision = review FAIL.
8. Brownfield impact audit coverage: every changed canonical value, hardcoded contract, UI/client mirror, side-effect path, and dependency found in `## Brownfield Impact Audit` is either implemented, tested, lint-guarded, or explicitly deferred with rationale. Missing dependency sweep = review FAIL for brownfield work.
9. QA / Smoke Plan: changed surfaces have a concrete smoke plan and evidence, especially browser/screenshot evidence for UI. Missing QA plan for operator-visible or integration work = review FAIL unless explicitly deferred.
10. Reuse/refactor-first rationale: new helpers, modules, UI components, statuses, schemas, or parallel paths must show why existing code could not be reused, extended, extracted, or replaced. Unjustified add-new = review FAIL for brownfield work.
11. Visual system compliance: UI changes use reusable CSS/component primitives; new visual variants are defined in CSS, not hardcoded via inline `style`, `cssText`, one-off colors, one-off spacing, one-off radii, or feature-specific visual families without rationale. Unjustified hardcoded visual = review FAIL.
12. Design standards compliance: every touched visual element follows existing tokens, component patterns, sizing/radius/spacing/typography conventions, interactive states, accessibility basics, and responsive behavior. Unexplained visual drift = review FAIL.
13. Implementation verification: completed artifacts are checked as exists / substantive / wired / functional. Existence-only verification = review FAIL.
14. Documentation staleness: docs that describe changed commands, workflows, APIs, UI behavior, or project structure are updated or explicitly marked not_applicable. Unexplained stale docs = WARN/FAIL by impact.
15. `edit_scope` drift: actual changed files obey backlog `edit_scope.allow` and avoid `edit_scope.forbid`; violations require explicit drift notes or user approval.
16. Adversarial review: high-risk diffs (auth, payments, data loss, migrations, security, broad refactors) need `/appmaker:review --mode=adversarial` or `--mode=ultra`, or a documented deferral.
17. Test quality: behavior through public interface, not implementation details.
18. Surgical changes: changed lines trace back to the requested scope.
19. Security and performance flags.
20. Graph context coverage: changed files match expected touched communities/files, or drift is justified.
21. Memory regression: change does not repeat a known testing or integration gotcha.

## Ultra mode

`--mode=ultra` delegates bug-finding to Claude Code `/ultra-review`, then AppMaker still runs the compliance layer: constitution, glossary, AC coverage, graph context, memory regression, and plan-vs-actual drift. Status is PASS only if both layers pass.

Fallback to local review only with an explicit warning if `/ultra-review` is unavailable, quota-limited, or unsupported in the current Claude Code installation.

## Compact review template

```markdown
## Review

**Status:** PASS | FAIL
**Date:** <YYYY-MM-DD>
**Subagent:** <reviewer>
**AC coverage:** <n>/<n>

### Findings

| Severity | Category | File:Line | Description |
|---|---|---|---|
| critical | constitution | `domain/bps.js:42` | Rule 3 violation: mock used in integration test |
| suggestion | quality | `tests/bps.test.js:88` | Extract `useTheme` hook to separate file |

### Notes
- Glossary: 0 violations
- TDD Plan Check: PASS/WARN; no unresolved gray areas
- Architecture Options Research: complete when required; decision sources cited
- Brownfield impact audit: complete; 0 unexplained dependencies
- QA / Smoke Plan: complete or deferred with risk
- Verification shape: exists / substantive / wired / functional
- Documentation staleness: checked
- edit_scope: obeyed or drift justified
- Adversarial review: complete when required
- Reuse/refactor-first: add-new decisions justified
- Visual system: no hardcoded visuals
- Design standards: touched elements follow existing patterns
- Memory wiki gotchas: 0 repeated
```

Omit the findings table and notes lines when empty. Do not create separate sections for critical/suggestions/constitution/glossary/AC if each has 0-1 item.
