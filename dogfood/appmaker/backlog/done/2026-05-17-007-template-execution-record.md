---
id: 007
slug: template-execution-record
status: done
completed: 2026-05-17
labels: [feature, template]
execution_class: autonomous
blocked_by: []
traces_to: [pcrit-001]
feature: 002-plan-evidence-drift-detection
user_stories_covered: []
context_packets: []
touches:
  files:
    - plugin/appmaker/resources/appmaker/templates/backlog-item-template.md
    - tests/smoke/test-backlog-execution-record.sh
created: 2026-05-17
source: decompose
---

# 007: Backlog template gets ## Execution Record section

## Parent

`dogfood/appmaker/features/002-plan-evidence-drift-detection/prd.md`

## What to build

Extend `plugin/appmaker/resources/appmaker/templates/backlog-item-template.md` with new `## Execution Record` section between existing `## Acceptance criteria` and `## Blocked by`. Section uses Codex's exact field layout (9 structured fields).

Section format (from PRD pcrit-001):

```
## Execution Record

**Base ref:** <sha | no_base_ref>
**Dirty at start:** yes/no
**Dirty files at start:**
- ...

**Planned files:**
- ...

**Planned tests:**
- ...

**Actual files:**
- ...

**Tests run:**
- ...

**AC completed:** <n>/<n>

**Drift notes:**
- ...
```

Field semantics block in template doc gets brief notes documenting Execution Record fields. New smoke test `tests/smoke/test-backlog-execution-record.sh` asserts template has section + all 9 bolded field labels.

## Acceptance criteria

- [x] Template example block has `## Execution Record` heading positioned between `## Acceptance criteria` and `## Blocked by` (traces_to: pcrit-001, test: `tests/smoke/test-backlog-execution-record.sh` — ordering assertion PASS)
- [x] All 9 bolded field labels present in example (Base ref, Dirty at start, Dirty files at start, Planned files, Planned tests, Actual files, Tests run, AC completed, Drift notes) (traces_to: pcrit-001, test: `tests/smoke/test-backlog-execution-record.sh` — 9 field assertions PASS)
- [x] Template doc Rules section documents Execution Record fields with brief notes (traces_to: pcrit-001, human-review: rule explains Base ref, dirty fields, planned/actual fields, AC completed, Drift notes)
- [x] Full smoke suite passes — new test integrates cleanly via glob auto-discovery, no regression in existing 50 assertions (traces_to: pcrit-001, test: `tests/smoke/run-all.sh` — 9 suites, 62/62 PASS)

## Blocked by

None — can start immediately.

## Review (Manual, 2026-05-17)

**Status:** PASS
**Scope:** `backlog-item-template.md` + `test-backlog-execution-record.sh`
**AC coverage:** 4/4

### Findings

None.

### Notes

- RED was meaningful: new smoke test failed 11 assertions before the template edit.
- Test anchors both section order and all 9 field labels, so a prose-only mention cannot pass.
- The semantics are documented in `## Rules`, keeping the Field semantics table focused on frontmatter fields.
