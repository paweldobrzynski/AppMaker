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

### Entry 3: `to-prd` → AppMaker PRD Synthesis

| Field | Value |
|---|---|
| `source_skill` | `Matt_Pocock_Skills/skills/engineering/to-prd/SKILL.md` |
| `source_commit` | `b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8` (2026-04-30) |
| `license` | MIT |
| `adr_reference` | ADR-004 |
| `appmaker_pattern` | PRD Synthesis |
| `surface` | lifecycle |
| `output_artifact` | `.appmaker/prd.md` (single project-level, kernel-managed; per ADR-004 §D2) |
| `notes` | Adapted from Matt Pocock's `/to-prd`. AppMaker adds: Understanding section with 7 mandatory subsections (users/buyers/operators, domain invariants, identity model, trust boundaries, non-delegable human judgments, verifiable success criteria, failure modes / unacceptable outcomes) per WU-005 lesson human_understanding; verifiable success criteria with auto-check OR human-review-with-criteria treatment per WU-005 lesson verifiability_bias; field-by-field consumption rule for `interview-result.yaml` per ADR-004 §D5 (no silent omission); PRD-required-before-decomposition gate per ADR-004 §D4; ready_with_override propagation from Interview per ADR-004 §D6 (PRD status `ACCEPTED_WITH_INHERITED_OVERRIDE`, UPPERCASE per work-unit-v1 status enum convention). AppMaker does NOT adopt Matt's "publish to issue tracker" step — no built-in issue tracker dependency in v1; PRD lives in `.appmaker/`-managed location. |

### Entry 4: `to-issues` → AppMaker Work_unit Decomposition

| Field | Value |
|---|---|
| `source_skill` | `Matt_Pocock_Skills/skills/engineering/to-issues/SKILL.md` |
| `source_commit` | `b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8` (2026-04-30) |
| `license` | MIT |
| `adr_reference` | ADR-005 |
| `appmaker_pattern` | Work_unit Decomposition |
| `surface` | lifecycle |
| `output_artifact` | `.appmaker/decomposition.md` (single project-level document; per ADR-005 §D3); per-WU `work-unit.yaml` files materialized downstream |
| `notes` | Adapted from Matt Pocock's `/to-issues`. AppMaker adds: vertical slice MUST have `execution_class: human_required \| autonomous` (AppMaker mapping of HITL/AFK per ADR-005 §D2(b2); not literal HITL/AFK acronyms — keeps AppMaker semantics independent of external project vocabulary) per WU-005 lesson human_understanding; per-WU acceptance criteria propagation rule per ADR-005 §D5 (every PRD success criterion → ≥1 WU AC; every WU AC traceable to PRD criterion or non-delegable judgment via `traces_to: <pcrit-id>` field; verifiability discipline inherited from PRD per WU-005 lesson verifiability_bias); cycle detection on `blocked_by` mandatory before promote per ADR-005 §D4; `work_unit_subtype: decomposition` is conceptual decision in ADR-005 §D4(b) — formal schema modification deferred to schemas-extension WU per ADR-004 §D4 commitment resolution path (a); ready_with_override propagation per ADR-005 §D6 — decomposition document carries artifact-level status `ACCEPTED_WITH_INHERITED_OVERRIDE` (artifact status, NOT work_unit status — per Codex Fix #2 + work-unit-v1.schema.json status enum unchanged), per-WU files use standard work-unit-v1 enum with override propagated as context-pack metadata. AppMaker does NOT adopt Matt's "publish to issue tracker" step — no built-in issue tracker dependency in v1; decomposition output lives in `.appmaker/`-managed location. |

## Revision History

| Date | Work_unit | Changes |
|---|---|---|
| 2026-05-09 | WU-003 | Initial creation. Two entries: `grill-me` (greenfield Interview) and `grill-with-docs` (brownfield Interview). Both adopted under ADR-002. |
| 2026-05-10 | WU-006 | Appended Entry 3: `to-prd` → AppMaker PRD Synthesis (adopted under ADR-004). Existing entries 1 (grill-me) and 2 (grill-with-docs) textually unchanged (diff verified pre-promote). |
| 2026-05-10 | WU-007 | Appended Entry 4: `to-issues` → AppMaker Work_unit Decomposition (adopted under ADR-005). Existing entries 1 (grill-me), 2 (grill-with-docs), 3 (to-prd) textually unchanged (diff verified pre-promote). |

---

**End of pattern mapping (last update: WU-007 promote, 2026-05-10).** Current entries: 4 (grill-me, grill-with-docs, to-prd, to-issues). Future ADRs expected to append entries: ADR-006 safety & quality hooks (git-guardrails + setup-pre-commit), ADR-007 implementation runner (tdd), ADR-008 bug workflow (diagnose), ADR-009 architecture review (improve-codebase-architecture). Plus future ADR-NNN candidates: Agent-Native Project Interface, Verifiability Standards, Context-Pack Schema, Design Exploration Stage.
