---
id: 004
slug: init-version-example
status: done
completed: 2026-05-17
labels: [bug, docs]
execution_class: autonomous
blocked_by: []
traces_to: [pcrit-005]
feature: 001-method-compliance-pass-1
user_stories_covered: []
context_packets: []
touches:
  files:
    - plugin/appmaker/skills/init/SKILL.md
    - tests/smoke/test-init-version-example.sh
created: 2026-05-17
source: decompose
---

# 004: init upgrade example version placeholder

## Parent

`dogfood/appmaker/features/001-method-compliance-pass-1/prd.md`

## What to build

`plugin/appmaker/skills/init/SKILL.md` upgrade example shows hardcoded version literals ("Upgrade: 0.1.1 → 0.2.11"). This violates v0.2.11 single-source-of-truth invariant — version is runtime-read from `plugin.json`, not embedded in skill docs.

Replace with placeholder: `<previous>` / `<current>` (reader-friendly) OR `${OLD_VERSION}` / `${PLUGIN_VERSION}` (shell-style consistent with materialization placeholders elsewhere in init).

Same fix applied to any other hardcoded "0.2.X" literal in init/SKILL.md output / example blocks (search for `0\.2\.\d+` outside `# v0.2.X:` decision labels).

New smoke test `tests/smoke/test-init-version-example.sh` asserts no hardcoded version literals remain in non-historical contexts.

## Acceptance criteria

- [x] `init/SKILL.md` does NOT contain `Upgrade: X.Y.Z → A.B.C` hardcoded pattern (line 314 fixed to `Upgrade: <previous> → <current>`; line 354 fixed similarly) (traces_to: pcrit-005, test: `tests/smoke/test-init-version-example.sh` — Upgrade-hardcoded assertion PASS)
- [x] `init/SKILL.md` upgrade example uses placeholder `<previous>` / `<current>` form (chosen over `${OLD_VERSION}/${PLUGIN_VERSION}` — angle-bracket convention matches doc style) (traces_to: pcrit-005, test: `tests/smoke/test-init-version-example.sh` — placeholder-form assertion PASS)
- [x] Other hardcoded "0.2.X" literals in init/SKILL.md output blocks replaced: lines 335 (`plugin v<current>`), 338 (`→ <current>`) (traces_to: pcrit-005, test: `tests/smoke/test-init-version-example.sh` — `→ X.Y.Z` end-of-line + `plugin vX.Y.Z` end-of-line assertions both PASS)
- [x] Decision-history labels and metadata untouched — 8 historical `v0.2.11` references preserved (lines 38, 52, 76, 83, 118, 242, 283, 305 verified via grep) (traces_to: pcrit-005, human-review: scoped regex `→[[:space:]]+X.Y.Z$` + `plugin vX.Y.Z$` only catches end-of-line bare versions, never prose/comment context)
- [x] Full smoke suite passes via `bash tests/smoke/run-all.sh` — 7 suites, 44/44 PASS (39 pre-existing + 5 new), zero regression (traces_to: pcrit-005, test: `tests/smoke/run-all.sh`)

## Blocked by

None — can start immediately.

## Review (Batch — slices 003 + 004, Self-check against Codex criteria, 2026-05-17)

**Status:** PASS pending operator/Codex sign-off
**AC coverage:** 5/5 (this slice) + 7/7 (slice 003, reviewed inline at `2026-05-17-003-doc-drift-batch.md`)
**Scope:** Both docs-drift slices reviewed together per earlier Codex framing (mechanical text edits, same drift class, same scoping discipline).

### Combined slice 003 + 004 self-review

Both slices applied the same Codex correction: **scoped regex to layout/example-block form, not global version literal ban**. This protected against false-failing on legitimate historical references:

| Slice | Files | Drift form | Historical form (preserved) |
|---|---|---|---|
| 003 | README.md, DESIGN.md | `← X dirs` (layout arrow), `(current: "0.2.X")` (file marker example) | Changelog narrative DESIGN:296 (`"16 dirs" → "18 dirs"`), decision labels `v0.2.X:` |
| 004 | init/SKILL.md | `→ X.Y.Z$` end-of-line, `plugin vX.Y.Z$` end-of-line, `Upgrade: X.Y.Z → A.B.C` | Comments `# (v0.2.11 ...)`, prose `as of v0.2.11`, decision labels |

**Empirical verification:** post-implementation `grep -nE 'v0\.2\.[0-9]+' init/SKILL.md` returned 8 expected historical references (lines 38, 52, 76, 83, 118, 242, 283, 305) — all preserved as intended.

### Findings (combined)

| Severity | Category | File:Line | Description |
|---|---|---|---|
| (none) | — | — | — |

### Self-review against slice 001's failure mode (re-applied)

Both slices 003 and 004 used positive + negative regex pairs:
- Positive: required form present (`← 19 dirs (...)`, `Upgrade: <previous>...`)
- Negative: drift form absent (`← 18 dirs`, `Upgrade: X.Y.Z → A.B.C`)

This double-anchoring (present + absent) avoids the slice-001 weakness where false-positive on prose alone could PASS. If someone reverted partially (e.g., kept new form but also restored old), at least one assertion fails.

### Notes

- **Operator deferred from per-slice review** for both 003 and 004 per Codex framing: "dla 003/004 można rozważyć batch review, bo to docs drift". Both slices are mechanical, same class, same scoping discipline. Batch review is one combined gate.
- **Slice 005 remains separate** — `human_required` (phrasing decision for `/appmaker:start` spike route). Operator picks Option A/B/C from backlog 005 OR own variant. Not eligible for batch with 003+004.
- Glossary: 0 violations
- Memory wiki gotchas: 0 repeated. Candidate for `memory/wiki/testing.md` synthesis at archive retro: **"Codex-style scoped regex pattern for documentation drift tests"** — useful for future drift batches.
- **Audit chain:** 4/4 PRD pcrits closed (003, 004, 005, 007, 008 → wait, 5 pcrits actually, not 4). 5/5 PRD pcrits closed in 003+004 batch (003-doc-drift covers pcrit-003, pcrit-004, pcrit-007, pcrit-008; 004 covers pcrit-005).

