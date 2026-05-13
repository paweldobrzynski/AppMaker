# Context Pack — WU-006: ADR-004 PRD Synthesis (to-prd from Matt Pocock skills)

> **R8 compliance statement.** Per `constitution.md` v2 Rule R8, this pack contains:
>
> - **Constitution v2** — Appendix A (critical excerpts inline; full at `/Users/pawel/Projects/AppMaker/constitution.md`, 18 rules including R18)
> - **ADR-001 / ADR-002 / ADR-003 relevant decisions** — Appendix B (relevant decisions quoted; full files at `decisions/`)
> - **WU-006 acceptance criteria (verbatim, 15)** — Appendix C
> - **Lessons applicable to wu-006 (verbatim, 12)** — Appendix D
>
> R8 v1 compliance for manual packs satisfied by including critical excerpts inline plus
> absolute path. Lessons inclusion mandatory per WU-006 acceptance criterion #4 (memory-stream
> test) and per Codex's directive that lessons must demonstrably influence design, not be
> name-dropped.
>
> **Per Codex's WU-006 directive: NARROW.** ADR-004 covers ONLY to-prd pattern. Does NOT mix
> decomposition (ADR-005), safety hooks (ADR-006), implementation runner (ADR-007), bug
> workflow (ADR-008), architecture review (ADR-009). These are explicit out-of-scope.
>
> **Per Codex's final fact-check note:** 12 lessons inform PRD shape and review discipline;
> they MUST NOT inflate ADR-004 with new scope or new ADR features.

---

## 1. Goal (recap from work-unit.yaml)

Produce **ADR-004 PRD Synthesis** (primary) + **append exactly 1 entry to
matt-pocock-pattern-mapping.md** (secondary). ADR-004 establishes PRD as
lifecycle stage between Interview Phase (ADR-002) and Work_unit Decomposition
(ADR-005, future).

PRD bridges: Interview reduces ambiguity → `interview-result.yaml` (structured
input); PRD Synthesis turns that into a product-level reference document that
downstream work_units (decomposition, implementation) read as their
"what-to-build" source of truth.

Inspiration: Matt Pocock `/to-prd` skill. AppMaker adapts as inspiration source,
NOT runtime dependency (per ADR-002 §D5 attribution policy + ADR-001 §D12
adapter selection + WU-005 lesson harness_engineering: invest in harness,
not external dependency).

WU-006 is **first WU authored under work-unit-v1 schema** (manual structural
conformance check; automatic validator deferred per ADR-003 §D4 + OQ-1).

---

## 2. What ADR-004 IS (and is NOT)

**IS:**
- Architectural decision record per `adr-v1` schema (12 sections, promoted in WU-005)
- Multi-output WU primary artifact (paired with mapping doc append)
- Decisive about 7 sub-decisions D1-D7 with rationale + ≥3 killed alternatives total
- Explicit about how PRD relates to interview-result.yaml (inputs), ADR (architectural decisions), implementation plan (work_unit decomposition outputs)
- Mandates PRD Understanding section with 7 named subsections (per WU-005 lesson human_understanding)
- Within-bounds: 250–550 lines markdown
- Codex's to-prd recommendation noted as context, not mandate (executor evaluates and justifies)

**IS NOT:**
- Decomposition design (ADR-005, future)
- Safety hooks design (ADR-006, future)
- Implementation runner design / TDD pattern (ADR-007, future)
- Bug workflow design / diagnose pattern (ADR-008, future)
- Architecture review design (ADR-009, future)
- Design Exploration Stage / Open Design integration (future ADR-NNN candidate; PRD-driven and Open Design-inspired but no runtime dependency, no prototype generation, no design-system catalog, no UI artifacts in WU-006)
- Validator implementation (ADR-003 OQ-1 deferred)
- Constitution amendment (no R18 modification, no new rules)
- Schema modification (work-unit-v1, interview-result-v1, adr-v1 immutable in this WU)
- Code change (no `.ts`, `.json`, `.sql`)

---

## 3. Decision Points — 7 to resolve in ADR-004

Verbatim from `work-unit.yaml.decisions_to_resolve`:

### D1. PRD definition (vs ADR vs implementation plan)

What IS a PRD in AppMaker context? What does it answer, what does it
explicitly NOT answer? How does it differ from:
- **ADR**: captures structural decisions (the *how* of architecture, with alternatives)
- **Implementation plan**: slicing of work into vertical work_units (the *who-does-what-when*)

PRD is **product-level what-to-build reference**. Audience: humans reading what
the project will deliver, plus downstream agents producing decomposition.

### D2. PRD location and format (with mandatory Understanding section)

Candidates for location:
- (a) `.appmaker/prd.md` (single project-level)
- (b) `.appmaker/product/prd.md` (under product subdirectory)
- (c) `.appmaker/prds/<feature-id>.md` (per-feature)
- (d) embedded as expanded section in interview-result.yaml

Pick one default with rationale; ≥3 alternatives go to killed.

**MANDATORY (regardless of location): PRD shape includes Understanding section
with 7 named subsections** (per WU-005 lesson human_understanding):

1. **users / buyers / operators** — who will use, pay for, operate the product
2. **domain invariants** — facts that MUST hold; cross-cutting business rules
3. **identity model** — how users, accounts, organizations relate (prevents Stripe-email=Google-email confusion)
4. **trust boundaries** — what the system trusts vs what it verifies
5. **non-delegable human judgments** — decisions that humans must own (taste, ethics, legal, strategic)
6. **verifiable success criteria** — each criterion auto-check OR human-review-with-explicit-criteria; unverifiable requirements turned into verifiable proxies (per WU-005 lesson verifiability_bias)
7. **failure modes / unacceptable outcomes** — what the system MUST NOT produce, what catastrophic states look like

### D3. When does PRD emerge?

Triggered after `interview-result.yaml` has `readiness.status` in `{ready,
ready_with_override}`; before any work_unit decomposition (ADR-005 future).

Specify:
- Manual command (`appmaker prd`) vs automatic on interview promote vs human-on-demand
- What happens if PRD requested before interview ready (fail-closed reject per R5)
- What happens if interview is `ready_with_override` (PRD inherits ambiguities — see D6)

### D4. Is PRD a required gate before to-issues (decomposition)?

Most likely YES per discipline (work_unit decomposition without product-level
reference produces drifting features). But this is the place to decide
explicitly.

If yes, define gate semantics: PRD must exist with status ACCEPTED before
decomposition WUs can be created.

### D5. How does PRD consume interview-result.yaml?

Field-by-field input mapping. PRD pulls from interview's `problem`, `scope`,
`product`, `technical`, `risks` blocks; PRD elaborates these into product-level
prose (workflows, user stories, acceptance criteria for product capabilities).

**Consumption rule**: every interview field must be either explicitly addressed
in PRD or explicitly noted as out-of-PRD-scope. No silent omission.

### D6. ready_with_override behavior in PRD

Per ADR-002 §D6, interview's `unresolved_ambiguities[]` propagate to downstream
context-packs. PRD specifically:
- MUST inherit `unresolved_ambiguities[]` (PRD has its own copy or references interview's by id)
- MUST surface them in a dedicated section (so product-level reading exposes them)
- MUST NOT silently resolve them (per R12 no silent fallbacks)

Specify: where in PRD do unresolved_ambiguities surface, what gate behavior
PRD has when interview was `ready_with_override`.

### D7. Matt Pocock attribution + lessons-derived fields explicit mapping

Combined housekeeping:

(a) **Attribution per ADR-002 §D5 model**:
- Inline in PRD prompt source (when AppMaker eventually authors the PRD prompt as a skill)
- Row in `matt-pocock-pattern-mapping.md` (this WU adds it)
- Pinned commit hash: `b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8` (per ADR-002 D5 + matt-pocock-pattern-mapping.md)
- Exact SKILL.md path: `skills/engineering/to-prd/SKILL.md`

(b) **Memory-stream test — TABLE mapping each of 12 lessons to concrete elements**:
- PRD shape constraint (Understanding subsection, success criterion verifiability, ambiguity propagation)
- Gate semantics (D4 PRD-required-before-decomposition)
- ADR-004 self-check item (cross-decision consistency, fact-check, wording scan)
- Mapping doc entry shape

Table format mandatory per WU-005 lesson adr_quality (cross-check claims against
actual artifacts).

---

## 4. Matt Pocock `/to-prd` — full SKILL.md content (with attribution)

**Source:** Matt Pocock Skills, MIT License, Copyright (c) 2026 Matt Pocock,
https://github.com/patjfree/Matt_Pocock_Skills
**Local path:** `/Users/pawel/Projects/Matt_Pocock_Skills/skills/engineering/to-prd/SKILL.md`
**Pinned commit hash:** `b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8` (2026-04-30)

```markdown
---
name: to-prd
description: Turn the current conversation context into a PRD and publish it to the project issue tracker. Use when user wants to create a PRD from the current context.
---

This skill takes the current conversation context and codebase understanding and produces a PRD. Do NOT interview the user — just synthesize what you already know.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-matt-pocock-skills` if not.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the PRD, and respect any ADRs in the area you're touching.

2. Sketch out the major modules you will need to build or modify to complete the implementation. Actively look for opportunities to extract deep modules that can be tested in isolation.

A deep module (as opposed to a shallow module) is one which encapsulates a lot of functionality in a simple, testable interface which rarely changes.

Check with the user that these modules match their expectations. Check with the user which modules they want tests written for.

3. Write the PRD using the template below, then publish it to the project issue tracker. Apply the `needs-triage` triage label so it enters the normal triage flow.

<prd-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this PRD.

## Further Notes

Any further notes about the feature.

</prd-template>
```

**Key concepts AppMaker adopts:**
- "Do NOT interview the user — just synthesize what you already know" — perfectly aligned: PRD comes AFTER interview-result.yaml exists; PRD does not re-prompt the user
- "Use the project's domain glossary vocabulary throughout the PRD" — informs PRD shape: must reference brownfield glossary if `interview-result.yaml.existing_codebase.glossary_terms_*` populated
- "Respect any ADRs in the area you're touching" — informs cross-reference discipline (PRD does not contradict ADR-001/002/003)
- PRD template (Problem Statement, Solution, User Stories, Implementation Decisions, Testing Decisions, Out of Scope, Further Notes) — usable foundation; AppMaker prepends Understanding section per WU-005 lesson human_understanding
- "Deep module" concept — design hint that informs decomposition WU (ADR-005, future), not PRD itself

**Key concepts AppMaker adapts (does NOT copy verbatim):**
- "Publish to the project issue tracker" — AppMaker has no built-in issue tracker dependency in v1; PRD lives in `.appmaker/` (D2 decides exact path); future ADR-NNN may integrate issue trackers
- "Check with the user which modules they want tests written for" — replaced by ADR-004 D5 (consume interview-result.yaml) + D7 (lessons mapping including verifiability_bias)
- PRD template — AppMaker extends with mandatory Understanding section (7 subsections) per WU-005 lesson human_understanding; success criteria must be verifiable per WU-005 lesson verifiability_bias

---

## 5. Codex's to-prd recommendation (context, not mandate)

Codex did not provide a hard recommendation for to-prd format the way they did for JSON Schema in WU-005. Their guidance was structural:

- **Narrow scope**: WU-006 covers ONLY to-prd; no decomposition, no hooks, no TDD, no diagnose, no architecture review (each is a separate future ADR)
- **Lessons must inform shape, not inflate scope**: 12 wu-006-applicable lessons map to PRD shape constraints OR review discipline OR ADR-004 self-check items — NOT to new ADR decisions or new ADR features
- **Manual schema conformance**: WU-006 work-unit.yaml is first WU under work-unit-v1 schema; conformance checked manually until validator implemented (ADR-003 OQ-1)
- **Specific decisions to resolve** (Codex's 6 user concerns, mapped to D1-D7 in WU-006 contract):
  - kiedy PRD powstaje (D3)
  - gdzie żyje PRD (D2 location)
  - czy PRD jest required gate przed to-issues (D4)
  - jak PRD używa interview-result.yaml (D5)
  - co przy ready_with_override (D6)
  - jak PRD różni się od ADR i implementation planu (D1)

**Executor's task:** evaluate Matt Pocock's PRD template against AppMaker's needs (with Understanding section requirement); pick PRD location (D2); decide gate semantics (D4); justify each decision in ADR-004 with ≥3 killed alternatives total.

---

## 6. Understanding section requirement (per WU-005 lesson human_understanding)

The 7 subsections AppMaker mandates for any PRD shape (D2 outcome):

| Subsection | Purpose | Anti-pattern prevented |
|---|---|---|
| **users / buyers / operators** | Distinguish who uses, who pays, who runs | "User" as undifferentiated mass; missing operator concerns |
| **domain invariants** | Facts that MUST hold; cross-cutting business rules | Silent assumption inheritance; invariant violations discovered in production |
| **identity model** | How users, accounts, organizations relate | Stripe-email = Google-email confusion; missing org/user distinction |
| **trust boundaries** | What system trusts vs verifies | Treating user input as trusted; treating external API as oracle |
| **non-delegable human judgments** | Decisions humans must own | Agent silently making taste/legal/strategic call |
| **verifiable success criteria** | Auto-check OR human-review-with-criteria | "Beautiful UI" without proxy (screenshot review, layout check, accessibility audit, workflow completion) |
| **failure modes / unacceptable outcomes** | What system MUST NOT produce | Missing red-line constraints; silent acceptance of catastrophic state |

The `verifiable success criteria` subsection enforces WU-005 lesson
verifiability_bias: every PRD success criterion is either auto-check OR
human-review with named criteria. Unverifiable requirements (e.g., "feels
right") are turned into verifiable proxies or explicitly marked as
human-judgment per WU-005 lesson human_understanding.

---

## 7. Required output structure

### ADR-004 (primary, per `adr-v1` schema)

12 sections (per `.appmaker/schemas/adr-v1.schema.json`):

1. **Status** — DRAFT initially; flips to ACCEPTED on promote
2. **Metadata** — date, authors, type (investigation), supersedes/superseded-by
3. **Context** — why PRD Synthesis now, how it relates to ADR-001/002/003
4. **Sources Consulted** — Codex multiple rounds, Matt Pocock to-prd, lessons.jsonl, ADR-001/002/003, constitution v2
5. **Decision (numbered)** — D1 through D7 each with Why + How/Implications. D7 includes the 12-row lessons-mapping table.
6. **Killed Alternatives** — at least 3, each with reason
7. **Risks and Mitigations** — table
8. **Rollback Plan** — soft + hard
9. **Open Questions** — what ADR-004 deliberately defers (per Codex narrow scope: decomposition, hooks, TDD, diagnose, architecture review; per WU-005: validator implementation, schema migration, future Verifiability Standards ADR, future Context-Pack Schema ADR, future Agent-Native Project Interface ADR)
10. **Acceptance Criteria** — self-check that ADR-004 itself meets verification
11. **Verification** — table mapping required sections to present/absent
12. **Revision History** — initial draft + future amendments

### Mapping doc append (secondary)

ADD exactly ONE row to `docs/reference/matt-pocock-pattern-mapping.md` (per
WU-003 append-oriented convention):

```
| Field | Value |
|---|---|
| source_skill | Matt_Pocock_Skills/skills/engineering/to-prd/SKILL.md |
| source_commit | b843cb5ea74b1fe5e58a0fc23cddef9e66076fb8 (2026-04-30) |
| license | MIT |
| adr_reference | ADR-004 |
| appmaker_pattern | PRD Synthesis |
| surface | lifecycle |
| output_artifact | .appmaker/prd.md (or per D2 outcome) + Understanding section (AppMaker extension) |
| notes | Adapted from Matt's to-prd. AppMaker adds: Understanding section with 7 subsections per lesson human_understanding; verifiable success criteria per lesson verifiability_bias; consumes interview-result.yaml as input (no re-interviewing) per ADR-002 D1 + ADR-004 D5; no built-in issue tracker dependency in v1 (D2 location is .appmaker/-managed). |
```

Existing 2 entries (grill-me, grill-with-docs) MUST remain textually unchanged
(diff verification before VERIFIED).

---

## 8. Forbidden patterns

ADR-004 prose MUST NOT contain (per WU-002 precedent + adr-v1.schema.json `forbidden_patterns: required` field):
- `TBD`
- `TODO`
- `...` (bare ellipsis as hand-waving; ellipsis inside concrete code-context placeholders is the only allowed exception)

Mapping doc append entry text similarly.

If a forbidden pattern is needed in instructional context (e.g., listing what
is forbidden), paraphrase to avoid the literal token.

---

## 9. Bounds

- **ADR-004:** 250–550 lines markdown
- **Mapping doc append:** 1 row added (~10 lines including blank lines around table); existing 2 entries unchanged

---

## 10. Self-check before declaring WU-006 ready

Before flipping work-unit.yaml `IN_PROGRESS` → `VERIFIED`:

- [ ] ADR-004 has all 12 required sections in declared order (per adr-v1)
- [ ] D1, D2, D3, D4, D5, D6, D7 each resolved with explicit decision and rationale
- [ ] At least 3 killed alternatives total
- [ ] D2 PRD shape MANDATES Understanding section with 7 named subsections (users/buyers/operators, domain invariants, identity model, trust boundaries, non-delegable human judgments, verifiable success criteria, failure modes / unacceptable outcomes)
- [ ] D5 specifies field-by-field interview-result.yaml consumption rule
- [ ] D6 specifies unresolved_ambiguities propagation mechanism
- [ ] D7 contains a TABLE mapping each of 12 lessons to one or more concrete elements
- [ ] Matt Pocock attribution: link, MIT license, author, exact SKILL.md path, pinned commit hash
- [ ] Mapping doc append: 1 new row with 7 required fields; existing 2 entries diff-verified unchanged
- [ ] No edits to ADR-001, ADR-002, ADR-003, constitution.md, schemas
- [ ] No new files outside scope (only ADR-004 + mapping append)
- [ ] No `TBD`, no `TODO`, no bare `...`
- [ ] Length: ADR-004 ≤ 550 and ≥ 250
- [ ] No contradiction with ADR-001 §§D2, D2a, D3, D11, D12; ADR-002 D1-D7; ADR-003 D1-D5; constitution v2 R1, R8, R12, R13, R18
- [ ] Cross-section consistency: ADR-004 §Decision-D1 / §D2 / §D3 / §D4 / §D5 / §D6 / §D7 / §Risks / §Open Questions all coherent
- [ ] Out-of-scope explicit: no decomposition (ADR-005), no hooks (ADR-006), no TDD (ADR-007), no diagnose (ADR-008), no architecture review (ADR-009)
- [ ] Roadmap placeholders for ADR-NNN Agent-Native Project Interface, Verifiability Standards, Context-Pack Schema mentioned in §Open Questions
- [ ] Codex's to-prd guidance cited (whether adopted or adapted, with reasoning)

---

## 11. Out-of-scope reminders (NARROW per Codex/user directive)

The executor MUST NOT:

- Design or specify decomposition (ADR-005, future) — even though to-prd's "deep module" concept hints at decomposition, ADR-004 mentions it only as future ADR
- Design or specify safety hooks (ADR-006, future) — even though git-guardrails would help PRD-edit safety, ADR-004 defers
- Design or specify implementation runner / TDD pattern (ADR-007, future)
- Design or specify bug workflow / diagnose pattern (ADR-008, future)
- Design or specify architecture review (ADR-009, future)
- Design or specify Design Exploration Stage / Open Design integration — future ADR-NNN candidate only; ADR-004 may NOTE Design Exploration Stage as future ADR in §Open Questions (Open Design-inspired, PRD-driven), but WU-006 does NOT adopt Open Design as runtime dependency, does NOT generate prototypes, does NOT define a design-system catalog, does NOT produce any UI artifact
- Implement validator (ADR-003 OQ-1 deferred)
- Edit ADR-001 / ADR-002 / ADR-003 (immutable)
- Edit constitution.md (amendments via dedicated WU only)
- Edit schemas v1 (immutable)
- Add fields to interview-result-v1 schema (out of scope; would require schema amendment WU)
- Implement PRD prompt as a skill (deferred to future skill-authoring WU)
- Build PRD authoring tooling (CLI command implementation deferred)
- Trigger or call any external service (no issue tracker integration in v1)
- Run `git commit`, `git push`, `git clone`, `npm install`, `rm -rf` (per R14)

---

## 12. Lessons stream application (memory-stream test, per Codex directive)

The full text of all 12 wu-006-applicable lessons is in Appendix D. This
section names how each lesson concretely shapes WU-006's design and
execution, satisfying acceptance criterion #4.

**Per Codex's final note:** lessons inform PRD shape and review discipline,
NOT new ADR decisions. Mapping table below stays within established scope.

### Direct wu-005 lessons (8) — load-bearing for PRD shape OR ADR-004 self-check

| # | Lesson | Concrete element in WU-006 / ADR-004 |
|---|---|---|
| L1 | wu-005 / schema_design | secondary_artifacts_policy declared in WU-006 verification block; mapping append covered explicitly |
| L2 | wu-005 / validator_gap | validator_tooling_preflight in WU-006 contract; ADR-004 does not pretend meta-validation; manual schema conformance for work-unit.yaml |
| L3 | wu-005 / actual_usage | WU-006 work-unit.yaml structurally cross-checked against work-unit-v1.schema.json (passed: 24 top-level keys, mixed string/object required_pass, lessons_applied populated) |
| L4 | wu-005 / adr_quality | ADR-004 §D7 mapping table cross-checked against actual artifacts (mapping doc entry must match); cross_decision_consistency review scorecard field for ADR-004 D1-D7 |
| L5 | wu-005 / harness_engineering | WU-006 invests in harness (manual schema conformance discipline, lessons traceability, gates) — not in chasing model upgrades; D4 (PRD-required gate) is harness investment |
| L6 | wu-005 / agentic_engineering / human_understanding | **PRD shape D2: Understanding section MANDATORY with 7 subsections.** Stripe-email=Google-email anti-pattern explicitly prevented |
| L7 | wu-005 / agentic_engineering / context_pack_as_program | **This pack itself is the test:** structured as Software 3.0 program (R8 inclusions, lessons traceability, scope, forbidden_patterns mention, self-check). Future ADR-NNN Context-Pack Schema deferred per roadmap |
| L8 | wu-005 / agentic_engineering / verifiability_bias | **PRD shape D2 Understanding subsection 6: verifiable success criteria.** Each criterion auto-check OR human-review-with-criteria; unverifiable → verifiable proxies |

### Broad lessons from wu-003/wu-004 (4) — review discipline

| # | Lesson | Concrete element in WU-006 / ADR-004 |
|---|---|---|
| L9 | wu-003 / review | §10 self-check is granular checklist; pre-execution external-state fact-check (Matt to-prd path, commit hash, schema fields); wording-consistency scan between ADR-004 §D1 ↔ §D3 ↔ §D7 |
| L10 | wu-003 / adr_quality | cross_decision_consistency check for ADR-004 D1-D7 (7 sub-decisions = potential cross-decision contradictions; mandatory review scorecard field) |
| L11 | wu-004 / memory_layer | **lessons_applied field populated in this WU contract** with 12 entries; WU-006 demonstrates that lessons.jsonl actually informs design (not name-dropped) |
| L12 | wu-004 / review | adr-v1 schema enforces forbidden_patterns; ADR-004 must contain zero TBD, zero TODO, zero bare ellipsis (parser-grep self-check before VERIFIED) |

**Memory-stream test outcome (executor must verify in WU-006 output):**
ADR-004 §D7 contains a TABLE with 12 rows mapping each lesson to specific
elements. If any lesson is not mapped to at least one concrete element in
ADR-004 (PRD shape constraint, gate semantics, self-check item, mapping doc
field), the WU is REJECTED. Per Codex: lessons map to existing scope, not new
scope.

---

## APPENDIX A — Constitution v2 (R8 inclusion: critical excerpts + full-file reference)

> Source: `/Users/pawel/Projects/AppMaker/constitution.md` (AMENDED, 2026-05-09; 395 lines, 18 rules)

### Critical rules directly affecting WU-006:

**R1.** ADRs require ≥3 alternatives, killed options, risks with mitigations. *(ADR-004 must comply.)*

**R5.** Gates fail closed. Three layers: rule, config, hook. *(WU-006 promote_gate uses fail-closed enum for secondary_artifacts.status; D3 PRD trigger is fail-closed if interview not ready.)*

**R7.** Machine-readable artifacts must pass parser/lint validation before VERIFIED. *(WU-006 work-unit.yaml passed PyYAML + Ruby Psych; ADR-004 markdown structure-validated.)*

**R8.** Every context-pack includes constitution, relevant recent ADRs, work_unit acceptance criteria. *(This pack complies via Appendices A, B, C; lessons inclusion in D goes beyond R8 minimum per Codex directive.)*

**R12.** No silent fallbacks. *(ADR-004 D6 explicit propagation rule for ready_with_override; D5 explicit consumption rule — every interview field addressed or noted out-of-scope.)*

**R13.** Every work_unit reduces uncertainty or delivers verified change. *(WU-006 reduces uncertainty about PRD shape and lifecycle; produces ADR-004 + mapping append as verified artifacts.)*

**R14.** Agents may not git push/commit/rm-rf/publish/deploy. *(blocked_actions enforces.)*

**R17.** Constitution stays under 25 rules. *(N/A — WU-006 doesn't amend constitution.)*

**R18.** Every project begins with Interview Phase producing `.appmaker/interview-result.yaml` with readiness in {ready, ready_with_override}. *(ADR-004 D3 builds on this: PRD comes AFTER interview ready.)*

**Full text of all 18 rules:** load `/Users/pawel/Projects/AppMaker/constitution.md` before drafting ADR-004.

---

## APPENDIX B — ADR-001 + ADR-002 + ADR-003 relevant decisions (R8 inclusion)

### From ADR-001:

**D2 — Process Kernel + work_unit primitive.** *(WU-006 is investigation work_unit per this primitive.)*

**D2a — work_unit type: investigation | implementation.** *(WU-006 is investigation; verification by artifact_schema = adr-v1 + structural checks.)*

**D3 — 6-file project model.** *(D2 of WU-006 PRD location follows .appmaker/-managed pattern for kernel-generated artifacts.)*

**D11 — Three-stream logging.** *(WU-006 promote produces events.jsonl entry; lessons.jsonl consulted for context-pack; decisions.jsonl not yet active.)*

**D12 — Adapter selection.** *(Matt Pocock to-prd is inspiration source, NOT runtime adapter; per ADR-002 §D5 attribution model.)*

**D13 — Gates fail closed.** *(D3 PRD trigger gate inherits this; D4 PRD-required-before-decomposition is a fail-closed gate.)*

### From ADR-002:

**D1 — Interview required first lifecycle stage.** *(ADR-004 D3 builds on: PRD comes AFTER Interview is ready.)*

**D5 — Matt Pocock attribution policy.** *(ADR-004 D7 reuses this: inline + mapping doc + pinned commit hash.)*

**D6 — `ready_with_override` propagation.** *(ADR-004 D6 inherits and extends to PRD: unresolved_ambiguities must surface in dedicated PRD section.)*

**D7 — Greenfield vs brownfield variants.** *(ADR-004 may need to address: brownfield PRD references existing codebase glossary from interview's existing_codebase block; greenfield PRD does not.)*

### From ADR-003:

**D1 — JSON Schema canonical.** *(WU-006 work-unit.yaml conforms to work-unit-v1.schema.json manually.)*

**D4 — Validation conformance: parser + structural at v1; meta-schema deferred.** *(WU-006 honors this: no meta-validation pretense; manual schema conformance check.)*

**D5 — Lessons-derived fields mapping table.** *(ADR-004 D7 inherits the pattern: 12-row lessons mapping table mandatory per memory-stream test.)*

**Full text of all three ADRs:** load before drafting ADR-004.

---

## APPENDIX C — WU-006 acceptance criteria (verbatim)

> Source: `/Users/pawel/Projects/AppMaker/.appmaker/work-units/wu-006/work-unit.yaml`

15 acceptance criteria from `work-unit.yaml.acceptance_criteria`:

1. ADR-004 resolves all 7 decisions D1–D7 with rationale and ≥3 killed alternatives total.
2. ADR-004 has all 12 required adr-v1 sections per `.appmaker/schemas/adr-v1.schema.json`.
3. ADR-004 length 250–550 lines.
4. ADR-004 explicitly cites all 12 wu-006-applicable lessons (8 wu-005 direct + 4 broader); for each, ADR shows which artifact element operationalizes the lesson.
5. ADR-004 stays NARROW per Codex/user directive: only to-prd; no decomposition / hooks / TDD / bug workflow / architecture review.
6. Matt Pocock attribution explicit: link, MIT, author, SKILL.md path, pinned commit hash.
7. matt-pocock-pattern-mapping.md gains exactly ONE new entry with all required fields.
8. matt-pocock-pattern-mapping.md existing 2 entries unchanged (diff verification).
9. PRD shape (D2) described conceptually; NOT delivered as parseable schema file.
10. No constitution edits, no schema files modified, no ADR-001/002/003 edits.
11. No contradiction with ADR-001/002/003 referenced decisions or constitution v2 R1/R8/R12/R13/R18.
12. Forbidden patterns absent in ADR-004 prose: zero TBD, zero TODO, zero bare ellipsis.
13. Open Questions section enumerates explicitly out-of-scope concerns (decomposition, safety hooks, implementation runner, validator implementation, schema migration, Design Exploration Stage) and any deferred design choices in PRD Synthesis itself. Design Exploration Stage is Open Design-inspired and PRD-driven, but WU-006 must only record it as a future ADR candidate; no Open Design runtime dependency, prototype generation, design-system catalog, or UI artifact is adopted here.
14. Memory-stream test: ADR-004 §D7 contains TABLE mapping each of 12 lessons to concrete elements (PRD shape constraint including Understanding subsection, downstream WU validation). REJECTED if any lesson unmapped.
15. Manual schema conformance (work-unit-v1): WU-006 work-unit.yaml structurally matches schema (required fields present; promote_gate.required_pass uses mixed string|object form per WU-005 schema fix; lessons_applied present per wu-004 lesson #5; secondary_artifacts_policy present per wu-005 lesson schema_design).

---

## APPENDIX D — Lessons applicable to wu-006 (verbatim from `.appmaker/lessons.jsonl`)

> Source: `/Users/pawel/Projects/AppMaker/.appmaker/lessons.jsonl`
> Total entries: 15
> WU-006 applicable: 12 (8 wu-005 direct + 4 broader from wu-003/wu-004)

### Direct wu-005 lessons (8)

```json
{"timestamp":"2026-05-09T23:58:00Z","source_work_unit":"wu-005","category":"schema_design","lesson":"WU-005 multi-output (primary ADR-003 + 3 secondary schema files) succeeded with conditional gate logic; secondary_artifacts_policy block enables deferral path (D1 GUARD case) without making default gate unsatisfiable.","action":"Future multi-output investigation WUs MUST declare secondary_artifacts_policy with deferred_allowed_only_if conditions and explicit if_deferred propagation to gate fields.","applies_to":["future-multi-output-work-units","wu-006-prd","future-multi-output-investigations"]}

{"timestamp":"2026-05-09T23:58:00Z","source_work_unit":"wu-005","category":"validator_gap","lesson":"WU-005 declared JSON Schema meta-validator gap (ajv/jsonschema unavailable locally) and adopted parser-only validation with deferred validator implementation as a separate OQ.","action":"Whenever a WU produces format-bound artifacts, run validator_tooling_preflight first; if required validator missing, declare gap explicitly and create deferred implementation OQ; do not pretend full validation.","applies_to":["future-format-bound-work-units","wu-006-prd","future-implementation-wus","wu-NNN-validator-implementation"]}

{"timestamp":"2026-05-09T23:58:00Z","source_work_unit":"wu-005","category":"actual_usage","lesson":"WU-005 work-unit-v1 schema initially defined promote_gate.required_pass items as string-only based on author's mental model. Reality (WU-002/003/004) used Hash form; WU-005 used mixed Hash+String. Codex caught the gap by reading actual yaml files.","action":"Schema design MUST cross-reference actual existing artifacts before declaring field shapes. Do not encode mental model unchecked.","applies_to":["future-schema-design-work-units","wu-006-prd","wu-NNN-validator-implementation","future-schema-evolution"]}

{"timestamp":"2026-05-09T23:58:00Z","source_work_unit":"wu-005","category":"adr_quality","lesson":"ADR-003 D5 lessons-mapping table promised 'verification.rules_unchanged_check encoded in schema if-clause when amendment_class is present', but the schema's then-clause initially required only amendment_target.","action":"When an ADR contains a mapping table that claims specific schema fields exist or are enforced, the WU verification step MUST cross-check each table row against the actual schema file before VERIFIED.","applies_to":["future-adr-with-schema-mapping","wu-006-prd","future-multi-output-investigations","future-amendment-wus"]}

{"timestamp":"2026-05-10T00:05:00Z","source_work_unit":"wu-005","category":"harness_engineering","lesson":"AppMaker's durable asset is the harness (governance + workflow + memory layer + verification gates + safety constraints), not any single LLM model.","action":"Future optimization should target the harness — context construction, gates, traces, review loops, safety constraints, and pruning — rather than chasing model upgrades.","applies_to":["future-implementation-wus","future-strategic-decisions","wu-006-prd","wu-NNN-validator-implementation","v1.1-context-compiler","future-architecture-review"]}

{"timestamp":"2026-05-10T00:30:00Z","source_work_unit":"wu-005","category":"agentic_engineering","lesson":"Human understanding, judgment, taste, domain invariants, and trust boundaries cannot be delegated to agents; AppMaker may outsource execution but must preserve human-owned decisions. Anti-patterns prevented: Stripe email = Google email (identity confusion); UI looks 'good' without verification (taste delegation); domain invariants without humans naming them.","action":"PRD specifically must include Understanding section: users/buyers/operators, domain invariants, identity model, trust boundaries, non-delegable human judgments, verifiable success criteria, failure modes / unacceptable outcomes.","applies_to":["wu-006-prd","prd-synthesis","architecture-selection","implementation-runner","future-quality-standards","future-implementation-wus"]}

{"timestamp":"2026-05-10T00:30:00Z","source_work_unit":"wu-005","category":"agentic_engineering","lesson":"context-pack.md is executable harness logic, not passive documentation. Each context-pack is a Software 3.0 program that programs the agent's behavior for one work_unit through inclusion/exclusion of context, lessons, decisions, gates.","action":"Context-packs must have schema/checklist/bounds. v1.1 context-compiler design must formalize this.","applies_to":["wu-006-prd","v1.1-context-compiler","future-context-pack-design","future-investigation-work-units"]}

{"timestamp":"2026-05-10T00:30:00Z","source_work_unit":"wu-005","category":"agentic_engineering","lesson":"If a requirement cannot be verified, AppMaker must either turn it into a verifiable proxy or mark it as human-reviewed. Unverifiable requirements (e.g., 'beautiful UI', 'feels right') silently fail because no gate catches their absence.","action":"PRD success_criteria must be verifiable (auto-check OR human-review-with-explicit-criteria). Future ADR-NNN for Verifiability Standards when implementation/UI work surfaces concrete needs.","applies_to":["wu-006-prd","future-quality-standards","future-implementation-wus","prd-synthesis","future-architecture-review"]}
```

### Broad lessons from wu-003 / wu-004 (4)

```json
{"timestamp":"2026-05-09T15:55:00Z","source_work_unit":"wu-003","category":"review","lesson":"Codex external review caught 3 distinct fix rounds that local self-check missed: wrong Matt Pocock file paths (skill subcategory omitted), wording inconsistency between context-pack intro and Appendix A, and cross-decision contradictions (D1 skip output incompatible with D3 ready_with_override structural requirements).","action":"Pre-execution checklist must include explicit fact-check against external state (paths, commit hashes, schema references) and wording-consistency scan between document sections.","applies_to":["all-investigation-work-units","wu-004","wu-005-schema"]}

{"timestamp":"2026-05-09T15:55:00Z","source_work_unit":"wu-003","category":"adr_quality","lesson":"Multi-decision ADRs may contain hidden cross-decision contradictions invisible to per-decision self-check (concrete example: WU-003 D1 specified --skip producing minimal ready_with_override; D3 required ready_with_override to have non-empty unresolved_ambiguities[] and populated override block; both decisions individually well-formed; contradiction visible only when read together).","action":"Add cross_decision_consistency field to review_scorecard_template. Reviewer explicitly diff-checks decisions against each other for structural compatibility.","applies_to":["wu-004","wu-005-schema","future-multi-decision-adrs"]}

{"timestamp":"2026-05-09T16:50:00Z","source_work_unit":"wu-004","category":"memory_layer","lesson":"WU-004 showed lessons.jsonl is useful only when context-pack and execution output prove specific influence, not citation.","action":"Schemas should add a lessons_applied field or review checklist item for work_units consuming lessons.","applies_to":["wu-005-schema","future-investigation-work-units"]}

{"timestamp":"2026-05-09T16:50:00Z","source_work_unit":"wu-004","category":"review","lesson":"Parser/grep-style checks caught a forbidden ellipsis before VERIFIED; simple textual checks prevent governance artifacts from leaking placeholders.","action":"Schema verification should require forbidden-pattern checks for markdown governance artifacts, not only YAML/JSON parser validation.","applies_to":["wu-005-schema","future-investigation-work-units"]}
```

How direct + broad lessons are applied is documented in §12 above.

---

**End of context pack.** Total ADR-004 + mapping doc append authoring estimated 2–3 hours. Output draft path: `.appmaker/work-units/wu-006/runs/<timestamp>/output.md` (ADR-004) and `.../matt-pocock-pattern-mapping-entry.md` (mapping append draft). On promote: ADR-004 to `decisions/`, mapping append integrated into `docs/reference/matt-pocock-pattern-mapping.md` (existing 2 entries unchanged + new 3rd entry).
