---
date: 2026-05-17
plugin_version: 0.2.17
method_version: METHOD.md (2026-05-17 draft)
status: complete
---

# Method vs Plugin Audit — v0.2.17

Systematic check: for each Method element (4 disciplines + 3 contracts + rhythm), does the plugin enforce it? Cite `file:line`. Classify gap severity.

**Purpose:** empirically ground v0.3 decisions. Replace "I noticed 3 gaps" with "I checked all elements; here are 9 gaps ranked".

## Summary

| Bucket | Count | Method elements |
|---|---|---|
| NONE (fully enforced) | 10 | constitution seed, glossary two-tier, memory wiki + linting, traces_to chain (slice + AC sides), determinism 3 tiers, decision filter, pre-flight, apply, debrief-review-part, persistence discipline |
| LOW | 3 | constitution count not linted, AC-in-code comments convention-only, archive split |
| MEDIUM | 3 | PRD explicit pcrit section, AC↔test name mapping, debrief drift detection |
| HIGH | 3 | slice-as-primary-unit (5-file contract), plan.md missing, slices live in backlog not feature folder |

**Top finding:** 3 HIGH gaps cluster around one root cause — **slice is not a primary durable unit in the plugin**. Plugin's "slice" = 1 row in `decomposition.md` + 1 file in `backlog/NNN-slug.md` + TDD plan in conversation + review appended back to backlog file. Method demands `features/NNN/slices/NN-slug/` directory with 5 named files. This is the single architectural decision driving v0.3.

The 3 MEDIUM gaps are secondary effects of the HIGH cluster: PRD pcrit anchor + AC→test mapping + drift detection all become trivial when slice subfolder exists with `requirements.md`, `acceptance.md`, `plan.md`, `evidence.md` as named files.

The 3 LOW gaps are isolated polish items, not architectural.

## Discipline 1 — Bounded context

| Element | Plugin status | Evidence | Severity |
|---|---|---|---|
| Constitution ≤7 rules | ENFORCED via seed; convention only | `init/SKILL.md:212-224` (7-rule heredoc seed); `decompose/SKILL.md:67` guardrail "constitution rule 6"; no lint check | LOW |
| Glossary ubiquitous language | FULLY ENFORCED (two-tier) | `hooks/glossary-extract.sh` (Tier 1 deterministic); `glossary/SKILL.md` (Tier 2 semantic); invoked by `prd:5`, `decompose:7`, `tdd:8`, `grill-brownfield:5`; CLAUDE.md pointer in `init/SKILL.md:246-272` | NONE |
| Memory wiki compiled/queryable/linted | FULLY ENFORCED | `init/SKILL.md:63` creates `memory/{wiki,raw,...}`; pre-flight cat in 8 generator skills; `checklist/SKILL.md:53-57` lints broken links FAIL + stale 30d WARN + raw orphans WARN; compiler analogy in DESIGN.md decision 32 | NONE |
| Constitution count lint check | NOT ENFORCED | Convention via init seed + guardrail "Don't write 18 constitutional rules. 7 max in seed" (`init/SKILL.md:373`); checklist has no rule-count check | LOW |

## Discipline 2 — Traceable intent

| Element | Plugin status | Evidence | Severity |
|---|---|---|---|
| PRD has stable criticism IDs | PARTIAL — referenced but not structurally produced | `checklist/SKILL.md:42` checks "PRD criterion IDs"; `checklist/SKILL.md:100-104` accepts `pcrit-NNN` OR `SC1`/`ID4`; **but** `prd/SKILL.md:84-155` template has User Stories + Implementation Decisions, NO explicit `## Criticisms` section with numbered IDs. Case study (Caseman BPS) used `SC*`/`ID*` ad-hoc | MEDIUM |
| Slice → pcrit traces_to | FULLY ENFORCED | `templates/backlog-item-template.md:15` `traces_to: [pcrit-001, pcrit-003]` in YAML; `decompose/SKILL.md:74` guardrail "traces_to per AC mandatory"; `decomposition-template.md:24-28` "Covers PRD criteria" column | NONE |
| AC → pcrit traces_to | FULLY ENFORCED | `templates/backlog-item-template.md:42-43` AC checkbox with `(traces_to: pcrit-001)` inline; `tdd/SKILL.md:89` "each behavior maps to AC traces_to" | NONE |
| AC → test name mapping | NOT ENFORCED | `tdd/SKILL.md:162-166` marks AC checkbox `[x]` per RED-GREEN cycle, but doesn't append test function name. Implicit timing only. Code rename → AC orphaned, no detection | MEDIUM |
| Production code → AC linkage | CONVENTION ONLY | Case study: `domain/bps-rules.js` cites `features/001-bps-risk-compute/prd.md` (file-level, not AC-level); no skill enforces AC ID in code comments | LOW |

## Discipline 3 — Per-feature folder

| Element | Plugin status | Evidence | Severity |
|---|---|---|---|
| `features/NNN-slug/` exists | FULLY ENFORCED | `init/SKILL.md:63` creates `features/`; `interview/SKILL.md:42-49` allocates NNN-slug; `grill-brownfield/SKILL.md:99-104` allocates folder + writes interview-result.md | NONE |
| Feature artifacts in folder | PARTIAL | `interview-result.md`, `prd.md`, `decomposition.md`, `review.md`, `retro.md` ALL in `features/NNN/`. **BUT** slices live in `appmaker/backlog/NNN-slug.md` (separate location) | HIGH |
| `slices/NN-slug/` subfolder per slice | NOT ENFORCED | No skill creates `features/NNN/slices/NN-slug/` subfolder. `tdd/SKILL.md:196` mentions "appmaker/backlog/NNN.md → appmaker/backlog/done/" — slice lives in backlog, not in feature/slices. `features/NNN/slices/` referenced in archive structure (`archive/SKILL.md:155`) but never created by any generator | HIGH |
| `slices/NN/{requirements,blueprint,acceptance,plan,evidence}.md` 5-file contract | NOT ENFORCED | Out of 5 mandatory files: requirements ≈ scattered (PRD section + backlog "What to build" + decomposition row); blueprint ≈ implicit (decomposition + TDD plan in conversation); acceptance ≈ backlog AC list (single file); plan ≈ MISSING (TDD plan not persisted); evidence ≈ partial (review.md exists but no plan-vs-actual diff) | HIGH |
| `features/archive/YYYY-MM-DD-NNN-slug/` | PARTIAL | `archive/SKILL.md:54-55` moves feature folder; `:51-52` moves backlog items to `backlog/done/<YYYY-MM-DD>-NNN-slug.md` (separate destination). Method demands all slice artifacts archive WITH feature | LOW (HIGH if slice-as-primary adopted) |
| No important state in chat | FULLY ENFORCED | v0.2.4 persistence patches (`review/SKILL.md:124`, `context/SKILL.md:57`, `afk/SKILL.md`); all artifacts explicit Bash heredoc + `test -f` verification | NONE |

## Discipline 4 — Determinism over judgment

| Tier | Plugin status | Evidence | Severity |
|---|---|---|---|
| Tier 1 deterministic | FULLY ENFORCED | `hooks/glossary-extract.sh` (pure bash, idempotent, `set +e`, exit 0/1); `hooks/session-start.sh` (read-only filesystem); `checklist/SKILL.md:60-72` deterministic checks via `test -f`/`rg`/`find -mtime`; `next/SKILL.md:23-85` state machine via filesystem read; `tests/smoke/` test harness 22 assertions | NONE |
| Tier 2 documented criterion | FULLY ENFORCED | `init/SKILL.md:173-195` decisions.md seed with Matt's filter inline; `archive/SKILL.md:105-118` applies criterion in retro; `constitution.md` 7 rules user-applied | NONE |
| Tier 3 LLM judgment | FULLY ENFORCED | `review/SKILL.md:81-99` Agent tool with code-reviewer subagent; `review/SKILL.md:102-122` `--mode=ultra` delegates to `/ultra-review`; `glossary/SKILL.md` Tier 2 semantic review | NONE |

## Contract 1 — Slice contract

**Method demands 5 files per slice:** requirements, blueprint, acceptance, plan, evidence.

| File | Plugin location | Status |
|---|---|---|
| requirements.md | Scattered: PRD `## User Stories` + backlog `## What to build` (`backlog-item-template.md:28-37`) + decomposition row | NOT CONSOLIDATED |
| blueprint.md | Implicit: decomposition row + TDD Plan output (`tdd/SKILL.md:103-118` table format) — only in conversation/chat | NOT PERSISTED |
| acceptance.md | Backlog AC list (`backlog-item-template.md:41-43`) | EXISTS (in different file) |
| plan.md | MISSING entirely | NOT PERSISTED |
| evidence.md | Partial: review.md appended to backlog file (`review/SKILL.md:163-173`) — covers review portion, no plan-vs-actual diff | PARTIAL |

**Severity: HIGH.** 2/5 files missing as named artifacts, 3/5 scattered across 3+ locations.

## Contract 2 — PRD contract

**Method demands 3 sections:** Understanding, Clarifications, Criticisms (with stable IDs).

| Section | Plugin status | Evidence |
|---|---|---|
| Understanding (7 subsections) | FULLY ENFORCED | `prd/SKILL.md:95-117` explicit template with 7 named `###` subsections; guardrail "Understanding section mandatory" line 195 |
| Clarifications | ENFORCED (slot reserved) | `prd/SKILL.md:119` explicit `## Clarifications (auto-populated by /appmaker:clarify if invoked)` |
| Criticisms with pcrit-* IDs | NOT STRUCTURALLY PRODUCED | PRD template has User Stories (numbered) + Implementation Decisions (table) + Testing Decisions, but NO explicit `## Criticisms` or `## Acceptance Criteria` section. `traces_to: [pcrit-*]` downstream references something the PRD template doesn't structurally emit. Case study used ad-hoc `SC*`/`ID*` |

**Severity: MEDIUM.** 2/3 sections enforced, 3rd is implicit. PRD template should have explicit Criticisms section emitting `pcrit-NNN` (or project-allowed alt) as numbered list — that's the anchor traces_to references.

## Contract 3 — Decision contract

**Method demands:** hard-to-reverse AND surprising-without-context filter applied to durable decision log.

| Element | Plugin status | Evidence | Severity |
|---|---|---|---|
| Filter applied at decision-capture time | FULLY ENFORCED | `init/SKILL.md:178-184` seed includes filter inline as decisions.md header; `archive/SKILL.md:105-118` retro step 5 applies filter when reading interview-result.md "Architectural decisions surfaced" + retro answers | NONE |
| decisions.md lifecycle | FULLY ENFORCED | v0.2.16 patch wired archive retro → decisions.md (DESIGN.md decision 33 v0.2.16 sub-point 2) | NONE |

## Rhythm — Pre-flight / Dry-run / Apply / Debrief

| Phase | Plugin status | Evidence | Severity |
|---|---|---|---|
| R1 Pre-flight (constitution + glossary + wiki + AC) | FULLY ENFORCED | Step 0 "Pre-flight: read memory wiki (MANDATORY)" in `grill/SKILL.md`, `grill-brownfield:18-37`, `interview:18-37`, `prd:27-48`, `decompose:20-39`, `tdd:42-61`, `review:29-48`, `diagnose`. `wiki_preflight_mode` config flag (`auto`/`always`/`never`). Skip empty pages guard (≤5 lines) for token diet | NONE |
| R2 Dry-run (write plan.md) | NOT ENFORCED | `tdd/SKILL.md:80-149` Planning step produces "TDD Plan" output (table or headings) — shown in conversation, gets user approval, but NOT written to `slices/NN/plan.md`. No skill persists plan as named artifact | HIGH |
| R3 Apply (TDD execution) | FULLY ENFORCED | `tdd/SKILL.md:150-181` RED-GREEN-REFACTOR (Matt 1:1); AC checkbox updates per cycle; constitution rule 3 + rule 7 enforced at step 7 verification | NONE |
| R4 Debrief — review part | FULLY ENFORCED | `review/SKILL.md` full critic gate, MANDATORY persistence (v0.2.4), PASS/FAIL classification, structured findings | NONE |
| R4 Debrief — drift detection part | NOT ENFORCED | No plan-vs-actual diff because no plan.md exists. Review covers code quality + AC coverage + constitution + glossary + graph context + memory regression, but cannot diff "what I said I'd touch" vs "what I actually touched" | MEDIUM |

## Ranked gap list

### HIGH (3 — all cluster around slice-as-primary-unit)

| # | Gap | Method element | Root cause |
|---|---|---|---|
| H1 | Slices live in `backlog/NNN-slug.md`, not in `features/NNN/slices/NN-slug/` | D3b, D3c | Architectural: backlog is a separate state surface from feature folder. Pre-Method, this seemed orthogonal (backlog = work queue; feature folder = spec). Method reframes: slice IS the feature unit, work queue is a view over it. |
| H2 | 5-file slice contract not honored (plan + evidence missing, others scattered) | C1 | Same root as H1 — without slice subfolder, the 5 files have nowhere coherent to live |
| H3 | `plan.md` (R2 dry-run) not persisted | R2 | Sub-symptom of H1+H2. Even if other 4 files existed, plan.md is the unique novel artifact Method introduces |

### MEDIUM (3 — secondary effects of HIGH cluster + one independent)

| # | Gap | Method element | Becomes trivial after HIGH fixed? |
|---|---|---|---|
| M1 | PRD lacks explicit `## Criticisms` section with stable IDs | C2 | NO — independent. PRD template needs explicit Criticisms section emitting `pcrit-NNN` numbered list |
| M2 | AC ↔ test name mapping not durable | D2d | PARTIAL — if `acceptance.md` per slice has `traces_to_test:` field per AC, mapping becomes explicit |
| M3 | Debrief drift detection (plan-vs-actual diff) missing | R4 | YES — trivially follows from H3 (plan.md exists) + extension to review skill to diff plan→evidence |

### LOW (3 — polish, no architectural blocker)

| # | Gap | Severity rationale |
|---|---|---|
| L1 | Constitution rule count (≤7) not lint-checked | Convention works in practice (init seeds 7, guardrail says max 7); lint would catch user edits adding rule 8 |
| L2 | Production code → AC linkage convention only | Case study evidence shows convention works (`domain/bps-rules.js` cites prd.md path); enforcement would be heavy-handed |
| L3 | Archive splits feature folder (`features/archive/...`) from backlog items (`backlog/done/...`) | Acceptable if slice-as-primary-unit NOT adopted; becomes HIGH inconsistency if H1 fixed (slices archive with feature) |

## NONE (Method fully enforced, surfaced for completeness)

10 elements enforced with strong evidence — these are AppMaker's mature core, evidence that the plugin is largely Method-compliant:

1. Constitution seed (7 rules, user-owned)
2. Glossary two-tier maintenance (deterministic extract + semantic review)
3. Memory wiki compile/query/lint (full Karpathy-compiler analogy)
4. `traces_to` chain at slice + AC level
5. Determinism Tier 1 (bash hooks + checklist + test harness)
6. Determinism Tier 2 (constitution + Matt's decision filter)
7. Determinism Tier 3 (review subagent + ultra-review delegation)
8. Decision filter applied at retro
9. Pre-flight read in 8 generator skills
10. Persistence discipline (v0.2.4 patches)

## v0.3 PRD inputs

Based on this audit, a v0.3 PRD using Method should propose `pcrit-*` covering:

| pcrit suggestion | Addresses gap(s) | Rationale |
|---|---|---|
| pcrit-001: Introduce `features/NNN/slices/NN-slug/` subfolder as primary slice location | H1, H2 | Single architectural change; backlog becomes derived view over slice subfolders |
| pcrit-002: Persist 5 files per slice (requirements, blueprint, acceptance, plan, evidence) | H2 | Each of 5 has defined shape; generators produce them deterministically |
| pcrit-003: `/appmaker:tdd` writes `slices/NN/plan.md` BEFORE implementation (dry-run gate) | H3, M3 | Plan-vs-actual diff becomes natural follow-up |
| pcrit-004: `/appmaker:review` extends to diff plan.md vs evidence.md; drift = WARN/FAIL | M3 | Closes audit chain at the apply boundary |
| pcrit-005: PRD template adds explicit `## Criticisms` section with `pcrit-NNN` (or project alt) numbering | M1 | Independent of slice-as-primary; pure template change |
| pcrit-006: `acceptance.md` per slice has `traces_to_test: <test_name>` per AC | M2 | Closes AC ↔ test name drift surface |
| pcrit-007 (optional): `/appmaker:checklist` lints constitution rule count ≤7 | L1 | Cheap polish; one regex check |
| pcrit-008 (optional): Archive moves slice subfolder into `features/archive/.../slices/` instead of `backlog/done/` | L3, follows from pcrit-001 | Consistency once H1 fixed |

**Out of v0.3 scope (deferred to vNext):**
- Production code → AC linkage enforcement (L2) — convention currently sufficient
- Aviation metaphor framework — separate marketing/learning concern, not structural

## Honest caveats

This audit was performed against METHOD.md (2026-05-17 draft). If Method statement itself is revised (e.g., dropping the 5-file slice contract in favor of "3 files + 2 sections inside `decomposition.md`"), the HIGH gaps disappear and v0.3 reduces to MEDIUM fixes only.

The Caseman BPS case study (the only real-world Method validation to date) shipped 5/7 slices with the current scattered representation. **The plugin's current architecture is not broken**; it just doesn't match the Method statement we wrote two days ago. v0.3 decision is: do we lift the plugin to match the new Method, or revise the Method to match the validated plugin?

This audit recommends the former (lift plugin) because:
- The scattering pre-existed Method statement; it was implicit not deliberate
- Slice subfolder with 5 files is a natural simplification (one place per slice vs 3+ places)
- Plan-vs-actual drift detection is the genuine missing primitive in the audit chain (`pcrit-*` → AC → test → code is incomplete without plan as the bridge between "intent" and "execution")

But the latter is a valid alternative if the user decides Method overreaches.
