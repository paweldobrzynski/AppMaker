---
feature: 001-method-compliance-pass-1
release: v0.2.18
created: 2026-05-17
lessons_extracted: 6
---

# Retro: 001-method-compliance-pass-1 (v0.2.18 release)

First AppMaker dogfood feature — Method applied to AppMaker plugin itself. Closes 9 PRD pcrits across 6 slices including 1 explicit PRD addendum (pcrit-009). All artifacts in `dogfood/appmaker/` (escapes `.gitignore /appmaker/` root-anchor).

## Q&A

| Question | Answer | Lesson |
|---|---|---|
| **Surprises?** | (1) PRD addendum pcrit-009 surfaced post-implementation; gap discovery proved Method discipline (Codex framed as "honest correction, not failure"). (2) Cross-slice drift in README:19 + DESIGN:3 caught only by feature-level review, never per-slice. (3) Codex review-gate value real on +9-line slice (slice 001 weak regex). | Method catches gaps you don't predict; gates compound (per-slice + feature-level both necessary). |
| **Differently?** | (1) Include release version bump in original PRD as pcrit-001 — avoid addendum class entirely when foreseeable. (2) Plan `dogfood/appmaker/` location BEFORE creating `appmaker/` — saved one mv operation post-Codex feedback. (3) Write tests from failure mode (what should FAIL), not from AC paraphrase — caught by Codex on slice 001. | Pre-PRD checklist: "list release-coherence invariants explicitly". Test-from-failure-mode beats test-from-AC-paraphrase. |
| **Reuse?** | (1) Codex-scoped regex pattern for drift tests (layout anchor `← X dirs` vs prose mention). (2) AskUserQuestion with previews for `human_required` slices (visual side-by-side). (3) Test EXTENSION over test CREATION — slice 006 reused `test-version-sot.sh` per Codex. (4) PRD addendum with `source: decompose-addendum` label preserves audit chain. | Pattern library: scoped-regex, preview-Q, extend-don't-create, source-addendum. |
| **Misfits?** | (1) `/appmaker:review` subagent was too heavy for tiny text-only slices; lightweight manual/Codex review worked per-slice, while feature-level review was still valuable for coherence — form must match scale. (2) `/appmaker:checklist` NOT invoked — would have caught manifest sync drift earlier if run pre-archive. (3) `/appmaker:next` NOT invoked — manual TDD slice-by-slice preferable for dogfood transparency. | Review-form scales with slice impact (text-only ≠ logic). `/appmaker:checklist` pre-archive belongs in checklist procedure. |

## Context packets referenced

None. v0.2.18 was text-level work (templates, docs, manifest); no codebase exploration needed.

## Lessons extracted (with proposed destination — pending operator approval)

| # | Lesson | Destination (proposed) | Matt's filter |
|---|---|---|---|
| 1 | METHOD.md correction: PRD upstream source of intent, NEVER rollup of slices. Inverting traceability creates circular dependency. | `memory/decisions.md` | Hard-to-reverse AND surprising — qualifies |
| 2 | Dogfood location: `dogfood/appmaker/` (not `appmaker/`) — escapes plugin source `.gitignore /appmaker/` rule | `memory/decisions.md` | Architectural; reversal requires migration |
| 3 | Test extension > test creation when contract already exists in adjacent test (slice 006 reused `test-version-sot.sh` per Codex) | `memory/wiki/testing.md` | Reusable testing pattern |
| 4 | Scoped regex pattern for documentation drift (layout-anchor `← X dirs` distinguishes from changelog narrative `"X dirs" → "Y dirs"`) | `memory/wiki/testing.md` | Reusable testing pattern |
| 5 | Cross-slice review gate catches different errors than per-slice — both necessary (per-slice = local, feature-level = coherence) | `memory/wiki/integration-gotchas.md` | Process insight worth durable capture |
| 6 | PRD addendum (`source: decompose-addendum`) is honest correction, not failure — preserves audit chain vs silent backfill | `memory/wiki/integration-gotchas.md` | Pattern for handling post-implementation discovery |

## Not promoted to memory (one-off, captured here only)

- Slice 001 weak test specifics — too narrow; captured under lesson #4 (scoped regex) durably.
- AskUserQuestion previews UX observation — useful but lower priority than #5/#6 in retro/wiki seeding.
- Operator-relayed Codex advisor pattern — sample size n=1 (this session). Capture in retro for posterity; promote to wiki only if pattern repeats in next feature.
