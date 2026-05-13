# Case Study: caseman BPS Risk Score — first AppMaker production feature

**Date:** 2026-05-11
**Project:** caseman (Apps Script clinical case management, single-operator)
**Feature:** `001-bps-risk-compute` — replace operator-manual BPS Risk Score with deterministic compute
**AppMaker version used:** v0.2.x (multiple patches through session)
**Outcome:** **5/7 slices shipped to production**, 4 library deploys, 21 unit tests passing

## Session metadata

| Field | Value |
|---|---|
| Session ID | `fe0e241c-3f70-427b-9f27-d65356f4a364` |
| Duration | 2026-05-11T08:35 → 14:04 (**~5h 30min**) |
| Plugin commands invoked | All 16 (15 core + AFK) |
| Bash tool calls | 81 |
| Errors recovered | 4 (1 zsh, 1 Python 3.9, 1 openai pkg, 1 ls exit) |
| User decisions captured (AskUserQuestion) | 15+ |

## Workflow trace

| Step | Outcome |
|---|---|
| `/appmaker:init` | Brownfield, local backlog, Graphify YES, Forest's CLAUDE.md merge, session hook YES, pre-commit NO. Auto-detected: clasp/Apps Script test commands, lint via `scripts/check_architecture.js` |
| Graphify install | Python 3.9 too old → pipx workaround → graph built (799 nodes, 2012 edges, 37 communities) using Gemini key from caseman's Script Properties |
| `/appmaker:start` | Classified as `feature`, suggested chain grill-brownfield → interview → prd → decompose → checklist → tdd → review → archive |
| `/appmaker:grill-brownfield` | Glossary populated with 5 rich domain terms (BPS, BPS Risk Score, Risk band, BPS rule, Aggregator-first BPS) — each with file references + line numbers |
| `/appmaker:interview` | Skipped (single-stakeholder feature, explicit user note) |
| `/appmaker:prd` | Full Understanding section (7 subsections), Implementation Decisions, Testing Decisions, 9 user stories, 9 SC + 9 ID criteria |
| `/appmaker:decompose` | 7 slices, cycle-checked, topological order, 8/8 SC coverage |
| `/appmaker:tdd 001-005` | 5 slices implemented through RED-GREEN cycles, 21 tests passing |
| `/appmaker:checklist` | 1 deterministic report persisted |
| `/appmaker:review` | 10 invocations, 0 files (gap identified, fixed in v0.2.4) |
| `/appmaker:archive` | Pending — slices 006 + 007 not done |

## Production evidence

| Commit | What |
|---|---|
| `3a684c5` | chore(workflow): bootstrap AppMaker + Graphify + Forest CLAUDE baseline |
| `64bfcc7` | feat(bps): replace manual BPS Risk Score with deterministic compute (slices 001+003) |
| `54400d5` | chore(deploy): bump Mgc library to v224 |
| `031a4bf` | feat(bps): wire MH-severity inputs from QuestionnaireHistory (slice 002 Phase B) |
| `2a9366c` | chore(deploy): bump Mgc library to v225 |
| `66c7663` | feat(bps): nightly recompute pass + pre-compute snapshot (slices 004 + 005) |
| `d51c705` | chore(deploy): bump Mgc library to v227 |

4 production deploys with explicit slice tracking in commit messages.

## Tests state

`tests/bps_compute.test.js` — 21 PASS / 0 FAIL covering:
- Terminal status short-circuit (multiple variants)
- Mental health severity rules (PHQ-9, GAD-7 brackets)
- Claim age rules
- Non-string input defensiveness
- Highest-band wins composition

Real RED → GREEN cycles visible in session log (4 FAIL → fixes → 19 PASS → 21 PASS).

## What worked

| Element | Evidence |
|---|---|
| Plugin loads in real session | All 16 commands invokable |
| Critical path executes | init through tdd validated |
| Auto-byproduct glossary update | 5 domain terms with file:line refs |
| Auto-detect project commands | Detected Apps Script clasp specifics, custom test runner pattern |
| AC checkbox tracking | 37/37 ACs marked across 5 done slices |
| TDD discipline enforced | RED-GREEN visible in test counts |
| Checklist persistence | 1 file in `appmaker/checklists/` |
| Code references AppMaker artifacts | `domain/bps-rules.js` comment cites `appmaker/features/001-bps-risk-compute/prd.md` |
| Graphify integration | Graph built, used cross-session (GAT-7 bug investigation) |

## What broke / gaps

| Issue | Cause | Fix |
|---|---|---|
| zsh `status` read-only | macOS default `$SHELL=/bin/zsh`, Claude Code Bash tool inherits | v0.2.2 patch — guidance on safe variable names |
| Python 3.9 too old for graphifyy | System Python is 3.9, graphifyy requires ≥3.10 | pipx via brew installed pipx, isolated install |
| `openai` package missing for graphify | Graphify pass-3 needs LLM client | Injected, re-ran |
| `/appmaker:review` 10 invocations, 0 files | Skill said "writes X" but Claude treated as suggestion not instruction | v0.2.4 patch — MANDATORY persistence z explicit Bash heredoc |
| `/appmaker:context` 9 invocations, 0 packets | Same root cause | v0.2.4 patch |
| `/appmaker:afk` 6 invocations, 0 reports | Same root cause | v0.2.4 patch (also handles early-exit case) |
| User bypassed `/appmaker:diagnose` for GAT-7 bug | Plugin nie był first-choice — quick manual investigation preferred | TBD v0.2.5 — diagnose UX promotion |

## Lessons

| Lesson | Source |
|---|---|
| Plugin self-containment matters | Reviewer caught early — resources had to be packaged, materialized by init |
| Dynamic injection (` ```! `) blocks permission check, not viable | v0.2.1 patch — environment vs docs mismatch |
| Skills must explicitly invoke Bash tool for side effects | v0.2.4 — saying "writes X" isn't enough; explicit Bash heredoc with `test -f` verification |
| zsh-reserved variables silently fail | macOS-specific gotcha, must be documented |
| Graphify-Anthropic substitution works | Gemini key from caseman's Script Properties was reused successfully for pass-3 |
| Interview can be safely skipped for single-stakeholder features | PRD inherits `readiness: ready` with explicit note in frontmatter |
| Real TDD discipline emerges with checkbox tracking | 37/37 ACs marked, RED→GREEN visible in test counts |
| Code-citing AppMaker artifacts adds durability | `domain/bps-rules.js` comments survive long after session ends |

## Time breakdown (rough)

| Phase | ~Time |
|---|---|
| Init + Graphify install + setup | 30min |
| Grill-brownfield + glossary | 30-45min |
| PRD synthesis + module sketch | 30-45min |
| Decomposition (7 slices) | 30min |
| TDD per slice (5 slices) | ~30min × 5 = 2h 30min |
| Production deploys + library bumps | 15-20min |
| **Total** | **~5h 30min** |

## Hypothesis to test in next feature

| Hypothesis | Test |
|---|---|
| Memory wiki teaches agent caseman patterns → faster setup | Second feature setup should take < 1h vs 3.5h for first |
| Context packets reduce Bash duplication | Per-slice TDD should require fewer Bash calls if context packet pre-computed |
| /appmaker:diagnose finds adoption hook | Second bug should attempt `/appmaker:diagnose` not manual investigation |
| Review/context/afk persistence v0.2.4 fix works | Second feature should leave actual files in those dirs |

## Verdict

### ✓ Validated (with evidence)

| Claim | Evidence |
|---|---|
| Plugin loads in real session | All 16 commands invokable |
| Critical path executes end-to-end (init → grill → prd → decompose → tdd) | Session log, 5/7 slices shipped |
| Production code shipped through workflow | Commits `64bfcc7`, `031a4bf`, `66c7663`; library `Mgc` v224→v227, 4 deploys |
| TDD discipline emerges with checkbox tracking | 37/37 ACs marked, RED→GREEN visible in test counts; `bps_compute.test.js` 21 PASS |
| Auto-byproduct glossary update | 5 domain terms populated with `file:line` refs after grill |
| Auto-detect project commands | clasp/Apps Script detected, custom test runner pattern handled |
| Graphify integration as read-only layer | 799-node graph built, cross-session reuse for GAT-7 bug |
| Code references AppMaker artifacts | `domain/bps-rules.js` cites `appmaker/features/001-bps-risk-compute/prd.md` |

### ✗ Not yet validated (hypotheses for next run)

| Hypothesis | Test |
|---|---|
| Full lifecycle through `/appmaker:archive` works end-to-end | Finish slices 006 + 007, run `/appmaker:archive 001-bps-risk-compute`, confirm retro flow |
| v0.2.4 persistence patches hold (review/context/afk write files reliably) | Second feature: count `/appmaker:review` invocations vs files in `appmaker/reviews/`; expect 1:1 |
| Memory wiki proactive read (v0.2.7) reduces setup time | Second feature setup target: < 1h vs 3.5h baseline. Measured via session timestamps |
| v0.2.7 LLM-grounded next-action refinement adds signal | Compare deterministic vs refined suggestions across 5 `/appmaker:status` calls in next session |
| v0.2.9 fix #2 (backlog/done counting) | Run `/appmaker:status` after first slice moves to `done/`; expect `1/N done` not `0/N` |
| Token diet (v0.2.10 skip-empty-wiki) saves measurable tokens | `/appmaker:token-audit` baseline before + after v0.2.10 upgrade |

### Honest statement

**AppMaker is validated on the critical path (build → ship), not yet on the full lifecycle (build → ship → archive → repeat).** "Production-grade workflow tool" is the goal; current achievement is "shipped real code through the build path on first attempt; lifecycle closure + repeatability are the next gates."
