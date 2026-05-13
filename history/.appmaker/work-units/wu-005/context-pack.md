# Context Pack — WU-005: ADR-003 Schema Format + interview-result-v1 + work-unit-v1 + adr-v1

> **R8 compliance statement.** Per `constitution.md` v2 Rule R8, this pack contains:
>
> - **Constitution v2** — Appendix A (critical excerpts inline; full accepted file at `/Users/pawel/Projects/AppMaker/constitution.md`, 18 rules including R18 Interview Phase)
> - **ADR-001 relevant decisions** — Appendix B (full file at `decisions/ADR-001-process-kernel-architecture.md`)
> - **ADR-002 relevant decisions** — Appendix B (full file at `decisions/ADR-002-interview-phase.md`)
> - **WU-005 acceptance criteria (verbatim)** — Appendix C
> - **Lessons applicable to wu-005-schema (verbatim)** — Appendix D (6 direct + 1 indirect)
>
> R8 v1 compliance for manual packs is satisfied by including critical excerpts
> inline plus an absolute path to the accepted file. Lessons inclusion is
> mandatory per WU-005 acceptance criterion #4 and Codex's memory-stream
> directive: lessons must demonstrably influence schema field design, not
> merely be cited.

---

## 1. Goal (recap from work-unit.yaml)

Produce four artifacts in one investigation work_unit:

1. **ADR-003** (primary): resolves five decisions D1–D5 about schema format,
   directory, versioning, validation conformance, and lessons-derived fields.
   Promotion path: `decisions/ADR-003-schema-format-and-artifact-schemas.md`.

2. **`interview-result-v1.schema.<ext>`** (secondary): formal schema for the
   conceptual shape from ADR-002 §schema-shape, with four-state readiness
   enum and `ready_with_override` structural requirements.

3. **`work-unit-v1.schema.<ext>`** (secondary): formal schema for the ad-hoc
   work_unit.yaml shape used in WU-002, WU-003, WU-004. Must include
   lessons-derived fields per Appendix D.

4. **`adr-v1.schema.<ext>`** (secondary): formal schema for ADR document
   structure used since ADR-001. Must include `forbidden_patterns`
   enforcement field per Appendix D lesson 4 (wu-004 review).

The `<ext>` is determined by ADR-003 D1 (format choice).

---

## 2. What ADR-003 IS (and is NOT)

**IS:**
- Architectural decision record per `adr-v1` schema conventions (12 sections)
- Multi-output WU primary artifact (paired with 3 secondary schema files)
- Decisive about schema format canonical choice with rationale + ≥3 killed alternatives
- Explicit about which lessons map to which schema fields (memory-stream test)
- Within-bounds: 250–550 lines markdown
- Codex's JSON Schema recommendation noted as context, not mandate (executor evaluates and justifies their D1 pick)

**IS NOT:**
- A validator implementation (deferred to follow-up implementation WU)
- A schema migration tool (deferred)
- A constitution amendment (R18 stays; ADR-003 does not edit constitution)
- A code change (no `.ts`, `.json`, `.sql` execution code)
- An edit to ADR-001 or ADR-002 (those are immutable ACCEPTED)
- A multi-amendment ADR (single decision class: schema design)

---

## 3. Decision Points — 5 to resolve in ADR-003

These are verbatim from `work-unit.yaml.decisions_to_resolve`.

### D1. Canonical schema format

Four candidates (executor evaluates and justifies one as default; ≥3 to killed):

- (a) **JSON Schema canonical + YAML examples for humans** — Codex's recommended default; works with CLI, Python, TS, CI, docs, editors; neutral, broad tooling
- (b) **Zod canonical + generated JSON Schema** — strong runtime TS, but binds AppMaker prematurely to TypeScript; **GUARD: WU-005 is no-code, scope blocks `**/*.ts`. If D1 picks Zod, ADR-003 must (a) DEFER schema-file authoring to follow-up implementation WU OR (b) drop to killed alternatives.**
- (c) **Custom YAML schema** — readable but no broad ecosystem; reinventing
- (d) **Hybrid ad hoc** — no canonical format; per-schema choice

Codex's suggested killed alternatives (executor may consolidate or extend):
- Custom YAML-only canonical
- TypeScript/Zod-only canonical for v1
- Schemas described in prose only (no machine-readable form)

### D2. Schema directory and naming convention

Recommended (executor confirms or adjusts): `.appmaker/schemas/<name>-v<n>.schema.<ext>` where `<n>` is incremental version. ADR-003 may pick alternative path (e.g. `schemas/` at project root) but must justify against the kernel-managed `.appmaker/` separation in ADR-001 §D3.

### D3. Schema versioning policy

How do v2+ supersede v1? Mandatory deprecation period? Co-existence (two versions live simultaneously)? Hard cutover (v2 replaces v1)?

ADR-003 picks one policy. Recommended starting position: incremental v1 → v2 with prior version archived to `.appmaker/_archive/schemas/` on supersedence (analogous to constitution amendment treatment).

### D4. Validation conformance requirements

Which artifacts MUST be validated against which schema? When is validation invoked (pre-execution, pre-VERIFIED, pre-PROMOTE)? Who runs the validator (kernel, manual, CI)?

**Critical interaction with `validator_tooling_preflight`:** local environment has jq, PyYAML, Ruby YAML, but no JSON Schema meta-validator (ajv, jsonschema). ADR-003 D4 must decide: (a) v1 validation = parser + structural only (defer meta-validation tooling to future implementation WU), OR (b) v1 validation requires meta-validator and the WU produces installation/setup directives, OR (c) v1 validation is ADR-003's policy but enforcement is conditional on tooling.

Codex's note: "ajv compile" mentioned in WU-005 risks is OK as example, but ADR-003 must record that ajv is unavailable locally and that validator implementation is deferred if needed.

### D5. Lessons-derived fields explicit mapping

ADR-003 §Decision-D5 must contain a TABLE (not prose) mapping each of the 6 wu-005-applicable lessons to one or more schema fields with named rationale.

Each field cited must appear in one of the three schema files. If any lesson is not mapped to at least one field, WU-005 is REJECTED.

This is the memory-stream test in concrete form.

---

## 4. Codex's JSON Schema recommendation (context, not mandate)

Codex's analysis: **JSON Schema canonical + YAML examples for humans** as default for v1.

Reasoning Codex provided:

- JSON Schema is neutral across runtime languages (works with Python, TypeScript, Go, CLI, CI, IDE plugins)
- Zod is excellent for runtime TS but **binds AppMaker prematurely to TypeScript implementation**, before ADR-001 §D10 (CLI-first, MCP later) plays out
- JSON Schema is widely supported by editors (VS Code, JetBrains) and CI tools without TS dependency
- Zod-equivalent can be generated/adapted later from JSON Schema

**Executor's task:** evaluate this recommendation against your assessment of project realities (current tooling, future kernel implementation language, schema evolution speed). Pick a default in D1, justify it, and place ≥3 alternatives in killed alternatives. Codex's recommendation is input, not verdict.

---

## 5. Required output structure

### ADR-003 (primary, per `adr-v1` conventions used in ADR-001/ADR-002)

12 sections:
1. **Status** — DRAFT initially; flips to ACCEPTED on promote
2. **Metadata** — date, authors, type (investigation), supersedes/superseded-by
3. **Context** — why schema format choice now, how it relates to ADR-001/ADR-002
4. **Sources Consulted** — Codex multiple rounds, lessons.jsonl, ADR-001/ADR-002, constitution v2
5. **Decision (numbered)** — D1 through D5 each with Why + How/Implications. D5 includes the lessons-mapping table.
6. **Killed Alternatives** — at least 3, each with reason
7. **Risks and Mitigations** — table
8. **Rollback Plan** — soft + hard
9. **Open Questions** — what ADR-003 deliberately defers (validator implementation, runner integration, schema migration tooling, schema reuse across projects)
10. **Acceptance Criteria** — self-check that ADR-003 itself meets verification
11. **Verification** — table mapping required sections to present/absent
12. **Revision History** — initial draft + future amendments

### Schema files (3 secondary, format determined by ADR-003 D1)

#### `interview-result-v1.schema.<ext>`

Must cover (per ADR-002 §schema-shape and §D3, §D6):

```yaml
problem: { statement, target_users[], current_pain }
scope: { goals[], non_goals[], constraints[] }
product: { primary_workflows[], success_criteria[], edge_cases[] }
technical: { preferred_stack[], integrations[], data_sensitivity, deployment_target }
risks: { ambiguous_areas[], assumptions[], questions_remaining[] }
readiness:
  status: enum(ready, needs_more_input, reject, ready_with_override)
  reason: string
  unresolved_ambiguities: [list of {id, description, decision_deferred_to, scope_affected[], suggested_resolution_work_unit}]
  override: {invoked_by, invoked_at, reason}        # required when status=ready_with_override

# brownfield variant (--with-docs):
existing_codebase:
  glossary_terms_resolved: []
  glossary_terms_introduced: []
  adr_candidates: [list of {id, title, reason}]
  contradictions_found: []
```

Constraints from ADR-002:
- `ready_with_override` REQUIRES non-empty `unresolved_ambiguities[]` AND populated `override` block
- Default decision when status missing or unknown is `reject` (fail-closed)

#### `work-unit-v1.schema.<ext>`

Must cover (fields actually used in WU-002 / WU-003 / WU-004 work-unit.yaml files):

Core fields:
- `id`, `title`, `type` (enum: investigation | implementation), `status` (full enum from WU-002 onwards)
- `created`, `created_by`, `authored_by`, `related_adr`, `related_work_units`
- `goal` (text)
- `scope`: `allowed_files_read[]`, `allowed_files_write[]`, `blocked_files_write[]`, `blocked_actions[]`, `allowed_actions[]`
- `output_target` or `output_targets[]` (multi-output for WU-003/WU-005 case)
- `acceptance_criteria[]`
- `verification`: `artifact_schema`, `required_sections[]`, `forbidden_patterns[]`, bounds, custom checks
- `review_required_from[]` (critic, human_primary, human_secondary)
- `review_scorecard_template`: open mapping with extensible fields
- `execution`: `mode` (single | voting | debate), `agent`, `context_pack`, `estimated_effort`
- `promote_gate`: `default_decision`, `on_missing_field`, `on_error`, `required_pass[]`, `break_glass`
- `risks[]`
- `rollback_plan` (text)
- `notes` (text)

**Lessons-derived fields (REQUIRED):**

- `lessons_applied[]` (per wu-004 memory_layer lesson) — list of {source: lessons.jsonl entry reference, influence: prose}
- `affects_core_safety_rules: bool` (amendment subtype only, per wu-004 amendment_process semantic-touching lesson)
- `semantic_relations: mapping<rule_id, rationale>` (amendment subtype only, per same lesson)
- `solo_execution_exception: object` (per WU-004 precedent; applicable when only one human operates)
- `validator_tooling_preflight: object` (per WU-005 self-introduction; for WUs producing schemas or other format-bound artifacts)
- `secondary_artifacts_policy: object` (per WU-005; for multi-output WUs)
- `amendment_target: object` (amendment subtype only; per WU-004 first amendment precedent)

#### `adr-v1.schema.<ext>`

Must cover (per ADR-001 / ADR-002 actual structure):

- `required_sections[]` (12 sections enumerated above)
- `forbidden_patterns[]` (TBD, TODO, "...") — per wu-004 review lesson, applies to markdown body
- `decisions_min_count` (e.g., 1 minimum but typically 3+ per ADR)
- `killed_alternatives_min_count` (≥3 per constitution R1)
- `risks_min_count` (≥1)
- `length_bounds`: { min: 200, max: 600 } (typical ADR range)
- `revision_history_required: true`
- `metadata_required: true` (date, authors, type, supersedes)
- `lessons_applied_optional: true` (when ADR is created by investigation WU, lessons traceability table strongly recommended)

---

## 6. Forbidden patterns (in ADR-003 prose; in schema description fields)

The amended constitution rule (R7-derived discipline) and WU-002 precedent require:

- No `TBD`
- No `TODO`
- No bare `...` (ellipsis as hand-waving; ellipsis inside concrete code-context placeholders is the only allowed exception, and only when paraphrasing is impossible)

This applies to:
- ADR-003 prose throughout
- Schema description fields (text values inside JSON Schema `description`, etc.)

If a forbidden pattern is needed in instructional context (e.g., listing what is forbidden), paraphrase to avoid the literal token.

---

## 7. Bounds

- **ADR-003:** 250–550 lines markdown
- **Schemas:** discreet but complete (typical 80–200 lines each, format-dependent); schema length is governed by content coverage, not arbitrary cap
- **Total run dir output (markdown + 3 schemas):** estimate 600–1100 lines combined

---

## 8. Self-check before declaring WU-005 ready

Before flipping work-unit.yaml `IN_PROGRESS` → `VERIFIED`:

- [ ] ADR-003 has all 12 required sections in declared order
- [ ] D1, D2, D3, D4, D5 each resolved with explicit decision and rationale
- [ ] At least 3 killed alternatives total (D1 alone likely contributes 3)
- [ ] D1 GUARD applied: if Zod or any code-backed format won, schema files were either (a) deferred with Open Questions entry OR (b) format dropped to killed
- [ ] Three schema files produced (or marked deferred per D1 GUARD)
- [ ] All produced schemas parse as their declared format (PyYAML, Ruby, jq, etc.)
- [ ] If JSON Schema chosen: each schema parses as JSON; meta-validation only if validator available locally; otherwise gap recorded in verification log
- [ ] All lessons-derived fields present in work-unit-v1 schema (lessons_applied, affects_core_safety_rules, semantic_relations, solo_execution_exception, validator_tooling_preflight, secondary_artifacts_policy, amendment_target)
- [ ] adr-v1 schema includes `forbidden_patterns` enforcement field
- [ ] interview-result-v1 schema covers ADR-002 §schema-shape including 4-state readiness enum
- [ ] Cross-schema consistency: shared concepts (status enum, type enum, etc.) aligned across schemas
- [ ] `validator_tooling_preflight` block recorded with available_tools enumerated
- [ ] ADR-003 §D5 contains a CONCRETE TABLE mapping each of 6 lessons to specific schema fields with rationale (not prose alone)
- [ ] ADR-003 explicitly cites Codex's JSON Schema recommendation (whether adopted or rejected, with reasoning)
- [ ] Forbidden patterns absent in ADR-003 and schema description fields
- [ ] No edits to ADR-001, ADR-002, constitution.md
- [ ] Open Questions enumerates deferred concerns (validator implementation, runner integration, schema migration, etc.)
- [ ] Length: ADR-003 ≤ 550 lines and ≥ 250 lines
- [ ] Both wu-005-applicable lessons stream entries cited in ADR-003 §D5 (all 6 mapped)
- [ ] Cross-section consistency: ADR-003 §Decision-D1 / §Risks / §Open Questions / Acceptance Criteria all coherent regarding format choice and validator availability

---

## 9. Out-of-scope reminders

The executor MUST NOT:

- Edit `decisions/ADR-001-process-kernel-architecture.md` (immutable)
- Edit `decisions/ADR-002-interview-phase.md` (immutable)
- Edit `constitution.md` (immutable in this WU; amendments require dedicated work_unit)
- Edit `.appmaker/work-units/wu-002/**`, `wu-003/**`, `wu-004/**` (closed, append-only audit)
- Create `.ts`, `.sql` files (per scope blocked_files_write)
- Run `git commit`, `git push`, `git clone`, `npm install`, `rm -rf` (per R14 and blocked_actions)
- Implement validators / runners / CI scripts (deferred to future implementation WUs)
- Add new Matt Pocock pattern mapping entries (this WU is schema design, not pattern adoption)
- Build constitution amendments (separate WU class)
- Declare schemas without `lessons_applied`, `affects_core_safety_rules`, `semantic_relations`, or `forbidden_patterns` enforcement fields (each is required per Appendix D lessons)

---

## 10. Lessons stream application (memory-stream test)

The full text of all wu-005-applicable lessons is in Appendix D. This section
names how each lesson concretely shapes WU-005's design and execution,
satisfying acceptance criterion #4.

### Lesson 2 (wu-003, category=review) → applied to WU-005

**Action from lesson:** "Pre-execution checklist must include explicit fact-check against external state (paths, commit hashes, schema references) and wording-consistency scan between document sections."

**Applied:**
- §8 self-check is a 19-item granular checklist with explicit fact-checks (line counts, parser pass, lesson coverage, cross-schema consistency)
- ADR-003 §D5 lessons-mapping table is itself an external-state fact-check (every claim about a schema field must trace to an actual field in one of the 3 schemas)
- Cross-schema consistency check is a dedicated verification step

### Lesson 3 (wu-003, category=adr_quality) → applied to WU-005

**Action from lesson:** "Add cross_decision_consistency field to review_scorecard_template. Reviewer explicitly diff-checks decisions against each other for structural compatibility."

**Applied:**
- WU-005 work-unit.yaml `review_scorecard_template` includes `cross_decision_consistency: pending` (within ADR-003 D1-D5) and `cross_artifact_consistency: pending` (ADR-003 ↔ 3 schemas)
- ADR-003 has 5 cross-related decisions (format, location, versioning, validation, lessons-fields); cross_decision_consistency check is mandatory
- §8 self-check explicitly addresses ADR-003 §Decision-D1 / §Risks / §Open Questions / Acceptance Criteria coherence (cross-section)

### Lesson 4 (wu-004, category=amendment_process) → applied to WU-005

**Action from lesson:** "Future constitution amendments must include a textual diff check proving unchanged rules remained unchanged."

**Applied:**
- WU-005 is not a constitution amendment, but the precedent informs schema design
- work-unit-v1 schema MUST include amendment subtype variant with `verification.rules_unchanged_check` field (per ADR-003 D5 mapping)
- Future amendment WUs will use this schema field to declare the diff verification

### Lesson 5 (wu-004, category=memory_layer) → applied to WU-005 (LOAD-BEARING)

**Action from lesson:** "Schemas should add a lessons_applied field or review checklist item for work_units consuming lessons."

**Applied:**
- DIRECTLY MANDATORY: work-unit-v1 schema MUST include `lessons_applied[]` field
- ADR-003 §D5 must explicitly design this field's shape
- Acceptance criterion #8 requires this field's presence

### Lesson 6 (wu-004, category=amendment_process semantic) → applied to WU-005 (LOAD-BEARING)

**Action from lesson:** "Schema for amendment work_units should include affects_core_safety_rules and semantic_relations fields."

**Applied:**
- DIRECTLY MANDATORY: work-unit-v1 schema (amendment subtype) MUST include `affects_core_safety_rules: bool` and `semantic_relations: mapping<rule_id, rationale>`
- ADR-003 §D5 designs these fields
- Acceptance criterion #8 requires their presence

### Lesson 7 (wu-004, category=review) → applied to WU-005 (LOAD-BEARING)

**Action from lesson:** "Schema verification should require forbidden-pattern checks for markdown governance artifacts."

**Applied:**
- DIRECTLY MANDATORY: adr-v1 schema MUST include `forbidden_patterns[]` enforcement field
- ADR-003 §D5 designs this field
- Acceptance criterion #10 requires this field's presence

### Indirect: Lesson 1 (wu-003, category=context_compiler)

**Action from lesson:** "Adopt v1.1 context-compiler with Aider-style ranking."

**Applied:** schemas v1 enable v1.1 context-compiler design (without machine-readable schema, the compiler cannot statically verify context-pack completeness). Indirect — design-informing only.

**Memory-stream test outcome (executor must verify in WU-005 output):** ADR-003 §D5 must contain a TABLE with 6 rows (one per direct lesson) explicitly mapping each lesson's `action` field to specific schema field(s) and naming the rationale. If any direct lesson is not mapped to at least one field, the WU is REJECTED. The indirect context_compiler lesson may appear in §Open Questions for future v1.1 work.

---

## APPENDIX A — Constitution v2 (R8 inclusion: critical excerpts + full-file reference)

> Source: `/Users/pawel/Projects/AppMaker/constitution.md` (AMENDED, 2026-05-09; 395 lines, 18 rules)

### Critical rules directly affecting WU-005:

**R1.** ADRs require ≥3 alternatives, killed options, risks with mitigations. *(ADR-003 must comply.)*

**R5.** Gates fail closed. Three layers: rule, config, hook. *(WU-005 promote_gate uses fail-closed enum for secondary_artifacts.status.)*

**R7.** Machine-readable artifacts must pass parser/lint validation before VERIFIED. *(WU-005 contract already passed PyYAML + Ruby Psych; the 3 schemas must each parse as their declared format.)*

**R8.** Every context-pack includes the constitution, the relevant recent ADRs, and the work_unit's acceptance criteria. *(This pack complies via Appendices A, B, C; lessons inclusion in Appendix D goes beyond R8 minimum per Codex directive.)*

**R12.** No silent fallbacks. *(ADR-003 must specify what happens when validator unavailable — explicit gap recording, not silent skip.)*

**R13.** Every work_unit reduces uncertainty or delivers verified change. *(WU-005 reduces uncertainty about schema format and produces 3 schemas as verified artifacts.)*

**R14.** Agents may not git push/commit/rm-rf/publish/deploy. *(blocked_actions enforces.)*

**R17.** Constitution stays under 25 rules. *(N/A here; WU-005 doesn't amend constitution.)*

**R18.** Every project begins with Interview Phase producing `.appmaker/interview-result.yaml` with readiness in {ready, ready_with_override}. *(This is the rule that justifies interview-result-v1 schema's existence and shape.)*

**Full text of all 18 rules:** load `/Users/pawel/Projects/AppMaker/constitution.md` before drafting ADR-003.

---

## APPENDIX B — ADR-001 + ADR-002 relevant decisions (R8 inclusion)

> Sources:
> - `/Users/pawel/Projects/AppMaker/decisions/ADR-001-process-kernel-architecture.md` (ACCEPTED)
> - `/Users/pawel/Projects/AppMaker/decisions/ADR-002-interview-phase.md` (ACCEPTED)

### From ADR-001:

**D2 — Process Kernel + work_unit primitive.** *(work-unit-v1 schema codifies the work_unit shape established by this decision.)*

**D2a — work_unit declares type: investigation | implementation.** *(work-unit-v1 schema MUST include `type` enum with these two values.)*

**D3 — 6-file project model.** Constitution / ADRs / config at root (human-authored); profile.yaml, state.sqlite, log streams in `.appmaker/`. *(Schemas join `.appmaker/schemas/` as kernel-managed artifacts; D2 of WU-005 confirms.)*

**D7 — Simple context-compiler v1, Aider-style v1.1.** *(WU-005 schemas enable v1.1 context-compiler — indirect lesson 1.)*

**D8 — Voting mode declared in schema, runner deferred.** *(work-unit-v1 schema MUST include `execution.mode` enum: single | voting | debate.)*

**D10 — CLI-first, MCP later.** *(ADR-003 D1 should not assume runtime TS — argues against Zod canonical for v1.)*

**D11 — Three-stream logging.** *(adr-v1 schema and work-unit-v1 schema may interact with these streams via promotion events; out of scope for schema definition itself.)*

**D13 — Gates fail closed.** *(WU-005 secondary_artifacts_policy enforces fail-closed for deferred path.)*

### From ADR-002:

**D2 — `.appmaker/interview-result.yaml` kernel-managed.** *(D2 of WU-005 schemas directory naming follows this pattern.)*

**D3 — 4-state readiness enum.** *(interview-result-v1 schema MUST encode this enum with fail-closed default.)*

**D6 — `ready_with_override` propagation.** *(interview-result-v1 schema MUST require non-empty `unresolved_ambiguities[]` and populated `override` block when status=ready_with_override.)*

**D7 — Greenfield vs brownfield.** *(interview-result-v1 schema MUST cover both: base structure + optional `existing_codebase` block for brownfield.)*

**Full text of both ADRs:** load before drafting ADR-003.

---

## APPENDIX C — WU-005 acceptance criteria (verbatim)

> Source: `/Users/pawel/Projects/AppMaker/.appmaker/work-units/wu-005/work-unit.yaml`

15 acceptance criteria from `work-unit.yaml.acceptance_criteria`:

1. ADR-003 resolves all 5 decisions D1–D5 with rationale and ≥3 alternatives each (or alternatives consolidated where reasonable, but never fewer than 3 killed alternatives total across the ADR).
2. ADR-003 has all 12 required adr-v1 sections (Status, Metadata, Context, Sources Consulted, Decision, Killed Alternatives, Risks, Rollback, Open Questions, Acceptance Criteria, Verification, Revision History).
3. ADR-003 length 250–550 lines (per WU-003 / ADR-002 precedent).
4. ADR-003 explicitly cites all 6 wu-005-applicable lessons by source / category / timestamp; for each, the ADR shows which schema field(s) operationalize the lesson.
5. Three schema files produced (interview-result-v1, work-unit-v1, adr-v1) in the format chosen by ADR-003 D1. EXCEPTION per D1 GUARD: if ADR-003 D1 selected a code-backed format requiring a scope-blocked extension (e.g. Zod requiring .ts), ADR-003 explicitly defers schema-file authoring to a follow-up implementation work_unit and records the deferral in §Open Questions; in that case WU-005's schema-file acceptance criteria (#5–#11 below) are marked 'deferred' rather than 'failed' in the verification record, and only ADR-003 (with full §D1 rationale, §Open Questions enumerating the deferral, and §Decision-D5 lessons-traceability table) is produced and PROMOTED by WU-005.
6. All three schema files parse as their declared format. If JSON Schema, files are valid JSON. Meta-schema validation (e.g. Draft 2020-12) is required only if a validator is available locally per validator_tooling_preflight; otherwise WU-005 records the validator gap explicitly and performs parser + structural validation only, with validator implementation deferred to a future implementation work_unit. EXCEPTION per D1 GUARD: if schema files were deferred, this criterion is marked 'deferred' rather than 'failed'.
7. interview-result-v1 schema covers the conceptual shape from ADR-002 §schema-shape, including the four-state readiness enum and `ready_with_override` structural requirements.
8. work-unit-v1 schema includes (at minimum) fields: id, title, type, status, scope, output_target, acceptance_criteria, verification, review_required_from, review_scorecard_template, execution, promote_gate, risks, rollback_plan, lessons_applied, notes.
9. work-unit-v1 schema MUST include `lessons_applied: []` (per wu-004 memory_layer lesson) and amendment subtype variant including `affects_core_safety_rules: bool` and `semantic_relations: mapping<rule_id, rationale>` fields per wu-004 amendment_process semantic-touching lesson.
10. adr-v1 schema includes (at minimum) `required_sections: []`, `forbidden_patterns: []`, `decisions_min_count`, `killed_alternatives_min_count`, length bounds. forbidden_patterns enforcement applies to the markdown body (per wu-004 review lesson).
11. Cross-schema consistency: shared concepts (e.g. status enum used in work-unit-v1 must match the values used historically; ADR section names in adr-v1 must match what ADR-001/002 actually use) are aligned. cross_decision_consistency check is a self-check item.
12. Memory-stream test: ADR-003 §Decision-D5 contains a table mapping each of the 6 lessons to one or more schema fields with named rationale. If any lesson is not mapped to at least one field, the WU is REJECTED.
13. Forbidden patterns absent in ADR-003 prose: zero TBD, zero TODO, zero bare ellipsis.
14. No edits to ADR-001, ADR-002, constitution.md, or any prior work_unit run dir.
15. Open Questions section enumerates anything ADR-003 deliberately defers (e.g. validator implementation, runner integration, schema migration tooling).

---

## APPENDIX D — Lessons applicable to wu-005 (verbatim from `.appmaker/lessons.jsonl`)

> Source: `/Users/pawel/Projects/AppMaker/.appmaker/lessons.jsonl`
> Direct lessons (applies_to includes wu-005-schema): 6
> Indirect lessons (mentioned for design-informing): 1

### Direct Lesson 1 — Lesson 2 (wu-003, category=review)

```json
{
  "timestamp": "2026-05-09T15:55:00Z",
  "source_work_unit": "wu-003",
  "category": "review",
  "lesson": "Codex external review caught 3 distinct fix rounds that local self-check missed: wrong Matt Pocock file paths (skill subcategory omitted), wording inconsistency between context-pack intro and Appendix A, and cross-decision contradictions (D1 skip output incompatible with D3 ready_with_override structural requirements).",
  "action": "Pre-execution checklist must include explicit fact-check against external state (paths, commit hashes, schema references) and wording-consistency scan between document sections (intro / body / appendices).",
  "applies_to": ["all-investigation-work-units", "wu-004", "wu-005-schema"]
}
```

### Direct Lesson 2 — Lesson 3 (wu-003, category=adr_quality)

```json
{
  "timestamp": "2026-05-09T15:55:00Z",
  "source_work_unit": "wu-003",
  "category": "adr_quality",
  "lesson": "Multi-decision ADRs may contain hidden cross-decision contradictions invisible to per-decision self-check (concrete example: WU-003 D1 specified --skip producing minimal ready_with_override; D3 required ready_with_override to have non-empty unresolved_ambiguities[] and populated override block; both decisions individually well-formed; contradiction visible only when read together).",
  "action": "Add cross_decision_consistency field to review_scorecard_template. Reviewer explicitly diff-checks decisions against each other for structural compatibility, particularly when one decision constrains structure (D3) and another invokes it (D1 --skip output).",
  "applies_to": ["wu-004", "wu-005-schema", "future-multi-decision-adrs"]
}
```

### Direct Lesson 3 — Lesson 4 (wu-004, category=amendment_process — diff verification)

```json
{
  "timestamp": "2026-05-09T16:50:00Z",
  "source_work_unit": "wu-004",
  "category": "amendment_process",
  "lesson": "First constitution amendment succeeded without changing R1-R17; amendment work_units can safely modify governance when write scope is narrow and diff verification is mandatory.",
  "action": "Future constitution amendments must include a textual diff check proving unchanged rules remained unchanged.",
  "applies_to": ["future-constitution-amendments", "wu-005-schema"]
}
```

### Direct Lesson 4 — Lesson 5 (wu-004, category=memory_layer) — LOAD-BEARING

```json
{
  "timestamp": "2026-05-09T16:50:00Z",
  "source_work_unit": "wu-004",
  "category": "memory_layer",
  "lesson": "WU-004 showed lessons.jsonl is useful only when context-pack and execution output prove specific influence, not citation.",
  "action": "Schemas should add a lessons_applied field or review checklist item for work_units consuming lessons.",
  "applies_to": ["wu-005-schema", "future-investigation-work-units"]
}
```

### Direct Lesson 5 — Lesson 6 (wu-004, category=amendment_process — semantic touching) — LOAD-BEARING

```json
{
  "timestamp": "2026-05-09T16:50:00Z",
  "source_work_unit": "wu-004",
  "category": "amendment_process",
  "lesson": "Semantic touching of core rules should count as touching for amendment review requirements, even when existing rule text is unchanged.",
  "action": "Schema for amendment work_units should include affects_core_safety_rules and semantic_relations fields.",
  "applies_to": ["wu-005-schema", "future-constitution-amendments"]
}
```

### Direct Lesson 6 — Lesson 7 (wu-004, category=review) — LOAD-BEARING

```json
{
  "timestamp": "2026-05-09T16:50:00Z",
  "source_work_unit": "wu-004",
  "category": "review",
  "lesson": "Parser/grep-style checks caught a forbidden ellipsis before VERIFIED; simple textual checks prevent governance artifacts from leaking placeholders.",
  "action": "Schema verification should require forbidden-pattern checks for markdown governance artifacts, not only YAML/JSON parser validation.",
  "applies_to": ["wu-005-schema", "future-investigation-work-units"]
}
```

### Indirect — Lesson 1 (wu-003, category=context_compiler)

```json
{
  "timestamp": "2026-05-09T15:55:00Z",
  "source_work_unit": "wu-003",
  "category": "context_compiler",
  "lesson": "Manual R8 context-pack inclusion produces packs roughly 2× larger than pre-R8 (515 vs 237 lines for WU-003 vs WU-002). Aider-style PageRank/tree-sitter compression planned in ADR-001 §D7 is justified by data, not speculation.",
  "action": "Adopt v1.1 context-compiler with Aider-style ranking. Confirm projection with usage data after first 5+ work_units.",
  "applies_to": ["v1.1-context-compiler", "future-investigation-work-units"]
}
```

Indirect status: not in `wu-005-schema` applies_to but informs the design (schemas v1 enable v1.1 context-compiler; this WU's pack length itself is a data point feeding the v1.1 case).

How direct lessons are applied is documented in §10 above. Application of indirect lesson is design-informing only and may appear in ADR-003 §Open Questions.

---

**End of context pack.** Total ADR-003 + 3 schemas authoring effort estimated 3–4 hours. Output draft path: `.appmaker/work-units/wu-005/runs/<timestamp>/output.md` (ADR-003) and `.../<schema-name>.schema.<ext>` (per ADR-003 D1). On promote: ADR-003 to `decisions/`, schemas to `.appmaker/schemas/` (per D2 directory decision; default `.appmaker/schemas/` per work-unit.yaml output_target).
