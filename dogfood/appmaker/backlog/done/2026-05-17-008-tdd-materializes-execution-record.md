---
id: 008
slug: tdd-materializes-execution-record
status: done
completed: 2026-05-17
labels: [feature, skill]
execution_class: autonomous
blocked_by: []
traces_to: [pcrit-002]
feature: 002-plan-evidence-drift-detection
user_stories_covered: []
context_packets: []
touches:
  files:
    - plugin/appmaker/skills/tdd/SKILL.md
    - tests/smoke/test-tdd-execution-record.sh
created: 2026-05-17
source: decompose
---

# 008: /appmaker:tdd materializes Execution Record

## Parent

`dogfood/appmaker/features/002-plan-evidence-drift-detection/prd.md`

## What to build

Extend `plugin/appmaker/skills/tdd/SKILL.md` step body to materialize `## Execution Record` section in backlog item. Two phases:

**Phase A — initial fields (AFTER step 3 approval, BEFORE step 4 RED tracer):**
- Capture `base_ref = $(git rev-parse HEAD 2>/dev/null || echo no_base_ref)`
- Detect dirty: `git status --short` — populate `Dirty at start: yes/no` + `Dirty files at start:` list
- Write `Planned files:` (from approved TDD plan)
- Write `Planned tests:` (from approved TDD plan)
- Append section to backlog file via Bash heredoc

**Phase B — final fields (in step 9 mark-done, BEFORE mv to `done/`):**
- Compute actual files: union of `git diff --name-only "$base_ref"..HEAD` (committed delta) + `git diff --name-only` (working-tree delta), minus `dirty_files` from Phase A that are clearly unrelated
- Write `Actual files:` list
- Write `Tests run:` count (from suite output)
- Write `AC completed:` count (from `[x]` count in AC list)
- Leave `Drift notes:` as `- (none)` placeholder unless operator wrote during slice work

**Dirty worktree behavior:** capture + WARN, NOT refuse (per PRD pcrit-002).

New smoke test `tests/smoke/test-tdd-execution-record.sh` asserts skill body has both materialization steps with correct ordering (Phase A between step 3 and step 4; Phase B in step 9 before mv).

## Acceptance criteria

- [x] `tdd/SKILL.md` has Phase A materialization step positioned AFTER step 3 (user approval / AskUserQuestion gate) AND BEFORE step 4 (RED tracer test) (traces_to: pcrit-002, test: `tests/smoke/test-tdd-execution-record.sh` — ordering assertion PASS)
- [x] `tdd/SKILL.md` has Phase B materialization step positioned in step 9 (mark done) BEFORE mv to `done/` (traces_to: pcrit-002, test: `tests/smoke/test-tdd-execution-record.sh` — ordering assertion PASS)
- [x] Skill uses `git rev-parse HEAD` for base_ref capture with `|| echo no_base_ref` graceful fallback (traces_to: pcrit-002, test: `tests/smoke/test-tdd-execution-record.sh` — base_ref assertion PASS)
- [x] Skill documents dirty worktree behavior as capture + WARN, NOT refuse (traces_to: pcrit-002, test: `tests/smoke/test-tdd-execution-record.sh` — dirty WARN assertion PASS)
- [x] Actual files computation documented as committed delta + working-tree delta where relevant, using dirty files at start to avoid mislabeling pre-existing changes (traces_to: pcrit-002, human-review: skill body text intentionally avoids hard subtraction algorithm)
- [x] Full smoke suite passes (traces_to: pcrit-002, test: `tests/smoke/run-all.sh` — 10 suites, 72/72 PASS)

## Execution Record

**Base ref:** 33568a3
**Dirty at start:** yes
**Dirty files at start:**
- v0.2.19 PRD/decomposition/backlog files were already uncommitted.
- Slice 007 template/test changes were already uncommitted.

**Planned files:**
- plugin/appmaker/skills/tdd/SKILL.md
- tests/smoke/test-tdd-execution-record.sh

**Planned tests:**
- bash tests/smoke/test-tdd-execution-record.sh
- bash tests/smoke/run-all.sh

**Actual files:**
- plugin/appmaker/skills/tdd/SKILL.md
- tests/smoke/test-tdd-execution-record.sh
- dogfood/appmaker/backlog/008-tdd-materializes-execution-record.md

**Tests run:**
- bash tests/smoke/test-tdd-execution-record.sh — 10/10 PASS
- bash tests/smoke/run-all.sh — 10 suites, 72/72 PASS

**AC completed:** 6/6

**Drift notes:**
- Added this Execution Record manually/backfilled because slice 008 introduces the TDD materialization behavior; future `/appmaker:tdd` runs should write it as part of the skill flow.

## Blocked by

None — can start immediately.

## Notes

Slice 008 work resolves git diff strategy (PRD deferred). Self-applying meta-test opportunity: this very backlog item could retroactively get `## Execution Record` filled during slice 008 TDD work — first dogfood instance of the new contract.

## Review (Manual, 2026-05-17)

**Status:** PASS
**Scope:** `tdd/SKILL.md` + `test-tdd-execution-record.sh`
**AC coverage:** 6/6

### Findings

None.

### Notes

- RED was meaningful: new smoke test failed 9 assertions before the skill edit.
- Test checks structural ordering and required command references; it intentionally does not test semantic diff automation.
- `tdd/SKILL.md` grew to 267 lines. This is above the 200-line trend target, but slice scope kept the addition minimal and avoided embedding a full shell algorithm.
