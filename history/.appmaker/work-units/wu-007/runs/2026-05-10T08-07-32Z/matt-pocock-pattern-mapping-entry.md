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
