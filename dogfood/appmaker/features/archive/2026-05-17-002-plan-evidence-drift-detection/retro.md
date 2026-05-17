---
feature: 002-plan-evidence-drift-detection
release: v0.2.19
created: 2026-05-17
lessons_extracted: 5
---

# Retro: 002-plan-evidence-drift-detection (v0.2.19 MVP)

Second AppMaker dogfood feature — Execution Record MVP for slice-level drift capture. 4 PRD pcrits closed across 4 slices. Codex-driven scope reduction mid-PRD ("produkt w produkcie") proved decisive — original 8-pcrit ambition cut to 4 capture-only pcrits. Released v0.2.19 with manifest + narrative coherence preserved.

## Q&A

| Question | Answer | Lesson |
|---|---|---|
| **Surprises?** | (1) Codex's mid-PRD scope reduction (8 pcrits → 4 MVP) prevented over-engineering — "produkt w produkcie" framing was the right read. (2) Self-applying meta-test EXCEEDED plan — all 4 v0.2.19 slices have Execution Record sections, not just slice 008 that introduced the contract. (3) Cross-slice coherence test extension from v0.2.18 caught README/DESIGN narrative drift on first usage (caught + closed within slice 009 cycle). | MVP design discipline saves real engineering effort. Closure patterns from prior release pay off cycle 1. |
| **Differently?** | (1) Pre-PRD checklist for release invariants: "list version bump, narrative updates, METHOD.md updates BEFORE finalizing pcrits" — would prevent v0.2.18-style pcrit-009 addendum and front-load coherence in initial scope. (2) Dogfood memory structure (`memory/lessons.md`, `decisions.md`, `wiki/`) could be materialized at `/appmaker:init` time rather than at first retro — saves bootstrap overhead. (3) `git diff` strategy for Actual files (committed vs working-tree delta) decided arbitrarily in slice 008; PRD could have stated preference even if "MVP". | Pre-PRD release-coherence checklist worth adding to v0.3 or later. Capture decisions even when "deferred", to anchor reasoning. |
| **Reuse?** | (1) Codex's "**capture first, automate later**" framing as default MVP design move. (2) Line-number ordering checks in tests (`grep -nE` + arithmetic comparison) — structural anchor, not content match. (3) Self-applying meta-test as design discipline — apply new contract to introducing feature's own artifacts. (4) `## Execution Record` as single cohesive section (cf. original 3-section split) — fewer artifacts, easier to scan/fill. | Pattern library extension for AppMaker. Self-applying meta-test now n=2 (v0.2.18 PRD `## Criticisms`, v0.2.19 Execution Record) — promotable. |
| **Misfits?** | (1) `/appmaker:review` subagent NOT invoked — slice changes were text + skill body, lightweight manual review sufficed (v0.2.18 lesson "review form scales with slice impact" still right). (2) `/appmaker:checklist` NOT invoked — would have value if pcrit-006 (checklist enforcement) was in MVP scope, but explicitly deferred. (3) `/appmaker:next` NOT used — manual slice flow preserved transparency. | Confirms v0.2.18 lesson: skill applicability depends on slice impact. MVP releases use lighter discipline. |

## Context packets referenced

None. v0.2.19 was template + skill body + version + docs — no Graphify exploration needed.

## Lessons extracted (with proposed destination — pending operator approval)

| # | Lesson | Destination (proposed) | Matt's filter |
|---|---|---|---|
| 1 | **Capture first, automate later** — MVP design move for new audit/observability features. Original v0.2.19 attempted full subsystem (8 pcrits, review auto-diff, checklist enforcement, classification); Codex cut to capture-only (4 pcrits). Validation criteria explicit before automation justified. | `memory/decisions.md` | Hard-to-reverse if propagated as design principle; surprising (default impulse is full subsystem) — qualifies |
| 2 | Self-applying meta-test for new contracts — apply new contract to introducing feature's own artifacts. v0.2.18 PRD `## Criticisms` self-instance; v0.2.19 Execution Record on all 4 v0.2.19 slices (not just slice 008). Proves contract teachable + builds trust. | `memory/wiki/integration-gotchas.md` | Pattern at n=2; promotable from observation to validated pattern |
| 3 | Line-number ordering checks in smoke tests — anchor structural position (e.g., "section X between Y and Z") via `grep -nE` + integer comparison. Stronger than content-string match (which fails on rephrasing) yet still mechanical. | `memory/wiki/testing.md` | Reusable testing pattern; new entry alongside scoped regex + test-from-failure-mode |
| 4 | Drift class closure pattern works cycle 1. v0.2.18 narrative coherence test extension (README + DESIGN must reference `EXPECTED_RELEASE_VERSION`) caught v0.2.19 narrative drift on first bump — paid off immediately. Validates "fix instance AND extend test to close class" pattern from v0.2.18 retro. | `memory/wiki/integration-gotchas.md` | Reinforces existing v0.2.18 pattern; append validation observation rather than new entry |
| 5 | Bump checklist is now 5 places — plugin.json (canonical), marketplace.json (mirror), test-version-sot.sh `EXPECTED_RELEASE_VERSION`, README:19 narrative, DESIGN:3 narrative. Worth tracking for future "is centralization worth it" decision (e.g., single `.release-target` file). | `memory/wiki/integration-gotchas.md` | Operational detail; helps future-self avoid missing places |

## Not promoted to memory (one-off, captured here only)

- Implementation choice "committed delta only for Actual files" — defensible per typical commit-then-review workflow; if working-tree changes become important, expand in v0.2.20+. Specific to slice 008, not a durable pattern.
- tdd/SKILL.md growth (233 → 267 lines) — flagged in feature review as v0.3+ bash extraction candidate. Tracked there, not durable lesson.
- `MOVE_LINE=$(line_no 'Move file:')` brittleness risk in test-tdd-execution-record.sh — locked-in skill body wording. Acceptable trade-off; only worth durable lesson if it breaks in real refactor.

## Pending operator review

Operator approves Q&A + lesson destinations before write to `dogfood/appmaker/memory/`. Default: write 5 lessons to destinations above (1 to decisions.md, 1 to wiki/testing.md, 3 to wiki/integration-gotchas.md).
