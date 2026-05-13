# Matt Pocock Pattern Mapping

> Reference ledger documenting which Matt Pocock skill patterns AppMaker
> adopts and where each adoption is recorded.
>
> **Source:** Matt Pocock Skills, MIT License, Copyright (c) 2026 Matt Pocock.
> Repository: https://github.com/patjfree/Matt_Pocock_Skills
> Local path at adoption time: `/Users/pawel/Projects/Matt_Pocock_Skills/`

## Convention — append-oriented, not strict append-only

This document is **append-oriented**: future ADR work_units that adopt
additional Matt Pocock patterns add new rows. It is **not** strict
append-only in the constitution-R10 sense (which governs `decisions.jsonl`,
`events.jsonl`, `lessons.jsonl` audit streams).

Corrections to existing rows (typo fixes, malformed fields) are permitted
via a dedicated work_unit that updates the Revision History section
below; silent rewrites are forbidden. New adoptions are simply appended.

This is reference / provenance material, not a decision artifact. The
authoritative decisions live in the referenced ADRs.

## Adoptions

### Entry 1: `grill-me` → AppMaker Interview (greenfield)

| Field | Value |
|---|---|
| `source_skill` | `Matt_Pocock_Skills/skills/productivity/grill-me/SKILL.md` |
| `source_commit` | `b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8` (2026-04-30) |
| `license` | MIT |
| `adr_reference` | ADR-002 |
| `appmaker_pattern` | Interview (greenfield variant) |
| `surface` | lifecycle |
| `output_artifact` | `.appmaker/interview-result.yaml` |
| `notes` | Adapted as relentless-questioning prompt with structured output. AppMaker adds `readiness` enum gate and `ready_with_override` propagation. |

### Entry 2: `grill-with-docs` → AppMaker Brownfield Interview

| Field | Value |
|---|---|
| `source_skill` | `Matt_Pocock_Skills/skills/engineering/grill-with-docs/SKILL.md` |
| `source_commit` | `b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8` (2026-04-30) |
| `license` | MIT |
| `adr_reference` | ADR-002 |
| `appmaker_pattern` | Interview (brownfield variant, `--with-docs`) |
| `surface` | lifecycle |
| `output_artifact` | `.appmaker/interview-result.yaml` (with `existing_codebase` block) + `.appmaker/glossary.md` |
| `notes` | Adds domain awareness, glossary challenge, code cross-reference, and 3-criteria ADR offer filter (hard-to-reverse + surprising + real-trade-off). Both outputs kernel-managed under `.appmaker/` per ADR-001 §D3 separation. |

## Revision History

| Date | Work_unit | Changes |
|---|---|---|
| 2026-05-09 | WU-003 | Initial creation. Two entries: `grill-me` (greenfield Interview) and `grill-with-docs` (brownfield Interview). Both adopted under ADR-002. |

---

**End of pattern mapping (WU-003 initial creation).** Future ADRs (ADR-003 PRD synthesis, ADR-004 work_unit decomposition, ADR-005 safety hooks, ADR-006 implementation runner, ADR-007 bug workflow, ADR-008 architecture review) are expected to append additional entries here.
