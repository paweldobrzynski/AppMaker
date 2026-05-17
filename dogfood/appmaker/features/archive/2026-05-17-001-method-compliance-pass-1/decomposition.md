---
feature: 001-method-compliance-pass-1
created: 2026-05-17
last_updated_by: decompose
slice_count: 6
human_required_count: 1
autonomous_count: 5
context_packets: []
addendum: pcrit-009 added 2026-05-17 post-implementation; slice 006 covers it.
---

# Decomposition: Method Compliance Pass 1 (v0.2.18)

## Slices

| ID | Slice | execution_class | blocked_by | Covers PRD criteria |
|---|---|---|---|---|
| 001 | prd-criticisms-section | autonomous | — | pcrit-001 |
| 002 | backlog-ac-test-ref | autonomous | — | pcrit-002 |
| 003 | doc-drift-batch | autonomous | — | pcrit-003, pcrit-004, pcrit-007, pcrit-008 |
| 004 | init-version-example | autonomous | — | pcrit-005 |
| 005 | start-spike-route | human_required | — | pcrit-006 |
| 006 | release-version-bump | autonomous | — | pcrit-009 (PRD addendum) |

## Dependency graph

```
(all independent — any order)

001 ── prd-criticisms-section
002 ── backlog-ac-test-ref
003 ── doc-drift-batch
004 ── init-version-example
005 ── start-spike-route (human_required)
006 ── release-version-bump (addendum)
```

No blocking edges. Each slice touches distinct files. TDD order can be reader's preference; suggested order: 001 → 002 → 003 → 004 → 005 (cheap → expensive → judgment).

## Coverage check

9/9 PRD criticisms mapped to ≥1 slice. No orphans. (pcrit-009 added 2026-05-17 as PRD addendum; slice 006 covers it.)

| pcrit | Slice |
|---|---|
| pcrit-001 | 001 |
| pcrit-002 | 002 |
| pcrit-003 | 003 |
| pcrit-004 | 003 |
| pcrit-005 | 004 |
| pcrit-006 | 005 |
| pcrit-007 | 003 |
| pcrit-008 | 003 |
| pcrit-009 | 006 (addendum) |

Cycle check: PASS (no `blocked_by` edges to evaluate).

## Context packets

None. v0.2.18 work is text-level edits to known files (`prd/SKILL.md`, `backlog-item-template.md`, `README.md`, `DESIGN.md`, `init/SKILL.md`, `start/SKILL.md`). No Graphify exploration needed.

## Expected touch map

| Slice | Files |
|---|---|
| 001 | `plugin/appmaker/skills/prd/SKILL.md` + `tests/smoke/test-prd-criticisms.sh` (new) |
| 002 | `plugin/appmaker/resources/appmaker/templates/backlog-item-template.md` + `tests/smoke/test-backlog-template-test-ref.sh` (new) |
| 003 | `README.md` + `DESIGN.md` + `tests/smoke/test-doc-drift.sh` (new) |
| 004 | `plugin/appmaker/skills/init/SKILL.md` + `tests/smoke/test-init-version-example.sh` (new) |
| 005 | `plugin/appmaker/skills/start/SKILL.md` + `tests/smoke/test-start-routes.sh` (new) |
| 006 | `plugin/appmaker/.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` + `tests/smoke/test-version-sot.sh` (extend existing, NOT new) |

## Notes

- **Slice 005 marked `human_required`:** phrasing decision for prototype-flow message (per PRD risk flag on pcrit-006). Options: "TODO — prototype flow not implemented yet" vs route to `/appmaker:grill` with note. Needs operator judgment, not autonomous.
- **Slice 003 batches 4 pcrit** because they all involve grep-level text edits to README/DESIGN — natural grouping. Slice still vertical (cuts code + tests for each pcrit).
- **AC format anticipates pcrit-002:** backlog items below use the new `test:` inline format, demonstrating Method self-application. Format becomes canonical via slice 002 template change.
- **No `plan.md` / `evidence.md` per slice:** v0.2.18 uses current backlog-as-slice model. v0.2.19 introduces those sections.
- **Slice 006 addendum (2026-05-17):** Added post-implementation when archive prep surfaced version-bump gap. Per Codex framing: release manifest consistency is invariant, not housekeeping. PRD amended (pcrit-009) + decomposition updated (this row) before slice 006 execution — preserves audit chain. Test path: **extend** `test-version-sot.sh` (already covers manifest consistency), don't create new file. One line edit per JSON manifest + one new assertion in existing test.
