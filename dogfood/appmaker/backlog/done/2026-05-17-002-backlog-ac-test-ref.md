---
id: 002
slug: backlog-ac-test-ref
status: done
completed: 2026-05-17
labels: [feature, template]
execution_class: autonomous
blocked_by: []
traces_to: [pcrit-002]
feature: 001-method-compliance-pass-1
user_stories_covered: []
context_packets: []
touches:
  files:
    - plugin/appmaker/resources/appmaker/templates/backlog-item-template.md
    - tests/smoke/test-backlog-template-test-ref.sh
created: 2026-05-17
source: decompose
---

# 002: Backlog AC test: reference

## Parent

`dogfood/appmaker/features/001-method-compliance-pass-1/prd.md`

## What to build

Extend backlog item template (`plugin/appmaker/resources/appmaker/templates/backlog-item-template.md`) acceptance criteria section to support inline `test:` reference per AC, alongside existing `traces_to:`. New canonical format:

```
- [ ] <description> (traces_to: pcrit-NNN, test: <test_file>::<test_name>)
```

`test:` field is optional in template (some AC have only `human-review`, no test). When AC has corresponding test, the reference creates explicit AC↔test name mapping — closes audit gap M2 (AC↔test name not durable, drift surface on code rename).

Update field semantics table in template doc to document `test:` field. Example block in template demonstrates both with-test and without-test forms.

## Acceptance criteria

- [x] `backlog-item-template.md` example block shows CONCRETE AC with inline `test: <file>.<ext>::<name>` syntax (NOT placeholder — per Codex contract #1) (traces_to: pcrit-002, test: `tests/smoke/test-backlog-template-test-ref.sh` — 5/5 PASS 2026-05-17, concrete-form assertion enforced)
- [x] Template documents `test:` as optional + applies to executable tests (rule item in `## Rules` section bundles all annotation semantics) (traces_to: pcrit-002, human-review: `test: optional for executable tests` present in Rules; test regex `test:.*optional` enforces)
- [x] Example shows form WITHOUT test (human-review with criterion — per Codex contract #2 + #3) (traces_to: pcrit-002, test: `tests/smoke/test-backlog-template-test-ref.sh` — human-review form assertion + criterion docs assertion both PASS)
- [x] Full smoke suite passes via `bash tests/smoke/run-all.sh` — 5 suites, 30/30 PASS (25 pre-existing + 5 new), zero regression (traces_to: pcrit-002, test: `tests/smoke/run-all.sh`)
- [x] Decompose skill behavior unchanged — `decompose/SKILL.md` has no `test:` requirement check; new template additions forward-only, old AC items remain valid (traces_to: pcrit-002, human-review: verified by reading decompose/SKILL.md guardrails section)

## Blocked by

None — can start immediately.

## Review (Self-check against Codex criteria, 2026-05-17)

**Status:** PASS pending operator/Codex sign-off
**AC coverage:** 5/5
**Scope:** diff against `backlog-item-template.md` + `tests/smoke/test-backlog-template-test-ref.sh`

### Codex 3-criterion contract check

| # | Criterion | Verification | Result |
|---|---|---|---|
| 1 | CONCRETE test: ref (not placeholder) | Test regex requires `\.(sh\|ts\|js\|py\|go\|rs\|md)::<identifier>` — placeholder `<test_file>` rejected | ✓ enforced |
| 2 | Example AC without test (human-review form) | Test regex matches `\(traces_to:[^)]*human-review` in template | ✓ enforced |
| 3 | Docs say `test:` optional + `human-review:` requires criterion | Both regexes match Rules item (single bundled line covers both) | ✓ enforced |

### Findings

| Severity | Category | File:Line | Description |
|---|---|---|---|
| (none) | — | — | — |

### Self-review against slice 001's failure mode

Slice 001's test was AC paraphrase that false-positived on prose. Slice 002 test was written from Codex's 3 explicit criteria with anti-patterns:
- Concrete check actively rejects placeholder syntax (extension required)
- Human-review check requires the annotation form in parens (not just word "human-review" in prose)
- Field semantics check requires both terms on same line (not scattered across docs)

If someone reverts template to placeholder-only example, concrete check fails (no `.ext`). If someone removes human-review example, that check fails. If someone rewords Rules to separate test/human-review docs across multiple bullets, criterion check might miss — moderate risk but acceptable (rewording is deliberate user action).

### Notes

- Glossary: 0 violations
- Memory wiki gotchas: 0 repeated
- **Pending:** operator (Pawel) eyeball OR `/appmaker:review 002` subagent invocation before slice 003.
- Both slice 001 and slice 002 established new artifact contracts. Slices 003/004 are docs drift (mechanical) — eligible for batch review per earlier Codex framing.

