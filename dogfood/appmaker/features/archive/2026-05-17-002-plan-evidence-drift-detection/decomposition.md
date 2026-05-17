---
feature: 002-plan-evidence-drift-detection
release: v0.2.19
created: 2026-05-17
last_updated_by: decompose
slice_count: 4
human_required_count: 0
autonomous_count: 4
context_packets: []
---

# Decomposition: Plan / Evidence / Drift Detection MVP (v0.2.19)

## Slices

| ID | Slice | execution_class | blocked_by | Covers PRD criteria |
|---|---|---|---|---|
| 007 | template-execution-record | autonomous | — | pcrit-001 |
| 008 | tdd-materializes-execution-record | autonomous | — | pcrit-002 |
| 009 | release-version-bump-0-2-19 | autonomous | — | pcrit-003 |
| 010 | method-status-mvp-under-validation | autonomous | — | pcrit-004 |

All slices independent (no `blocked_by` edges). IDs continue from global backlog counter (v0.2.18 used 001-006; v0.2.19 = 007-010). Suggested order: 007 → 008 → 009 → 010 (template before skill behavior; release plumbing before docs).

## Dependency graph

```
(all independent — any order)

007 ── template-execution-record
008 ── tdd-materializes-execution-record
009 ── release-version-bump-0-2-19
010 ── method-status-mvp-under-validation
```

No blocking edges. Slice 008 does NOT block_by slice 007 — TDD skill update can append Execution Record to backlog items regardless of whether template has the section pre-populated. But slice 007 first is cleanest UX (template + skill agree on shape).

## Coverage check

4/4 PRD criticisms mapped to ≥1 slice. No orphans.

| pcrit | Slice |
|---|---|
| pcrit-001 | 007 |
| pcrit-002 | 008 |
| pcrit-003 | 009 |
| pcrit-004 | 010 |

Cycle check: PASS (no `blocked_by` edges to evaluate).

## Context packets

None. v0.2.19 is text + skill body changes — no Graphify exploration needed.

## Expected touch map

| Slice | Files |
|---|---|
| 007 | `plugin/appmaker/resources/appmaker/templates/backlog-item-template.md` + `tests/smoke/test-backlog-execution-record.sh` (new) |
| 008 | `plugin/appmaker/skills/tdd/SKILL.md` + `tests/smoke/test-tdd-execution-record.sh` (new) |
| 009 | `plugin/appmaker/.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` + `tests/smoke/test-version-sot.sh` (extend, NOT new) |
| 010 | `METHOD.md` (single bullet update under "Open invariants" #2) |

## Notes

- **MVP scope reduction context:** Original v0.2.19 PRD draft attempted full subsystem (8 pcrits, 6 slices). Codex pushed back ("produkt w produkcie"). Reduced to 4 pcrits / 4 slices — capture only, no review/checklist automation. This decomposition reflects MVP scope.
- **ID continuation:** backlog ID is global counter (per template field semantics). v0.2.18 used 001-006 (all in `done/`); v0.2.19 = 007-010.
- **Self-applying meta-test opportunity:** slice 007 ships template change → slice 008 (next slice) could retroactively add `## Execution Record` to its OWN backlog item, demonstrating the new template works for AppMaker itself. Operator decision during slice 008 TDD.
- **No `human_required` slices.** All 4 are mechanical: template change, skill body update, manifest bump, METHOD.md edit. No phrasing decisions like v0.2.18 slice 005.
- **Slice 008 TDD work resolves git diff strategy** (PRD says "deferred to slice 002 implementation"). Options: committed delta only, union with working-tree delta, etc. Slice 008 picks per real-world utility.
