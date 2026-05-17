# Decisions Memory

Cross-feature hard-to-reverse decisions. Markdown, NIE numbered ADRs.

## When to log

Both criteria:
- Hard to reverse (migration, public API, schema, lib lock-in)
- Surprising without context (real trade-off; future reader asks "why?")

Skip interchangeable choices, defaults, style preferences.

## Format

    ### YYYY-MM-DD — <title>
    **Feature:** <NNN-slug> (or cross-cutting)
    **Decision:** <what picked>
    **Why:** <trade-off + alternatives rejected>
    **Consequences:** <downstream impacts>

Written by /appmaker:archive retro from interview-result.md "Architectural decisions surfaced" + retro answers.

---

### 2026-05-17 — PRD as upstream source of intent (not rollup of slices)
**Feature:** 001-method-compliance-pass-1 (METHOD.md correction during dogfood)
**Decision:** PRD remains upstream source of product intent. Decomposition may be rollup over slices; PRD cannot. Slice = execution record, derived from PRD intent — never originator.
**Why:** Original METHOD.md "Open invariants" sketched `prd.md ← AUTO rollup` of slice requirements. Codex (via operator-relayed advisor) flagged: inverting traceability creates circular dependency — slice could declare intent PRD never asserted; PRD becomes downstream aggregator, no single source of product truth. Hard-to-reverse if propagated to plugin behavior (`decompose`, `archive` would need rework). Surprising-without-context because intuition initially says "slice owns its requirements".
**Consequences:** METHOD.md Open invariants reframed to make direction explicit. Plugin v0.3 candidate decisions (slice-as-primary-unit) must preserve this direction. `decomposition.md` may rollup; `prd.md` MAY NOT.

### 2026-05-17 — Dogfood location: `dogfood/appmaker/`
**Feature:** 001-method-compliance-pass-1 (operator pattern for plugin self-development)
**Decision:** AppMaker plugin source repo dogfoods itself via `dogfood/appmaker/` directory (not `appmaker/` at repo root).
**Why:** Plugin source `.gitignore` line 31 explicitly excludes `/appmaker/` to prevent init-test materialization pollution. Codex flagged: original `appmaker/` location would make dogfood invisible to git (audit trail lost). `.gitignore /appmaker/` is root-anchored (leading slash) — doesn't match `dogfood/appmaker/`. Reversible only via migration (mv + path update across all internal refs).
**Consequences:** All future AppMaker dogfood features live in `dogfood/appmaker/`. Plugin source materialization (templates, resources) stays canonical in `plugin/appmaker/resources/appmaker/`. Two distinct paths for two distinct uses: plugin source vs plugin self-dogfood state.

### 2026-05-17 — Capture first, automate later (MVP design move for audit/observability features)
**Feature:** 002-plan-evidence-drift-detection (v0.2.19 MVP)
**Decision:** When introducing a new audit/observability primitive (drift detection, instrumentation, compliance gate), default to **capture-only MVP first**. Materialize structured fields in artifact; users (or `/appmaker:tdd`-like skills) fill them. Defer auto-diff / enforcement / classification logic until 2-3 features show real usage of the captured data.
**Why:** Original v0.2.19 PRD attempted full subsystem (8 pcrits: separate Plan / Evidence / Plan-vs-Actual sections + TDD writes Plan + Review auto-classification with 4 cases + Checklist FAIL enforcement + `artifact_contract` marker for grandfathering). Codex pushed back: *"produkt w produkcie"* — too much surface for first iteration without evidence of which automation users actually need. Reduced to 4 pcrits (one cohesive `## Execution Record` section, two TDD write phases, version bump, METHOD.md status). MVP validates whether the captured data is useful BEFORE engineering automation around it. Surprising because default instinct is full subsystem; hard-to-reverse if propagated as design principle (commitment to gradual rollouts).
**Consequences:** Future audit/observability features in AppMaker follow MVP-first. Validation criteria stated up-front (does data get filled? do operators use it on resume? does manual review surface drift?). Automation justified by evidence, not aspiration. METHOD.md "Open invariants" framing reflects this — "MVP under validation" status flag distinguishes captured-not-automated primitives.
