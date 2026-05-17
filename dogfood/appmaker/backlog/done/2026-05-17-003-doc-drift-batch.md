---
id: 003
slug: doc-drift-batch
status: done
completed: 2026-05-17
labels: [bug, docs]
execution_class: autonomous
blocked_by: []
traces_to: [pcrit-003, pcrit-004, pcrit-007, pcrit-008]
feature: 001-method-compliance-pass-1
user_stories_covered: []
context_packets: []
touches:
  files:
    - README.md
    - DESIGN.md
    - tests/smoke/test-doc-drift.sh
created: 2026-05-17
source: decompose
---

# 003: Documentation Drift Batch

## Parent

`dogfood/appmaker/features/001-method-compliance-pass-1/prd.md`

## What to build

Fix 4 documentation drift bugs in README.md and DESIGN.md via text edits. All bugs are stale references to plugin state — pure cosmetic, no logic change.

**Drift items:**

1. **Skill count "18 dirs" → "19 dirs"** in both README.md (~line 137) and DESIGN.md (~line 113). Plugin added `next/` skill in v0.2.13; count never updated. Real count: 15 core + 4 supporting (afk, status, token-audit, next) = 19.

2. **`.appmaker-version` example literals** in DESIGN.md example/output blocks. Replace stale versions like "0.2.7" / "0.2.9" / "0.2.11" in example contexts with `<version>` placeholder OR current version. Real version references in decision-history labels ("v0.2.11:") remain — they are historical, not stale examples.

3. **README "skills written" sentences** (~line 65) reflect 15 core + 4 supporting = 19 total. Current ambiguous "15 written" needs explicit context per pcrit-008.

4. **DESIGN.md `.appmaker-version` examples** — same shape as item 2 if any remain after item 2 edits (deduplicate handling).

New smoke test `tests/smoke/test-doc-drift.sh` asserts all 4 drift items resolved via `rg` patterns. Registered in `run-all.sh`.

## Acceptance criteria

- [x] `README.md` layout shows `← 19 dirs (15 core + afk + status + token-audit + next)` — Codex-scoped to arrow form (traces_to: pcrit-003, test: `tests/smoke/test-doc-drift.sh` — README 19-dirs assertion PASS)
- [x] `README.md` does NOT contain `← 18 dirs` (arrow form, layout-block scoped — historical narrative form NOT a concern here since README has no equivalent changelog) (traces_to: pcrit-003, test: `tests/smoke/test-doc-drift.sh` — README no-18 assertion PASS)
- [x] `DESIGN.md` layout shows `← 19 dirs (15 core + afk + status + token-audit + next)` — same scoped form (traces_to: pcrit-004, test: `tests/smoke/test-doc-drift.sh` — DESIGN 19-dirs assertion PASS)
- [x] `DESIGN.md` does NOT contain `← 18 dirs` (arrow form only — preserves DESIGN:296 changelog narrative `"16 dirs" → "18 dirs"` per Codex correction on scoping) (traces_to: pcrit-004, test: `tests/smoke/test-doc-drift.sh` — DESIGN no-18 assertion PASS; grep confirms only changelog narrative line 296 retains "18 dirs" mention)
- [x] `DESIGN.md` `.appmaker-version` layout example uses placeholder `(current: "<version>")` not stale literal — scoped via `(current:` prefix (preserves historical `"0.2.0" → "0.2.9"` mention in DESIGN:296 changelog) (traces_to: pcrit-007, test: `tests/smoke/test-doc-drift.sh` — stale-literal assertion PASS)
- [x] `README.md` skill-count narrative: `19 written: 15 core (above) + 4 supporting (afk, status, token-audit, next).` — explicit total + enumeration (traces_to: pcrit-008, test: `tests/smoke/test-doc-drift.sh` — bare-15 gone + 19-written-explicit assertions PASS)
- [x] Full smoke suite passes via `bash tests/smoke/run-all.sh` — 6 suites, 39/39 PASS (30 pre-existing + 9 new), zero regression (traces_to: pcrit-003, pcrit-004, pcrit-007, pcrit-008, test: `tests/smoke/run-all.sh`)

## Blocked by

None — can start immediately.

## Review (Self-check against Codex criteria, 2026-05-17)

**Status:** PASS pending operator/Codex sign-off (batch with slice 004 per earlier framing)
**AC coverage:** 7/7
**Scope:** diff against `README.md` (2 edits) + `DESIGN.md` (2 edits) + `tests/smoke/test-doc-drift.sh` (new)

### Codex scoping correction applied

Initial plan: global `0\.2\.[0-9]+` ban on DESIGN.md + global `18 dirs` ban. Codex flagged: DESIGN.md contains legitimate historical decision labels (`v0.2.11:`) + changelog narrative (line 296: `"16 dirs" → "18 dirs"`) that would false-fail a global ban.

**Correction:** scoped regexes to layout-block forms:
- `← 18 dirs` — left-arrow indicates layout context, not changelog (which uses `→` right-arrow + quoted strings)
- `(current: "0.2.X")` — `(current:` prefix indicates `.appmaker-version` layout example, not historical narrative

**Verified post-implementation:** `grep -n '18 dirs\|"0\.2\.9"' DESIGN.md` returns only line 296 (the changelog narrative). Historical references preserved. Scoped regex approach validated empirically.

### Findings

| Severity | Category | File:Line | Description |
|---|---|---|---|
| (none) | — | — | — |

### Self-review against slice 001's failure mode

Initial plan would have failed Codex review (over-broad regex). Caught at planning stage via Codex's intervention, not after implementation. Same failure-mode signal that emerged in slice 001 review — test/scope mismatch between what user said ("audit drift") and what an over-eager regex would assert ("ban all version mentions"). Lesson: when user says "fix drift", interpret as "fix THIS specific drift form", not "ban this string globally".

### Notes

- **Implementation chose enumeration form** (`+ afk + status + token-audit + next`) over abbreviated form (`+ 4 supporting`). Reason: matches existing line 19 Status line, maintains consistency within README. Either form passes assertion since test regex is specific to enumeration.
- **README narrative form** ("19 written: 15 core (above) + 4 supporting (...).") explicitly satisfies pcrit-008 dual criterion (mentions "19" AND "15 core + 4 supporting").
- **Placeholder choice** `<version>` over `${VERSION}`. Reason: angle-bracket placeholders match doc convention; `${VERSION}` is shell-style used in config.yaml.template runtime substitution context. Different contexts, different conventions.
- Glossary: 0 violations
- Memory wiki gotchas: 0 repeated
- **Per Codex batching framework:** review for 003 deferred to combined gate after slice 004 ships (next slice = mechanical init/SKILL.md version-example fix, same docs-drift class).

