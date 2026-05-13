# Context Pack — WU-002: Draft AppMaker `constitution.md`

> Briefing material for the executor of work_unit `wu-002`. This pack is the
> **complete and self-contained input** to write `constitution.md`. The executor
> should not need to fetch additional context; if something is missing, it is a
> defect of this pack.
>
> Per ADR-001 §D7 (v1 context compiler), this pack was assembled manually from:
> ADR-001, conversation rounds with Codex (4), and `work-unit.yaml` for wu-002.

---

## 1. Goal (recap from work-unit.yaml)

Produce `constitution.md` at project root: a governance document that states
the rules AppMaker (system) enforces and that agents operating within AppMaker
projects must obey. Each rule must be **testable or auditable**, with explicit
rationale.

Constitution is the FIRST non-bootstrap artifact of the AppMaker project.
Its existence proves AppMaker's discipline is workable — even before the
kernel is implemented.

---

## 2. What constitution.md IS (and is NOT)

**IS:**
- Governance — rules that constrain behavior of the system and its agents
- Stable — amendments only via separate work_unit, no edit-in-place
- Testable — rules expressed as constraints that can be auto-checked OR human-audited
- Concise — 200–400 lines, 10–25 rules; bloat is a sign of low signal
- Self-justifying — every rule has a "why", not just a "what"

**IS NOT:**
- **Configuration** — that lives in `appmaker.config.yaml` (per ADR-001 §D12)
- **Recommendation** — that is the Advisor's job (per ADR-001 §D12)
- **Taste / style** — culture beats governance for stylistic choices; do not legislate them
- **Aspirational manifesto** — no "we strive to" language without a concrete check
- **Tutorial** — no "how to use AppMaker" content; that goes in README

---

## 3. The 6 Founding Principles (Codex, attributed verbatim)

These are non-negotiable rules from the discussion that produced ADR-001.
The constitution MUST encode each of these, though it may add more.

### P1. Every `context-pack.md` contains constitution + relevant ADRs + acceptance criteria
**Why:** Without constitution in the pack, the agent forgets governance at the
moment of execution. Without ADRs, agent re-invents decisions already made.
Without acceptance criteria, agent doesn't know when to stop.
**How to apply:** The context-compiler MUST always inject these three. Missing any of them = pack is invalid.

### P2. Promote impossible without verification result
**Why:** Promotion is the moment work_unit becomes "real". A promoted
work_unit without verification is a lie about the system's state.
**How to apply:** `appmaker promote` REJECTS unless `verification.<artifact_or_command>` produced a recorded `pass` result.

### P3. Schema / auth / secrets / prod changes require human approval
**Why:** These four categories are where an agent error becomes
catastrophic and irreversible. Speed of agent ≠ correctness on these.
**How to apply:** Any work_unit touching these surfaces sets `review_required_from: [..., human]` and gate fails closed without explicit human pass.

### P4. Gates fail closed
**Why:** A gate that fails open silently lets bad work pass. The cost of
false-reject (re-do) is much smaller than false-accept (broken system).
**How to apply:** Per ADR-001 §D13, three-layer enforcement: constitution rule, gate config (`default_decision: reject`, `on_missing_field: reject`, `on_error: reject`), CLI hook (no force without human break-glass + `promoted_with_exception` state).

### P5. No silent fallbacks
**Why:** Silent fallbacks hide system state from the user. "It worked, but
not how you asked" is worse than "it didn't work, here's why".
**How to apply:** Setting `mode: voting` when runner is not implemented produces an explicit error, not a fallback to `single`. Same pattern for any feature gap.

### P6. Every work_unit must reduce uncertainty OR deliver verified change
**Why:** This is the value test. Work_units that produce neither knowledge
nor verified change are theater. Theater wastes context, time, money.
**How to apply:** At promote, gate checks: did this WU produce an artifact (investigation) OR pass verification commands (implementation)? If neither, reject.

### Pre-constitution condition for WU-002

Because WU-002 creates the first `constitution.md`, this context-pack cannot
include the constitution as input. This is **not** a bootstrap exception and
does **not** relax ADR-001. After WU-002 is promoted, every future
`context-pack.md` MUST include `constitution.md`; missing constitution
becomes a context-pack validation failure (per P1).

This pre-constitution condition is scoped exclusively to WU-002 and expires
the moment WU-002 reaches `PROMOTED` state. Subsequent work_units have no
license to invoke it.

---

## 4. ADR-001 decisions that constrain the constitution

The constitution must not contradict ADR-001. Specifically:

| ADR-001 ref | Constraint on constitution |
|---|---|
| **D2** (Process Kernel) | Constitution does NOT mandate multi-agent debate as default; single-agent + contracts is the norm |
| **D2a** (Investigation vs Implementation) | Constitution must allow both verification modes (artifact-schema OR command-pass) |
| **D3** (6-file model) | Constitution lives at project root as `constitution.md`; do not propose alternative location |
| **D4** (Bootstrap exception) | Constitution may declare "no more bootstrap exceptions" as a rule |
| **D8** (Voting in schema, runner deferred) | Constitution must not require voting; voting is opt-in, not default |
| **D10** (CLI-first) | Constitution rules must be enforceable from CLI in v1 (or marked as "deferred to v1.1+") |
| **D11** (Three-stream logging) | Constitution may declare logging stream discipline as a rule |
| **D12** (Adapter selection) | Constitution may forbid CLASSES of adapters (e.g. cloud-only), not specific ones |
| **D13** (Gates fail closed) | Already encoded as P4; constitution must restate as a rule |
| **D14** (events vs runs scope) | Constitution may declare append-only discipline for `events.jsonl`, `decisions.jsonl`, `lessons.jsonl` |

---

## 5. Required structure (per work-unit.yaml `verification.required_sections`)

Constitution.md MUST contain these 7 sections, in this order:

1. **Status** — `DRAFT` | `ACCEPTED` | `AMENDED` (current state of the document)
2. **Purpose** — one paragraph: why constitution exists, what problem it solves
3. **Scope (in / out)** — what constitution governs vs what it explicitly does NOT
4. **Rules (numbered, each with rationale)** — the heart; 10–25 numbered items
5. **Amendment Process** — how the constitution itself can be changed (must be ≥ ADR-level rigor)
6. **Verification Hooks** — for each rule, mark how it is enforced: `auto-check` (specific command/script), `human-review` (which role), or `cultural` (no enforcement, just norm)
7. **Revision History** — append-only log of amendments

---

## 6. Forbidden patterns (per work-unit.yaml)

The output MUST NOT contain:
- `TBD` (no unresolved placeholders in governance)
- `TODO` (constitution either rules or doesn't; no half-rules)
- `...` (no ellipsis hand-waving — be explicit or omit)

---

## 7. Bounds (per work-unit.yaml)

- **Minimum 10 rules**, maximum 25
- **Target length:** 200–400 lines of markdown
- **Each rule** has: rule statement, rationale (`Why:` line), enforcement (`How to apply:` or section reference)

---

## 8. Suggested rules to consider

These are CANDIDATES distilled from ADR-001 + 6 principles + 4 Codex rounds.
The executor may include, modify, combine, or omit any of them. Rules MUST NOT
be copy-pasted without judgment — selection is the work.

### Governance & process

1. ADRs require minimum 3 alternatives, explicit killed options, risks + mitigations
2. Bootstrap exception is one-time; ADR-002 onwards must follow work_unit pipeline
3. Constitution amendments require dedicated work_unit + supersede semantics (no in-place edits)
4. Each work_unit declares `type: investigation | implementation` (per ADR-001 §D2a)

### Verification & gates

5. Promote is impossible without recorded verification result (encodes P2)
6. Gates fail closed — constitution rule + gate config + CLI hook (encodes P4 + ADR-001 §D13)
7. Break-glass is human-only and produces `promoted_with_exception` state, never `promoted`
8. Machine-readable artifacts (yaml, json, code) MUST pass parser/lint validation before being marked READY  *(new lesson from WU-002)*

### Context & memory

9. Every `context-pack.md` contains constitution + recent ADRs + acceptance criteria (encodes P1)
10. Three log streams remain separate: `decisions.jsonl` (rare, signal), `events.jsonl` (frequent, lifecycle), `lessons.jsonl` (rare, retro). No cross-pollination.
11. All log streams are append-only; rewriting history requires dedicated work_unit + audit entry

### Safety

12. Schema / auth / secrets / prod changes require human approval (encodes P3)
13. No silent fallbacks; missing capability produces explicit error (encodes P5)
14. Each work_unit must reduce uncertainty OR deliver verified change (encodes P6)
15. Agents may not invoke `git push`, `git commit`, `rm -rf`, package publishing, or production deploys (human-only in v1)

### Adapters & extensibility

16. AppMaker exposes its own internal contracts; adapters TRANSLATE, never DEFINE
17. Constitution may forbid classes of adapters (e.g., adapters requiring cloud auth); specific adapter selection lives in `appmaker.config.yaml`
18. Catalog skills with deprecated upstream dependencies are flagged and require explicit re-approval per work_unit

### Discipline

19. Each rule has a written rationale; rules without "why" are rejected
20. Bloat is a smell — constitution stays under 25 rules; over 25 = candidate for refactor or rule-merge
21. Constitution does not legislate taste, style, or recommendations — those belong elsewhere

The executor is encouraged to **reduce** this list to 10–18 well-chosen rules,
not to use all 21. Quality > coverage.

---

## 9. Source provenance (where each idea came from)

| Source | What it contributed |
|---|---|
| ADR-001 (this repo) | All `D*` decision references, structural constraints |
| Codex round 1 | Process Kernel framing, work_unit primitive, "structure over agents" |
| Codex round 2 | Salvage discipline, voting as inspiration not silver bullet |
| Codex round 3 | 6-file model, three-stream logging, adapter selection three-role model |
| Codex round 4 | YAML parser-validation lesson (became Suggested Rule 8) |
| Spec Kit (github/spec-kit, ~93k★) | Constitution-as-first-class-citizen pattern |
| Matt Pocock Skills | "Practical engineering, not vibe coding" ethos |
| Aider repo-map | Token budget discipline (informs context-compiler behavior) |
| AppsMaker-2025 (read-only archive) | Negative example: "75% complete = abandoned" → Suggested Rule 14 (deliver or reduce uncertainty) |

---

## 10. Self-check before declaring `constitution.md` ready

Before changing the artifact's status from DRAFT to READY-FOR-REVIEW:

- [ ] All 7 required sections present in declared order
- [ ] 10–25 numbered rules, no more
- [ ] Each rule has rationale (`Why:` line or paragraph)
- [ ] No `TBD`, `TODO`, or `...` anywhere in body
- [ ] No contradiction with ADR-001 §§D2, D2a, D3, D8, D10, D11, D12, D13, D14
- [ ] All 6 founding principles (P1–P6) encoded as one or more rules
- [ ] Verification Hooks section maps each rule to `auto-check` / `human-review` / `cultural`
- [ ] Length 200–400 lines
- [ ] Document validates as well-formed markdown (no broken headings, valid table syntax)

---

## 11. Out-of-scope reminders

The executor MUST NOT:
- Edit `decisions/ADR-001-process-kernel-architecture.md` (per work-unit.yaml `scope.blocked_files`)
- Create or modify any code files (per `scope.blocked_files: **/*.ts, **/*.json`)
- Run `git commit` or `git push` (per `scope.blocked_actions`)
- Invent rules not grounded in either ADR-001, the 6 principles, or explicit conversation
- Exceed 25 rules or 400 lines

---

**End of context pack.** Total constitution authoring should take 1–2 hours of focused work. Output draft path: `.appmaker/work-units/wu-002/runs/<timestamp>/output.md`. On promote: moves to `/Users/pawel/Projects/AppMaker/constitution.md`.
