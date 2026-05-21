# TDD Plan Check

Use after drafting the TDD plan and before the first RED test. This is a bounded revision gate, not another planning ceremony.

## Bounded revision

Run the check against the draft plan. If it fails, revise the plan once and re-check. After two failed revisions, escalate to the user with the unresolved gaps instead of starting implementation.

## Required Checks

- **AC coverage:** every acceptance criterion is covered by a RED cycle, a named test, or an explicit `human-review:` / deferred rationale.
- **Dependency audit coverage:** every non-deferred dependency audit finding is represented in tests, lint/static guards, manual smoke, or implementation steps.
- **Architecture research:** required `Architecture Options Research` is complete, including package legitimacy if new dependencies are proposed.
- **Gray areas:** implementation decisions are resolved, or the backlog item is marked `human_required` with the exact question.
- **Verification shape:** the plan verifies exists / substantive / wired / functional, not only file existence.
- **Scope:** planned files/tests trace back to ACs, brownfield audit findings, or approved refactor/reuse rationale.

## Output

```markdown
## TDD Plan Check
**Status:** PASS | WARN | FAIL
**Revision:** 0 | 1 | 2
**Findings:**
- ...
```

FAIL blocks the first RED test. WARN is allowed only with a concrete accepted risk.
