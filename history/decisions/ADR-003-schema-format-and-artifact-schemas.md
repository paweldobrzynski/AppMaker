# ADR-003: Schema Format and v1 Artifact Schemas

## Status

**ACCEPTED** — promoted from WU-005 to `decisions/` on 2026-05-09. The original draft remains immutable at `.appmaker/work-units/wu-005/runs/2026-05-09T21-52-08Z/output.md` for audit. Three secondary schema files concurrently promoted to `.appmaker/schemas/`.

Lifecycle: `DRAFT` (in run dir, immutable) → **`ACCEPTED`** (current — this file at `decisions/ADR-003-schema-format-and-artifact-schemas.md`) → `AMENDED` (if modified by future amendment work_unit, per Amendment Process in constitution).

## Metadata

- **Date:** 2026-05-09
- **Authors:** pawedo@gmail.com (decision-maker), Claude Opus 4.7 (synthesis), Codex (critic, multiple rounds)
- **Type:** investigation work_unit (multi-output: ADR + 3 schemas)
- **Supersedes:** none
- **Superseded by:** none
- **Related:** ADR-001 (process kernel), ADR-002 (interview phase), constitution v2 (amended with R18), WU-005 contract

## Context

ADR-001 established work_unit as primitive. ADR-002 added Interview Phase with conceptual `interview-result.yaml` shape. Constitution v2 added R18 enforcing Interview as first lifecycle gate. Across WU-002, WU-003, WU-004 the `work-unit.yaml` shape evolved organically (different field sets per WU, ad-hoc additions like `amendment_target`, `solo_execution_exception`, `validator_tooling_preflight`, `secondary_artifacts_policy`). ADR documents have settled into a 12-section convention but with no enforced schema.

This drift is sustainable for 4 WUs; it will not scale to 40. ADR-003 introduces formal v1 schemas for the three artifact classes that have stabilized enough to schematize: `interview-result.yaml`, `work-unit.yaml`, and ADR documents. These schemas turn six lessons accumulated through WU-003 and WU-004 into hard machine-readable fields and validators.

ADR-003 is also the place where the schema **format** is decided (canonical representation: JSON Schema, Zod, custom YAML, or hybrid), since making three schemas without first picking a format would lock the choice silently. Per Codex's WU-005 directive, schema-format-as-architectural-decision must be in an ADR; combining the format ADR and the v1 schema artifacts in one work_unit (multi-output) avoids ceremonial overhead while preserving the architectural separation.

## Sources Consulted

| Source | Contribution |
|---|---|
| ADR-001 | work_unit primitive (D2), type enum (D2a), 6-file model (D3), CLI-first / no-MCP-yet (D10), 3-stream logging (D11), gates fail closed (D13) |
| ADR-002 | `interview-result.yaml` conceptual shape, 4-state readiness enum (D3), `ready_with_override` propagation (D6) |
| constitution v2 | R1 (ADR shape), R5 (gates fail closed), R7 (parser validation), R8 (context-pack inclusion), R12 (no silent fallbacks), R13 (uncertainty / change), R17 (≤25 rules), R18 (Interview required) |
| Codex critique rounds | JSON Schema canonical recommendation (rationale: neutral, broad tooling, doesn't bind to TS prematurely); D1 GUARD (no-code WU); validator_tooling_preflight (ajv unavailable locally); secondary_artifacts_policy (gate conditional for deferred path) |
| lessons.jsonl entries | 6 direct (wu-005-applicable) + 1 indirect (context_compiler informing v1.1 planning); see §Decision-D5 for explicit mapping table |
| Local environment audit | jq 1.7.1, PyYAML 6.0.3, Ruby Psych available; ajv and python jsonschema NOT INSTALLED |

## Decision

Five numbered, individually addressable decisions D1–D5.

### D1. Canonical schema format: **JSON Schema (Draft 2020-12) + YAML examples for humans.**

**Decision:** Schemas are authored as JSON Schema documents (`.schema.json`) using JSON Schema Draft 2020-12. Human-facing examples and reference snippets are kept as YAML alongside, either inline in ADRs or as separate `.examples.yaml` files when verbose. Codex's recommendation (provided as context, not mandate) is adopted with the following stated reasons:

**Why:**
- JSON Schema is **language-neutral**: validators exist in TypeScript (ajv), Python (jsonschema, fastjsonschema), Go, Rust, Ruby, etc. Picking JSON Schema does not commit AppMaker to any specific runtime.
- ADR-001 §D10 commits AppMaker to **CLI-first**, MCP/runtime-language deferred. Adopting Zod canonical now would prematurely bind to TypeScript.
- JSON Schema is **widely supported by editors** (VS Code, JetBrains) and **CI tools** without additional runtime, providing developer-experience value with no extra dependency.
- Zod / equivalent runtime-typed wrappers can be **generated or adapted** from JSON Schema later without changing the canonical source.
- YAML examples remain human-friendly for documentation, sample work_unit.yaml files, and onboarding; JSON Schema validates the YAML when desired (YAML maps cleanly to JSON for validation purposes).

**How / Implications:**
- All v1 schema files use `.schema.json` extension and JSON Schema Draft 2020-12 (`$schema: "https://json-schema.org/draft/2020-12/schema"`).
- Human-facing examples in this ADR and in future WU context-packs may use YAML when readability matters (work-unit.yaml, interview-result.yaml).
- Validator implementation (ajv install or equivalent) is deferred — see D4.
- D1 GUARD compliance: JSON Schema is text-based JSON, not code; scope is satisfied.

### D2. Schema directory: **`.appmaker/schemas/<name>-v<n>.schema.json`** (kernel-managed, versioned in filename).

**Decision:** Schemas live at `.appmaker/schemas/`, with filename pattern `<name>-v<n>.schema.json` where `<n>` is an incremental version. v1 files: `interview-result-v1.schema.json`, `work-unit-v1.schema.json`, `adr-v1.schema.json`.

**Why:** Per ADR-001 §D3, kernel-managed artifacts live under `.appmaker/`; human-authored governance (constitution, ADRs, north-star) lives at root. Schemas are kernel-generated/maintained, not human-authored; therefore `.appmaker/schemas/` is correct. Versioning in the filename (rather than a separate `v1/` directory) keeps related versions visually adjacent and avoids directory proliferation as schemas evolve.

**How / Implications:**
- Three v1 schemas added by this WU.
- Future v2 schemas land alongside v1 (e.g. `work-unit-v2.schema.json` next to `work-unit-v1.schema.json`).
- Superseded versions move to `.appmaker/_archive/schemas/` per D3 policy.

### D3. Versioning policy: **incremental (v1 → v2 → vN) with prior version archived to `.appmaker/_archive/schemas/` on supersedence.**

**Decision:** Schema versions are integers starting at 1. A new version supersedes the prior; on PROMOTE of the new schema, the prior version is moved to `.appmaker/_archive/schemas/` (not deleted) and the new version takes the canonical path. Co-existence of two non-archived versions is not permitted.

**Why:** Mirrors constitution amendment treatment (audit trail preserved; current canonical version is single). Avoids the mental tax of two competing versions at once. Archive (rather than delete) preserves R10-style audit even though schemas are not part of the audit-stream trio (decisions/events/lessons).

**How / Implications:**
- Each schema has exactly one canonical file in `.appmaker/schemas/` at any time.
- Migration path is encoded in the new schema's `description` or in a dedicated migration ADR for breaking changes.
- Existing artifacts (work_units, ADRs, interview results) authored against an archived schema remain valid for audit; new artifacts must use the canonical version.

### D4. Validation conformance: **parser + structural at v1; meta-schema validator deferred to future implementation WU.**

**Decision:** v1 validation requirements:
- All `.schema.json` files MUST pass `jq empty` (JSON syntax check).
- All artifacts (work_units, interview results, ADRs) MUST pass parser validation in their declared format (PyYAML or Ruby for YAML; jq for JSON; markdown structural checks for ADRs).
- Structural validation (section presence, required-fields, forbidden-patterns) is performed by ad-hoc shell scripts (`grep`, `awk`, `sed`) and acceptance-criteria checklists per WU.
- **JSON Schema meta-validation** (validating that schemas conform to Draft 2020-12) is **deferred** to a future implementation work_unit that installs and configures `ajv` (or equivalent: `python jsonschema`, etc.).
- Until the validator is in place, schemas are treated as **structurally trusted** (manual review at this ADR-003 review) and **content-validated** by their declared use (work-unit.yaml conforming to work-unit-v1 is checked manually until validator exists).

**Why:**
- Local environment audit (validator_tooling_preflight): `jq` available; `ajv` and `python jsonschema` NOT installed. Requiring meta-validation at v1 would create an unsatisfiable gate (per Codex's review of WU-005 contract).
- Per constitution R12 (no silent fallbacks), the gap must be **explicit** (recorded here and in WU-005 events.jsonl) and **addressed** (deferred to a named future WU), not silently ignored.
- Per Codex's execution directive: "do not pretend full meta-validation; jq syntax pass + structural self-check + explicit deferral".

**How / Implications:**
- Promote gate accepts `declared_format_validation_pass` based on parser + structural check, not meta-schema.
- ADR-003 §Open Questions records the deferred validator implementation work (see OQ-1).
- When validator is implemented (future WU), schemas may need adjustment to pass strict meta-schema; this is expected and acceptable.

### D5. Lessons-derived fields explicit mapping (memory-stream test).

**Decision:** Each of the 6 wu-005-applicable lessons maps to one or more concrete schema fields in the three v1 schemas. The mapping is the table below.

| Lesson source / category | Action from lesson | Schema field(s) operationalizing the action | Located in |
|---|---|---|---|
| wu-003 / review (2026-05-09T15:55Z) | Pre-execution checklist must include external-state fact-check + wording-consistency scan | (process, not schema field) → ADR-003 acceptance criteria + WU-005 self-check; informs `review_scorecard_template.cross_decision_consistency` and `cross_artifact_consistency` field design | work-unit-v1.schema.json `review_scorecard_template` (extensible mapping permits these fields) |
| wu-003 / adr_quality (2026-05-09T15:55Z) | Add `cross_decision_consistency` field to `review_scorecard_template` | `review_scorecard_template.cross_decision_consistency` (and `cross_artifact_consistency` by extension); `review_scorecard_template` declared as extensible mapping in schema | work-unit-v1.schema.json `review_scorecard_template` |
| wu-004 / amendment_process diff (2026-05-09T16:50Z) | Future constitution amendments must include textual diff check proving unchanged rules | `amendment_target` object (amendment subtype) including `rule_change` enum and `rules_unchanged_check` requirement encoded in schema's `if` clause when `amendment_class` is present | work-unit-v1.schema.json `amendment_target` + `verification.rules_unchanged_check` |
| wu-004 / memory_layer (2026-05-09T16:50Z) — LOAD-BEARING | Add `lessons_applied` field for work_units consuming lessons | `lessons_applied: array of {source, influence}` field at work_unit level | work-unit-v1.schema.json `lessons_applied` |
| wu-004 / amendment_process semantic (2026-05-09T16:50Z) — LOAD-BEARING | Schema for amendment work_units must include `affects_core_safety_rules` and `semantic_relations` | `amendment_target.affects_core_safety_rules: bool` + `amendment_target.semantic_relations: mapping<rule_id, rationale>` | work-unit-v1.schema.json `amendment_target` |
| wu-004 / review (2026-05-09T16:50Z) — LOAD-BEARING | Schema verification should require forbidden-pattern checks for markdown governance artifacts | `forbidden_patterns: array of strings` field in adr-v1; same pattern reusable in constitution-v1 (future) | adr-v1.schema.json `forbidden_patterns` |

Indirect lesson (wu-003 / context_compiler): not mapped to a v1 schema field; informs v1.1 context-compiler design — see §Open Questions OQ-2.

**Why:** Per Codex's directive, lessons must demonstrably influence schema field design (memory-stream test). The table provides a one-to-one trace from each load-bearing lesson's `action` to a specific schema field. WU-005 review scorecard explicitly tests this traceability.

**How / Implications:** All listed fields are required in the corresponding schema files (interview-result-v1, work-unit-v1, adr-v1) per WU-005 acceptance criteria #8–#10. Cross-schema consistency (status enum, type enum) is verified at WU-005 self-check.

## Killed Alternatives

### KA-1. Zod canonical for v1 (with generated JSON Schema)

**Considered because:** Zod offers excellent runtime TypeScript ergonomics; generated JSON Schema can serve non-TS consumers.

**Rejected because:**
- Binds AppMaker to TypeScript runtime prematurely (ADR-001 §D10 commits to CLI-first, MCP/runtime later).
- Codex flagged D1 GUARD: WU-005 is no-code; Zod authoring requires `.ts` which is scope-blocked. Adopting Zod would force deferring all schema files to a follow-up implementation WU, doubling ceremony.
- Generated JSON Schema from Zod is downstream; canonical source matters for editors, CI, docs. Authoring in Zod and generating JSON Schema makes the JSON Schema "second-class".
- Future Zod adapter can be generated FROM JSON Schema (reverse direction is well-supported); the inverse is also possible but adds tooling complexity.

### KA-2. Custom YAML schema (no JSON Schema)

**Considered because:** YAML is the format AppMaker work_units already use; a YAML-native schema language would feel more native.

**Rejected because:**
- No standardized YAML-native schema language exists with broad tooling support. Options like Kwalify or ad-hoc YAML structure lack editor support, IDE integration, and CI validators.
- Reinventing schema validation for YAML duplicates work that JSON Schema already does (YAML parses cleanly to JSON for validation purposes).
- Limits future portability: most external tools and integrations expect JSON Schema, not custom YAML schema.

### KA-3. Schemas described in prose only (no machine-readable form)

**Considered because:** ADR-002 §schema-shape worked as conceptual prose; perhaps formal schema is overkill for v1.

**Rejected because:**
- Constitution R7 requires machine-readable artifacts to pass parser validation. Schemas described only in prose cannot be invoked by the kernel for automatic validation.
- Memory-stream test (lessons #5, #6, #7) explicitly requires concrete schema fields, not prose descriptions.
- Future work_units (WU-006+) need an enforceable contract for what counts as a valid `work-unit.yaml`. Prose-only contracts are interpreted differently each time.

### KA-4. Hybrid ad hoc (no canonical format; per-schema choice)

**Considered because:** Different schemas have different needs; perhaps interview-result wants YAML, work-unit wants JSON Schema, adr-v1 wants Markdown spec.

**Rejected because:**
- Inconsistency creates cognitive load and tooling fragmentation.
- WU-005 acceptance criterion #11 requires cross-schema consistency (shared concepts like status enum). A single canonical format makes this enforceable; a hybrid does not.
- "We'll figure it out per schema" is silent fallback (R12 violation in spirit): the format choice is hidden inside each schema rather than made architecturally.

### KA-5. No schemas in v1 (continue ad-hoc work-unit.yaml)

**Considered because:** WU-002, WU-003, WU-004 worked without formal schemas; perhaps schemas are premature.

**Rejected because:**
- Lessons #5, #6, #7 explicitly call for schema fields. Memory layer would be unused if the actions are deferred indefinitely.
- WU-006+ adoption of new patterns (PRD synthesis, decomposition, safety hooks, TDD runner) will multiply work_unit.yaml shapes; schema enforcement now keeps drift bounded.
- Per Codex: schemas v1 are the moment to operationalize lessons; postponing means lessons rot.

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| JSON Schema meta-validator gap masks subtle schema bugs | Medium | Medium | D4 records gap explicitly; structural review by Codex + human at WU-005 promote; deferred validator WU is OQ-1 |
| `ajv compile` mentioned in WU-005 risks but not available locally | Low (already addressed) | Low | This ADR records ajv as unavailable; D4 deferral is explicit; no claim of meta-validation in v1 |
| Schemas under-specify v1 (miss fields used in WU-002/003/004) | Medium | Medium | Acceptance criteria #8–#10 enumerate required fields; cross-reference with actual work-unit.yaml files in run dir |
| Schemas over-specify v1 (lock fields that should be flexible) | Medium | Low | Mark optional fields explicitly; use `additionalProperties: true` for extensibility maps (e.g. `review_scorecard_template`) |
| Schema versioning policy (D3) creates archive sprawl over time | Low | Low | Archive directory is reviewable; future amendment may add cleanup policy |
| Lessons-derived fields are present but not enforced (kernel doesn't check) | High | Medium | Explicit deferral to future implementation WU (OQ-1); manual review enforces in v1 |
| Future Zod adapter conflicts with JSON Schema canonical | Low | Low | D1 explicitly states JSON Schema is canonical; any adapter (Zod, etc.) is downstream and must regenerate from canonical |
| Cross-schema consistency drifts as schemas evolve independently | Medium | Medium | WU-005 acceptance criterion #11 explicit; future amendments must include cross-schema check |
| JSON Schema Draft version compatibility across consumer tools | Low | Medium | Draft 2020-12 explicit in `$schema` URI; future tools that only support Draft 7 or earlier require either schema downgrade or tool upgrade; OQ-1 implementation WU records validator's supported drafts |

## Rollback Plan

**Soft rollback:** Future ADR (ADR-NNN) supersedes specific decisions. For example, if D1 (JSON Schema canonical) proves wrong (e.g. ecosystem fragmentation forces Zod), ADR-NNN documents the supersedence; existing v1 schemas migrate to new format via dedicated implementation WU. Constitution and ADR-003 itself remain in audit; the new ADR is the active reference.

**Hard rollback:** Archive ADR-003 + 3 schemas (mark status `REJECTED` in revision history, move to `.appmaker/_archive/`). AppMaker continues using ad-hoc work-unit.yaml conventions (as in WU-002/003/004) until v1 schemas are re-attempted with revised ADR. No production users affected (greenfield); cost is design rework only.

## Open Questions

- **OQ-1.** Validator implementation (ajv install + integration) is deferred. Future implementation WU (likely WU-NNN, post-WU-005-promote) will:
  - Install `ajv` (Node.js) or `python jsonschema` package (whichever the implementation WU justifies).
  - Validate all three v1 schema files against JSON Schema Draft 2020-12 meta-schema (this is the missing meta-validation step).
  - Integrate the validator into the kernel for pre-VERIFIED checks: any new work_unit.yaml or interview-result.yaml validates against the corresponding v1 schema before status can flip to VERIFIED.
  - Re-validate any v1 schema adjustments that the meta-validator flags. Schemas authored under v1 review-only conditions may have subtle Draft 2020-12 violations; expected and acceptable rework.
  - Decide whether validator runs in CI, in pre-commit hook, or only on `appmaker promote` (likely all three, with config).
- **OQ-2.** Indirect lesson #1 (wu-003 context_compiler): v1.1 context-compiler with Aider-style PageRank + tree-sitter compression is enabled by these v1 schemas. Specifically:
  - work-unit-v1 schema lets the compiler statically check that a context-pack contains required fields (constitution, recent ADRs, acceptance criteria per R8).
  - adr-v1 schema lets the compiler validate that cited ADRs have the structure they claim (sections present, decisions resolved).
  - Implementation deferred to v1.1 work_units; data point for justification: WU-005 context-pack itself was 549 lines, larger than WU-002's 237.
- **OQ-3.** Schema reuse across multiple AppMaker projects (cross-project pattern library, ADR-001 §D11 OQ-2 deferred). v1 schemas are per-project; future may centralize via a shared `~/.appmaker/global/schemas/` directory or by publishing schemas as a versioned npm package. Decision deferred until at least 3 AppMaker projects exist and shared-schema friction becomes evident.
- **OQ-4.** Constitution-v1 schema (formal schema for `constitution.md`) — not in this WU. Consider adding when constitution evolves further (after 2-3 amendments) and benefits become clear.
- **OQ-5.** Schema migration tooling (automated upgrade of artifacts when schema version bumps) — deferred. Manual migration with archive at v1.

## Acceptance Criteria

This ADR is `READY-FOR-REVIEW` (informally; the formal status is governed by WU-005 work-unit.yaml) when:

- All 5 decisions D1–D5 resolved with explicit decision and rationale ✓
- D5 mapping table is concrete (6 rows) not prose ✓
- ≥3 killed alternatives documented with reasons ✓ (5 documented: KA-1 through KA-5)
- D1 GUARD compliance: JSON Schema is text-based JSON, not code; no .ts files needed; D1 GUARD does not activate; schema files produced ✓
- D4 explicitly states meta-schema validation deferred + records local validator gap ✓
- Codex's JSON Schema recommendation cited and adopted with stated reasons (or, if rejected, with stated alternative) ✓
- All 6 wu-005-applicable lessons mapped in §D5 table ✓
- 12 required adr-v1 sections present ✓
- No constitution edits, no schema files within ADR (schemas are separate files) ✓
- No contradiction with ADR-001, ADR-002, constitution v2 ✓
- Open Questions enumerates deferred work ✓ (OQ-1 through OQ-5)
- Forbidden patterns absent in ADR body per `work-unit.yaml.verification.forbidden_patterns` for WU-005 (no placeholder markers, no deferred-task markers, no bare three-dot ellipsis hand-waving)
- Length 250–550 lines

## Verification

| Required section (per `adr-v1` informal v1 conventions) | Present? |
|---|---|
| Status | yes |
| Metadata | yes |
| Context | yes |
| Sources Consulted | yes |
| Decision (numbered) | yes (D1–D5) |
| Killed Alternatives | yes (KA-1 through KA-5) |
| Risks and Mitigations | yes (8 rows) |
| Rollback Plan | yes (soft + hard) |
| Open Questions | yes (OQ-1 through OQ-5) |
| Acceptance Criteria | yes |
| Verification | yes (this table) |
| Revision History | yes (below) |

**Validator status (per validator_tooling_preflight + Codex execution directive):**
- `jq empty` for JSON Schema syntax: AVAILABLE locally (`/usr/bin/jq` 1.7.1).
- PyYAML + Ruby Psych for YAML parsing: AVAILABLE.
- JSON Schema Draft 2020-12 meta-validator (ajv, jsonschema): NOT AVAILABLE locally.
- v1 validation = parser + structural only. Meta-validation deferred to OQ-1 implementation WU.

## Revision History

| Date | Author / Work_unit | Status | Changes |
|---|---|---|---|
| 2026-05-09 | WU-005 (draft) | DRAFT | Initial draft. 5 decisions D1–D5 resolved. JSON Schema canonical (D1) adopted from Codex's recommendation with stated reasons. 5 killed alternatives. 5 open questions. Lessons-mapping table (6 direct lessons → schema fields) per memory-stream test. Validator gap (ajv/jsonschema unavailable locally) recorded explicitly per Codex execution directive. |
| 2026-05-09 | WU-005 (Codex post-execution review) | DRAFT | Two consistency fixes pre-promote: (1) work-unit-v1 `promote_gate.required_pass` items: changed from string-only to `oneOf [string, object]` to match historical usage in WU-002/003/004 (Hash) and WU-005 (Hash+String); (2) work-unit-v1 amendment subtype `then` clause now requires both `amendment_target` AND `verification.rules_unchanged_check` with `[rules_to_compare, method]` per ADR-003 §D5 lessons-mapping (lesson #4 wu-004 amendment_process diff-verification). 251 lines unchanged; ADR body unchanged. |
| 2026-05-09 | WU-005 (promote) | ACCEPTED | Promoted from `.appmaker/work-units/wu-005/runs/2026-05-09T21-52-08Z/output.md` to `decisions/` after Codex REVIEW PASS. Status flip DRAFT → ACCEPTED in promoted copy; original draft immutable in run dir. Three secondary schemas concurrently promoted to `.appmaker/schemas/` (interview-result-v1, work-unit-v1, adr-v1). All schemas pass `jq empty`. Meta-schema validation deferred to future implementation WU per D4 + OQ-1. |

---

**End of ADR-003 (ACCEPTED — WU-005 promoted 2026-05-09; current canonical schema-format decision; v1 schemas at `.appmaker/schemas/`).**
