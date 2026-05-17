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
