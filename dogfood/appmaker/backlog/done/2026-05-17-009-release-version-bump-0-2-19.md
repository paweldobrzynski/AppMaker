---
id: 009
slug: release-version-bump-0-2-19
status: done
completed: 2026-05-17
labels: [release]
execution_class: autonomous
blocked_by: []
traces_to: [pcrit-003]
feature: 002-plan-evidence-drift-detection
user_stories_covered: []
context_packets: []
touches:
  files:
    - plugin/appmaker/.claude-plugin/plugin.json
    - .claude-plugin/marketplace.json
    - tests/smoke/test-version-sot.sh
    - README.md
    - DESIGN.md
created: 2026-05-17
source: decompose
---

# 009: Release version bump 0.2.18 → 0.2.19

## Parent

`dogfood/appmaker/features/002-plan-evidence-drift-detection/prd.md`

## What to build

Bump release version per v0.2.11 single-source-of-truth pattern. Three canonical sources + two narrative locations (per v0.2.18 cross-slice coherence test extension):

1. `plugin/appmaker/.claude-plugin/plugin.json` `version`: `"0.2.18"` → `"0.2.19"` (CANONICAL)
2. `.claude-plugin/marketplace.json` `metadata.version`: `"0.2.18"` → `"0.2.19"` (mirror)
3. `tests/smoke/test-version-sot.sh` `EXPECTED_RELEASE_VERSION`: `"0.2.18"` → `"0.2.19"` (release-target sentinel)
4. `README.md:19` Status narrative — mentions `v0.2.19` + describes Execution Record MVP content
5. `DESIGN.md:3` Status narrative — same as README

Apply v0.2.18 lesson: bump checklist is 5 places (3 canonical + 2 narrative). Test extension from v0.2.18 already asserts narrative coherence — just update narrative content here.

## Acceptance criteria

- [x] `plugin.json` `version` field equals `"0.2.19"` (traces_to: pcrit-003, test: `tests/smoke/test-version-sot.sh::plugin_json_version_matches_release_target` — PASS)
- [x] `marketplace.json` `metadata.version` equals `"0.2.19"` (verified transitively by equality assertion with plugin.json) (traces_to: pcrit-003, test: `tests/smoke/test-version-sot.sh::plugin_marketplace_versions_match` — PASS)
- [x] `test-version-sot.sh` `EXPECTED_RELEASE_VERSION="0.2.19"` (traces_to: pcrit-003, human-review: diff shows constant bump only in release-target block)
- [x] README Status narrative line mentions `v0.2.19` and describes Execution Record MVP content (traces_to: pcrit-003, test: `tests/smoke/test-version-sot.sh::readme_status_references_release_target` — PASS)
- [x] DESIGN Status narrative mentions `v0.2.19 ` (space-anchored) and describes Execution Record MVP (traces_to: pcrit-003, test: `tests/smoke/test-version-sot.sh::design_status_references_release_target` — PASS)
- [x] Full smoke suite passes (traces_to: pcrit-003, test: `tests/smoke/run-all.sh` — 10 suites PASS)

## Execution Record

**Base ref:** 33568a3
**Dirty at start:** yes
**Dirty files at start:**
- v0.2.19 PRD/decomposition/backlog files were already uncommitted.
- Slice 007 and 008 implementation/test/backlog changes were already uncommitted.

**Planned files:**
- plugin/appmaker/.claude-plugin/plugin.json
- .claude-plugin/marketplace.json
- tests/smoke/test-version-sot.sh
- README.md
- DESIGN.md

**Planned tests:**
- bash tests/smoke/test-version-sot.sh
- bash tests/smoke/run-all.sh

**Actual files:**
- plugin/appmaker/.claude-plugin/plugin.json
- .claude-plugin/marketplace.json
- tests/smoke/test-version-sot.sh
- README.md
- DESIGN.md
- dogfood/appmaker/backlog/009-release-version-bump-0-2-19.md

**Tests run:**
- bash tests/smoke/test-version-sot.sh — 8/8 PASS
- bash tests/smoke/run-all.sh — 10 suites PASS

**AC completed:** 6/6

**Drift notes:**
- (none)

## Blocked by

None — can start immediately.

## Review (Manual, 2026-05-17)

**Status:** PASS
**Scope:** release-target sentinel, manifest mirror, README/DESIGN status narratives
**AC coverage:** 6/6

### Findings

None.

### Notes

- RED was meaningful: after bumping `EXPECTED_RELEASE_VERSION`, the version SoT test failed on plugin manifest, README status, and DESIGN status.
- Marketplace equality stayed green in RED because both manifests were still consistently stale at `0.2.18`; the release-target assertion caught the real issue.
