# Context Pack — WU-007: ADR-005 Work_unit Decomposition (to-issues from Matt Pocock skills)

> **R8 compliance statement.** Per `constitution.md` v2 Rule R8, this pack contains:
>
> - **Constitution v2** — Appendix A (critical excerpts inline; full at `/Users/pawel/Projects/AppMaker/constitution.md`, 18 rules including R18)
> - **ADR-001 / ADR-002 / ADR-003 / ADR-004 relevant decisions** — Appendix B (full files at `decisions/`)
> - **WU-007 acceptance criteria (verbatim, 19)** — Appendix C
> - **Lessons applicable to wu-007 (verbatim, 16)** — Appendix D (12 prior + 4 fresh wu-006)
>
> R8 v1 compliance for manual packs satisfied by including critical excerpts inline plus
> absolute path. Lessons inclusion is mandatory per WU-007 acceptance criterion #4 (memory-stream
> test) and per Codex's directive that lessons must demonstrably influence design.
>
> **Per Codex/user WU-007 directive: NARROW.** ADR-005 covers ONLY to-issues / decomposition
> pattern. Does NOT mix safety hooks (ADR-006), implementation runner (ADR-007), bug workflow
> (ADR-008), architecture review (ADR-009).
>
> **Per WU-006 fresh lessons (load-bearing):** ACTIVE cross-decision pairwise diff (7 pairs) +
> ACTIVE cross-artifact field-by-field check + within-decision wording-consistency scan.
> Scorecard fields are PASSIVE labels; the check is the diff itself.

---

## 1. Goal (recap from work-unit.yaml)

Produce **ADR-005 Work_unit Decomposition** (primary) + **append exactly 1 entry as Entry 4 to
matt-pocock-pattern-mapping.md** (secondary; existing 3 entries unchanged). ADR-005 establishes
Decomposition as lifecycle stage between PRD Synthesis (ADR-004) and Implementation work_units.

Decomposition consumes the promoted PRD and produces:
- A set of vertical-slice work_units (each independently testable / deployable / verifiable)
- Relation graph (blocked_by, depends_on, related_to)
- Per-WU acceptance criteria (each traceable to PRD success criteria per Understanding subsection 6 verifiable)
- Per-slice typing (HITL / AFK or AppMaker equivalent — see D2)

Inspiration: Matt Pocock `/to-issues` skill. AppMaker adapts as inspiration source, NOT runtime
dependency, per ADR-002 §D5 + ADR-001 §D12 + WU-005 lesson harness_engineering.

**This is the SECOND WU under work-unit-v1 schema** (after WU-006). Manual structural conformance
already verified in WU-007 contract.

---

## 2. What ADR-005 IS (and is NOT)

**IS:**
- Architectural decision record per `adr-v1` schema (12 sections)
- Multi-output WU primary artifact (paired with mapping doc append)
- Decisive about 7 sub-decisions D1-D7 with rationale + ≥3 killed alternatives total
- Explicit about how decomposition relates to PRD (input) and implementation WUs (output)
- Mandates per-slice typing (HITL/AFK or AppMaker equivalent — D2 sub-decision b1/b2/b3)
- Specifies per-WU acceptance criteria propagation rule from PRD (D5)
- Within-bounds: 250–550 lines markdown
- ACTIVE cross-decision (7 pairs) + cross-artifact + within-decision wording checks per WU-006 lessons

**IS NOT:**
- Safety hooks design (ADR-006, future)
- Implementation runner / TDD pattern (ADR-007, future)
- Bug workflow / diagnose pattern (ADR-008, future)
- Architecture review (ADR-009, future)
- Validator implementation (ADR-003 OQ-1 deferred)
- Constitution amendment
- Schema modification (work-unit-v1, interview-result-v1, adr-v1 immutable)
- Code change (no `.ts`, `.json`, `.sql`)
- Issue tracker integration (Matt's "publish to issue tracker" step NOT adopted in v1)
- Future ADR-NNN candidates (Agent-Native Project Interface, Verifiability Standards, Context-Pack Schema, Design Exploration Stage) — referenced but not specified

---

## 3. Decision Points — 7 to resolve in ADR-005

Verbatim from `work-unit.yaml.decisions_to_resolve`:

### D1. Decomposition definition (vs PRD vs implementation WUs)

What IS work_unit decomposition in AppMaker? Output of which lifecycle stage (post-PRD)? What
does it produce (set of vertical-slice work_units + relation graph)? How does it differ from:

- **PRD** (product reference; from ADR-004)
- **Individual implementation work_units** (the slices themselves)

Decomposition is the **planning stage** that emits vertical-slice WUs as a coherent set with
explicit relations.

### D2. Vertical slice vs horizontal task + slice typing (HITL / AFK or AppMaker equivalent)

**Two coupled sub-decisions:**

**(a) Vertical slice (per Matt Pocock to-issues principle):**
- Each slice cuts through ALL integration layers end-to-end (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- "Tracer bullet" — narrow but COMPLETE path
- Many thin slices > few thick ones
- Horizontal task antipattern (one technical layer fragment) → killed alternative

**(b) Slice typing — Matt's HITL/AFK or AppMaker equivalent:**

Matt's to-issues mandates each slice as:
- **HITL** (human-in-the-loop): requires human interaction (architectural decision, design review)
- **AFK** (away-from-keyboard): agent-executable end-to-end without human interaction

ADR-005 must decide:
- **(b1) Adopt HITL/AFK literally** — simplest, matches Matt verbatim, low cognitive cost for users familiar with Matt's skills
- **(b2) Map to AppMaker-native terminology** — e.g. `execution_class: human_required | autonomous` — consistent with WU-005 lesson human_understanding for non-delegable judgments; potentially clearer in AppMaker context (not borrowing acronyms from external source)
- **(b3) Drop typing entirely** — REJECTED per WU-005 lesson human_understanding (non-delegable judgments must be marked explicitly per slice; without typing, agent silently makes calls)

Pick (b1) or (b2) with rationale; (b3) goes to killed alternatives.

### D3. Decomposition output location and shape

Three candidates:

- **(a)** `.appmaker/decomposition.md` — single project-level document (mirrors `.appmaker/prd.md` precedent from ADR-004 D2)
- **(b)** Per-WU `work-unit.yaml` files emitted directly to `.appmaker/work-units/wu-NNN/` (no separate decomposition artifact; the WU files ARE the decomposition)
- **(c)** Intermediate `.appmaker/decomposition.yaml` graph listing planned WUs as nodes + edges, then materialized into individual `work-unit.yaml` files via separate command

Pick one with rationale; ≥3 alternatives killed (option (b) might be one if rejected).

**Cross-decision constraint with D4:** output shape MUST accommodate relation graph storage
(blocked_by, depends_on). If (b), graph lives in each work_unit.yaml. If (a) or (c), graph in
single artifact.

**Cross-decision constraint with D5:** output shape MUST have explicit place for tracing each
PRD success criterion → WU acceptance criterion mapping (e.g., AC tag pointing back to PRD
criterion id).

### D4. Relation graph (blocked_by, depends_on, related_to)

Specify:
- Which relations decomposition produces (blocked_by, depends_on, related_to — Matt's `Blocked by` field is canonical example; AppMaker may add depends_on for non-blocking dependencies)
- Where they live (in each `work_unit.yaml` per D3 outcome, or in separate graph artifact)
- How cycle detection works (mandatory before promote; reject decomposition with cycles)
- How relation changes during execution are recorded (events.jsonl entries when WU adds/removes blocked_by post-decomposition)

### D5. Per-work_unit acceptance criteria propagation from PRD

How does each decomposed WU's `acceptance_criteria` derive from PRD success criteria
(Understanding subsection 6 — verifiable per WU-005 lesson verifiability_bias)?

**Propagation rule:**
- Every PRD success criterion MUST map to ≥1 decomposed WU's acceptance criterion (no PRD criterion silently orphaned)
- Every WU acceptance criterion MUST trace back to a PRD criterion or non-delegable human judgment (no WU AC silently invented)
- Each WU AC inherits verifiability discipline (auto-check OR human-review-with-explicit-criteria)

**Cross-decision constraint with D2 (slice typing):** if D2(b) AppMaker execution_class chosen,
HITL slices' acceptance criteria reference non-delegable judgments explicitly; AFK slices have
fully verifiable AC without human judgment dependency.

### D6. ready_with_override propagation through decomposition

Per ADR-002 §D6 + ADR-004 §D6, override propagates through downstream context-packs.

Specify:
- How decomposed WUs inherit `unresolved_ambiguities[]` from PRD (each WU's context-pack injects relevant subset, filtered by `scope_affected`)
- Per-WU filtering by scope_affected (only ambiguities relevant to the WU's scope appear in its context-pack)
- Third hop in chain: interview → PRD → decomposition → individual WU context-packs

**Status semantics — IMPORTANT cross-artifact distinction (per WU-006 lesson cross_artifact_consistency_active_check + work-unit-v1 schema actual enum):**

`ACCEPTED_WITH_INHERITED_OVERRIDE` is the status of an **ARTIFACT** (a markdown/yaml document like PRD or decomposition.md) that inherited override from upstream — analog to ADR-004 §D6 PRD status. It is **NOT** a value in the `work-unit-v1.schema.json` status enum (which contains exactly: `PROPOSED`, `ACCEPTED`, `IN_PROGRESS`, `VERIFIED`, `PROMOTED`, `PROMOTED_WITH_EXCEPTION`, `REJECTED`).

Therefore D6 propagation depends on D3 outcome:

- **If D3 chooses (a)** `.appmaker/decomposition.md` single document, OR **(c)** intermediate `.appmaker/decomposition.yaml` graph: the **decomposition artifact** can carry status `ACCEPTED` or `ACCEPTED_WITH_INHERITED_OVERRIDE` (artifact-level status, not work_unit status). Per-WU `work-unit.yaml` files use the standard work-unit-v1 enum (no inheritance status); ambiguity propagation reaches them via context-pack metadata only.

- **If D3 chooses (b)** per-WU `work-unit.yaml` files emitted directly (no separate decomposition artifact): there IS no decomposition artifact to carry `ACCEPTED_WITH_INHERITED_OVERRIDE`. Ambiguity propagation reaches each WU as **context-pack metadata** (filtered `unresolved_ambiguities[]` injection per scope_affected) — NOT as a status value on the WU itself. Future schemas-extension WU may add a per-WU `inherited_override` boolean or similar field; until then, the metadata-in-context-pack mechanism is the v1 path.

D6 in ADR-005 MUST decide (consistent with D3 outcome) which of these mechanisms it adopts and explicitly state that work-unit-v1 status enum is NOT extended by ADR-005 (no schema modification — per WU-007 scope discipline).

### D7. Matt Pocock to-issues attribution + 16-lessons mapping table

**(a) Attribution per ADR-002 §D5 model:**
- Future decomposition prompt skill MUST include inline header naming Matt Pocock, MIT license, repo URL, exact SKILL.md path (`skills/engineering/to-issues/SKILL.md`)
- `docs/reference/matt-pocock-pattern-mapping.md` gains Entry 4 (this WU appends)
- Pinned commit hash: `b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8` (same as ADR-002/003/004)

**(b) Memory-stream test — TABLE mapping each of 16 wu-007-applicable lessons:**

Per ADR-002/003/004 §D7 precedent + WU-005 lesson adr_quality. Table format mandatory.

Per **WU-006 lesson #1 (cross_decision_consistency_active_check)**, this D7 table MUST be
ACTIVELY cross-checked against the actual mapping doc Entry 4 being appended.

Per **WU-006 lesson #2 (cross_artifact_consistency_active_check)**, every status name,
terminology, and field name claimed in this D7 table MUST be verified to match in mapping
entry, in PRD shape from ADR-004, and in work-unit-v1 schema (within scope of EXISTING fields;
NEW decomposition fields marked as schema-extension candidates per AC #17b).

---

## 4. Matt Pocock `/to-issues` — full SKILL.md content (with attribution)

**Source:** Matt Pocock Skills, MIT License, Copyright (c) 2026 Matt Pocock,
https://github.com/patjfree/Matt_Pocock_Skills
**Local path:** `/Users/pawel/Projects/Matt_Pocock_Skills/skills/engineering/to-issues/SKILL.md`
**Pinned commit hash:** `b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8` (2026-04-30)

```markdown
---
name: to-issues
description: Break a plan, spec, or PRD into independently-grabbable issues on the project issue tracker using tracer-bullet vertical slices. Use when user wants to convert a plan into issues, create implementation tickets, or break down work into issues.
---

# To Issues

Break a plan into independently-grabbable issues using vertical slices (tracer bullets).

## Process

### 1. Gather context
Work from whatever is already in the conversation context. If the user passes an issue reference, fetch it from the issue tracker.

### 2. Explore the codebase (optional)
If you have not already explored the codebase, do so. Issue titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

### 3. Draft vertical slices
Break the plan into tracer bullet issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

Vertical slice rules:
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones

### 4. Quiz the user
Present the proposed breakdown as a numbered list. For each slice, show:
- Title: short descriptive name
- Type: HITL / AFK
- Blocked by: which other slices (if any) must complete first
- User stories covered: which user stories this addresses

Ask:
- Does the granularity feel right?
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user approves the breakdown.

### 5. Publish the issues to the issue tracker
For each approved slice, publish a new issue with `needs-triage` triage label. Publish in dependency order (blockers first).

Issue body template:
- Parent (reference if existing parent issue)
- What to build (concise description, end-to-end behavior)
- Acceptance criteria (numbered checklist)
- Blocked by (reference or "None - can start immediately")

Do NOT close or modify any parent issue.
```

**Key concepts AppMaker adopts:**
- "Tracer bullet vertical slices through ALL integration layers" — directly informs D2(a) vertical slice definition
- "HITL / AFK" — directly informs D2(b) slice typing (decision: literal adoption b1 or AppMaker mapping b2)
- "Blocked by" relation — directly informs D4 relation graph
- "Acceptance criteria" per slice — directly informs D5 propagation rule
- "Demoable or verifiable on its own" — informs verifiability_bias propagation per WU-005 lesson
- "Many thin slices > few thick ones" — design heuristic for D2/D5 granularity

**Key concepts AppMaker adapts (does NOT copy verbatim):**
- "Publish to the project issue tracker" — AppMaker has no built-in issue tracker dependency in v1; decomposition output lives in `.appmaker/` per D3 (location TBD by ADR-005)
- "Quiz the user" iteration loop — AppMaker uses standard work_unit review/promote cycle instead
- "needs-triage label" — AppMaker uses status enum (per work-unit-v1 schema); triage convention not adopted

---

## 5. Codex's WU-007 guidance (context, not mandate)

Codex did not provide hard format recommendations the way they did for JSON Schema in WU-005.
Their WU-007 guidance was structural:

- **Narrow scope**: only to-issues / decomposition; no safety hooks, TDD, diagnose, architecture review (each separate future ADR)
- **HITL/AFK decision required** per Matt to-issues SKILL.md:26 + SKILL.md:39 — D2 must explicitly decide adoption (b1), mapping (b2), or rejection (b3)
- **AC #17 split**: existing schema fields strict-diffed vs new decomposition fields marked conceptual / schema-extension candidates
- **Cross-decision pairs additions**: D2↔D5 (slice typing ↔ AC propagation), D3↔D5 (output shape ↔ PRD criterion tracing) — both important coupling points
- **DRY discipline for AC ↔ verification block**: AC text references canonical list in verification, not duplicated enumeration (per WU-006 lesson wording_internal_contradiction)
- **Active cross-decision/cross-artifact checks**: not passive scorecard labels (per WU-006 lessons #1 and #2)

**Executor's task:** evaluate Matt to-issues template against AppMaker needs (with HITL/AFK
decision); pick D2(b) slice typing approach; pick D3 output location; specify D4 relation graph
mechanics; specify D5 PRD → WU AC propagation rule; specify D6 override propagation chain
extension; justify each decision in ADR-005 with ≥3 killed alternatives total.

---

## 6. Critical inheritances from prior ADRs (cross-decision context)

Decisions in ADR-005 MUST align with these prior decisions (per AC #11 no contradiction):

| Prior ADR / Rule | What ADR-005 inherits |
|---|---|
| ADR-001 §D2 (Process Kernel + work_unit primitive) | Decomposition produces work_units (the primitive); not a different artifact class |
| ADR-001 §D2a (work_unit type: investigation \| implementation) | Decomposed slices are typically `type: implementation`; some may be `type: investigation` (e.g., "design slice" requiring ADR before code) |
| ADR-001 §D3 (6-file model) | Decomposition output (per D3) lives in `.appmaker/`; decomposed work_units in `.appmaker/work-units/` (existing pattern) |
| ADR-001 §D8 (voting deferred) | Decomposed WUs use `execution.mode: single`; voting deferred per ADR-001 |
| ADR-001 §D11 (3-stream logging) | Decomposition events go to events.jsonl (decomposition_promoted, slice_added, slice_blocked, etc.); no decisions.jsonl yet active |
| ADR-001 §D13 (gates fail closed) | D6 readiness gate fails closed (PRD missing or status wrong → reject); D5 AC propagation fails closed (any PRD criterion unmapped → reject) |
| ADR-002 §D6 (ready_with_override propagation) | D6 chain extension: interview → PRD → **decomposition** → individual WU context-packs |
| ADR-003 §D1 (JSON Schema canonical) | D3 output shape (if formal schema): JSON Schema; if YAML: examples-only (consistent with PRD shape from ADR-004) |
| ADR-003 §D4 (validator deferred) | Decomposition validator deferred too; manual structural review |
| ADR-004 §D2 (PRD shape with Understanding section) | Decomposition consumes PRD's Understanding subsections; non-delegable judgments and verifiable success criteria propagate per D5 |
| ADR-004 §D4 (PRD-required gate before decomposition) | This ADR-005 IS the decomposition stage that the gate guards — circular reference managed: ADR-005 defines what decomposition IS; ADR-004 §D4 says it requires PRD first. **ADR-004 §D4 also commits ADR-005 to "introduce a formal `work_unit_subtype: decomposition` to work-unit-v1 schema and let the kernel gate on it"** (see ADR-004 §D4 "How / Implications" para 1). ADR-005 MUST explicitly resolve this commitment — two acceptable paths: (a) ADR-005 makes `work_unit_subtype: decomposition` (or equivalent name) a CONCEPTUAL DECISION here, names the field + semantics, but defers actual schema modification to a separate schema-extension WU (consistent with WU-007 scope: no schema files modified per AC #10 + out-of-scope reminders); OR (b) ADR-005 partially supersedes/clarifies ADR-004 §D4's wording — the schema modification is explicitly a separate future WU, not part of ADR-005 itself; ADR-004 §D4 is interpreted as "decomposition design is defined in ADR-005; mechanical schema gate lands when schema-extension WU promotes". Either path keeps WU-007 narrow (no schema work). The choice is itself a sub-decision (likely belongs in D4 or §Open Questions of ADR-005). |
| ADR-004 §D6 (PRD `ACCEPTED_WITH_INHERITED_OVERRIDE`) | D6 PRD status check: gate accepts both `ACCEPTED` and `ACCEPTED_WITH_INHERITED_OVERRIDE`; if latter, propagate ambiguities further |
| constitution v2 R12 (no silent fallbacks) | D5 propagation rule: silent omission of PRD criterion → REJECT; silent invention of WU AC → REJECT |
| constitution v2 R18 (Interview required) | Indirect — decomposition presumes PRD which presumes Interview (transitively) |

---

## 7. Required output structure

### ADR-005 (primary, per `adr-v1` schema)

12 sections per `.appmaker/schemas/adr-v1.schema.json`:

1. **Status** — DRAFT initially; flips to ACCEPTED on promote
2. **Metadata** — date, authors, type (investigation), supersedes/superseded-by
3. **Context** — why decomposition stage now, how it relates to ADR-004 PRD output and future ADR-007 implementation runner
4. **Sources Consulted** — Codex multiple rounds, Matt Pocock to-issues, lessons.jsonl, ADR-001/002/003/004, constitution v2
5. **Decision (numbered)** — D1 through D7 each with Why + How/Implications. D7 includes the 16-row lessons-mapping table (cross-checked against mapping entry per WU-006 lesson #1).
6. **Killed Alternatives** — at least 3, each with reason
7. **Risks and Mitigations** — table
8. **Rollback Plan** — soft + hard
9. **Open Questions** — what ADR-005 deliberately defers
10. **Acceptance Criteria** — self-check that ADR-005 itself meets verification
11. **Verification** — table mapping required sections to present/absent + ACTIVE cross-checks results
12. **Revision History** — initial draft + future amendments

### Mapping doc append (secondary, Entry 4)

Add ONE new row to `docs/reference/matt-pocock-pattern-mapping.md` per WU-003 append-oriented
convention. Required fields (cross-checked against ADR-005 D7 per WU-006 lesson #2):

```
| Field | Value |
|---|---|
| source_skill | Matt_Pocock_Skills/skills/engineering/to-issues/SKILL.md |
| source_commit | b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8 (2026-04-30) |
| license | MIT |
| adr_reference | ADR-005 |
| appmaker_pattern | Work_unit Decomposition |
| surface | lifecycle |
| output_artifact | per ADR-005 §D3 outcome (e.g. .appmaker/decomposition.md or per-WU files in .appmaker/work-units/) |
| notes | Adapted from Matt's /to-issues. AppMaker adds: Understanding-section propagation per WU-005 lesson human_understanding; verifiable AC per WU-005 lesson verifiability_bias; field-by-field PRD criterion → WU AC propagation rule per ADR-005 §D5 (no silent omission per R12); ready_with_override chain extension per ADR-005 §D6; slice typing per D2(b1 HITL/AFK | b2 AppMaker execution_class). AppMaker does NOT adopt Matt's "publish to issue tracker" step — no built-in issue tracker dependency in v1. |
```

Existing 3 entries (grill-me, grill-with-docs, to-prd) MUST remain textually unchanged
(diff verification before VERIFIED per WU-006 lesson cross_artifact_consistency_active_check).

---

## 8. Forbidden patterns

ADR-005 prose MUST NOT contain (per WU-002 precedent + adr-v1.schema.json `forbidden_patterns: required` field):
- `TBD`
- `TODO`
- `...` (bare ellipsis as hand-waving; ellipsis in concrete code-context placeholders only)

Mapping doc append entry text similarly.

If a forbidden pattern is needed in instructional context, paraphrase to avoid the literal token.

---

## 9. Bounds

- **ADR-005:** 250–550 lines markdown
- **Mapping doc append:** 1 row added (~10 lines including blank lines around table)

---

## 10. Self-check before declaring WU-007 ready (24 items)

Before flipping work-unit.yaml `IN_PROGRESS` → `VERIFIED`:

### Standard adr-v1 conformance (per ADR-003 §D5)
- [ ] ADR-005 has all 12 required sections in declared order
- [ ] D1, D2, D3, D4, D5, D6, D7 each resolved with explicit decision and rationale
- [ ] At least 3 killed alternatives total
- [ ] Length: ADR-005 ≤ 550 and ≥ 250 lines
- [ ] No `TBD`, no `TODO`, no bare `...`

### D1-D7 specific
- [ ] D2(a) defines vertical slice (tracer bullet through ALL layers) + horizontal task antipattern explicit in killed alternatives
- [ ] D2(b) decides slice typing (b1 literal HITL/AFK | b2 AppMaker execution_class | b3 drop — REJECTED) with rationale
- [ ] D3 picks output location with rationale; ≥3 alternatives killed; output shape accommodates D4 relation graph + D5 PRD criterion tracing
- [ ] D4 specifies relation set (blocked_by, depends_on, related_to or subset), location (per D3), cycle detection mandatory
- [ ] D5 propagation rule explicit: every PRD criterion → ≥1 WU AC; every WU AC → PRD criterion or non-delegable judgment; verifiability discipline inherited
- [ ] D6 chain extension: interview → PRD → decomposition → individual WU context-packs; status `ACCEPTED_WITH_INHERITED_OVERRIDE` UPPERCASE
- [ ] D7 contains 16-row lessons mapping table (1 per applicable lesson)

### Matt Pocock attribution
- [ ] Link to repo, MIT license, author, exact SKILL.md path, pinned commit hash
- [ ] Mapping doc entry: 1 new row (Entry 4) with 8 required fields; existing 3 entries diff-verified unchanged

### WU-006 active checks (load-bearing per fresh lessons)
- [ ] **Cross-decision consistency ACTIVE**: each pair in `verification.cross_decision_consistency_active_step.pairs_to_diff` (canonical list, 7 pairs) executed; result recorded; semantic alignment confirmed for each pair
- [ ] **Cross-artifact consistency ACTIVE**: every status name, terminology, schema field, convention claimed in ADR-005 verified to match in mapping entry, in PRD shape from ADR-004, in work-unit-v1 schema (existing fields) OR explicitly marked as schema-extension candidate (new decomposition fields)
- [ ] **Within-decision wording consistency**: each ADR-005 sub-decision's "Decision" + "How / Implications" subsections diff-checked for internal terminology drift (kernel vs process vs human; v1 vs v2; mechanical vs human-enforced; HITL/AFK vs execution_class)

### Cross-ADR consistency
- [ ] No contradiction with ADR-001 §§D2, D2a, D3, D8, D11, D13
- [ ] No contradiction with ADR-002 D6 (override propagation)
- [ ] No contradiction with ADR-003 D1 (JSON Schema), D4 (validator deferred)
- [ ] No contradiction with ADR-004 D2 (PRD shape), D4 (PRD-required gate), D6 (PRD override propagation)
- [ ] No contradiction with constitution v2 R1, R8, R12, R13, R18

### Memory-stream
- [ ] All 16 wu-007-applicable lessons mapped in §D7 table (concrete elements, not name-drops)
- [ ] Open Questions enumerates deferred items (slice prompt as skill, decomposition validator, schema migration, future ADR-NNN candidates)

---

## 11. Out-of-scope reminders (NARROW per Codex/user directive)

The executor MUST NOT:

- Design or specify safety hooks (ADR-006, future)
- Design or specify implementation runner / TDD pattern (ADR-007, future)
- Design or specify bug workflow / diagnose pattern (ADR-008, future)
- Design or specify architecture review (ADR-009, future)
- Design or specify Design Exploration Stage / Open Design integration (future ADR-NNN)
- Implement validator (ADR-003 OQ-1 deferred)
- Edit ADR-001 / ADR-002 / ADR-003 / ADR-004 (immutable)
- Edit constitution.md (amendments via dedicated WU only)
- Edit schemas v1 (immutable)
- Add fields to work-unit-v1.schema.json (out of scope; future schemas-extension WU)
- Implement decomposition prompt as a skill (deferred to future skill-authoring WU)
- Build decomposition CLI tooling (deferred)
- Trigger or call any external service (no issue tracker integration in v1; Matt's "publish to issue tracker" step explicitly NOT adopted)
- Run `git commit`, `git push`, `git clone`, `npm install`, `rm -rf` (per R14)
- Modify `docs/reference/future-scope-registry.md` (Codex/user discovery reference, non-binding)

---

## 12. Lessons stream application (memory-stream test)

The full text of all 16 wu-007-applicable lessons is in Appendix D. This section names how each
lesson concretely shapes WU-007's design and execution, satisfying acceptance criterion #4.

**Per Codex/WU-006 lesson #2 (cross_artifact_consistency_active_check):** every claim in this
section MUST be cross-checkable against actual artifact element (work-unit.yaml field, ADR-005
section, mapping doc field, self-check item).

### Direct wu-005 lessons (8) — load-bearing for decomposition shape

| # | Lesson | Concrete element in WU-007 / ADR-005 |
|---|---|---|
| L1 | wu-005 / schema_design | `secondary_artifacts_policy` declared in WU-007 verification block; mapping append covered explicitly |
| L2 | wu-005 / validator_gap | `validator_tooling_preflight` in WU-007 contract; ADR-005 §D2/D3 explicit that formal decomposition schema deferred (no meta-validation pretense) |
| L3 | wu-005 / actual_usage | ADR-005 §D2/D3 explicit: no historical decomposition artifacts to mirror (greenfield); proposed shape revisited in v2 per OQ |
| L4 | wu-005 / adr_quality | This §12 + ADR-005 §D7 mapping table cross-checked against actual mapping doc Entry 4 being appended |
| L5 | wu-005 / harness_engineering | ADR-005 §D5 (every PRD criterion → ≥1 WU AC) + §D6 (override propagation chain) are harness investments — enforce structural lifecycle ordering |
| L6 | wu-005 / human_understanding | **D2(b) slice typing decision MANDATES explicit handling of non-delegable human judgments per slice** (HITL marker carries this; or AppMaker execution_class equivalent) |
| L7 | wu-005 / context_pack_as_program | **Decomposed WU context-packs** (D6 outcome) inherit Software 3.0 program discipline: each gets relevant subset of unresolved_ambiguities filtered by scope_affected; future ADR-NNN Context-Pack Schema deferred |
| L8 | wu-005 / verifiability_bias | **D5 propagation rule MANDATES verifiable AC per decomposed WU** (auto-check OR human-review-with-criteria); unverifiable WU AC → REJECT |

### Broad lessons from wu-003/wu-004 (4) — review discipline

| # | Lesson | Concrete element |
|---|---|---|
| L9 | wu-003 / review | §10 self-check is granular 24-item checklist; pre-execution external-state fact-check (Matt to-issues path, commit hash, schema fields); wording-consistency scan between ADR-005 §D1 ↔ §D3 ↔ §D7 |
| L10 | wu-003 / adr_quality | Cross-decision consistency check for ADR-005 D1-D7 — 7 selected canonical high-risk pairs from `verification.cross_decision_consistency_active_step.pairs_to_diff` (curated set of decision pairs that share concepts; not every pair of 7 decisions, which would be C(7,2) = 21) |
| L11 | wu-004 / memory_layer | `lessons_applied` field populated in WU-007 work-unit.yaml with 16 entries; this §12 demonstrates lessons.jsonl actually informs design |
| L12 | wu-004 / review | adr-v1.schema.json `forbidden_patterns: required` enforced; ADR-005 prose self-check confirms zero TBD, zero TODO, zero bare ellipsis |

### Fresh wu-006 lessons (4) — load-bearing for active checks

| # | Lesson | Concrete element |
|---|---|---|
| L13 | wu-006 / cross_decision_consistency_active_check | **`verification.cross_decision_consistency_active_step.pairs_to_diff` block with 7 explicit pairs** (D2↔D3, D2↔D5, D3↔D4, D3↔D5, D5↔D6, D6↔ADR-004 §D6, D7↔mapping). Reviewer MUST execute each pair (active step), not just check scorecard label (passive). |
| L14 | wu-006 / cross_artifact_consistency_active_check | **AC #17 split** into existing-fields-strict-diff vs new-decomposition-fields-marked-conceptual. Mapping entry casing UPPERCASE consistent with ADR-005 (per ADR-004 §D4 convention). Status names cross-checked between ADR-005 D6, mapping entry, work-unit-v1.schema.json. |
| L15 | wu-006 / wording_internal_contradiction | **`verification.within_decision_wording_consistency_required: True`** — each ADR-005 sub-decision's "Decision" + "How / Implications" diff-checked for internal terminology drift (e.g., HITL/AFK vs execution_class within D2; kernel vs process within D4; v1 vs v2 within D3). |
| L16 | wu-006 / supersedes_pattern_for_correction_events | **INDIRECT** — pattern stable from prior WUs (retro_recorded_v2/v3); ADR-005 may produce events.jsonl correction event if needed during execution; no novel use here. |

**Memory-stream test outcome (executor must verify in WU-007 output):** ADR-005 §D7 contains
TABLE with 16 rows mapping each lesson to specific elements. If any lesson is not mapped to
at least one concrete element in ADR-005 (decomposition shape constraint, gate semantics,
self-check item, mapping doc field), WU-007 is REJECTED. Per Codex: lessons map to existing
scope (decomposition only), not new scope (no decomposition tooling, no validator, no schema
extension implementation in this WU).

---

## APPENDIX A — Constitution v2 (R8 inclusion: critical excerpts + full-file reference)

> Source: `/Users/pawel/Projects/AppMaker/constitution.md` (AMENDED, 2026-05-09; 395 lines, 18 rules)

### Critical rules directly affecting WU-007:

**R1.** ADRs require ≥3 alternatives, killed options, risks. *(ADR-005 must comply.)*

**R5.** Gates fail closed. *(D6 readiness gate; D5 AC propagation gate.)*

**R7.** Machine-readable artifacts must pass parser/lint validation before VERIFIED. *(WU-007 work-unit.yaml passed PyYAML + Ruby Psych.)*

**R8.** Every context-pack includes constitution + relevant recent ADRs + acceptance criteria. *(This pack complies.)*

**R12.** No silent fallbacks. *(D5 propagation rule: silent omission → REJECT; silent invention → REJECT.)*

**R13.** Every work_unit reduces uncertainty or delivers verified change. *(WU-007 reduces uncertainty about decomposition shape.)*

**R14.** Agents may not git push/commit/rm-rf/publish/deploy. *(blocked_actions enforces.)*

**R18.** Every project begins with Interview Phase. *(Indirect — decomposition presumes PRD which presumes Interview transitively.)*

**Full text of all 18 rules:** load `/Users/pawel/Projects/AppMaker/constitution.md` before drafting ADR-005.

---

## APPENDIX B — ADR-001 + ADR-002 + ADR-003 + ADR-004 relevant decisions (R8 inclusion)

> Sources:
> - `decisions/ADR-001-process-kernel-architecture.md` (ACCEPTED)
> - `decisions/ADR-002-interview-phase.md` (ACCEPTED)
> - `decisions/ADR-003-schema-format-and-artifact-schemas.md` (ACCEPTED)
> - `decisions/ADR-004-prd-synthesis.md` (ACCEPTED)

Critical inheritances per §6 cross-decision context table above. Full text load before drafting.

---

## APPENDIX C — WU-007 acceptance criteria (verbatim)

> Source: `/Users/pawel/Projects/AppMaker/.appmaker/work-units/wu-007/work-unit.yaml`

19 acceptance criteria from `work-unit.yaml.acceptance_criteria`. Critical ones:

1. ADR-005 resolves all 7 decisions D1–D7 with rationale and ≥3 killed alternatives total.
2. ADR-005 has all 12 required adr-v1 sections.
3. ADR-005 length 250–550 lines.
4. ADR-005 explicitly cites all 16 wu-007-applicable lessons (12 prior + 4 fresh from WU-006 closeout).
5. ADR-005 stays NARROW: only to-issues / decomposition.
6. Matt Pocock attribution explicit: link, MIT, author, exact SKILL.md path, pinned commit hash.
7. matt-pocock-pattern-mapping.md gains exactly ONE new entry as Entry 4.
8. Existing 3 entries unchanged (diff verification per WU-006 lesson cross_artifact_consistency_active_check).
9. Decomposition shape conceptual; NOT delivered as parseable schema file.
10. No constitution edits, no schema files modified, no ADR-001/002/003/004 edits.
11. No contradiction with prior ADRs and constitution.
12. Forbidden patterns absent.
13. Open Questions enumerates explicitly out-of-scope concerns.
14. Memory-stream test: ADR-005 §D7 contains TABLE mapping each of 16 lessons.
15. Manual schema conformance (work-unit-v1).
16. **ACTIVE cross-decision consistency check** per `verification.cross_decision_consistency_active_step.pairs_to_diff` (canonical list, 7 pairs — DRY per WU-006 lesson wording_internal_contradiction).
17a. **EXISTING fields cross-check** strict-diff vs work-unit-v1 (per WU-006 lesson cross_artifact_consistency_active_check).
17b. **NEW decomposition fields** marked conceptual / schema-extension candidates (NOT claimed in work-unit-v1 schema).
18. **Within-decision wording consistency** scan per WU-006 lesson wording_internal_contradiction.

---

## APPENDIX D — Lessons applicable to wu-007 (verbatim from `.appmaker/lessons.jsonl`)

> Source: `/Users/pawel/Projects/AppMaker/.appmaker/lessons.jsonl`
> Total entries: 19
> WU-007 applicable: 16 (8 wu-005 direct + 4 broad wu-003/wu-004 + 4 fresh wu-006)

Direct wu-005 lessons (8 entries — schema_design, validator_gap, actual_usage, adr_quality,
harness_engineering, human_understanding, context_pack_as_program, verifiability_bias),
broad wu-003/wu-004 lessons (4 entries — review, adr_quality, memory_layer, review), and
fresh wu-006 lessons (4 entries — cross_decision_consistency_active_check,
cross_artifact_consistency_active_check, wording_internal_contradiction,
supersedes_pattern_for_correction_events) are stored in lessons.jsonl as JSONL.

For brevity, full JSON not duplicated here (already cited verbatim in WU-005 and WU-006
context-packs per WU-005 lesson context_pack_as_program — Software 3.0 discipline includes
not bloating context unnecessarily). Executor must read lessons.jsonl directly via:
`grep '"source_work_unit":"wu-005"\|"source_work_unit":"wu-006"' .appmaker/lessons.jsonl`
plus broad lessons (wu-003 review/adr_quality, wu-004 memory_layer/review).

How each is applied is documented in §12 above (16-row table).

---

**End of context pack.** Total ADR-005 + mapping append authoring estimated 2-3 hours. Output draft path: `.appmaker/work-units/wu-007/runs/<timestamp>/output.md` (ADR-005) and `.../matt-pocock-pattern-mapping-entry.md` (mapping append draft). On promote: ADR-005 to `decisions/`, mapping append integrated into `docs/reference/matt-pocock-pattern-mapping.md` (existing 3 entries unchanged + new 4th entry).
