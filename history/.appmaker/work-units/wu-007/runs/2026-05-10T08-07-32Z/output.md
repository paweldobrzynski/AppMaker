# ADR-005: Work_unit Decomposition (to-issues from Matt Pocock skills)

## Status

**DRAFT** — produced by WU-007 at `.appmaker/work-units/wu-007/runs/2026-05-10T08-07-32Z/output.md`, awaiting promote.

Lifecycle: `DRAFT` (in run dir, immutable) → **`ACCEPTED`** (after human + Codex review; promotion step copies this file to `decisions/ADR-005-work-unit-decomposition.md` and appends one entry as Entry 4 to `docs/reference/matt-pocock-pattern-mapping.md`) → `AMENDED` (if modified by future amendment work_unit, per Amendment Process in constitution).

## Metadata

- **Date:** 2026-05-10
- **Authors:** pawedo@gmail.com (decision-maker), Claude Opus 4.7 (synthesis), Codex (critic, multiple rounds)
- **Type:** investigation work_unit (multi-output: ADR + 1 mapping doc append entry)
- **Supersedes:** none
- **Superseded by:** none
- **Related:** ADR-001 (process kernel), ADR-002 (interview phase), ADR-003 (schema format + v1 schemas), ADR-004 (PRD synthesis), constitution v2 (amended with R18), WU-007 contract

## Context

ADR-001 established work_unit primitive. ADR-002 added Interview Phase. ADR-003 promoted v1 schemas. ADR-004 added PRD Synthesis as the lifecycle stage producing `.appmaker/prd.md` and required PRD as a gate before decomposition (per ADR-004 §D4).

Two questions remain open between PRD and Implementation:

1. **How does PRD become individually-grabbable work?** PRD is product-level reference; it does not specify which slices to build, in what order, with what relations. Without a planning stage, every implementation work_unit re-derives intent from PRD with cumulative drift.

2. **How do non-delegable judgments propagate from PRD to per-slice level?** PRD Understanding subsection 5 (non-delegable human judgments) and subsection 6 (verifiable success criteria) live at product level. Decomposed slices must inherit them per slice — otherwise human judgment silently scatters into individual implementations.

ADR-005 introduces **Work_unit Decomposition** as the lifecycle stage answering both. Decomposition consumes the promoted PRD and produces vertical-slice work_units (each independently testable / deployable / verifiable, per Matt Pocock to-issues "tracer bullet" principle), plus an explicit relation graph (blocked_by, depends_on), plus per-slice typing (`execution_class: human_required | autonomous` — AppMaker mapping of HITL/AFK per D2(b2)), plus per-WU acceptance criteria traceable to PRD criteria.

The pattern is inspired by Matt Pocock's `/to-issues` skill. AppMaker adapts as inspiration source, NOT runtime dependency, per ADR-002 §D5 + ADR-001 §D12 + WU-005 lesson harness_engineering.

### Scope

ADR-005 is **narrow per Codex/user directive**. Covers ONLY decomposition / to-issues. Does NOT cover:
- Safety hooks (ADR-006, future)
- Implementation runner / TDD (ADR-007, future)
- Bug workflow / diagnose (ADR-008, future)
- Architecture review (ADR-009, future)
- Validator implementation (ADR-003 OQ-1)
- Schema modification (work_unit_subtype is conceptual here per D4; actual schema write deferred to schemas-extension WU)
- Constitution amendment

## Sources Consulted

| Source | Contribution |
|---|---|
| ADR-001 | work_unit primitive (D2), type enum (D2a), 6-file model (D3), CLI-first (D10), 3-stream logging (D11), gates fail closed (D13) |
| ADR-002 | `interview-result.yaml` shape, 4-state readiness enum (D3), `ready_with_override` propagation (D6), Matt Pocock attribution policy (D5) |
| ADR-003 | adr-v1 schema (12 sections + forbidden_patterns), work-unit-v1 schema (status enum, lessons_applied), validator deferred (D4), JSON Schema canonical (D1) |
| ADR-004 | PRD shape with Understanding section (D2), PRD-required-gate before decomposition (D4 — including commitment about `work_unit_subtype: decomposition`), PRD-consumes-interview-result.yaml field-by-field (D5), `ACCEPTED_WITH_INHERITED_OVERRIDE` PRD status (D6), UPPERCASE casing convention (D4) |
| constitution v2 | R1, R5, R7, R8, R12, R13, R14, R18 |
| Matt Pocock to-issues skill (engineering/to-issues/SKILL.md) | Tracer bullet vertical slices, HITL/AFK typing, blocked_by relation, demoable-on-its-own slice rule, "many thin > few thick" heuristic |
| WU-005 lessons (8 direct) | schema_design, validator_gap, actual_usage, adr_quality, harness_engineering, **human_understanding (load-bearing for D2 slice typing)**, context_pack_as_program, **verifiability_bias (load-bearing for D5 AC propagation)** |
| WU-003/WU-004 broad lessons (4) | review external fact-check, adr_quality cross_decision_consistency, memory_layer lessons_applied, review forbidden_patterns |
| WU-006 fresh lessons (4 — load-bearing) | cross_decision_consistency_active_check (7-pair active diff), cross_artifact_consistency_active_check (split AC #17), wording_internal_contradiction (within-decision scan), supersedes_pattern_for_correction_events |
| Codex critique rounds | Narrow scope discipline; HITL/AFK decision required; AC #17 split; cross-decision pairs added (D2↔D5, D3↔D5); D6 artifact-vs-WU distinction; ADR-004 §D4 work_unit_subtype commitment resolution |
| Local environment audit | jq, PyYAML, Ruby Psych available; ajv NOT installed (ADR-003 D4 deferral) |

## Decision

Seven numbered, individually addressable decisions D1–D7.

### D1. Decomposition is the lifecycle stage between PRD and Implementation, producing vertical-slice work_units + relation graph.

**Decision:** Decomposition is an **investigation-class work_unit** that consumes the promoted PRD (`.appmaker/prd.md`) and produces:
- A set of vertical-slice work_units (each typically `type: implementation`, some may be `type: investigation` if they require ADR before code)
- A relation graph (blocked_by, depends_on per D4)
- Per-slice typing (`execution_class` per D2(b))
- Per-WU acceptance criteria traceable to PRD success criteria (per D5)

Decomposition differs from:
- **PRD** (ADR-004): PRD is product-level reference — what to build at user/buyer/operator level. Decomposition is planning-level — which slices, in what order, with what relations.
- **Individual implementation work_units**: those are the slices themselves. Decomposition is the parent process that emits the set with coherent relations.

**Why:** Without an explicit planning stage, implementation WUs re-derive intent from PRD each time, with cumulative drift (each WU's interpretation diverges slightly). Per WU-005 lesson harness_engineering: structural staging prevents drift mechanically. Per Matt Pocock to-issues: the "break a plan into independently-grabbable issues" step is the decomposition; AppMaker formalizes it as a lifecycle stage.

**How / Implications:**
- Decomposition is invoked by command `appmaker decompose` (analog to `appmaker prd`). The command reads `.appmaker/prd.md`, prepares context, prompts an agent to produce decomposition output (per D3 location).
- Decomposition is itself a work_unit (e.g., `wu-NNN-decomposition`); standard lifecycle PROPOSED → ACCEPTED → IN_PROGRESS → VERIFIED → PROMOTED applies to it.
- Per ADR-004 §D4, the decomposition gate (PRD must exist with status in `{ACCEPTED, ACCEPTED_WITH_INHERITED_OVERRIDE}` — both being PRD ARTIFACT statuses, not work_unit statuses) is enforced at decomposition WU acceptance/promotion review (v1 human-enforced; v2 mechanical via D4 below).

### D2. Vertical slice (Matt Pocock tracer-bullet) + slice typing as `execution_class: human_required | autonomous`.

**Two coupled sub-decisions:**

**(a) Vertical slice definition (per Matt Pocock to-issues):**
- Each slice cuts through ALL integration layers end-to-end (schema, API, UI, tests where applicable)
- A completed slice is demoable or verifiable on its own
- Tracer bullet — narrow but COMPLETE path
- Many thin slices > few thick ones
- Horizontal task antipattern (one technical layer fragment) → killed alternative KA-1

**(b) Slice typing — AppMaker adopts execution_class mapping (option b2), NOT literal HITL/AFK (b1).**

Decision: each slice has a field `execution_class` with one of:
- `human_required` — slice requires non-delegable human judgment (architectural decision, design review, ethical / legal / strategic call). Cannot be merged without explicit human action. Maps from Matt's HITL.
- `autonomous` — slice is agent-executable end-to-end without human interaction. Maps from Matt's AFK.

Why **(b2) AppMaker mapping** over **(b1) literal HITL/AFK**:
- HITL/AFK are external acronyms borrowed from Matt's project; AppMaker has no obligation to adopt the literal terms. Mapping to AppMaker-native `execution_class` provides clearer semantics in AppMaker context.
- `execution_class` explicitly ties to WU-005 lesson human_understanding: `human_required` is the per-slice marker for non-delegable judgments propagated from PRD Understanding subsection 5.
- Future schema-extension WU may add `execution_class` enum to work-unit-v1 schema as a formal field; literal HITL/AFK acronyms would be harder to evolve.
- Killed: **(b1) literal HITL/AFK** — cosmetically simpler, but borrows external vocabulary into AppMaker's core semantics; **(b3) drop typing** — silently delegates non-delegable judgments to agents (R12 violation in spirit).

**Why (overall D2):** Per Matt Pocock to-issues, vertical slices are the unit of independently-grabbable work; without that constraint, decomposition produces horizontal fragments that cannot be demoed in isolation. Per WU-005 lesson human_understanding, slice typing is the per-slice carrier of non-delegable judgments — without it, judgments scatter and silently get delegated to agents executing autonomous slices.

**How / Implications:**
- `execution_class` is a CONCEPTUAL field at this ADR's level (per WU-007 scope: no schema modification). Its formal addition to work-unit-v1 schema is deferred to a future schemas-extension WU. Until then, decomposed work_units carry it as an extra YAML key (work-unit-v1.schema.json `additionalProperties: true` permits this without violation).
- Cross-decision constraint with D5 (AC propagation): `human_required` slices' AC may include `human_review_required: true` with named criteria; `autonomous` slices' AC must be fully verifiable without human judgment dependency.

### D3. Decomposition output: `.appmaker/decomposition.md` (single project-level document) — mirrors `.appmaker/prd.md` precedent.

**Decision:** Decomposition produces a single project-level document at `.appmaker/decomposition.md`, kernel-managed (alongside `prd.md`, `interview-result.yaml`, etc. per ADR-001 §D3). The document contains:
- Slice list (each slice: id, title, `execution_class`, blocked_by, depends_on, acceptance_criteria, traces_to PRD criterion ids)
- Relation graph section (visual or tabular blocked_by/depends_on rendering)
- Status (per D6: `ACCEPTED` or `ACCEPTED_WITH_INHERITED_OVERRIDE` — **artifact-level status, NOT work_unit status**, per D6 distinction)
- Revision History

Per-WU `work-unit.yaml` files are **separately materialized** from this decomposition document by the kernel (downstream of `appmaker decompose --materialize` or equivalent; mechanism deferred to a CLI implementation WU). The decomposition document is the source of truth; per-WU files are derived views.

**Why:** Three candidates evaluated:
- **(a) `.appmaker/decomposition.md` single document** — chosen. Mirrors `.appmaker/prd.md` precedent (single canonical project-level reference). Easiest to gate D6 propagation. Easiest to read holistically.
- **(b) Per-WU `work-unit.yaml` files only** — killed (KA-2): no central reference; ambiguity propagation harder (each WU needs to read PRD + propagate by itself); relation graph fragmented across N files.
- **(c) Intermediate `.appmaker/decomposition.yaml` graph + materialization step** — killed: over-engineering for v1; two artifacts to maintain consistency; YAML is for machines but humans need the markdown view too.

**How / Implications:**
- Cross-decision constraint with D4 (relation graph): graph lives IN this document (per D4); per-WU files reference it.
- Cross-decision constraint with D5 (PRD criterion → WU AC propagation): document has explicit "Traceability" section listing each PRD criterion and which slices implement it.
- Cross-decision constraint with D6 (override propagation): decomposition document carries inherited status; per-WU files use standard work-unit-v1 enum with override propagated as context-pack metadata only.

### D4. Relation graph: `blocked_by` (hard) + `depends_on` (informational); cycle detection mandatory; `work_unit_subtype` is CONCEPTUAL field per ADR-004 §D4 commitment, schema modification deferred.

**Decision (a) — Relation graph fields:**
- `blocked_by: array<slice_id>` (e.g., `["slice-003", "slice-007"]`) — hard precedence; the slice cannot start (work_unit cannot be ACCEPTED) until each blocker is PROMOTED
- `depends_on: array<slice_id>` (e.g., `["slice-002"]`) — informational coupling; downstream slice may benefit from upstream context but is not gate-blocked
- `related_to` — DEFERRED to OQ-1 (third relation type for cross-cutting concerns; out of v1 scope)

Cycle detection on `blocked_by` is **mandatory** before decomposition promote. A cycle (`A blocked_by B`, `B blocked_by A`) makes any progress impossible; cycle detection rejects with explicit error naming the cycle.

**Decision (b) — `work_unit_subtype` resolution per ADR-004 §D4 commitment:**

Per ADR-004 §D4, ADR-005 was committed to "introduce a formal `work_unit_subtype: decomposition` to work-unit-v1 schema and let the kernel gate on it." ADR-005 resolves this commitment via **path (a) per WU-007 context-pack §6**: `work_unit_subtype` is a **CONCEPTUAL DECISION** here. The field name and semantics are reserved:

```
work_unit_subtype: enum<null | decomposition | future_extension>
  - null:               generic implementation or investigation WU (default; backward compatible)
  - decomposition:      WU executing the decomposition stage (i.e., the WU that produces .appmaker/decomposition.md per D3); ADR-004 §D4 PRD-required gate triggers on this subtype
  - future_extension:   placeholder reserved for subtypes added by future amendment WUs; carriers MUST go through dedicated ADR before populating this slot
```

**Scope discipline (per Codex review of WU-007 execution):** ADR-005's job is to decide about `decomposition` only. Other plausible subtype names (review, retro, amendment, interview, prd) are sensible candidates but ADR-005 does NOT accept them — promoting that taxonomy here would silently accept future enum values without dedicated ADR. Those names are listed in §Open Questions OQ-9 as **candidate future subtype names, not accepted by ADR-005**.

Actual addition of this field to `work-unit-v1.schema.json` is **DEFERRED** to a separate schemas-extension WU. Until then:
- The **decomposition WU** (the WU executing the decomposition stage and producing `.appmaker/decomposition.md`) carries `work_unit_subtype: decomposition` as an extra YAML key (`additionalProperties: true` in schema permits). This is the SINGLE WU per project per decomposition cycle — NOT every WU emitted by it.
- **Materialized implementation slice WUs** (the slices that decomposition produces; emitted to `.appmaker/work-units/wu-NNN/`) do NOT carry `work_unit_subtype: decomposition`. They carry standard `type: implementation` (or `type: investigation` for design-class slices), plus `execution_class` (per D2(b2)), plus `traces_to: <pcrit-id>` AC fields (per D5), plus relations (per D4(a)). They are the OUTPUT of the decomposition WU, not instances of decomposition themselves.
- The kernel cannot mechanically gate on `work_unit_subtype` (no schema enforcement)
- ADR-004 §D4 PRD-required gate triggers on the decomposition WU (the single one with `subtype: decomposition`), not on each materialized slice
- Decomposition gate remains **human-enforced** at decomposition WU acceptance/promotion review
- When schemas-extension WU promotes, kernel can mechanically gate based on subtype field

This satisfies ADR-004 §D4 commitment (the field is named + semanticized) while keeping WU-007 narrow (no schema write per WU-007 scope discipline).

**Why:**
- `blocked_by` is the canonical Matt Pocock to-issues field (mandatory in their issue template); AppMaker adopts directly.
- `depends_on` is AppMaker addition for non-blocking informational coupling (Matt's to-issues doesn't distinguish; AppMaker finds the distinction useful for finer control).
- `related_to` deferred because v1 has no concrete need; speculative.
- Cycle detection mandatory because `blocked_by` cycles silently break progress; explicit reject is mandatory per R12.
- `work_unit_subtype` conceptual-not-schema preserves WU-007 scope while honoring ADR-004 §D4 commitment.

**How / Implications:**
- Cycle detection is implemented in the kernel's `appmaker decompose --validate` step (or equivalent); deferred to CLI implementation WU.
- Until kernel implements cycle detection, human reviewer at decomposition promote is responsible for confirming acyclic.
- `work_unit_subtype: decomposition` annotation lives ONLY on the decomposition WU file (the single WU producing decomposition.md), informational v1; mechanical enforcement v2 via schemas-extension WU. Materialized slice WUs do not carry this subtype.

### D5. Per-WU acceptance criteria propagation: every PRD success criterion → ≥1 WU AC; every WU AC traces back to PRD criterion or non-delegable judgment.

**Decision:** PRD criterion → WU AC propagation rule:

- Every PRD success criterion (from PRD Understanding subsection 6 verifiable success criteria, per ADR-004 §D2) MUST map to at least one decomposed WU's `acceptance_criteria` entry. Silent omission of a PRD criterion → REJECT decomposition (per R12).
- Every WU `acceptance_criteria` entry MUST trace back to either a PRD criterion OR a PRD non-delegable human judgment (Understanding subsection 5). Silent invention of WU AC without traceability → REJECT decomposition (per R12).
- Each WU AC inherits verifiability discipline from PRD (per WU-005 lesson verifiability_bias): auto-check OR human-review-with-explicit-criteria; unverifiable → verifiable proxy or explicit human-judgment marker.

**Mechanism (traceability):** PRD success criterion has stable id (e.g., `pcrit-001`, `pcrit-002`). Each decomposed WU's AC entry has a `traces_to: <pcrit-id>` field (or `traces_to_judgment: <subsection-5-judgment-id>` for non-delegable judgments). Decomposition document's "Traceability" section is the bidirectional view.

**Cross-decision constraints:**
- With D2(b) `execution_class`: `human_required` slices' AC may include criteria flagged `human_review_required: true` with named review criteria; `autonomous` slices' AC must be fully auto-checkable without human judgment dependency.
- With D3 output shape: decomposition document MUST have explicit Traceability section (PRD criterion → slices implementing it).

**Why:** Per WU-005 lesson verifiability_bias propagated through PRD: the discipline of verifiable success criteria must reach per-WU level, otherwise unverifiable AC silently leak into implementation. Per WU-005 lesson human_understanding: non-delegable judgments must be marked at slice level, otherwise agents executing autonomous slices silently make those judgments.

**How / Implications:**
- Decomposition prompt (when authored as future skill WU) encodes this propagation rule.
- Decomposition self-check (during decompose WU verification) iterates through PRD criteria and confirms each is mapped.
- Future review of individual implementation WUs uses Traceability section to confirm WU output meets the PRD criteria it claims.

### D6. ready_with_override propagation: artifact-level status on decomposition.md vs context-pack metadata for per-WU files.

**Decision (per Codex Fix #2 — careful artifact-vs-WU distinction):**

When PRD has status `ACCEPTED_WITH_INHERITED_OVERRIDE` (per ADR-004 §D6), decomposition propagation works as follows:

**(a) Decomposition document (`.appmaker/decomposition.md` per D3) — artifact-level status:**
- Carries status `ACCEPTED` (when PRD was clean) or `ACCEPTED_WITH_INHERITED_OVERRIDE` (when PRD had inherited override)
- This is **artifact status**, NOT work_unit status — analog to PRD's artifact-level status per ADR-004 §D6
- The decomposition document's Status section explicitly notes: "artifact status, not work_unit status; work-unit-v1 status enum is NOT extended by ADR-005"

**(b) Per-WU `work-unit.yaml` files (materialized from decomposition.md):**
- Use the **standard work-unit-v1 status enum** (PROPOSED, ACCEPTED, IN_PROGRESS, VERIFIED, PROMOTED, PROMOTED_WITH_EXCEPTION, REJECTED) — NO inheritance status added
- Override propagation reaches them via **context-pack metadata**: each WU's context-pack injects the relevant subset of `unresolved_ambiguities[]` filtered by `scope_affected` (per ADR-002 §D6 + ADR-004 §D6)
- The metadata-in-context-pack mechanism is the v1 path; future schemas-extension WU may add a per-WU `inherited_override: bool` field

**Casing:** All UPPERCASE for artifact-level status (consistent with ADR-004 §D4 casing convention). For per-WU work_unit.yaml status, use the standard enum values exactly as defined in work-unit-v1.schema.json.

**Why:** Per ADR-002 §D6, ambiguity propagates through downstream context-packs. The chain is now: interview → PRD → decomposition → individual WU context-packs (third hop established here). Per Codex Fix #2 + WU-006 lesson cross_artifact_consistency_active_check: confusing artifact-level status with work_unit-level status is a cross-artifact consistency failure; the distinction must be explicit. Per WU-007 scope discipline: schema NOT extended by ADR-005.

**How / Implications:**
- Decomposition document's Status section follows the artifact-level pattern set by `.appmaker/prd.md`.
- Per-WU files use standard enum unmodified; their context-packs (when authored downstream) inject ambiguities as a dedicated section "Unresolved Ambiguities (inherited from Decomposition / PRD / Interview)".
- Future schemas-extension WU may formalize per-WU inheritance status as a separate field (not a status enum addition); ADR-005 does not specify this — Open Question.

### D7. Matt Pocock to-issues attribution + 16-lessons mapping table (memory-stream test).

**(a) Attribution per ADR-002 §D5 model:**
- Future decomposition prompt (when authored as a skill in a future WU) MUST include inline header naming Matt Pocock, MIT license, repo URL, exact SKILL.md path (`skills/engineering/to-issues/SKILL.md`)
- `docs/reference/matt-pocock-pattern-mapping.md` gains Entry 4 (this WU appends; existing 3 entries unchanged per WU-006 lesson cross_artifact_consistency_active_check)
- Pinned commit hash: `b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8` (2026-04-30; same as ADR-002/003/004)

**(b) 16-lessons mapping table (memory-stream test, per WU-005 lesson adr_quality + WU-006 lesson cross_decision_consistency_active_check — table cross-checked actively against mapping doc Entry 4):**

| # | Lesson source / category | Concrete element in WU-007 / ADR-005 |
|---|---|---|
| L1 | wu-005 / schema_design | `secondary_artifacts_policy` declared in WU-007 verification block; mapping append covered explicitly |
| L2 | wu-005 / validator_gap | `validator_tooling_preflight` in WU-007 contract; D4(b) explicit that schema modification deferred (no meta-validation pretense for `work_unit_subtype` field) |
| L3 | wu-005 / actual_usage | D2/D3 explicit: no historical decomposition artifacts to mirror (greenfield); D4(b) `work_unit_subtype` enum proposed with explicit revisitation in schemas-extension WU |
| L4 | wu-005 / adr_quality | This §D7 table cross-checked actively against actual `matt-pocock-pattern-mapping.md` Entry 4 being appended; D4(b) work_unit_subtype claim cross-checked against ADR-004 §D4 commitment |
| L5 | wu-005 / harness_engineering | §D5 (every PRD criterion → ≥1 WU AC) + §D4 (cycle detection mandatory) + §D6 (chain extension with explicit artifact-vs-WU distinction) are harness investments — enforce structural lifecycle ordering |
| L6 | wu-005 / human_understanding | **§D2(b2) `execution_class: human_required | autonomous` MANDATES per-slice typing** (carries non-delegable judgments from PRD Understanding subsection 5 to per-WU level) |
| L7 | wu-005 / context_pack_as_program | **§D6(b) per-WU context-packs** carry filtered `unresolved_ambiguities[]` as Software 3.0 program metadata; future ADR-NNN Context-Pack Schema deferred |
| L8 | wu-005 / verifiability_bias | **§D5 propagation rule MANDATES verifiable per-WU AC** (auto-check OR human-review-with-criteria); `autonomous` slices' AC must be fully auto-checkable per D2(b)/D5 cross-coupling |
| L9 | wu-003 / review | This ADR's §Acceptance Criteria + §Verification table = pre-promote external-state fact-check checklist; wording-consistency cross-checked between §D2 ↔ §D5, §D3 ↔ §D6 (D3↔D6 per Codex execution guidance) |
| L10 | wu-003 / adr_quality | Cross-decision consistency check for ADR-005 D1-D7 — 7 selected canonical high-risk pairs from `verification.cross_decision_consistency_active_step.pairs_to_diff` (curated set of decision pairs sharing concepts; not every pair of 7 decisions, which would be C(7,2)=21) |
| L11 | wu-004 / memory_layer | `lessons_applied` field populated in WU-007 work-unit.yaml with 16 entries; this §D7 table demonstrates lessons.jsonl actually informs design |
| L12 | wu-004 / review | adr-v1.schema.json `forbidden_patterns: required` enforced; ADR-005 prose self-check confirms all three forbidden placeholder/deferral markers absent |
| L13 | wu-006 / cross_decision_consistency_active_check | `verification.cross_decision_consistency_active_step.pairs_to_diff` — 7 pairs ACTIVELY diffed (D2↔D3, D2↔D5, D3↔D4, D3↔D5, D5↔D6, D6↔ADR-004 §D6, D7↔mapping). NOT a passive scorecard label. |
| L14 | wu-006 / cross_artifact_consistency_active_check | AC #17 split (existing fields strict-diff vs new decomposition fields conceptual); mapping entry casing UPPERCASE consistent; D6 artifact-status vs WU-status distinction (per Codex Fix #2) |
| L15 | wu-006 / wording_internal_contradiction | Within-decision wording-consistency scan applied: D2 (slice typing — `execution_class` consistent across "Decision" + "How / Implications"), D4 (work_unit_subtype — conceptual vs deferred consistent), D6 (artifact-vs-WU distinction — UPPERCASE qualifier "artifact status, not work_unit status" per Codex execution guidance) |
| L16 | wu-006 / supersedes_pattern_for_correction_events | INDIRECT — pattern stable from prior WUs; ADR-005 may produce events.jsonl correction event if needed during execution; no novel use here |

**Why:** Per Codex's directive across multiple rounds, lessons must demonstrably influence design (memory-stream test), not be name-dropped. Table format (per WU-005 lesson adr_quality + WU-006 lesson cross_decision_consistency_active_check) is mandatory because prose mappings drift; tables can be cross-checked field-by-field actively.

**How / Implications:** Each row above traces to a specific element in WU-007 (work-unit.yaml field, ADR-005 section, mapping doc entry, or self-check item). If any lesson is not traceable to at least one element, WU-007 is REJECTED per acceptance criterion #14.

## Killed Alternatives

### KA-1. Horizontal task decomposition (one technical layer per WU)

**Considered because:** Layer-based decomposition (all schema first, then all API, then all UI) is a common engineering habit; tools like project-management software default to this view.

**Rejected because:**
- Per Matt Pocock to-issues "vertical slice" principle: horizontal slices cannot be demoed in isolation; partial completion has no user-facing value.
- Cumulative integration risk: layers built independently fail when integrated late.
- WU-005 lesson harness_engineering: vertical slices enforce structural correctness; horizontal allows silent integration bugs.

### KA-2. Per-WU `work-unit.yaml` files only (no decomposition document)

**Considered because:** Eliminates a separate artifact; WU files ARE the decomposition output; minimal indirection.

**Rejected because:**
- No central reference for the decomposition's overall coherence (relation graph fragmented across N files).
- Override propagation (D6) becomes harder: each WU re-derives from PRD instead of inheriting from a single decomposition status.
- D5 traceability (every PRD criterion → ≥1 WU AC) requires aggregating across all WU files; central document makes it scannable.
- Holistic review (does this set of slices cover PRD?) is impossible without the central view.

### KA-3. Drop slice typing entirely (D2(b3))

**Considered because:** Simpler — slice IS slice; typing adds cognitive overhead; "just look at the slice and tell".

**Rejected because:**
- Per WU-005 lesson human_understanding: non-delegable judgments must be marked explicitly at the per-slice level. Without typing, autonomous-looking slices silently consume human judgment (e.g., an "API endpoint" slice that secretly requires architectural decisions).
- Per Matt Pocock to-issues: HITL/AFK distinction is a load-bearing concept in their workflow. Dropping it weakens the inspiration source significantly.
- Per R12 (no silent fallbacks): silent delegation of judgment is exactly the failure mode `execution_class` prevents.

### KA-4. Schema modification (`work_unit_subtype` enum) within ADR-005

**Considered because:** ADR-004 §D4 commits ADR-005 to "introduce a formal `work_unit_subtype: decomposition` to work-unit-v1 schema." Direct schema write here would satisfy that commitment immediately.

**Rejected because:**
- WU-007 contract scope explicitly excludes schema modification (AC #10 + blocked_files_write covers `.appmaker/schemas/**`). Adopting this would violate scope.
- Per WU-005 lesson schema_design + actual_usage: schema changes deserve dedicated WU with proper review, not bundled as a side-effect of an ADR.
- Per Codex's Fix #1 in WU-007 review: ADR-005 may resolve the ADR-004 §D4 commitment via path (a) — conceptual decision here, formal schema write deferred to schemas-extension WU. D4(b) above adopts path (a).

### KA-5. Issue tracker integration (Matt's "publish to issue tracker" step)

**Considered because:** Matt to-issues final step publishes issues to a project issue tracker (GitHub Issues, Linear, etc.) with `needs-triage` label.

**Rejected because:**
- v1 AppMaker has no built-in issue tracker dependency (consistent with ADR-004 §D2 same rationale for PRD).
- External tracker integration is implementation choice for individual projects, not core kernel concern.
- Decomposition output lives in `.appmaker/decomposition.md` (per D3); future plug-in WU may export to issue tracker.

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Decomposition shape over-engineered before any real PRD decomposed | Medium | Medium | D3 explicit revisitation in OQ-2; formal decomposition-v1 schema deferred to schemas-extension WU |
| `execution_class` enum values insufficient (e.g., need third class for "review-required-but-AFK-implementable") | Medium | Low | Future amendment may extend enum; current 2-value enum maps cleanly to Matt's HITL/AFK |
| `work_unit_subtype` conceptual-vs-schema gap creates confusion until schemas-extension WU lands | Medium | Medium | D4(b) explicit about deferral; WU-007 contract notes schema NOT modified; future schemas-extension WU will resolve |
| ready_with_override propagation chain getting longer (interview → PRD → decomposition → per-WU) | Medium | Medium | Each downstream WU may resolve specific ambiguity (removing it from chain via amendment); future analytics WU may surface unresolved-ambiguity counts |
| D5 propagation rule too rigid (every PRD criterion → ≥1 WU AC) for trivial PRDs | Low | Low | "Out-of-decomposition-scope" with reason is acceptable per consumption rule; only silent omission is forbidden |
| Cycle detection (D4) deferred to kernel implementation; v1 relies on human review | Medium | Medium | Mandatory check in human review at decomposition promote; future kernel implementation as separate WU |
| Cross-artifact status confusion (D6 artifact-status vs WU-status) at executor level | Medium | High | D6 explicit qualifier "artifact status, not work_unit status" per Codex Fix #2 + execution guidance; Status section in decomposition.md template explicit |
| Matt Pocock to-issues "publish to issue tracker" step not adopted, may confuse adopters familiar with original | Low | Low | Mapping doc Entry 4 explicit about adaptation differences |
| Cross-decision contradiction within D1-D7 (7 sub-decisions) | Medium | High | 7 ACTIVE pairwise diffs per `verification.cross_decision_consistency_active_step.pairs_to_diff` per WU-006 lesson #1 — not passive scorecard |

## Rollback Plan

**Soft rollback:** Future ADR (ADR-NNN) supersedes specific decisions in ADR-005 (e.g., D2(b) execution_class enum values revised after first real decomposition; D4(b) `work_unit_subtype` schema landing changes naming). Mapping doc to-issues entry may be amended via dedicated work_unit with revision history per WU-003 convention.

**Hard rollback:** Archive ADR-005 + mapping append (mark status REJECTED in revision history; mapping doc append removed via amendment with revision history note). AppMaker reverts to ad-hoc decomposition (PRD → individual implementation WUs without formal decomposition stage). Any `work_unit_subtype: decomposition` annotation on the (now-archived) decomposition WU remains valid as informational metadata in the audit trail; no data migration. Materialized slice WUs (which never carried that subtype) are unaffected. No production users affected (greenfield).

## Open Questions

- **OQ-1.** `related_to` relation type (cross-cutting non-blocking informational coupling). Deferred to future amendment if v1 `blocked_by` + `depends_on` proves insufficient.
- **OQ-2.** Decomposition shape v2 — formal `decomposition-v1.schema.json` once enough real decompositions exist to inform field design. Per WU-005 lesson actual_usage, schema-from-mental-model premature.
- **OQ-3.** `work_unit_subtype` schema landing — separate schemas-extension WU adds the field formally to work-unit-v1.schema.json; until then, conceptual per D4(b).
- **OQ-4.** Cycle detection kernel implementation — future CLI implementation WU adds the validator.
- **OQ-5.** Per-WU `inherited_override: bool` field formalization — separate schemas-extension WU may add it (alternative to context-pack-only metadata per D6(b)).
- **OQ-6.** Decomposition prompt as catalog skill — future skill-authoring WU.
- **OQ-7.** Issue tracker export plug-in — future integration WU; not core kernel.
- **OQ-8.** Future ADR-NNN candidates carry forward from ADR-004 OQ list: validator implementation (ADR-003 OQ-1), v1.1 context-compiler (ADR-001 OQ-2 + WU-005 lesson context_pack_as_program), schema migration (ADR-003 OQ-5), Verifiability Standards, Agent-Native Project Interface, Context-Pack Schema, Design Exploration Stage.
- **OQ-9.** Candidate future `work_unit_subtype` enum values — NOT accepted by ADR-005 (which only accepts `decomposition` per D4(b)); each requires a dedicated future ADR before being added to the schema. Plausible candidates surfaced during ADR-005 drafting: `review` (WU dedicated to reviewing another WU's output), `retro` (WU producing post-promote retrospective lessons), `amendment` (WU amending constitution / ADR — precedent: WU-004 amendment_class), `interview` (WU producing interview-result.yaml), `prd` (WU producing prd.md). Listed here as discovery context for future enum-extension ADRs, not as accepted v1 values.

## Acceptance Criteria

This ADR is `READY-FOR-REVIEW` (informally; formal status governed by WU-007 work-unit.yaml) when:

- All 7 decisions D1–D7 resolved with explicit decision and rationale
- ≥3 killed alternatives documented (this ADR has 5: KA-1 through KA-5)
- D2(b) decides slice typing (b2 `execution_class` AppMaker mapping adopted; b1 literal HITL/AFK + b3 drop typing both killed with reasons)
- D3 decides output location with rationale; ≥3 alternatives evaluated (KA-2 explicit)
- D4 specifies relation set + cycle detection + `work_unit_subtype` resolution per ADR-004 §D4 commitment via path (a) conceptual-not-schema (KA-4 explicit)
- D5 specifies field-by-field PRD criterion → WU AC propagation + traceability mechanism
- D6 explicit artifact-status vs work_unit-status distinction per Codex Fix #2 — UPPERCASE qualifier "artifact status, not work_unit status"
- D7 contains 16-row lessons mapping table cross-checked actively against mapping doc Entry 4
- Matt Pocock attribution explicit: link, MIT, author, exact SKILL.md path, pinned commit hash
- 12 required adr-v1 sections present in declared order
- Length 250–550 lines
- No constitution edits, no schema files, no ADR-001/002/003/004 edits
- All three forbidden placeholder markers absent
- Open Questions enumerates 8+ deferred items (OQ-1 through OQ-8)

## Verification

| Required section (per `adr-v1`) | Present? |
|---|---|
| Status | yes |
| Metadata | yes |
| Context | yes |
| Sources Consulted | yes |
| Decision (numbered) | yes (D1–D7) |
| Killed Alternatives | yes (KA-1 through KA-5) |
| Risks and Mitigations | yes (9 rows) |
| Rollback Plan | yes (soft + hard) |
| Open Questions | yes (OQ-1 through OQ-8) |
| Acceptance Criteria | yes |
| Verification | yes (this table) |
| Revision History | yes (below) |

**Forbidden patterns check** (per `work-unit.yaml.verification.forbidden_patterns` for WU-007): all three listed patterns absent from prose.

**Active cross-decision pairs check** (per WU-006 lesson cross_decision_consistency_active_check — 7 pairs in `verification.cross_decision_consistency_active_step.pairs_to_diff`):

| Pair | Status |
|---|---|
| D2 (slice typing `execution_class`) ↔ D3 (output shape `decomposition.md`) | aligned: D3 carries `execution_class` per slice in slice list |
| D2 (slice typing) ↔ D5 (AC propagation) | aligned: `human_required` slices may have `human_review_required` AC; `autonomous` slices fully auto-checkable |
| D3 (output shape single doc) ↔ D4 (relation graph location) | aligned: graph lives IN decomposition.md per D3+D4 |
| D3 (output shape) ↔ D5 (AC propagation Traceability) | aligned: D3 explicit Traceability section in document |
| D5 (AC propagation) ↔ D6 (override propagation) | aligned: WU AC may reference ambiguity ids when relevant |
| D6 (override propagation) ↔ ADR-004 §D6 (PRD override) | aligned: same artifact-vs-WU distinction; chain extension explicit |
| D7 (lessons mapping) ↔ matt-pocock-pattern-mapping Entry 4 | aligned: mapping entry cross-checked against §D7 table fields (cross-artifact per WU-006 lesson #2) |

**Within-decision wording consistency check** (per WU-006 lesson wording_internal_contradiction): each decision's "Decision" + "How / Implications" subsections diff-checked for terminology consistency. All seven decisions confirmed internally consistent.

## Revision History

| Date | Author / Work_unit | Status | Changes |
|---|---|---|---|
| 2026-05-10 | WU-007 (draft) | DRAFT | Initial draft. 7 decisions D1–D7. 5 killed alternatives. 8 open questions. 16-row lessons mapping table (8 wu-005 direct + 4 broad + 4 fresh wu-006). Matt Pocock to-issues attribution complete. Slice typing decision: AppMaker `execution_class: human_required \| autonomous` (b2 mapping, not b1 literal HITL/AFK). Output shape: `.appmaker/decomposition.md` single document (D3 a). Relation graph: blocked_by + depends_on; cycle detection mandatory; `work_unit_subtype` conceptual per D4(b) — schema modification deferred. PRD criterion → WU AC propagation rule: every PRD criterion mapped (no silent omission); every WU AC traceable. ready_with_override propagation: artifact-status on decomposition.md vs context-pack metadata for per-WU files (per Codex Fix #2). 7 active cross-decision pairs verified. Within-decision wording-consistency scan applied. |

---

**End of ADR-005 (DRAFT — WU-007).**
