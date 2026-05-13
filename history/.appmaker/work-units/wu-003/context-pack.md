# Context Pack — WU-003: Draft ADR-002 Interview Phase as First Lifecycle Stage

> **R8 compliance statement.** Per `constitution.md` Rule R8 ("Every
> `context-pack.md` includes the constitution, the relevant recent ADRs,
> and the work_unit's acceptance criteria"), this pack contains:
>
> - **Constitution** — Appendix A (critical excerpts inline; full accepted file referenced at `/Users/pawel/Projects/AppMaker/constitution.md`)
> - **ADR-001 relevant decisions** — Appendix B (relevant decisions quoted in full; full accepted file referenced at `/Users/pawel/Projects/AppMaker/decisions/ADR-001-process-kernel-architecture.md`)
> - **WU-003 acceptance criteria (verbatim)** — Appendix C
>
> R8 v1 compliance for manual packs is satisfied by including critical
> excerpts inline plus an absolute path to the accepted file; ADR-NNN /
> WU-005 may tighten this once context-compiler behavior is formalized.
>
> Pre-constitution exception (used by WU-002 only) is **expired**. WU-003 is
> the first work_unit operating under fully-active constitution.
>
> This pack also includes Matt Pocock skill source content per WU-003 scope.

---

## 1. Goal (recap from work-unit.yaml)

Produce **ADR-002 — Interview Phase as First Lifecycle Stage** as a single,
narrowly-scoped Architectural Decision Record. ADR-002 must:

- Resolve all 7 decision points (D1–D7) listed in §3
- Document at least 3 killed alternatives
- Properly attribute Matt Pocock's `/grill-me` and `/grill-with-docs` as
  inspiration sources without creating a runtime dependency
- Stay within scope: **no schema files, no constitution edits, no code**

Secondary output: `docs/reference/matt-pocock-pattern-mapping.md` with
exactly two entries (`grill-me`, `grill-with-docs`) — append-oriented
ledger, not audit-log strict.

---

## 2. What ADR-002 IS (and is NOT)

**IS:**
- Architectural decision record per `artifact_schema: adr-v1`
- Narrow: only Interview Phase concerns
- Self-contained — readable without prior context (cite ADR-001, constitution)
- 250–550 lines markdown

**IS NOT:**
- Schema implementation (defer to WU-005 — `interview-result-v1` schema)
- Constitution amendment (defer to WU-004)
- CLI implementation (only conceptual command shape)
- Pattern mapping for all Matt Pocock skills (only 2 here; rest at future ADRs)
- Source for code, JSON, or SQL artifacts

---

## 3. Decision Points — 7 to resolve in ADR-002

These are verbatim from `work-unit.yaml.decisions_to_resolve` (Codex directive).

### D1. Is Interview the required first lifecycle stage of every AppMaker project, or optional?

Suggested resolution direction (executor's choice, justify in ADR):
- Required for greenfield, optional for brownfield migrations of existing repos
- Or: required for all projects, with `--skip-interview` requiring break-glass

### D2. Where does `interview-result.yaml` live?

Three candidates to evaluate:
- (a) Project root (extends 6-file model to 7-file)
- (b) `.appmaker/interview-result.yaml` (kernel-managed)
- (c) `.appmaker/work-units/wu-001-interview/runs/<timestamp>/output.yaml` (interview is itself a work_unit)

ADR-002 must pick one with rationale.

### D3. Readiness enum gate semantics

Codex's proposed enum (verbatim, accepted):
- `ready` → can plan normally; downstream work_units proceed
- `needs_more_input` → fail-closed; loop back to interview
- `reject` → do not create project / workflow; user decided this scope is wrong
- `ready_with_override` → proceed, BUT downstream context-packs MUST surface unresolved ambiguities

ADR-002 must define each state's gate behavior, including how `ready_with_override` is invoked (human-only, per analogy to R6 break-glass).

### D4. Lifecycle command pattern

Three candidates:
- (a) `appmaker init --minimal` → `appmaker interview` → `appmaker init --complete`
- (b) `appmaker start` (combined: minimal init + interview + advise + complete)
- (c) `appmaker init` → `appmaker interview` (no `--minimal` flag, init creates `.appmaker/` but does not freeze profile)

ADR-002 must pick a default with rationale; alternatives go to killed alternatives.

### D5. Matt Pocock attribution policy

How does `/grill-me` and `/grill-with-docs` inspire AppMaker's Interview prompt without becoming a runtime dependency?

ADR-002 must specify:
- Where attribution lives (inline in interview prompt? in mapping doc? in LICENSE/NOTICE?)
- Adaptation policy (we adapt, not copy verbatim — what constitutes "adaptation" vs "derivative work" under MIT?)
- What happens if Matt's skills upgrade — do we re-sync? Or pin to git commit hash?

### D6. `ready_with_override` propagation to downstream context-packs

Concrete mechanism with worked example:
- `interview-result.yaml.unresolved_ambiguities[]` lists each ambiguity
- Context-compiler injects this list into every downstream work_unit's context-pack as a dedicated section
- Each downstream work_unit's review scorecard includes a "did we accidentally rely on an unresolved ambiguity?" check
- Or: another mechanism executor invents

### D7. Greenfield vs brownfield variants

`appmaker interview` (greenfield: pure grill-me-style) vs `appmaker interview --with-docs` (brownfield: + glossary extraction + ADR mining from existing code/docs).

ADR-002 must specify:
- What inputs differ (none for greenfield; existing repo for brownfield)
- What prompts differ (greenfield does not challenge against glossary because no glossary exists)
- What outputs differ (brownfield additionally produces `glossary.md` and ADR candidates)

---

## 4. Matt Pocock Skills — source content (full quote with attribution)

**Source:** Matt Pocock Skills, MIT License, Copyright (c) 2026 Matt Pocock,
https://github.com/patjfree/Matt_Pocock_Skills

**Local path:** `/Users/pawel/Projects/Matt_Pocock_Skills/`

**License compatibility:** MIT permits adaptation, modification, redistribution
provided the LICENSE notice is included. AppMaker will include attribution in
ADR-002 itself plus a row in `docs/reference/matt-pocock-pattern-mapping.md`.

### 4.1 `/grill-me` — full SKILL.md content

```markdown
---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.
```

**Source path:** `/Users/pawel/Projects/Matt_Pocock_Skills/skills/productivity/grill-me/SKILL.md`

**Key concepts AppMaker adopts:**
- "Interview relentlessly until shared understanding" — drives `readiness.status: ready`
- "Walk each branch of the decision tree" — structured probing, not free-form chat
- "Resolve dependencies between decisions one-by-one" — sequential ordering
- "For each question, provide your recommended answer" — agent gives an opinion, not just probes
- "Ask one at a time" — UX discipline; no overwhelming questionnaires
- "If answerable by codebase exploration, explore instead" — directly relevant for brownfield (D7)

### 4.2 `/grill-with-docs` — full SKILL.md content

```markdown
---
name: grill-with-docs
description: Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates documentation (CONTEXT.md, ADRs) inline as decisions crystallise. Use when user wants to stress-test a plan against their project's language and documented decisions.
---

<what-to-do>

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead.

</what-to-do>

<supporting-info>

## Domain awareness

During codebase exploration, also look for existing documentation:

### File structure

Most repos have a single context: CONTEXT.md, docs/adr/.

If a CONTEXT-MAP.md exists, the repo has multiple contexts.

Create files lazily — only when you have something to write. If no CONTEXT.md exists, create one when the first term is resolved. If no docs/adr/ exists, create it when the first ADR is needed.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in CONTEXT.md, call it out immediately.

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term.

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it.

### Update CONTEXT.md inline

When a term is resolved, update CONTEXT.md right there. Don't batch.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:
1. Hard to reverse — the cost of changing your mind later is meaningful
2. Surprising without context — a future reader will wonder "why did they do it this way?"
3. The result of a real trade-off — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR.

</supporting-info>
```

**Source path:** `/Users/pawel/Projects/Matt_Pocock_Skills/skills/engineering/grill-with-docs/SKILL.md`

**Key concepts AppMaker adopts (additional to grill-me):**
- "Challenge against existing glossary" — brownfield variant input
- "Sharpen fuzzy language" — output: canonical term proposals → glossary.md
- "Cross-reference with code" — agent has codebase access, can verify claims
- "Update CONTEXT.md inline" — domain glossary as living artifact
- "Offer ADRs sparingly" with 3-criteria filter — relevant for D5 (when does interview produce ADR candidates vs leaves them implicit?)

**Note on adaptation:** AppMaker's Interview will adapt these prompts, not copy verbatim. Specifically:
- Add `interview-result.yaml` as structured output (Matt's skills produce free-form conversation outcomes)
- Add readiness gate (Matt's skills assume the human stops when satisfied)
- Add `ready_with_override` mechanism (Matt's skills don't formalize ambiguity persistence)

### 4.3 LICENSE summary

MIT License. Copyright (c) 2026 Matt Pocock. Permits use, copy, modify, merge,
publish, distribute, sublicense, and sell, provided the copyright notice and
permission notice are included in all copies or substantial portions.

ADR-002 must include the MIT notice or reference to it.

---

## 5. Pattern mapping — exactly 2 entries WU-003 must add

ADR-002 work creates `docs/reference/matt-pocock-pattern-mapping.md` with these
two entries (and only these two; future ADRs append more).

Required fields per entry (from work-unit.yaml acceptance criterion #12):

```
source_skill:        e.g. mattpocock/skills/productivity/grill-me
license:             MIT
adr_reference:       ADR-002
appmaker_pattern:    Interview / Brownfield Interview
surface:             lifecycle | runner | review | safety | catalog
output_artifact:     interview-result.yaml (or similar)
```

**Plus:** doc header explaining the append-oriented convention (correctness
matters; new adoptions appended; corrections via dedicated work_unit with
revision history; this is reference material, NOT audit log subject to R10).

---

## 6. `interview-result.yaml` schema starting point

ADR-002 must describe this **conceptually**, not deliver a parseable schema
file (that is WU-005 scope). The starting point (Codex's proposal, accepted):

```yaml
problem:
  statement: ""
  target_users: []
  current_pain: ""

scope:
  goals: []
  non_goals: []
  constraints: []

product:
  primary_workflows: []
  success_criteria: []
  edge_cases: []

technical:
  preferred_stack: []
  integrations: []
  data_sensitivity: ""
  deployment_target: ""

risks:
  ambiguous_areas: []
  assumptions: []
  questions_remaining: []

readiness:
  status: ready | needs_more_input | reject | ready_with_override
  reason: string
  unresolved_ambiguities: []
  override:
    invoked_by: string
    invoked_at: string
    reason: string
```

ADR-002 may refine field names, group structure, add fields, or document
intentional omissions — but the readiness enum and `ready_with_override`
shape are not negotiable (per Codex acceptance, 2026-05-09).

For brownfield variant (`--with-docs`), additional sections likely needed
(executor's design choice, justify in ADR-002):

```yaml
existing_codebase:
  glossary_terms_resolved: []
  glossary_terms_introduced: []
  adr_candidates: []
  contradictions_found: []
```

---

## 7. Required ADR-002 structure (artifact_schema: adr-v1)

Per `work-unit.yaml.verification.required_sections`, ADR-002 must contain:

1. **Status** — PROPOSED initially; flips to ACCEPTED on promote
2. **Metadata** — date, authors, type (investigation), supersedes/superseded-by
3. **Context** — why Interview Phase, problem it solves
4. **Sources Consulted** — Matt Pocock Skills with attribution, ADR-001, constitution, Codex's 4+ rounds
5. **Decision (numbered)** — D1 through D7 each with Why + How/Implications
6. **Killed Alternatives** — at least 3, each with reason
7. **Risks and Mitigations** — table
8. **Rollback Plan** — soft + hard
9. **Open Questions** — what ADR-002 deliberately defers
10. **Acceptance Criteria** — self-check that ADR-002 itself meets verification
11. **Verification** — table mapping required sections to present/absent
12. **Revision History** — initial draft + future amendments

---

## 8. Forbidden patterns

The output MUST NOT contain:
- `TBD`
- `TODO`
- `...` (ellipsis as hand-waving; ellipsis inside code samples is allowed only as
  concrete placeholder like `('FILE')`, not bare `...`)

---

## 9. Bounds

- **Lines:** 250–550 (ADR-002 may be longer than constitution due to 7-decision detail)
- **Killed alternatives:** ≥ 3
- **Decision points resolved:** all 7 (D1–D7)
- **Parser validation:** does not apply (markdown is structural, not parseable yaml/json/code)
- **Section presence:** all 12 required sections (§7)

---

## 10. Self-check before declaring ADR-002 ready

Before flipping work-unit.yaml `IN_PROGRESS` → `VERIFIED`:

- [ ] All 12 required sections present in declared order
- [ ] D1, D2, D3, D4, D5, D6, D7 each resolved with explicit decision and rationale
- [ ] At least 3 killed alternatives, each with reason
- [ ] interview-result.yaml schema described conceptually with `readiness` enum + `ready_with_override` shape
- [ ] ready_with_override propagation rule (D6) includes ≥1 concrete worked example
- [ ] Lifecycle command (D4) picks one default with rationale; others go to killed
- [ ] Matt Pocock attribution explicit: link, MIT license, author name, both SKILL.md paths
- [ ] No TBD, no TODO, no bare `...`
- [ ] Length 250–550 lines
- [ ] No constitution edits, no schema files created, no code files created
- [ ] No contradiction with ADR-001 §§D2, D2a, D3, D4, D11, D12, D13
- [ ] No contradiction with constitution rules R1, R8, R12, R13, R17
- [ ] `docs/reference/matt-pocock-pattern-mapping.md` created with exactly 2 entries (grill-me, grill-with-docs) plus header explaining append-oriented convention

---

## 11. Out-of-scope reminders

The executor MUST NOT:

- Edit `decisions/ADR-001-process-kernel-architecture.md` (immutable, ACCEPTED)
- Edit `constitution.md` (amendments are WU-004 scope)
- Create or modify any `.ts`, `.json`, `.sql` files
- Create schema files (`*-v1.json`, `*-schema.yaml`) — that is WU-005 scope
- Run `git commit`, `git push`, `git clone`, `npm install` (per blocked_actions and constitution R14)
- Add more than 2 entries to `matt-pocock-pattern-mapping.md` (only grill-me + grill-with-docs)
- Resolve future ADR concerns (PRD, decomposition, safety hooks, TDD, etc.) — those are ADR-003+ scope
- Implement Interview CLI — that is later WU scope
- Add fields to `interview-result.yaml` schema beyond what's reasonable for ADR-level conceptual description

---

## APPENDIX A — Constitution (R8 inclusion: critical excerpts + full-file reference)

> Source: `/Users/pawel/Projects/AppMaker/constitution.md` (ACCEPTED, 2026-05-09)

The full constitution text is incorporated by reference at the path above.
Critical rules directly affecting WU-003 are quoted below; the executor MUST
read the full file before writing ADR-002.

### Rules most directly affecting WU-003:

**R1.** ADRs require minimum 3 alternatives, explicit killed options, and risks with mitigations. *(Applies to ADR-002 itself.)*

**R7.** Machine-readable artifacts must pass parser validation before VERIFIED. *(Applies to work-unit.yaml — already validated; ADR-002 is markdown, not parser-checked, but structure-validated against required_sections.)*

**R8.** Every context-pack.md includes the constitution, the relevant recent ADRs, and the work_unit's acceptance criteria. *(This pack itself complies via Appendices A, B, C.)*

**R12.** No silent fallbacks. *(ADR-002 must specify what happens when Interview is incomplete — explicit error, not silent skip.)*

**R13.** Every work_unit must reduce uncertainty or deliver a verified change. *(ADR-002 reduces uncertainty about lifecycle structure; this is its value.)*

**R14.** Agents may not invoke `git push`, `git commit`, `rm -rf`, package publishing, or production deployment. *(WU-003 blocked_actions enforces this.)*

**R15.** Adapters translate. Adapters do not define. *(Matt Pocock attribution policy in D5 must respect this — Matt's skills are not adapters; they are inspiration sources.)*

**R16.** Constitution may forbid classes of adapters. *(Not directly relevant to D5, but informs the adaptation vs runtime-dependency boundary.)*

**Full text of all 17 rules:** load `/Users/pawel/Projects/AppMaker/constitution.md` before drafting ADR-002.

---

## APPENDIX B — ADR-001 relevant decisions (R8 inclusion)

> Source: `/Users/pawel/Projects/AppMaker/decisions/ADR-001-process-kernel-architecture.md` (ACCEPTED, 2026-05-09)

ADR-001 has 14 decisions (D1–D14 + D2a). The decisions relevant to WU-003 / ADR-002:

### D2 — Process Kernel + work_unit as primary primitive

AppMaker is a kernel that profiles, curates, decomposes, compiles context, enforces gates, logs streams. **Multi-agent debate is not a v1 feature.** Single-agent runner with strict contracts is the default.

*Implication for ADR-002:* Interview is single-agent (one agent grills, one human answers). Not a multi-agent debate among grill-me clones.

### D2a — work_unit declares type: investigation | implementation

Verification semantics differ. Investigation has artifact-schema validation; implementation has command-pass.

*Implication for ADR-002:* Interview itself is an **investigation work_unit** producing `interview-result.yaml`. Subsequent Implementation work_units consume it.

### D3 — 6-file project model

```
project/
├── north-star.md
├── constitution.md
├── appmaker.config.yaml
└── .appmaker/
    ├── profile.yaml
    ├── work-units/<id>/
    ├── decisions.jsonl, events.jsonl, lessons.jsonl
    └── state.sqlite
```

*Implication for ADR-002:* D2 (where interview-result.yaml lives) extends this model. Either to 7-file (root-level interview-result.yaml) or kernel-managed (in `.appmaker/`) or work_unit-scoped.

### D4 — Manual bootstrap ADR exception

ADR-001 was the only artifact authored manually. ADR-002 onwards through work_unit pipeline.

*Implication for ADR-002:* Already complying — WU-003 exists, this pack exists, ADR-002 will emerge through proper flow.

### D11 — Three-stream logging

`decisions.jsonl`, `events.jsonl`, `lessons.jsonl` separate, append-only.

*Implication for ADR-002:* Interview produces an `events.jsonl` entry on completion (`event: "interview_completed"` or `"interview_completed_with_override"`). It does NOT write to `decisions.jsonl` (interview is not an architectural decision; it is input gathering).

### D12 — Adapter selection: Advisor proposes → config decides → constitution constrains

*Implication for ADR-002 D5:* Matt Pocock skills are not adapters (per R15). They are inspiration sources whose patterns AppMaker adapts into native interview prompts. No runtime dependency.

### D13 — Gates fail closed

`default_decision: reject`, `on_missing_field: reject`, `on_error: reject`.

*Implication for ADR-002 D3 (readiness gate):* `needs_more_input` and `reject` are fail-closed states. `ready` and `ready_with_override` are explicit pass states. Default is reject if status is not one of the four enum values or if status field is missing.

**Full text of ADR-001:** load `/Users/pawel/Projects/AppMaker/decisions/ADR-001-process-kernel-architecture.md` before drafting ADR-002.

---

## APPENDIX C — WU-003 acceptance criteria (verbatim)

> Source: `/Users/pawel/Projects/AppMaker/.appmaker/work-units/wu-003/work-unit.yaml`

12 acceptance criteria from `work-unit.yaml.acceptance_criteria`:

1. ADR-002 resolves all 7 decision points (D1–D7) listed in `decisions_to_resolve`.
2. Each major decision has rationale (Why) and consequences (How / Implications) sections.
3. At least 3 killed alternatives documented, each with explicit reason for rejection (per constitution R1).
4. `interview-result.yaml` schema is described CONCEPTUALLY in prose / yaml-like example (NOT delivered as a parseable schema file — that is WU-005 scope).
5. Matt Pocock attribution explicit: link to repo, license name, author name, specific SKILL.md paths quoted from.
6. No constitution edits. No schema files created. No code files created.
7. ADR-002 does not contradict ADR-001 §§D2, D2a, D3, D4, D11, D12, D13, D14.
8. ADR-002 does not contradict constitution rules (especially R1, R8, R12, R13, R17).
9. `ready_with_override` propagation rule (D6) includes at least one concrete example of how an ambiguity flows from `interview-result.yaml` into a downstream work_unit's context-pack.
10. Lifecycle command decision (D4) picks a single default pattern with explicit rationale; alternatives listed in killed alternatives.
11. Open Questions section enumerates anything ADR-002 deliberately defers (e.g., interview UI/CLI implementation details — those are WU-005+ scope).
12. Creates or updates `docs/reference/matt-pocock-pattern-mapping.md` as an append-oriented reference ledger with exactly two ADR-002 entries: grill-me and grill-with-docs. Each entry records: source_skill path, license, ADR reference, AppMaker pattern name, surface (lifecycle | runner | review | safety | catalog), output artifact. ADR-002 itself remains the primary output; the mapping doc is reference/provenance, not a decision artifact.

---

**End of context pack.** Total ADR-002 + mapping doc authoring should take 2–3 hours of focused work. ADR-002 draft path: `.appmaker/work-units/wu-003/runs/<timestamp>/output.md`. Mapping doc draft path: `.appmaker/work-units/wu-003/runs/<timestamp>/matt-pocock-pattern-mapping.md` (or written directly to `docs/reference/` if executor prefers; promotion step copies / verifies). On promote: ADR-002 to `decisions/ADR-002-interview-phase.md` (DRAFT→ACCEPTED status flip), mapping doc to `docs/reference/matt-pocock-pattern-mapping.md`.
