# Decomposition Overview Template

Per-feature overview for `appmaker/features/<NNN-slug>/decomposition.md`. Summary view of all slices for feature, dependency graph, coverage check.

## Template

```markdown
---
feature: 003-add-dark-mode
created: 2026-05-10
last_updated_by: decompose
slice_count: 4
human_required_count: 1
autonomous_count: 3
context_packets:
  - appmaker/context/2026-05-11-theme-context.md
provenance:                        # v0.2.27 — see appmaker/skills/output-style.md (provenance schema)
  author: appmaker:decompose
  confidence: model_assertion      # model_assertion | web_verified | file_verified | human_confirmed (weakest link)
---

# Decomposition: Add Dark Mode

## Slices

| ID | Slice | execution_class | blocked_by | Covers PRD criteria |
|---|---|---|---|---|
| 008 | theme-context-setup | autonomous | — | pcrit-001, 003, 008 |
| 009 | toggle-component | autonomous | 008 | pcrit-002, 004 |
| 010 | storage-persistence | autonomous | 008 | pcrit-005, 006 |
| 011 | system-pref-detection | human_required | 008 | pcrit-007, 009 |

## Dependency graph

```
008 ──┬── 009
      ├── 010
      └── 011 (human_required)
```

## Coverage check

12/12 PRD acceptance criteria mapped to ≥1 slice. No orphans.

## Context packets

- `appmaker/context/2026-05-11-theme-context.md` — Graphify packet used to identify affected theme-state community.

## Expected graph touch map

| Slice | Communities | Key files |
|---|---|---|
| 008 | theme-state | `src/theme/provider.tsx` |
| 009 | theme-state, ui-controls | `src/components/theme-toggle.tsx` |

## Notes

- Slice 011 marked `human_required`: system preference change handling has UX implications (auto-switch vs prompt) needing design review.
```

## Field semantics

| Field | Required | Notes |
|---|---|---|
| `feature` | yes | Matches feature folder slug |
| `slice_count` | yes | Total slices for feature |
| `human_required_count` | yes | Count of slices marked `human_required` |
| `autonomous_count` | yes | Count of slices marked `autonomous` |
| `context_packets` | optional | Context snapshots used for decomposition. |
| `last_updated_by` | yes | Skill name (`decompose` initial; `checklist` may update) |

## Sections

- **Slices table** — required. One row per slice. Same data as backlog items but condensed.
- **Dependency graph** — required if any blockers. ASCII tree showing blocked_by relationships.
- **Coverage check** — required. "X/Y PRD acceptance criteria mapped, N orphans". Refuse decomposition if N > 0.
- **Context packets** — required if `/appmaker:context` was used.
- **Expected graph touch map** — required when Graphify context exists; advisory, checked by review/checklist.
- **Notes** — optional. Justifications for `human_required` markings, scope decisions, etc.

## Rules

- **Coverage must be 100%.** Every PRD criterion mapped to ≥1 slice. Refuse to write decomposition if orphans exist.
- **Dependency graph mandatory if any blockers exist.** Easier visual review than reading blocked_by per slice.
- **Notes section captures `human_required` reasons.** Don't leave `human_required` unjustified — invites scope drift.
