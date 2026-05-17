---
id: 010
slug: method-status-mvp-under-validation
status: done
completed: 2026-05-17
labels: [docs]
execution_class: autonomous
blocked_by: []
traces_to: [pcrit-004]
feature: 002-plan-evidence-drift-detection
user_stories_covered: []
context_packets: []
touches:
  files:
    - METHOD.md
created: 2026-05-17
source: decompose
---

# 010: METHOD.md Open invariants #2 status flip

## Parent

`dogfood/appmaker/features/002-plan-evidence-drift-detection/prd.md`

## What to build

Update METHOD.md "Open invariants worth testing" section #2 (plan-vs-actual drift detection). Current text describes it as v0.3 candidate / missing audit ogniwo. Replace with honest MVP framing:

**Honest replacement language:**
- Status changes from "v0.3 candidate" to "**MVP under validation in v0.2.19**"
- Explicit caveat: captures Plan + Actual + Drift notes in `## Execution Record` per slice; does NOT implement auto-diff or checklist enforcement; those remain v0.3+ candidates pending MVP evidence
- Reference to validation criteria (does section get filled? do operators use it when resuming work? does manual cross-feature review surface drift via reading?)

**Do NOT claim** "implemented" or "shipped full drift detection" without MVP/candidate caveat. MVP = capture only. Future reader of METHOD.md should accurately understand what AppMaker does have (capture) vs what's still candidate (automation).

## Acceptance criteria

- [x] METHOD.md "Open invariants" #2 contains phrase "MVP under validation" in plan-vs-actual context (traces_to: pcrit-004, human-review: `rg "MVP under validation" METHOD.md` PASS)
- [x] METHOD.md "Open invariants" #2 does NOT claim drift detection is "implemented" or "shipped" without MVP/candidate caveat (traces_to: pcrit-004, human-review: bullet explicitly says capture-only; auto-diff/checklist enforcement remain v0.3+ candidates)
- [x] Reference to validation criteria present (does section get filled, do operators use it) (traces_to: pcrit-004, human-review: bullet names fill/resume/review criteria before v0.3 automation)
- [x] Full smoke suite passes (no test changes for this slice — single doc edit) (traces_to: pcrit-004, test: `tests/smoke/run-all.sh` — 10 suites PASS)

## Execution Record

**Base ref:** 33568a3
**Dirty at start:** yes
**Dirty files at start:**
- v0.2.19 PRD/decomposition/backlog files were already uncommitted.
- Slice 007, 008, and 009 implementation/test/backlog changes were already uncommitted.

**Planned files:**
- METHOD.md

**Planned tests:**
- rg "MVP under validation|auto-diff|checklist enforcement|does the section get filled|operators" METHOD.md
- bash tests/smoke/run-all.sh

**Actual files:**
- METHOD.md
- dogfood/appmaker/backlog/010-method-status-mvp-under-validation.md

**Tests run:**
- rg "MVP under validation|auto-diff|checklist enforcement|does the section get filled|operators" METHOD.md — PASS
- bash tests/smoke/run-all.sh — 10 suites PASS

**AC completed:** 4/4

**Drift notes:**
- (none)

## Blocked by

None — can start immediately.

## Review (Manual, 2026-05-17)

**Status:** PASS
**Scope:** METHOD.md Open invariants #2
**AC coverage:** 4/4

### Findings

None.

### Notes

- Wording avoids overclaiming: the Method now says capture-only MVP under validation, not full drift detection.
- The v0.3+ candidates are explicit: review auto-diff and checklist enforcement require evidence from real use first.
