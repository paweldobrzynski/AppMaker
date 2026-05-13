# Context Pack — WU-004: Constitution Amendment Adding R18 (Interview Required First Lifecycle Stage)

> **R8 compliance statement.** Per `constitution.md` Rule R8, this pack contains:
>
> - **Constitution** — Appendix A (critical excerpts inline; full accepted file at `/Users/pawel/Projects/AppMaker/constitution.md`)
> - **ADR-001 relevant decisions** — Appendix B (relevant decisions quoted; full file at `decisions/ADR-001-process-kernel-architecture.md`)
> - **ADR-002 relevant decisions** — Appendix B (relevant decisions quoted; full file at `decisions/ADR-002-interview-phase.md`)
> - **WU-004 acceptance criteria (verbatim)** — Appendix C
> - **Lessons stream applicable to wu-004 (verbatim)** — Appendix D ← per Codex's memory-stream directive
>
> R8 v1 compliance for manual packs is satisfied by including critical
> excerpts inline plus an absolute path to the accepted file. Lessons inclusion
> goes beyond R8 minimum and is required by WU-004 acceptance criterion #15
> (memory-stream test).
>
> Pre-constitution exception is long expired (WU-002 only). All R8 enforcement
> is active. WU-004 is the FIRST AMENDMENT WORK_UNIT in AppMaker.

---

## 1. Goal (recap from work-unit.yaml)

Amend `constitution.md` to add exactly one new rule (proposed slot R18)
formalizing ADR-002 §D1: Interview Phase is the required first lifecycle
stage of every AppMaker project. R1–R17 remain unchanged. Output is the
amended constitution, promoted to project root replacing the v1 version.

This is the first AMENDMENT work_unit and the first test of:
1. Whether the Amendment Process defined inside `constitution.md` itself is workable.
2. Whether the lessons stream actually influences subsequent work_units.
3. Whether the per-WU exception model (constitution writable here, blocked elsewhere) holds.

---

## 2. What the amendment IS (and is NOT)

**IS:**
- A single ADD to constitution Rules section (slot R18)
- Strict reading of "amendments touching core rules" — R18 semantically touches R5 (fail-closed gates) and R13 (uncertainty reduction), so dual review applies
- Solo-execution-exception explicit and audit-recorded (no silent bypass)
- Within-bounds: pre-amendment constitution is 383 lines; post-amendment must remain ≤ 400 (hard cap, no exceptions)
- Substantive — must encode R18's Why and How to apply with reference to ADR-002 (constitution stays terse, ADR carries the architecture)

**IS NOT:**
- A modification, removal, or rename of any existing rule R1–R17
- A silent deletion of any Founding Principle (P1–P6 from ADR-001 discussion)
- A retroactive invalidation of WU-002 (constitution v1 creation) or WU-003 (ADR-002 promote)
- A schema implementation (interview-result-v1 schema is WU-005 scope)
- A code change (no `.ts`, `.json`, `.sql`)
- An edit to ADR-001 or ADR-002 (those are immutable ACCEPTED)
- An interview implementation (no skill, no CLI, no runner — those are later WUs)

---

## 3. Substance of the new rule R18

The executor MUST add R18 with semantic content equivalent to the following.
Wording may be refined; the substance must be preserved.

```markdown
### R18. Every project begins with Interview Phase producing `.appmaker/interview-result.yaml` with `readiness.status` in {ready, ready_with_override}.

**Why:** Without a structured uncertainty-reduction stage at project start, every downstream work_unit inherits ambiguous requirements and either spirals into rework (R13 violation by silent assumption) or pretends ready when it is not (R12 violation as silent fallback). Interview Phase is the project-level mechanism by which projects honour R13 (uncertainty reduction OR verified change) and R12 (no silent fallbacks). Constitution must not allow this to be optional — see ADR-002 §D1 for full design rationale.

**How to apply:** AppMaker kernel refuses to create any work_unit (other than the dedicated interview work_unit itself) until `.appmaker/interview-result.yaml` exists with `readiness.status` in `{ready, ready_with_override}`. Skipping requires explicit human break-glass `appmaker interview --skip --reason="..."`, which still produces a structured `interview-result.yaml` whose `readiness.status` is forced to `ready_with_override` with a project-wide ambiguity entry per ADR-002 §D1. The four-state readiness enum (`ready`, `needs_more_input`, `reject`, `ready_with_override`) and `ready_with_override` propagation rules are defined in ADR-002 §§D3, D6.
```

The executor is responsible for: choosing the exact placement under the
correct subgroup in Rules section (governance? safety? gates?), final
wording polish, and consistency with the constitution's prevailing tone.

### Verification Hooks table — new row to add

```markdown
| R18 | auto-check + human-review | Kernel checks `.appmaker/interview-result.yaml` exists with `readiness.status` in `{ready, ready_with_override}`; if status is `ready_with_override`, also enforces unresolved-ambiguity propagation per ADR-002 §D6; `--skip` remains human-only exception aligned with R6's break-glass discipline (producing structured `ready_with_override` with project-wide ambiguity entry, never silent). |
```

### Revision History — new row to add (replaces no existing row)

```markdown
| 2026-05-09 | WU-004 (amendment) | ACCEPTED (post-amendment) | Added rule R18 enforcing ADR-002 §D1: Interview Phase is required first lifecycle stage; `.appmaker/interview-result.yaml` with `readiness.status` in `{ready, ready_with_override}` is gate for any other work_unit creation. R1–R17 unchanged in title, body, Why, and How to apply. All six Founding Principles (P1–P6) still encoded. Verification Hooks table extended with R18 row (auto-check + human-review). Pre-amendment: 383 lines; post-amendment within ≤ 400 hard cap. Strict reading of Amendment Process applied (R18 semantically touches R5/R13); dual human review with documented solo_execution_exception per WU-004 work-unit.yaml. |
```

---

## 4. Constraints from Amendment Process (verbatim from current constitution)

The current `constitution.md` "Amendment Process" section governs this WU. Key constraints:

1. Investigation work_unit (this WU is `type: investigation` ✓)
2. `acceptance_criteria` lists each amended/added/removed rule with rationale (this WU's contract ✓)
3. Context-pack must include current constitution + ADR-001 + work_units that surfaced the need (this pack ✓; surfacing WU is WU-003 / ADR-002)
4. Same validation as WU-002 (forbidden patterns absent, bounds, parser-clean, all founding principles encoded) ✓ in acceptance_criteria
5. At minimum one human reviewer plus the critic role
6. **Amendments touching R4, R5, R6, R8, R11, or R13 require an additional second human reviewer.** R18 semantically touches R5 (fail-closed gates) and R13 (uncertainty reduction). Strict reading applied. Two human reviewers required (or documented solo_execution_exception).
7. On promote, new constitution replaces old; prior version recorded in Revision History.

**Meta-rules for amendments:**

- Each modified or added rule carries `Why:` and `How to apply:` (R18 has both — see §3 above). ✓ planned
- An amendment may not silently delete a Founding Principle (P1–P6). R18 ADDS a rule; does not delete. ✓
- Amendments may not retroactively invalidate already-promoted work_units. WU-002 (constitution v1) and WU-003 (ADR-002) remain valid; the new rule applies to projects created after WU-004 promote. Existing AppMaker (the meta-project) is grandfathered with explicit transitional note in Revision History. ✓ acceptance criterion #13

---

## 5. Required output structure (constitution-v1)

Constitution must contain these 7 sections in this order (per WU-002 schema):

1. **Status** — current ACCEPTED + amendment lifecycle note
2. **Purpose**
3. **Scope (in / out)**
4. **Rules (numbered, each with rationale)** — heart, 17 → 18 rules after amendment
5. **Amendment Process**
6. **Verification Hooks** — table with R18 row appended
7. **Revision History** — row appended for amendment

Status section must be updated to reflect amendment (e.g., "ACCEPTED — initial v1 promoted from WU-002 on 2026-05-09; AMENDED on 2026-05-09 by WU-004 adding R18").

---

## 6. Forbidden patterns

The amended constitution MUST NOT contain (per WU-002 precedent + R7-derived discipline):
- `TBD`
- `TODO`
- `...` (bare ellipsis as hand-waving; ellipsis inside concrete code-context placeholders is the only allowed exception)

If executing makes inadvertent placeholder mention while writing rationale, paraphrase instead.

> **IMPORTANT — ellipsis quoted in Appendix C is not a copy-paste source.** Acceptance criterion #14 in Appendix C contains a literal `...` ("ACCEPTED — promoted from WU-002... AMENDED on 2026-05-09 by WU-004") because that is how the criterion is written in `work-unit.yaml`. **Do NOT copy that ellipsis into the amended constitution's Status section.** Expand the Status wording fully — for example: "ACCEPTED — initial v1 promoted from WU-002 on 2026-05-09; AMENDED on 2026-05-09 by WU-004 adding R18". The amended constitution must have zero bare ellipsis.

---

## 7. Bounds (HARD CAP 400 lines, NO EXCEPTIONS)

- **Pre-amendment:** 383 lines (verified 2026-05-09)
- **Post-amendment:** must remain ≤ 400 lines (hard cap)
- **Rule count:** 17 → 18 (within R17's max-25 cap)
- **If R18 + Verification Hooks row + Revision History row push past 400:** executor MUST trim non-load-bearing prose elsewhere before declaring VERIFIED. The hard cap is not negotiable.

---

## 8. Self-check before declaring amendment ready

Before flipping work-unit.yaml `IN_PROGRESS` → `VERIFIED`:

- [ ] All 7 required sections present in declared order
- [ ] Total rule count is exactly 18 (was 17 in v1)
- [ ] Each of R1–R17 unchanged in title, Why, and How to apply (textual diff against pre-amendment)
- [ ] R18 has `Why:` and `How to apply:` paragraphs
- [ ] R18 references ADR-002 for full design rationale
- [ ] R18 placed in appropriate Rules subgroup (executor choice; should match prevailing pattern of constitution v1)
- [ ] Verification Hooks table extended with R18 row, classified as `auto-check + human-review`
- [ ] All six Founding Principles (P1–P6) still encoded somewhere in the amended constitution
- [ ] Status section updated with amendment lifecycle note
- [ ] Revision History row added for the amendment with WU-004 reference
- [ ] No `TBD`, no `TODO`, no bare `...`
- [ ] Length ≤ 400 lines (hard cap)
- [ ] Length ≥ 200 lines (lower bound from constitution-v1)
- [ ] No edits to ADR-001 or ADR-002
- [ ] No new files in `decisions/`, `docs/`, or `.appmaker/work-units/wu-002|wu-003/`
- [ ] No code/JSON/SQL files created
- [ ] Both lessons.jsonl entries applicable to wu-004 (lesson 2 review + lesson 3 adr_quality) referenced in this run's output where their content is relevant (especially in self-check methodology and review_scorecard preparation)

---

## 9. Out-of-scope reminders

The executor MUST NOT:

- Edit `decisions/ADR-001-process-kernel-architecture.md` (immutable, ACCEPTED)
- Edit `decisions/ADR-002-interview-phase.md` (immutable, ACCEPTED)
- Edit `.appmaker/work-units/wu-002/**` or `.appmaker/work-units/wu-003/**` (closed, append-only audit)
- Create or modify any `.ts`, `.json`, `.sql` files
- Run `git commit`, `git push`, `git clone`, `npm install`, `rm -rf` (per R14)
- Write to `decisions.jsonl`, `events.jsonl`, or `lessons.jsonl` (those are kernel-managed append streams; events.jsonl gets a single promote entry on PROMOTE step, not during execution)
- Add Matt Pocock pattern mapping entries (those are tied to specific ADRs adopting patterns; this WU is constitution amendment, not pattern adoption)
- Implement Interview prompt, CLI, runner — those are subsequent WUs (WU-005+)
- Touch text of R1–R17 in any way that creates a textual diff (only Verification Hooks table row addition for R18 and Revision History row addition are permitted edits to non-Rules sections)

---

## 10. Lessons stream application (memory-stream test, per Codex directive)

The full text of both lessons applicable to `wu-004` is in Appendix D. This
section names how each lesson concretely shapes WU-004's design and
execution, satisfying acceptance criterion #15 (lessons must influence,
not just be name-dropped).

### Lesson 2 (category=review, source=wu-003) → applied to WU-004

**Lesson:** "Codex external review caught 3 distinct fix rounds that local self-check missed... Pre-execution checklist must include explicit fact-check against external state (paths, commit hashes, schema references) and wording-consistency scan between document sections (intro / body / appendices)."

**Applied to WU-004:**

1. Pre-execution checklist for this WU is in §8 of this pack — explicit, granular, includes fact-check items (e.g., "rule count is exactly 18", "length is 383 → ≤400", "each of R1–R17 textually unchanged"). Concrete, verifiable.
2. Wording consistency: §3 (R18 substance) and §5 (output structure) and §10 (lessons application) are written to be cross-checkable. Executor's first action after drafting amended constitution should run a wording-consistency scan: do Status, Revision History, and the new R18 row all reference the same date, work_unit id, and amendment scope?
3. External-state fact-check: pre-amendment line count (383) was independently verified by Codex during WU-004 contract review. The hard cap (400) is anchored to this verified baseline, not a remembered approximate.

### Lesson 3 (category=adr_quality, source=wu-003) → applied to WU-004

**Lesson:** "Multi-decision ADRs may contain hidden cross-decision contradictions invisible to per-decision self-check (concrete example: WU-003 D1↔D3 about ready_with_override structure)... Add cross_decision_consistency field to review_scorecard_template..."

**Applied to WU-004:**

1. WU-004 work-unit.yaml `review_scorecard_template` includes `cross_decision_consistency: pending` field — directly distilled from this lesson. This is the first time a lesson is reflected in the schema of a subsequent work_unit.
2. WU-004 is technically not a multi-decision ADR (it adds one rule), but it has cross-section coupling: Status section lifecycle note must be consistent with Revision History row, which must be consistent with Verification Hooks row, which must be consistent with R18's Why/How. Self-check item 9 in §8 ("Status section updated with amendment lifecycle note") and item 10 ("Revision History row added") flag this coupling explicitly.
3. The `affects_core_safety_rules: true` decision in WU-004 was made under explicit cross-decision awareness: the rule (R18 = additive) and the procedural class (touches R5/R13 semantically) are different; flagging the latter strict was the correct precedent because of cross-decision implications (future amendments will cite this).

**Memory-stream test outcome (executor must verify in WU-004 output):** Both lessons are referenced not only in this context-pack but also in the WU-004 run output's self-check / verification narrative. If the run output does not reference these lessons in justifying its approach, `lessons_stream_actually_read` review scorecard field is `fail`.

---

## APPENDIX A — Constitution (R8 inclusion: critical excerpts + full-file reference)

> Source: `/Users/pawel/Projects/AppMaker/constitution.md` (ACCEPTED, 2026-05-09; 383 lines)

### Critical rules directly affecting WU-004 (verbatim or paraphrased):

**R1.** ADRs require minimum 3 alternatives, explicit killed options, and risks with mitigations. *(Indirectly: WU-004 references ADR-002 which honoured this. R18's Why must reference ADR-002's full design.)*

**R5.** Gates fail closed. Three-layer enforcement: rule, config, hook. *(R18 adds a new gate within R5's framework — semantic touching, dual review.)*

**R7.** Machine-readable artifacts must pass parser/lint validation before VERIFIED. *(WU-004 work-unit.yaml passed PyYAML + Ruby Psych; the amended constitution is markdown, structure-validated against required_sections rather than parser-validated.)*

**R8.** Every context-pack.md includes the constitution, the relevant recent ADRs, and the work_unit's acceptance criteria. *(This pack complies via Appendices A, B, C; lessons inclusion in Appendix D goes beyond R8 minimum per Codex directive.)*

**R12.** No silent fallbacks. *(R18 must specify what happens when interview is missing or invalid — explicit error, not silent skip. The `--skip` flag is the only escape, and it is human-only with explicit ready_with_override + project-wide ambiguity, never silent.)*

**R13.** Every work_unit must reduce uncertainty or deliver a verified change. *(R18 is the project-level mechanism instantiating R13 — Interview Phase IS the uncertainty-reduction step. Semantic touching, dual review.)*

**R14.** Agents may not invoke `git push`, `git commit`, `rm -rf`, package publishing, or production deployment. *(WU-004 work-unit.yaml `blocked_actions` enforces this for execution.)*

**R17.** The constitution stays under 25 rules. *(After R18, count is 18 — well within cap.)*

**Full text of all 17 rules:** load `/Users/pawel/Projects/AppMaker/constitution.md` before drafting the amendment. Critical: the textual content of R1–R17 must remain identical post-amendment.

---

## APPENDIX B — ADR-001 + ADR-002 relevant decisions (R8 inclusion)

> Sources:
> - `/Users/pawel/Projects/AppMaker/decisions/ADR-001-process-kernel-architecture.md` (ACCEPTED, 2026-05-09)
> - `/Users/pawel/Projects/AppMaker/decisions/ADR-002-interview-phase.md` (ACCEPTED, 2026-05-09)

### From ADR-001 (relevant to WU-004):

**D2 — Process Kernel + work_unit primitive.** AppMaker is a kernel that profiles, curates, decomposes, compiles context, enforces gates, logs streams. Single-agent runner with strict contracts is the default. *(Implication: amendment is an investigation work_unit producing knowledge artifact. Single-agent execution.)*

**D2a — work_unit declares type: investigation | implementation.** *(WU-004 is investigation; verification by artifact_schema = constitution-v1.)*

**D3 — 6-file project model.** `north-star.md`, `constitution.md`, `appmaker.config.yaml` at root (human-authored); `profile.yaml`, `state.sqlite`, log streams in `.appmaker/`. *(R18 introduces a new kernel-managed file `.appmaker/interview-result.yaml`, fitting the existing model — not a new root file.)*

**D11 — Three-stream logging.** *(WU-004 promote produces an `events.jsonl` entry. Lessons.jsonl is consulted but not written by this WU. Decisions.jsonl is not yet active.)*

**D13 — Gates fail closed.** *(R18 instantiates this for the Interview gate; semantic touching, dual review applies per Amendment Process.)*

### From ADR-002 (most relevant to WU-004):

**D1 — Interview is the required first lifecycle stage.** Required for all projects (greenfield + brownfield). `--skip` is human-only break-glass producing structured `ready_with_override` with project-wide ambiguity entry. *(This is what R18 codifies in the constitution.)*

**D2 — `.appmaker/interview-result.yaml` is kernel-managed location.** *(R18 names this exact path explicitly.)*

**D3 — Readiness enum: 4 states (ready, needs_more_input, reject, ready_with_override) with fail-closed gate semantics.** Default decision when status is missing or unknown is reject. *(R18 enforces "readiness.status in {ready, ready_with_override}" as the gate condition.)*

**D6 — `ready_with_override` propagates `unresolved_ambiguities[]` into every downstream context-pack via scope-filtered injection.** *(R18 references this; the propagation mechanism is in ADR-002, not R18 itself.)*

**Full text of both ADRs:** load before drafting the amendment. R18 must reference ADR-002 explicitly; constitution stays terse, ADR carries the architecture.

---

## APPENDIX C — WU-004 acceptance criteria (verbatim)

> Source: `/Users/pawel/Projects/AppMaker/.appmaker/work-units/wu-004/work-unit.yaml`

15 acceptance criteria from `work-unit.yaml.acceptance_criteria`:

1. Constitution adds exactly one new rule, slot R18, in the appropriate Rules section subgroup. Each existing rule R1–R17 is unchanged in title, body, Why, and How to apply.
2. Rule R18 is titled 'Every project begins with Interview Phase producing .appmaker/interview-result.yaml' (or near-equivalent that captures the gate enforcement).
3. Rule R18 has a Why: paragraph (rationale tied to R13 uncertainty reduction and R12 no-silent-fallbacks).
4. Rule R18 has a How to apply: paragraph specifying the kernel-level enforcement (no work_units other than interview work_unit until .appmaker/interview-result.yaml has readiness.status in {ready, ready_with_override}; --skip is human-only break-glass producing structured ready_with_override per ADR-002 §D1).
5. Rule R18 explicitly references ADR-002 for full design rationale; constitution stays terse.
6. Verification Hooks table extended with R18 row, classified as auto-check + human-review.
7. All six Founding Principles (P1 through P6 from ADR-001 discussion) remain encoded in the post-amendment constitution. None silently deleted.
8. Amended constitution length stays in 200–400 line bounds. Pre-amendment: 383 lines. Amended constitution must remain ≤ 400; if R18 + Verification Hooks row + Revision History row push past 400, executor must trim non-load-bearing prose before declaring VERIFIED. The hard cap is 400, no exceptions.
9. Total rule count is 18 (was 17 in v1). R17's max-25 cap respected with 7-rule buffer.
10. Forbidden patterns absent: zero TBD, zero TODO, zero bare ellipsis (per R7-derived discipline; mentions of these strings inside instructional / quoted contexts should be paraphrased to avoid the literal strings).
11. Revision History gains a new row for the amendment, recording: date 2026-05-09, work_unit wu-004, status ACCEPTED, summary of change (added R18 enforcing ADR-002 §D1), and explicit confirmation that R1–R17 were not modified.
12. Section ordering preserved: Status, Purpose, Scope, Rules, Amendment Process, Verification Hooks, Revision History.
13. No retroactive invalidation: WU-002 (constitution creation) and WU-003 (ADR-002 promote) remain valid promoted artifacts. The amendment applies to projects created after WU-004 promote; existing AppMaker (the meta-project) is grandfathered with an explicit transitional note in Revision History.
14. Status section in promoted constitution.md updates: 'ACCEPTED — promoted from WU-002... AMENDED on 2026-05-09 by WU-004' (or near-equivalent capturing the amendment chain).
15. Memory-stream test: Context-pack for this WU (next step) explicitly cites BOTH lessons.jsonl entries that list `wu-004` in their `applies_to` field. As of 2026-05-09 these are: (a) lesson 2 (category=review) — pre-execution checklist must include external fact-check + wording consistency; and (b) lesson 3 (category=adr_quality) — cross-decision consistency must be checked, particularly when one decision constrains structure and another invokes it. The amendment work_unit must demonstrate that both lessons influenced its design or execution, not merely be name-dropped.

---

## APPENDIX D — Lessons applicable to wu-004 (verbatim from `.appmaker/lessons.jsonl`)

> Source: `/Users/pawel/Projects/AppMaker/.appmaker/lessons.jsonl`
> Lessons included: those whose `applies_to` list contains `wu-004`

### Lesson 2 (category=review, source=wu-003)

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

### Lesson 3 (category=adr_quality, source=wu-003)

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

How these are applied is documented in §10 above.

---

**End of context pack.** Total amendment authoring effort estimated 1–2 hours. Output draft path: `.appmaker/work-units/wu-004/runs/<timestamp>/output.md` (the full amended constitution). On promote: replaces `/Users/pawel/Projects/AppMaker/constitution.md` (DRAFT → ACCEPTED status flip in promoted copy; original draft immutable in run dir).
