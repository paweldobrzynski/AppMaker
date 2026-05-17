# AppMaker Method

**Method = thinking discipline for AI-assisted software. Plugin-independent.**

This document describes WHAT to do and WHY, with no dependency on the AppMaker plugin or Claude Code. If you can read this and adopt the discipline using plain markdown files, then the Method is real. If you cannot, the Method is fiction and the plugin is the actual product.

The plugin (`/appmaker:*` skills) is **one implementation** of this Method. When Claude Code ships better primitives (`/goal`, `/ultra-review`, agent view), the plugin delegates. The Method stays.

---

## Why method

Vibe-coding fails not because the AI is bad. It fails because **intent drifts** across a long chat history. A business rule decided in message 12 is invisible by message 47. An edge case raised by a stakeholder lives in a transcript no one re-reads. Acceptance criteria do not exist because no one wrote them down. The AI improvises into the gap — guessing permissions, inventing workflows, deciding what "done" means.

The fix is not "more context." The fix is **structured artifacts** that pin intent to disk, link levels of intent to each other, and make drift detectable.

The Method has three claims:

1. **Artifacts > chat history.** Source of truth is the per-feature folder, never the conversation.
2. **Traceability > acceptance.** Every line of done-condition links upward to the higher intent it serves. Drift becomes a broken link, not a missed nuance.
3. **Determinism > judgment.** Where a check can be a script, it is a script. Where it cannot, it is a documented human criterion. LLM judgment is the last resort, not the first.

---

## Four disciplines

These are orthogonal commitments. You either follow them or you do not. Half-following produces fake structure.

### 1. Bounded context

A project has three durable knowledge surfaces:

| Surface | Rule | Size limit |
|---|---|---|
| `constitution.md` | 5-7 rules the project NEVER breaks. Things hard-to-reverse if violated. | ≤7 lines worth of rules |
| `glossary.md` | Ubiquitous language. Every domain term defined once. Source of contradiction-free communication with AI. | Grows; lint for unused stubs |
| `memory/wiki/*.md` | Compiled knowledge. Architecture, domain model, testing patterns, integration gotchas. Queried before generating, NOT after. | Lint: stale > 30 days = warn |

Compiler analogy: `memory/raw/` (user drops) → `memory/wiki/` (compiled, queryable) → generator reads at pre-flight (runtime). Linting = test suite (broken `[[links]]`, stale pages, raw orphans).

**Discipline test:** Open your project root. Can you point at a file holding (a) inviolable rules, (b) domain language, (c) compiled architecture knowledge? If any is missing or scattered across chat history, this discipline is failing.

### 2. Traceable intent

Every level of intent points up to the next:

```
PRD criticism IDs (pcrit-001, pcrit-002, ...)
        ▲
        │ traces_to:
        │
Slice acceptance criteria
        ▲
        │ test name reference
        │
Executable test
        ▲
        │ asserts on
        │
Production code
```

When a business rule changes:
- pcrit-001 text changes
- The slice(s) with `traces_to: [pcrit-001]` are flagged
- Their AC checkboxes are re-evaluated
- Their tests fail or pass; mismatch = drift
- Production code follows from passing tests

When chain is broken (slice with no `traces_to`, AC with no test, test with no AC), you have drift surface. The chain MUST be unbroken end to end.

**Discipline test:** Pick any line of production code shipped this month. Walk back: which test asserts this? Which AC does that test cover? Which `pcrit-*` does the AC trace to? Which PRD criticism wrote that pcrit? If you stop before the PRD, the chain is broken.

### 3. Per-feature folder

A unit of work has a home:

```
features/NNN-slug/
├── interview-result.md       what + who + pain + workflow + constraints
├── prd.md                    PRD with pcrit-* criticisms + Understanding + Clarifications
├── decomposition.md          vertical slices with traces_to + cycle check
├── slices/
│   └── NN-slug/
│       ├── requirements.md   what + why (cites pcrit refs)
│       ├── blueprint.md      how (files to touch, approach)
│       ├── acceptance.md     AC checkboxes with traces_to
│       ├── plan.md           dry-run declaration BEFORE implementation
│       └── evidence.md       review + test results + plan-vs-actual diff
└── retro.md                  post-feature: what to durable memory
```

**Note on layout:** The diagram shows one valid materialization. Method demands "5 contract artifacts per slice in coherent location" — implementation may put them as `slices/NN/{requirements,blueprint,acceptance,plan,evidence}.md` OR as sections within a single per-slice file (e.g., `backlog/NNN-slug.md` with `## Plan`, `## Evidence`, `## Plan vs Actual` sections). Audit and real-world evidence determine which materialization the plugin adopts.

The chat history is **not** the artifact. It is scratch paper. Anything that matters is written to a file. When the feature archives, all artifacts move to `features/archive/YYYY-MM-DD-NNN-slug/` together. Audit trail survives.

**Discipline test:** Delete every chat log. Can you reconstruct what was built, why, with what trade-offs? If no, this discipline is failing.

### 4. Determinism over judgment

Three tiers, used in this order:

| Tier | Mechanism | Examples |
|---|---|---|
| 1 — Deterministic | Bash script, file existence check, regex on artifact | Glossary stub extraction; checklist gates (file present, link valid, status set); test run; lint |
| 2 — Documented human criterion | Written rule a human applies consistently | Matt's "hard-to-reverse AND surprising" filter for decisions; "is this an architectural decision or a tactical one"; constitution rules |
| 3 — LLM judgment | Critic subagent, semantic review | `/appmaker:review` calling code-reviewer; glossary semantic enrichment; clarification questions |

When you reach for Tier 3, ask: could this be Tier 2 if I wrote down a criterion? Could it be Tier 1 if I scripted the check?

**Discipline test:** Pick any gate in your workflow. Which tier is it? If everything is Tier 3, the workflow has no determinism floor and will drift the moment the LLM picks a worse interpretation.

---

## Three contracts

A contract = mandatory shape an artifact must have. No contract, no integration with the chain.

### Slice contract

A slice is the unit of plan-and-build. It is "done" when ALL of:

1. `requirements.md` — what + why + `traces_to: [pcrit-*]`
2. `blueprint.md` — how, including specific files to touch
3. `acceptance.md` — AC list, every AC has `traces_to: [pcrit-*]` and at least one test reference
4. `plan.md` — dry-run declaration: files I WILL touch, tests I WILL write, AC I WILL satisfy. Written BEFORE implementation.
5. `evidence.md` — actual outcome. Diff against `plan.md` documented. Drift WARN if files-touched or tests-written differ from plan without explanation.

A slice without all 5 is not done. It is an unfinished slice. Calling it done corrupts the audit trail.

### PRD contract

A PRD has three mandatory sections:

1. **Understanding** — what the team currently believes about the problem. Surfaces hidden assumptions before they go to code. (Matt Pocock's pattern.)
2. **Clarifications** — explicit list of open questions and how each was resolved. Stakeholder answers live here, not in chat.
3. **Criticisms** — numbered `pcrit-*` items. Each is one tight statement of what the system must do or NOT do. These are the anchor points the slice contract traces to.

A PRD without `pcrit-*` IDs is not a PRD. It is a meeting note.

### Decision contract

Not every choice deserves a durable record. The criterion (Matt Pocock):

**A choice goes to `memory/decisions.md` if it is hard-to-reverse AND surprising-without-context.**

- Library choice that took 3 days to migrate to → hard-to-reverse, may or may not be surprising. Maybe yes.
- Variable rename → easy to reverse. No.
- Subtle ordering of database operations that prevents a race → hard-to-reverse if production data depends on it, very surprising. YES.
- Decision to skip auth on dev endpoint → easy to reverse, surprising. Maybe yes (security context).

When in doubt, default NO. Decisions log inflates fast; quality dies.

---

## One rhythm

The Method has a single repeating cycle. Each slice goes through it.

```
PRE-FLIGHT  ──▶  DRY-RUN  ──▶  APPLY  ──▶  DEBRIEF
   │             │             │           │
   │             │             │           └─ artifacts to durable memory
   │             │             └─ implement, test, review
   │             └─ declare plan.md
   └─ read constitution + glossary + relevant wiki pages + open AC
```

### Pre-flight

Before any code, read:

1. `constitution.md` — re-anchor on inviolable rules
2. `glossary.md` (relevant terms) — speak the project's language, not generic
3. `memory/wiki/<relevant>.md` — compiled knowledge from prior features
4. Current slice's `requirements.md`, `blueprint.md`, `acceptance.md`

If pre-flight reads less than this, the slice will improvise the missing parts.

### Dry-run

Write `plan.md`:

- Files I will create or modify (specific paths, not categories)
- Tests I will write (test names, what they assert)
- AC I will satisfy (which `pcrit-*` references covered)
- Risks I am aware of

`plan.md` is the contract for the build phase. It exists for debrief drift detection.

### Apply

Implement against the plan. Tests first (red), code second (green), refactor third. Standard TDD discipline. Touch only files in `plan.md` unless you update `plan.md` first with a written reason.

### Debrief

Write `evidence.md`:

- Plan-vs-actual diff (files actually touched, tests actually written, AC actually satisfied)
- Review findings (Tier 3 critic subagent, optional Tier 1 checklist gate)
- Drift reasons documented (if any)

Then archive lessons that meet the Decision contract criterion. Most do not.

---

## Stress test

How to know you are following the Method, not LARPing:

| Sign of Method | Sign of LARP |
|---|---|
| Stakeholder asks "why did we pick X?" — you point at a `decisions.md` entry | "I think we discussed it... let me search Slack" |
| AI proposes change to file F — you ask "which AC does this serve?" and reject if no answer | AI proposes change, you accept because it sounds right |
| `plan.md` and `evidence.md` differ — you investigate before next slice | Slice ships, next slice starts |
| `glossary.md` has a definition for every project-specific term used in PRD | PRD uses "user", "system", "process" with no project anchoring |
| Pre-flight read happens before every slice | Pre-flight happens only when you remember |
| Constitution has ≤7 rules and you can recite them | Constitution has 23 rules and you read them once at init |

The Method's value is **prevention of drift**, not productivity. If you adopt all four disciplines and three contracts and the rhythm, your first slice will take longer than vibe-coding. Your tenth slice will take a fraction, because nothing is being relitigated.

---

## Worked example: Caseman BPS Risk Score

Real production feature (May 2026, ~5h30min, 5/7 slices shipped, 4 library deploys, 21 unit tests).

**Discipline 1 — Bounded context:**
- `constitution.md`: 5 rules including "Apps Script library boundary — Mgc public API never breaks consumers"
- `glossary.md`: 5 domain terms (BPS, BPS Risk Score, Risk band, BPS rule, Aggregator-first BPS) each with `file:line` references — extraction Tier 1, semantic enrichment Tier 2
- `memory/wiki/architecture.md`: Apps Script library deploy model, version bump semantics

**Discipline 2 — Traceable intent:**
- PRD with 9 criticisms (`SC1`-`SC9` per project-specific naming, equivalent to `pcrit-*`)
- 7 slices decomposed, cycle-checked, 8/8 coverage
- 37/37 AC checkboxes marked across 5 done slices, each with `traces_to: [SC...]`
- 21 tests covering AC ranges
- Production commits cite slice IDs in messages

**Discipline 3 — Per-feature folder:**
- `features/001-bps-risk-compute/` with PRD, decomposition, 5 slice subfolders
- Code comments cite PRD path: `domain/bps-rules.js` references `appmaker/features/001-bps-risk-compute/prd.md`
- Audit survives — six months later, original intent is reconstructible

**Discipline 4 — Determinism over judgment:**
- Tier 1: glossary stub extraction via bash hook (5 terms appended automatically)
- Tier 2: Matt's hard-to-reverse criterion applied to "use aggregator-first BPS computation" — surprising decision, kept in durable memory
- Tier 3: code-reviewer subagent invoked per slice (gap discovered: 10 invocations, 0 persisted files → patched in v0.2.4)

**Where the example exposed Method gaps:**

The case study surfaced gaps NOT in Method (which held) but in plugin implementation (which patched):
- Persistence reliability (v0.2.4)
- Glossary lifecycle clarity (v0.2.11 two-tier)
- Decisions lifecycle wiring (v0.2.16)
- Per-slice review gate (v0.2.15)

Method's structure made each gap surgical to fix. Without the contracts, fixes would have been UX bandaids.

---

## Relation to AppMaker plugin

The plugin is one implementation of this Method. Concretely:

| Method element | Plugin implementation |
|---|---|
| Discipline 1 (bounded context) | `/appmaker:init` materializes constitution + glossary + memory tree; `/appmaker:checklist memory` lints |
| Discipline 2 (traceable intent) | `/appmaker:prd` emits `pcrit-*`; `/appmaker:decompose` writes `traces_to`; `/appmaker:tdd` enforces AC-test linkage |
| Discipline 3 (per-feature folder) | `/appmaker:interview` allocates `features/NNN-slug/`; `/appmaker:archive` moves to `features/archive/` |
| Discipline 4 (determinism) | `appmaker/hooks/glossary-extract.sh` (Tier 1); constitution-as-doc (Tier 2); `/appmaker:review` (Tier 3) |
| Slice contract | `/appmaker:decompose` writes header; `/appmaker:tdd` enforces AC; `evidence.md` produced by `/appmaker:review` |
| PRD contract | `/appmaker:prd` template enforces Understanding + Clarifications + Criticisms |
| Decision contract | `/appmaker:archive` retro applies Matt's filter, appends to `memory/decisions.md` |
| Rhythm | `/appmaker:next` orchestrates pre-flight → dry-run → apply → debrief across skills |

If Claude Code ships native equivalents for any of these, the plugin delegates and the Method continues unchanged.

**You can adopt this Method without the plugin.** Use plain markdown files in the layout above. The plugin removes friction; the Method provides the structure.

---

## What the Method does NOT include

- A specific tool, model, or vendor
- A particular test framework or language
- A team size assumption (works for solo or N people; contracts scale)
- A project type assumption (greenfield or brownfield; web app or CLI)
- A specific cadence of releases (per-slice ship, per-feature ship, batch — all valid)

The Method describes **what artifacts exist and how they link**. Everything else is implementation choice.

---

## Open invariants worth testing

The Method is current as of v0.2.17. Hypotheses still being validated:

1. **Slice contract: consolidate 5 artifacts per slice in one coherent location.** Plugin currently scatters across PRD section + decomposition row + backlog item + chat-only TDD plan. v0.3 candidate: single location per slice — either `slices/NN/` subfolder OR sections in backlog item (audit-driven decision).

   **Important — traceability direction:** PRD stays upstream source of product intent, NEVER a rollup of slices. Decomposition may be a rollup/index over slices. Slice is execution record, derived from PRD intent — never the originator of product intent. Inverting this direction would break traceability (slices could declare intent the PRD never asserted), creating circular dependency.

2. **Plan-vs-actual drift detection is the missing audit ogniwo.** Method demands `plan.md` before `apply` and `evidence.md` after. Plugin currently has neither as named artifact. v0.3 candidate primitive.

3. **Aviation metaphor unification.** Constitution = aircraft limitations, checklist = pre-flight, plan.md = filed flight plan, retro = post-flight debrief. Worth lifting into Method language as a learning aid, not just marketing.

These three hypotheses are the next stress tests. If they fail (Method works fine without them), do not add them. If they succeed (Method has visible gaps without them), formalize.
