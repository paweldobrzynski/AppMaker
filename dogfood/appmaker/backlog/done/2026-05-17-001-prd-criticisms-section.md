---
id: 001
slug: prd-criticisms-section
status: done
completed: 2026-05-17
labels: [feature, template]
execution_class: autonomous
blocked_by: []
traces_to: [pcrit-001]
feature: 001-method-compliance-pass-1
user_stories_covered: []
context_packets: []
touches:
  files:
    - plugin/appmaker/skills/prd/SKILL.md
    - tests/smoke/test-prd-criticisms.sh
created: 2026-05-17
source: decompose
---

# 001: PRD Criticisms Section

## Parent

`dogfood/appmaker/features/001-method-compliance-pass-1/prd.md`

## What to build

Extend PRD template (in `plugin/appmaker/skills/prd/SKILL.md` step 4 template body) to include explicit `## Criticisms` section with stable `pcrit-NNN` numbered list convention. Section appears between `## Clarifications` and `## Problem Statement` in the template (or place adjacent — choose what reads natural). Each pcrit item is a tight statement of what the system must do or NOT do, with explicit verification mechanism (auto-check OR human-review-with-criteria).

Anchor point for downstream `traces_to: [pcrit-*]` references in decomposition and backlog items.

## Acceptance criteria

- [x] `prd/SKILL.md` template body has `## Criticisms` heading with at least 1 example `pcrit-NNN` item (traces_to: pcrit-001, test: `tests/smoke/test-prd-criticisms.sh` — 3/3 PASS 2026-05-17)
- [x] Template documents verification mechanism per pcrit (auto-check / human-review-with-criteria) (traces_to: pcrit-001, human-review — `Per criterion: verification mechanism explicit — auto-check (scripted) OR human-review-with-criteria (documented rule)` present in new section; pending critic-subagent confirmation)
- [x] Full smoke suite passes via `bash tests/smoke/run-all.sh` — 25/25 PASS (22 pre-existing + 3 new), exit 0 (traces_to: pcrit-001, test: `tests/smoke/run-all.sh`)
- [x] Existing prd skill behavior unchanged — Understanding (7 subsections) + Clarifications + Implementation Decisions + Testing Decisions sections intact, edit was pure insert between Clarifications and Problem Statement (traces_to: pcrit-001, human-review — pending critic-subagent confirmation)

## Blocked by

None — can start immediately.

## Review (Manual — Codex advisor, 2026-05-17)

**Status:** PASS (after fix)
**Reviewer:** Codex (advisor, operator-relayed)
**AC coverage:** 4/4
**Scope:** diff against prd/SKILL.md + tests/smoke/test-prd-criticisms.sh

### Findings

| Severity | Category | File:Line | Description |
|---|---|---|---|
| critical | test-quality | `tests/smoke/test-prd-criticisms.sh:26` (initial) | Regex `pcrit-[0-9N]+` matched any prose mention, not list items. AC required "example `pcrit-NNN` ITEM" (list bullet). Test would pass false-positive even if `## Criticisms` had only prose without actual list items. |

### Fix applied

Regex strengthened: `pcrit-[0-9N]+` → `^- \*\*pcrit-[0-9]{3}:\*\*`. Now requires markdown bullet + bold + canonical 3-digit ID. Stricter than AC literal (which says "pcrit-NNN") — bound to canonical numeric form per `checklist/SKILL.md:100-104`.

**Re-verified after fix:** test 3/3 PASS, full suite 25/25 PASS, no regression.

### Notes

- **Lesson worth durable memory:** Test weakness caught by manual review, NOT by writing test from AC verbatim. Initial test was AC paraphrase, not AC enforcement. Review-gate value demonstrated even on +9-line slice. Candidate for `memory/wiki/testing.md` synthesis at archive retro.
- **Slice 001 establishes new PRD contract (`## Criticisms` section).** Per Codex framing: this is the right place for full review gate, not a "tiny doc edit". Future v0.2.18 slices: 002 also new contract (AC `test:` refs) → per-slice review. 003/004 docs drift → batch review OK. 005 human_required → operator decision.
- Glossary: 0 violations
- Memory wiki gotchas: 0 repeated

