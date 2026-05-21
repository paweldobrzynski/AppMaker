# Review Contract

## Reviewer checklist

Pass this checklist to the configured reviewer:

1. Code quality: idiomatic, readable, maintainable.
2. Constitution compliance: real integration boundaries and promote-green rule.
3. Glossary consistency: no invented synonyms for canonical terms.
4. AC coverage: every AC has corresponding `test:` or `human-review:`.
5. Plan-vs-actual drift: compare `## Approved TDD Plan`, planned files/tests, actual files/tests, and drift notes.
6. Brownfield impact audit coverage: every changed canonical value, hardcoded contract, UI/client mirror, side-effect path, and dependency found in `## Brownfield Impact Audit` is either implemented, tested, lint-guarded, or explicitly deferred with rationale. Missing dependency sweep = review FAIL for brownfield work.
7. Reuse/refactor-first rationale: new helpers, modules, UI components, statuses, schemas, or parallel paths must show why existing code could not be reused, extended, extracted, or replaced. Unjustified add-new = review FAIL for brownfield work.
8. Test quality: behavior through public interface, not implementation details.
9. Surgical changes: changed lines trace back to the requested scope.
10. Security and performance flags.
11. Graph context coverage: changed files match expected touched communities/files, or drift is justified.
12. Memory regression: change does not repeat a known testing or integration gotcha.

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
- Brownfield impact audit: complete; 0 unexplained dependencies
- Reuse/refactor-first: add-new decisions justified
- Memory wiki gotchas: 0 repeated
```

Omit the findings table and notes lines when empty. Do not create separate sections for critical/suggestions/constitution/glossary/AC if each has 0-1 item.
