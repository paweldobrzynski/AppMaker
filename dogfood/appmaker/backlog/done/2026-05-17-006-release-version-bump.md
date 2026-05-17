---
id: 006
slug: release-version-bump
status: done
completed: 2026-05-17
labels: [release, addendum]
execution_class: autonomous
blocked_by: []
traces_to: [pcrit-009]
feature: 001-method-compliance-pass-1
user_stories_covered: []
context_packets: []
touches:
  files:
    - plugin/appmaker/.claude-plugin/plugin.json
    - .claude-plugin/marketplace.json
    - tests/smoke/test-version-sot.sh
created: 2026-05-17
source: decompose-addendum
---

# 006: Release Version Bump (PRD Addendum pcrit-009)

## Parent

`dogfood/appmaker/features/001-method-compliance-pass-1/prd.md`

## What to build

Bump plugin manifest from v0.2.17 to v0.2.18 in both canonical files (per v0.2.11 single-source-of-truth + marketplace mirror). Extend existing `tests/smoke/test-version-sot.sh` with release-target assertion — do **NOT** create new test file (test already covers manifest consistency contract; extension is the right shape).

**Why this is an addendum, not original scope:** Original PRD missed version bump. Gap surfaced during archive prep when realizing feature targets v0.2.18 but manifest still reports 0.2.17. Per Codex framing: release manifest consistency is invariant, not optional housekeeping. PRD amended (pcrit-009 added) before this slice execution — preserves audit chain over silent backfill.

## Acceptance criteria

- [x] `plugin/appmaker/.claude-plugin/plugin.json` `version` field equals `"0.2.18"` (traces_to: pcrit-009, test: `tests/smoke/test-version-sot.sh` — release-target assertion PASS)
- [x] `.claude-plugin/marketplace.json` `metadata.version` field equals `"0.2.18"` — verified transitively by existing equality assertion (plugin.json == marketplace.json) combined with new release-target assertion (plugin.json == "0.2.18") (traces_to: pcrit-009, test: `tests/smoke/test-version-sot.sh` — both equality + release-target PASS)
- [x] `tests/smoke/test-version-sot.sh` extended additively — new `EXPECTED_RELEASE_VERSION="0.2.18"` constant + assertion line; existing 5 assertions preserved unchanged (traces_to: pcrit-009, human-review: diff inspection shows pure addition, no replacement)
- [x] Full smoke suite passes via `bash tests/smoke/run-all.sh` — 8 suites, 48/48 PASS (47 pre-existing + 1 new = release-target assertion), zero regression (traces_to: pcrit-009, test: `tests/smoke/run-all.sh`)

## Blocked by

None — can start immediately.

## Notes

Codex-guided minimal contract: 2 file edits (JSON manifests) + 1 test extension, no new test file. Honest dogfood — addendum amends PRD explicitly rather than silent backfill.

## Review (Self-check, addendum slice, 2026-05-17)

**Status:** PASS pending operator/Codex sign-off
**AC coverage:** 4/4
**Scope:** addendum slice closing PRD gap discovered post-implementation. Edits:
- `plugin.json` line 4: `"version": "0.2.17"` → `"version": "0.2.18"`
- `marketplace.json` line 9: `"version": "0.2.17"` → `"version": "0.2.18"`
- `tests/smoke/test-version-sot.sh`: added `EXPECTED_RELEASE_VERSION="0.2.18"` constant + assertion (additive only)

### Codex minimal-contract honored

| Codex prescription | Implementation |
|---|---|
| Extend existing test-version-sot.sh, NOT create new test file | ✓ Added 3 lines to existing file; new file not created |
| Edit both manifest files | ✓ plugin.json + marketplace.json both bumped |
| Run full suite | ✓ 8 suites, 48/48 PASS |
| Move slice to done with brief review note | ✓ This section |

### Addendum-as-honest-correction lesson

PRD missed version bump in original scope (8 pcrits drafted, none covered manifest). Gap discovered when reaching archive prep stage. Two paths considered:
- **Silent backfill:** bump version during archive step, no PRD amendment. Breaks audit chain — future reader sees feature labeled v0.2.18, slices addressing 8 pcrits, but no traceability to "where did the version bump decision live?"
- **Explicit amendment (chosen):** add pcrit-009 to PRD with note about post-implementation discovery, add slice 006 with `source: decompose-addendum`, treat as 6th slice with full Method discipline.

Codex explicitly endorsed the latter. This is the dogfood signal: **discovery + explicit amendment > polished initial PRD with hidden patches**. Worth durable memory at retro.

### Findings

| Severity | Category | File:Line | Description |
|---|---|---|---|
| (none) | — | — | — |

### Notes

- Test maintenance note: `EXPECTED_RELEASE_VERSION` is hardcoded in test. Next release (v0.2.19+) must update this constant alongside plugin.json + marketplace.json. Bump checklist now has 3 places (was 2): plugin.json (canonical), marketplace.json (mirror), test-version-sot.sh (release-target assertion).
- Could optionally extract release target to separate config (e.g., `tests/smoke/.release-target`) to centralize, but YAGNI for now — 3 places still tractable.
- Glossary: 0 violations
- Memory wiki gotchas: 0 repeated
- **Feature 001-method-compliance-pass-1 truly ready for archive now.** 9/9 pcrit closed across 6 slices. Manifest semantically consistent with feature target.

