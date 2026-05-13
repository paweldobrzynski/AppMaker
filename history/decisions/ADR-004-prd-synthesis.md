# ADR-004: PRD Synthesis (to-prd from Matt Pocock skills)

## Status

**ACCEPTED** — promoted from WU-006 to `decisions/` on 2026-05-10. The original draft remains immutable at `.appmaker/work-units/wu-006/runs/2026-05-09T23-44-24Z/output.md` for audit. One mapping entry concurrently appended to `docs/reference/matt-pocock-pattern-mapping.md` (3rd row; existing 2 entries unchanged).

Lifecycle: `DRAFT` (in run dir, immutable) → **`ACCEPTED`** (current — this file at `decisions/ADR-004-prd-synthesis.md`) → `AMENDED` (if modified by future amendment work_unit, per Amendment Process in constitution).

## Metadata

- **Date:** 2026-05-10
- **Authors:** pawedo@gmail.com (decision-maker), Claude Opus 4.7 (synthesis), Codex (critic, multiple rounds)
- **Type:** investigation work_unit (multi-output: ADR + 1 mapping doc append entry)
- **Supersedes:** none
- **Superseded by:** none
- **Related:** ADR-001 (process kernel), ADR-002 (interview phase), ADR-003 (schema format + v1 schemas), constitution v2 (amended with R18), WU-006 contract

## Context

ADR-001 established work_unit primitive. ADR-002 added Interview Phase producing `interview-result.yaml` (the structured uncertainty-reduction output). ADR-003 promoted v1 schemas. Constitution v2 R18 enforces Interview as the first lifecycle gate.

Two questions remain unresolved at the lifecycle boundary between Interview and Decomposition:

1. **What is the project actually building?** `interview-result.yaml` captures problem/scope/product/technical/risks/readiness as structured input — it does not synthesize this into product-level user-facing reference. Without that synthesis, downstream work_units (decomposition, implementation) re-derive intent each time, drifting between WUs.

2. **Where does Understanding live?** WU-005 lessons (especially `human_understanding`) surfaced that AppMaker must explicitly mark which assumptions require human judgment vs which tasks are agent-executable. Currently no artifact carries that delineation.

ADR-004 introduces **PRD Synthesis** as the lifecycle stage that answers both. PRD bridges Interview (input) and Decomposition (output stage, ADR-005 future). PRD is the product-level "what-to-build" reference document, mandatorily including a 7-subsection **Understanding** block (per WU-005 lesson human_understanding) and verifiable success criteria (per WU-005 lesson verifiability_bias).

The pattern is inspired by Matt Pocock's `/to-prd` skill. AppMaker adapts it as inspiration source, NOT runtime dependency (per ADR-002 §D5 attribution policy + ADR-001 §D12 adapter selection + WU-005 lesson harness_engineering).

### Scope

ADR-004 is **narrow per Codex/user directive**. It covers ONLY PRD Synthesis. It does NOT cover:
- Decomposition / `to-issues` (ADR-005, future)
- Safety hooks / `git-guardrails` (ADR-006, future)
- Implementation runner / `tdd` (ADR-007, future)
- Bug workflow / `diagnose` (ADR-008, future)
- Architecture review / `improve-codebase-architecture` (ADR-009, future)
- Design Exploration Stage / Open Design integration (future ADR-NNN candidate; NOT adopted in WU-006)
- Validator implementation (ADR-003 OQ-1 deferred)
- Constitution amendment (no R18 modification)
- Schema modification (work-unit-v1, interview-result-v1, adr-v1 immutable)

## Sources Consulted

| Source | Contribution |
|---|---|
| ADR-001 (process kernel) | work_unit primitive (D2), CLI-first / no-MCP-yet (D10), gates fail closed (D13) |
| ADR-002 (interview phase) | `interview-result.yaml` shape; 4-state readiness enum (D3); `ready_with_override` propagation (D6); Matt Pocock attribution policy (D5); greenfield vs brownfield variants (D7) |
| ADR-003 (schema format + v1 schemas) | adr-v1 schema (12 sections + forbidden_patterns); work-unit-v1 schema; lessons-mapping table convention (D5) |
| constitution v2 | R1 (ADR shape), R5 (gates fail closed), R7 (parser validation), R8 (context-pack inclusion), R12 (no silent fallbacks), R13 (uncertainty / change), R18 (Interview required) |
| Matt Pocock to-prd skill (engineering/to-prd/SKILL.md) | PRD pattern: synthesize-don't-interview, deep modules, PRD template (Problem Statement / Solution / User Stories / Implementation Decisions / Testing Decisions / Out of Scope / Further Notes) |
| WU-005 lessons (8 direct + 4 broad from wu-003/wu-004 = 12 applicable to wu-006) | Schema design discipline, validator gap honesty, actual usage cross-ref, ADR mapping cross-check, harness investment, **human_understanding (load-bearing for D2 Understanding section)**, context_pack_as_program, **verifiability_bias (load-bearing for D2 verifiable success criteria)** |
| WU-003 lessons (review, adr_quality) | Pre-execution external-state fact-check; cross_decision_consistency for multi-decision ADRs |
| WU-004 lessons (memory_layer, review) | lessons_applied schema field; forbidden_patterns enforcement |
| Codex critique rounds | Narrow scope discipline; lessons must inform shape not inflate scope; manual schema conformance for WU-006; Design Exploration Stage as future ADR placeholder only |
| Local environment audit | jq, PyYAML, Ruby Psych available; ajv NOT installed (per ADR-003 D4 deferral) |

## Decision

Seven numbered, individually addressable decisions D1–D7.

### D1. PRD definition: product-level "what-to-build" reference distinct from ADR (architectural how) and implementation plan (work_unit decomposition).

**Decision:** A PRD in AppMaker is a markdown document that synthesizes `interview-result.yaml` into a product-level reference, readable by humans and consumable by downstream work_units. PRD answers:
- What is the product, from the user/buyer/operator perspective?
- What user stories cover the scope?
- What success looks like (verifiable per D2 Understanding subsection)?
- What is explicitly out of scope?
- What understanding (users/invariants/identity/trust/non-delegable/criteria/failure-modes) must humans own?

PRD does NOT answer:
- HOW the system is built architecturally (that is ADRs — separate concern, structural decisions with alternatives + killed)
- WHO does WHAT WHEN (that is implementation plan / work_unit decomposition — ADR-005, future)
- HOW code is written (that is implementation work_units)

**Why:** Without explicit PRD, downstream work_units must re-derive product intent from `interview-result.yaml` each time, with drift. ADRs cannot serve this role: ADRs are decision-class documents (decisions + alternatives + killed + risks), not product-reference. Implementation plans are sequencing documents, not reference.

**How / Implications:**
- PRD is a single canonical document per project (D2 picks `.appmaker/prd.md`).
- PRD is human-authored under agent assistance (similar to ADRs); it is not auto-generated without human review.
- PRD text is product-perspective, not technical-perspective (technical depth lives in ADRs).
- PRD references ADRs by id (ADR-NNN) but does not duplicate their content.

### D2. PRD location: **`.appmaker/prd.md`** (single project-level, kernel-managed). MANDATORY Understanding section with 7 named subsections.

**Decision:** PRD lives at `.appmaker/prd.md` for v1: single project-level document, kernel-managed (alongside `interview-result.yaml`, `profile.yaml`, etc. per ADR-001 §D3). Per-feature PRDs are deferred (see Open Question OQ-1).

PRD shape MUST include an **Understanding** section as the second top-level section (after Status), with these 7 named subsections in order:

1. **users / buyers / operators** — distinguish who uses, who pays, who runs
2. **domain invariants** — facts that MUST hold; cross-cutting business rules
3. **identity model** — how users, accounts, organizations relate (prevents identity-confusion anti-patterns like Stripe-email = Google-email)
4. **trust boundaries** — what the system trusts vs what it verifies
5. **non-delegable human judgments** — decisions humans must own (taste, ethics, legal, strategic)
6. **verifiable success criteria** — each criterion auto-check OR human-review-with-explicit-criteria; unverifiable requirements turned into verifiable proxies (per WU-005 lesson verifiability_bias)
7. **failure modes / unacceptable outcomes** — what the system MUST NOT produce; catastrophic states

**Why:** Per WU-005 lesson human_understanding, AppMaker must explicitly mark which assumptions require human judgment vs which tasks are agent-executable. The 7-subsection Understanding block operationalizes this as a structural artifact. Per WU-005 lesson verifiability_bias, success criteria must be verifiable; the dedicated subsection enforces this at PRD shape level. Single project-level location (a) over per-feature (c) avoids premature directory proliferation; over interview-result.yaml embedding (d) avoids overloading interview's schema (separation of concerns); over `.appmaker/product/prd.md` subdirectory (b) avoids unnecessary nesting for v1 (a flat path is simpler and consistent with `interview-result.yaml`).

**How / Implications:**
- AppMaker kernel knows to read `.appmaker/prd.md` as canonical PRD.
- PRD shape (full template including Understanding subsections) is described conceptually here; formal `prd-v1.schema.json` is deferred to a future schemas-extension WU (not WU-006).
- Beyond Understanding, PRD also includes (per Matt Pocock to-prd template adaptation): Problem Statement, Solution, User Stories, Implementation Decisions, Testing Decisions, Out of Scope, Further Notes.
- For brownfield projects (per ADR-002 D7), PRD references existing codebase glossary from `interview-result.yaml.existing_codebase.glossary_terms_*` — terminology must align.

### D3. PRD emerges after Interview ready (manual command `appmaker prd`); fail-closed if Interview not ready.

**Decision:** PRD is created by an explicit command `appmaker prd`. Triggered after `interview-result.yaml` has `readiness.status` in `{ready, ready_with_override}`. If Interview not ready (status missing, `needs_more_input`, `reject`): kernel rejects `appmaker prd` with explicit error — fail-closed per R5 + R12.

**Why:** Per ADR-001 §D10 (CLI-first, explicit commands over hidden state), PRD trigger is a separate user-invoked step, not auto-cascaded from Interview promote. This gives humans a checkpoint to confirm readiness ("Interview is ready; do I want to commit to PRD synthesis now, or revise Interview first?"). Per R5 + R12, the gate fails closed (no silent generation when Interview is invalid).

**How / Implications:**
- `appmaker prd` reads `.appmaker/interview-result.yaml`; if status invalid, exits with explicit error message naming the missing precondition.
- On success, the command (in v1) prepares an agent context (Interview content + Matt Pocock to-prd-inspired prompt + Understanding subsection requirements + verifiability discipline) and writes a draft PRD to `.appmaker/work-units/wu-NNN/runs/<timestamp>/prd-draft.md`. The draft is then reviewed and promoted to `.appmaker/prd.md` via standard work_unit lifecycle.
- PRD authoring is itself an investigation work_unit per ADR-001 §D2a: input = interview-result.yaml; output = prd.md (artifact-validated against shape from D2).

### D4. PRD is a **required gate** before decomposition (to-issues / ADR-005 future).

**Decision:** Decomposition work_units (which produce vertical slices via `to-issues`-style decomposition; ADR-005 future) cannot be ACCEPTED or PROMOTED until `.appmaker/prd.md` exists with status in `{ACCEPTED, ACCEPTED_WITH_INHERITED_OVERRIDE}` (the latter per D6 — when interview was `ready_with_override`, the inherited PRD status is also valid for the gate, with mandatory ambiguity propagation). In v1, AppMaker process (human-enforced at WU review time per "How / Implications" below) rejects acceptance/promotion of decomposition-class WUs if PRD missing or status not in the accepted set. Mechanical kernel-level rejection at WU creation time is deferred to ADR-005 (which will introduce a formal `work_unit_subtype: decomposition` to work-unit-v1 schema and let the kernel gate on it). Bypass: human-only break-glass (similar to R6 pattern) producing `ACCEPTED_WITH_PRD_EXCEPTION` state recorded in `events.jsonl`.

**Casing convention:** PRD statuses use UPPERCASE consistent with work-unit-v1 status enum (per WU-002 schema precedent: `PROPOSED`, `ACCEPTED`, `IN_PROGRESS`, `VERIFIED`, `PROMOTED`, `PROMOTED_WITH_EXCEPTION`, `REJECTED`). PRD-specific extensions: `ACCEPTED_WITH_INHERITED_OVERRIDE` (D6 — inherited from interview), `ACCEPTED_WITH_PRD_EXCEPTION` (D4 break-glass).

**Why:** Without PRD reference, decomposition produces drifting features (each decomposition WU re-derives intent from interview-result.yaml, with cumulative semantic drift). Per WU-005 lesson harness_engineering: enforcing structural ordering of the lifecycle is a harness investment that catches errors mechanically. Per R12 (no silent fallbacks): allowing decomposition without PRD would silently let drift accumulate. Accepting `ACCEPTED_WITH_INHERITED_OVERRIDE` at the gate (vs requiring strict `ACCEPTED`) prevents D4↔D6 contradiction: a properly-promoted PRD that inherited override from interview is still a valid PRD; the gate enforces existence + readiness, not ambiguity-freeness.

**How / Implications:**
- Gate is human-enforced at WU review time as the v1 mechanism (a reviewer confirms the WU is decomposition-class and checks PRD existence + status). Mechanical gate is deferred to ADR-005 (decomposition design) which will introduce `work_unit_subtype: decomposition` (or equivalent) to work-unit-v1 schema; once that field exists, the kernel can mechanically gate. Until then, the convention is human-review-enforced and recorded in WU promote scorecards.
- Break-glass `appmaker decompose --break-glass --reason="<text>"` records to `events.jsonl` with `severity: critical`; resulting state is `ACCEPTED_WITH_PRD_EXCEPTION` (PRD-level) propagating to `DECOMPOSED_WITH_PRD_EXCEPTION` for downstream decomposition WU status.
- This decision creates a downstream dependency on ADR-005 (decomposition design) but does not specify decomposition mechanics — only the gate before it. Mechanical gate enforcement is part of ADR-005 work, not ADR-004.

### D5. PRD consumes `interview-result.yaml` field-by-field; every interview field either explicitly addressed in PRD or explicitly noted as out-of-PRD-scope (no silent omission).

**Decision:** PRD synthesis follows a consumption rule: every populated field in `interview-result.yaml` (per `interview-result-v1.schema.json`) maps to a PRD section/subsection or is explicitly listed in PRD's "Out of Scope" / "Further Notes" sections with reason. Silent omission is forbidden per R12.

**Field mapping (template):**

| `interview-result.yaml` field | PRD section / subsection |
|---|---|
| `problem.statement` | PRD Problem Statement |
| `problem.target_users` | PRD Understanding § users / buyers / operators |
| `problem.current_pain` | PRD Problem Statement (motivation) |
| `scope.goals` | PRD Solution + User Stories |
| `scope.non_goals` | PRD Out of Scope |
| `scope.constraints` | PRD Implementation Decisions (constraints subsection) |
| `product.primary_workflows` | PRD User Stories |
| `product.success_criteria` | PRD Understanding § verifiable success criteria (with verifiability_bias treatment) |
| `product.edge_cases` | PRD Understanding § failure modes / unacceptable outcomes |
| `technical.preferred_stack` | PRD Implementation Decisions |
| `technical.integrations` | PRD Implementation Decisions |
| `technical.data_sensitivity` | PRD Understanding § trust boundaries |
| `technical.deployment_target` | PRD Implementation Decisions |
| `risks.ambiguous_areas` | PRD Understanding § failure modes + Further Notes |
| `risks.assumptions` | PRD Further Notes (with explicit human_understanding marker if non-delegable) |
| `risks.questions_remaining` | PRD Open Questions (PRD-level OQ section, distinct from ADR Open Questions) |
| `readiness.status` | PRD Status reflects interview readiness state (see D6 for `ready_with_override` propagation; D4 for accepted statuses at downstream gate) |
| `readiness.reason` | PRD Status metadata (rationale annotation accompanying the status; if `ready_with_override`, the reason explains why human accepted to proceed despite ambiguities) |
| `readiness.unresolved_ambiguities` | PRD "Unresolved Ambiguities (from Interview)" dedicated section (per D6); each ambiguity preserves full descriptor (id, description, decision_deferred_to, scope_affected, suggested_resolution_work_unit) |
| `readiness.override.invoked_by` | PRD Status metadata (audit trail for `ACCEPTED_WITH_INHERITED_OVERRIDE` PRD: which human invoked the underlying interview override) |
| `readiness.override.invoked_at` | PRD Status metadata (audit trail timestamp) |
| `readiness.override.reason` | PRD Status metadata + PRD Further Notes (the human's reason for accepting interview override propagates to PRD reader as context) |
| `existing_codebase.*` (brownfield) | PRD Implementation Decisions + Understanding § domain invariants (glossary terms become PRD vocabulary) |

**Why:** Without explicit consumption mapping, PRD authors may accidentally omit interview content (e.g., a `risks.ambiguous_areas` entry might never reach PRD reader). Per WU-005 lesson actual_usage: the schema (interview-result-v1) describes the input; the consumption rule must map every schema field. Per R12: silent omission is forbidden.

**How / Implications:**
- PRD prompt (when authored as skill in future WU) encodes this mapping table.
- PRD self-check (during PRD work_unit verification) iterates through the mapping table and confirms each interview field is either addressed or explicitly omitted.
- "Explicitly omitted" means: a sentence in PRD's Further Notes saying (for example) "Interview field `risks.assumptions[3]` not addressed in this PRD because that risk falls under post-launch operational concerns, deferred to future operational ADR." Every omission must carry a concrete reason; a placeholder reason fails the consumption rule.

### D6. PRD inherits `unresolved_ambiguities[]` from `ready_with_override` interview; surfaces in dedicated PRD section; PRD status `ACCEPTED_WITH_INHERITED_OVERRIDE`.

**Decision:** When `interview-result.yaml.readiness.status` is `ready_with_override`, PRD inherits the `unresolved_ambiguities[]` list and surfaces it in a dedicated PRD section "Unresolved Ambiguities (from Interview)" placed between Implementation Decisions and Testing Decisions. Each ambiguity preserves its full descriptor: `id`, `description`, `decision_deferred_to`, `scope_affected`, `suggested_resolution_work_unit`. PRD's own status reflects the inheritance: when interview was `ready_with_override`, PRD on promote becomes `ACCEPTED_WITH_INHERITED_OVERRIDE` (UPPERCASE per D4 casing convention; analog to work-unit `PROMOTED_WITH_EXCEPTION`).

Downstream decomposition work_units (ADR-005 future) read PRD status; if `ACCEPTED_WITH_INHERITED_OVERRIDE`, decomposition WUs MUST surface unresolved_ambiguities in their context-packs (per ADR-002 §D6 propagation chain extended through PRD). Per D4, `ACCEPTED_WITH_INHERITED_OVERRIDE` is a valid PRD status at the decomposition gate (the gate enforces existence + readiness, not ambiguity-freeness).

**Why:** Per ADR-002 §D6, `ready_with_override` propagates ambiguities through downstream context-packs. PRD is one such downstream artifact; without explicit propagation rule, PRD would silently resolve (or hide) interview ambiguities, breaking the chain. Per R12 (no silent fallbacks): the inherited override must be explicit at PRD level. Resolving the D4↔D6 contradiction requires the gate to accept `ACCEPTED_WITH_INHERITED_OVERRIDE` alongside plain `ACCEPTED` (see D4).

**How / Implications:**
- PRD prompt template includes a conditional block: if interview readiness is `ready_with_override`, render the "Unresolved Ambiguities (from Interview)" section; otherwise skip it.
- PRD lifecycle states (UPPERCASE per D4 convention): `DRAFT` → `ACCEPTED` (when interview was `ready`) OR `ACCEPTED_WITH_INHERITED_OVERRIDE` (when interview was `ready_with_override`). Promote gate enforces correct status based on interview state.
- Future decomposition WUs (ADR-005) inherit the chain: unresolved_ambiguities propagate from interview → PRD → decomposition WU context-packs → individual implementation work_units (filtered by `scope_affected` per ADR-002 §D6).
- Casing note: interview's `readiness.status` enum uses lowercase values (`ready`, `needs_more_input`, `reject`, `ready_with_override`) per ADR-002 §D3 + interview-result-v1.schema.json; PRD status (this ADR's invention) uses UPPERCASE per work-unit-v1 status enum precedent. Different artifacts, different conventions; cross-referencing prose names both casings explicitly to avoid confusion.

### D7. Matt Pocock attribution policy + 12-lessons mapping table (memory-stream test).

**Decision:**

**(a) Attribution per ADR-002 §D5 model:**
- Future PRD prompt (when authored as a skill in a future WU) MUST include inline header naming Matt Pocock, MIT license, repo URL, exact SKILL.md path (`skills/engineering/to-prd/SKILL.md`).
- `docs/reference/matt-pocock-pattern-mapping.md` gains one new entry (this WU appends it as secondary output).
- Pinned commit hash: `b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8` (2026-04-30; same as ADR-002 D5 + existing mapping doc entries).

**(b) 12-lessons mapping table (memory-stream test):**

Each of the 12 wu-006-applicable lessons maps to a concrete element in WU-006 / ADR-004. Per WU-005 lesson adr_quality, the table is concrete (not prose) and cross-checked against the actual artifact.

| # | Lesson source / category | Concrete element in WU-006 / ADR-004 |
|---|---|---|
| L1 | wu-005 / schema_design | `secondary_artifacts_policy` declared in WU-006 verification block; mapping append covered explicitly |
| L2 | wu-005 / validator_gap | `validator_tooling_preflight` in WU-006 contract; ADR-004 §D2 explicit that formal `prd-v1.schema.json` deferred (no meta-validator pretense) |
| L3 | wu-005 / actual_usage | ADR-004 §D2 explicit: no historical PRD artifacts to mirror (greenfield); proposed shape revisited in v2 (OQ-1) |
| L4 | wu-005 / adr_quality | This §D7 table cross-checked against actual `matt-pocock-pattern-mapping.md` entry being appended (mapping doc fields must match this table's expectations) |
| L5 | wu-005 / harness_engineering | §D4 (PRD-required gate before decomposition) is harness investment — enforces structural lifecycle ordering, not a model-trick |
| L6 | wu-005 / human_understanding | **§D2 PRD shape MANDATES Understanding section with 7 named subsections** (load-bearing). Stripe-email = Google-email anti-pattern explicitly prevented |
| L7 | wu-005 / context_pack_as_program | §Open Questions OQ-5 notes v1.1 context-compiler design informed by WU-006 context-pack itself (583 lines, structured as Software 3.0 program); future ADR-NNN Context-Pack Schema deferred |
| L8 | wu-005 / verifiability_bias | **§D2 Understanding subsection 6 (verifiable success criteria) MANDATES verifiability** — auto-check OR human-review-with-explicit-criteria; unverifiable → verifiable proxies |
| L9 | wu-003 / review | This ADR's §Acceptance Criteria + §Verification table = pre-promote external-state fact-check checklist; wording-consistency cross-checked between §D1 ↔ §D3 ↔ §D7 |
| L10 | wu-003 / adr_quality | `cross_decision_consistency` mandatory for ADR-004 D1-D7 (7 sub-decisions = potential cross-decision contradictions); review_scorecard tracks this |
| L11 | wu-004 / memory_layer | `lessons_applied` field populated in WU-006 work-unit.yaml with 12 entries; this §D7 table demonstrates lessons.jsonl actually informs design |
| L12 | wu-004 / review | adr-v1.schema.json `forbidden_patterns: required` field enforced; ADR-004 prose self-check confirms all three forbidden placeholder/deferral markers absent (per `work-unit.yaml.verification.forbidden_patterns` for WU-006) |

**Why:** Per Codex's directive across multiple rounds, lessons must demonstrably influence design (memory-stream test), not be name-dropped. Table format (per WU-005 lesson adr_quality + ADR-003 D5 precedent) is mandatory because prose mappings drift; tables can be cross-checked field-by-field.

**How / Implications:** Each row above must trace to a specific element in WU-006 (work-unit.yaml field, ADR-004 section, mapping doc entry, or self-check item). If any lesson is not traceable to at least one element, WU-006 is REJECTED per acceptance criterion #14.

## Killed Alternatives

### KA-1. Per-feature PRDs (`.appmaker/prds/<feature-id>.md`) for v1

**Considered because:** Different features may have different product narratives; per-feature PRD allows independent evolution.

**Rejected because:**
- Premature for v1 (no real project has yet exercised even single PRD).
- Creates directory + naming convention overhead before benefit is proven.
- Per ADR-001 §D3, kernel-managed artifacts are flat under `.appmaker/`; subdirectories should be justified by usage data.
- Future expansion path retained as Open Question OQ-1.

### KA-2. PRD embedded as expanded section in `interview-result.yaml`

**Considered because:** Eliminates a separate file; PRD content lives next to its inputs.

**Rejected because:**
- Overloads `interview-result.yaml` schema (interview-result-v1.schema.json) with product-narrative content that is structurally different (free-form prose vs structured fields).
- Couples interview revision lifecycle to PRD revision lifecycle: changing PRD requires re-promoting interview, which is wrong abstraction.
- Loses readability — interview is a schema-validated data file; PRD is a human-readable narrative document.
- Violates separation of concerns established in ADR-001 §D3 (interview is input, PRD is product reference).

### KA-3. PRD optional (no required gate before decomposition)

**Considered because:** Small features with simple interview may not need full PRD; gate adds friction.

**Rejected because:**
- Optional → de facto unused (per ADR-002 KA-1 logic for Interview): if PRD is optional, projects skip it under time pressure, drift accumulates silently.
- Per R12 (no silent fallbacks): allowing decomposition without PRD would silently let drift accumulate without a gate to catch it.
- Per WU-005 lesson harness_engineering: harness investment in structural lifecycle ordering catches errors mechanically that human review may miss.
- Required-with-explicit-break-glass (D4) gives users a documented escape for trivial cases; bypass is auditable. Open Question OQ-4 captures future amendment for trivial-work skip.

### KA-4. PRD without Understanding section (Matt's plain to-prd template)

**Considered because:** Matt Pocock's to-prd template is proven and concise (Problem Statement, Solution, User Stories, Implementation Decisions, Testing Decisions, Out of Scope, Further Notes); adding Understanding subsections expands scope beyond the inspiration source.

**Rejected because:**
- Per WU-005 lesson human_understanding (load-bearing for D2): AppMaker MUST explicitly mark non-delegable judgments, identity model, trust boundaries, etc. Without Understanding section, these become implicit and silently delegated to agents.
- Per WU-005 lesson verifiability_bias: success criteria must be verifiable; without dedicated Understanding subsection 6, "feels right" PRD criteria leak into downstream work.
- Matt's plain template was designed for human-only PRD authoring with implicit judgment ownership; AppMaker's agent-assisted authoring REQUIRES explicit judgment ownership (otherwise agents silently make calls).
- The 7 Understanding subsections add ~30-50 lines per PRD: real cost, but proportionate to value (preventing Stripe-email = Google-email anti-pattern class).

### KA-5. PRD as code-generated artifact (via Zod or similar)

**Considered because:** Code-backed PRD shape would enable automatic validation + IDE autocomplete + type-safe generation.

**Rejected because:**
- Per ADR-003 §D1 + KA-1 (Zod canonical): premature TypeScript binding violates ADR-001 §D10 (CLI-first, MCP/runtime later).
- PRD is a human-readable narrative document; code-generation produces stilted, formulaic output unsuitable for product reference.
- Future Zod adapter could be generated FROM `prd-v1.schema.json` if needed (deferred OQ-1); the inverse (code-canonical) creates lock-in.
- WU-005 lesson harness_engineering: invest in harness (PRD shape discipline + verification) not in chasing tooling.

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| PRD shape over-engineered before any real PRD authored | Medium | Medium | D2 explicit revisitation in OQ-1; formal `prd-v1.schema.json` deferred to future schemas-extension WU; v1 PRD authors may discover real-shape gaps |
| Understanding subsections ambiguous (e.g. "domain invariants" — what counts?) | Medium | Medium | Each subsection name includes parenthetical clarification in §D2; future PRD prompt skill will provide examples per subsection; iteration based on first PRD authoring experience |
| `ready_with_override` propagation chain getting long (interview → PRD → decomposition → implementation) — ambiguities pile up | Medium | Medium | Each downstream WU may resolve a specific ambiguity (removing it from chain via amendment); future analytics WU may surface unresolved-ambiguity counts as warning signal |
| D5 consumption rule too rigid (every interview field) | Low | Low | "Out-of-PRD-scope" with reason is acceptable per consumption rule; only silent omission is forbidden |
| D4 gate too strict — trivial features may not need full PRD | Medium | Low | OQ-4 captures future amendment for PRD-skip mechanism; v1 break-glass available via human-only invocation |
| Matt to-prd "publish to issue tracker" not adopted, may cause confusion for adopters familiar with original | Low | Low | Mapping doc entry explicit about adaptation differences; future PRD prompt skill will name divergences |
| Cross-decision contradiction within ADR-004 D1-D7 | Medium | Medium | review_scorecard `cross_decision_consistency` field; self-check explicit step; ADR-002 D1 ↔ D3 contradiction in WU-003 was caught by Codex |
| Mapping doc append silently rewrites existing 2 entries | Low | Medium | Diff verification before VERIFIED (per WU-005 actual_usage lesson); review_scorecard `mapping_doc_existing_entries_unchanged` field |
| Future Design Exploration Stage ADR-NNN scope creep into ADR-004 | Medium | Low | Codex/user directive: Design Exploration Stage is future ADR placeholder ONLY; ADR-004 §Open Questions records it without adopting any Open Design integration |

## Rollback Plan

**Soft rollback:** Future ADR (ADR-NNN) supersedes specific decisions in ADR-004. For example, if D2 (single project-level PRD) proves wrong (real projects need per-feature), ADR-NNN documents the supersedence; existing `.appmaker/prd.md` may be migrated to `.appmaker/prds/main.md` via dedicated implementation work_unit. Mapping doc entry for to-prd may be amended via dedicated work_unit with revision history (per WU-003 append-oriented convention).

**Hard rollback:** Archive ADR-004 + mapping append entry (mark status REJECTED in revision history; mapping doc append removed via amendment with revision history note). AppMaker reverts to using `interview-result.yaml` as both Interview output AND informal product reference; downstream decomposition (when ADR-005 lands) operates without PRD gate. No production users affected (greenfield); cost is design rework only.

## Open Questions

These are deliberately deferred; future ADRs or work_units resolve them.

- **OQ-1.** Per-feature PRD evolution. When project complexity requires it, extension to `.appmaker/prds/<feature-id>.md` per KA-1 alternative; PRD index for cross-feature consistency. Triggered by usage data (e.g., 3+ feature areas in one project).
- **OQ-2.** Validator implementation for `prd-v1.schema.json` (formal PRD shape validator). Per ADR-003 OQ-1 deferral (ajv install + integration); when validator infrastructure lands, PRD shape becomes machine-validated.
- **OQ-3.** PRD prompt as skill (skill-authoring deferred). Future WU authors the AppMaker PRD prompt as a catalog skill with proper attribution to Matt Pocock.
- **OQ-4.** PRD-skip mechanism for trivial work. Future amendment may allow PRD-skip via human break-glass for sufficiently small interview scope; specific criteria for "trivial" deferred to that future amendment WU.
- **OQ-5.** v1.1 Context-compiler schema (per ADR-001 §D7 + WU-005 lesson context_pack_as_program). Future ADR-NNN Context-Pack Schema may formalize what makes a context-pack a valid Software 3.0 program.
- **OQ-6.** Verifiability Standards ADR-NNN. Per WU-005 lesson verifiability_bias: when implementation/UI work surfaces concrete needs (screenshot review, accessibility audit, workflow completion proxies), formalize as ADR.
- **OQ-7.** Agent-Native Project Interface ADR-NNN (per Codex deferred per user directive). AGENTS.md, `.appmaker/context/`, copy-pasteable commands, explicit task contracts, docs for agents not just humans.
- **OQ-8.** Design Exploration Stage ADR-NNN candidate. Open Design-inspired, PRD-driven. Possible artifacts: design-brief.md, screen-map.md, prototypes/*.html, ux-decisions.md, design-review-scorecard.yaml. Deferred; no Open Design runtime dependency, no prototype generation, no design-system catalog, no UI artifact in WU-006.

## Acceptance Criteria

This ADR is `READY-FOR-REVIEW` (informally; formal status is governed by WU-006 work-unit.yaml) when:

- All 7 decisions D1–D7 resolved with explicit decision and rationale
- ≥3 killed alternatives documented (this ADR has 5)
- D2 mandates Understanding section with 7 named subsections
- D5 includes complete consumption rule mapping table
- D6 specifies propagation mechanism with worked status flow
- D7 contains 12-row lessons mapping table (1 per applicable lesson), each with traceable concrete element
- Matt Pocock attribution explicit: link, MIT, author, exact SKILL.md path, pinned commit hash
- 12 required adr-v1 sections present in declared order
- Length 250–550 lines
- No constitution edits, no schema files, no ADR-001/002/003 edits
- All three forbidden placeholder markers (per `work-unit.yaml.verification.forbidden_patterns` for WU-006) absent from prose
- Open Questions enumerates 8 deferred items including 4 future ADR-NNN candidates (Context-Pack Schema, Verifiability Standards, Agent-Native Project Interface, Design Exploration Stage)

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

**Forbidden patterns check** (per `work-unit.yaml.verification.forbidden_patterns` for WU-006): all listed patterns absent.

## Revision History

| Date | Author / Work_unit | Status | Changes |
|---|---|---|---|
| 2026-05-10 | WU-006 (draft) | DRAFT | Initial draft. 7 decisions D1–D7. 5 killed alternatives. 8 open questions. Lessons-mapping table (12 wu-006-applicable lessons → schema-fields/self-check-items/PRD-shape-constraints). Matt Pocock attribution complete (MIT, repo URL, SKILL.md path, pinned commit hash). Understanding section requirement (7 subsections per WU-005 lesson human_understanding) MANDATORY. Verifiable success criteria per WU-005 lesson verifiability_bias. PRD location: `.appmaker/prd.md` (single project-level, kernel-managed). PRD as required gate before decomposition (D4). PRD inherits ready_with_override from Interview (D6). Field-by-field consumption rule for interview-result.yaml (D5). |
| 2026-05-10 | WU-006 (Codex pre-promote review × 2) | DRAFT | Six revisions over two Codex review rounds: **Round 1 (3 blocking + 1 non-blocking):** Fix #1 stale "8 direct + 3 broad" → "8 direct + 4 broad = 12"; Fix #2 D4↔D6 contradiction resolved (D4 now accepts {ACCEPTED, ACCEPTED_WITH_INHERITED_OVERRIDE}); Fix #3 D5 mapping table extended with 5 readiness.* fields rows (reason, unresolved_ambiguities, override.invoked_by, override.invoked_at, override.reason); Fix #5 (non-blocking) mechanism softened from "kernel detects via goal contains 'decomposition'" to "human-enforced at WU review; mechanical kernel deferred to ADR-005 work_unit_subtype". Casing convention UPPERCASE for PRD statuses adopted (consistent with work-unit-v1 status enum). **Round 2 (2 blocking):** Fix #6 mapping entry stale lowercase `accepted_with_inherited_override` → UPPERCASE (cross-artifact consistency); Fix #7 D4 internal contradiction (kernel vs human-enforced) resolved — line 121 reworded to "AppMaker process (human-enforced at WU review time)" with mechanical kernel deferred to ADR-005 explicit. 338 → 346 lines. |
| 2026-05-10 | WU-006 (promote) | ACCEPTED | Promoted from `.appmaker/work-units/wu-006/runs/2026-05-09T23-44-24Z/output.md` to `decisions/` after Codex REVIEW PASS. Status flip DRAFT → ACCEPTED in promoted copy; original draft immutable in run dir. Mapping entry concurrently appended as 3rd row to `docs/reference/matt-pocock-pattern-mapping.md` (existing 2 entries — grill-me, grill-with-docs — diff-verified unchanged). |

---

**End of ADR-004 (ACCEPTED — WU-006 promoted 2026-05-10).**
