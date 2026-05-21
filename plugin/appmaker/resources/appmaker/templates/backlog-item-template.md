# Backlog Item Template

Per-slice format for `appmaker/backlog/NNN-<slug>.md`. Used by `decompose` skill (and `feedback` skill for ad-hoc items).

## Template

```markdown
---
id: 008
slug: theme-context-setup
status: open                       # open | in_progress | done | blocked
labels: [feature, ui]              # feature | bug | feedback | refactor | architecture
execution_class: autonomous        # human_required | autonomous | conditional
blocked_by: []                     # list of backlog item IDs
traces_to: [pcrit-001, pcrit-003]  # PRD acceptance criteria IDs
feature: 003-add-dark-mode         # links to appmaker/features/<NNN>/
user_stories_covered: [1, 2, 5]    # PRD user story numbers
context_packets:
  - appmaker/context/2026-05-11-theme-context.md
touches:
  communities: [theme-state]
  files:
    - src/theme/provider.tsx
edit_scope:
  allow: [src/theme/, tests/theme/]
  forbid: [src/billing/, migrations/]
created: 2026-05-10
source: decompose                  # decompose | feedback | manual
---

# 008: Theme Context Setup

## Parent

`appmaker/features/003-add-dark-mode/prd.md`

## What to build

End-to-end ability for app to read current theme via React context. Default `light`. Setter via `useTheme()` hook.

Avoid file paths — they go stale. **Exception (per Matt Pocock canonical to-issues):** if `/appmaker:spike` produced a snippet (state machine, reducer, schema, type shape) encoding a decision more precisely than prose, inline here with note "from prototype". Trim to decision-rich parts only.

## Acceptance criteria

- [ ] `useTheme()` returns `{ theme, setTheme }` (traces_to: pcrit-001, test: tests/theme.test.ts::useTheme_returns_theme)
- [ ] `setTheme('dark')` updates context, triggers re-render (traces_to: pcrit-003, test: tests/theme.test.ts::setTheme_triggers_rerender)
- [ ] Toggle visual feedback feels responsive on Safari + Chrome (traces_to: pcrit-004, human-review: no flicker, < 300ms perceived latency)

## Implementation Decisions / Gray Areas

| Gray area | Decision | Evidence | Status |
|---|---|---|---|
| State owner | Use existing `src/theme/provider.tsx` | context packet + `rg -n "useTheme"` | resolved |
| Error behavior | ... | ... | resolved / Unresolved gray area / human_required |

## Architecture Options Research

**Required:** yes | no
**Status:** pending | complete | not_applicable
**Trigger:** architecture | library | storage | auth | billing | security | AI | design-system | migration | not_applicable

**Sources checked**
| Source | Query / URL | Why used | Key finding |
|---|---|---|---|
| local | `rg -n "theme|Theme" src tests` | existing owner | theme state already centralized |
| Ref | `ref_search_documentation: "React context theme provider"` | official docs / indexed resources | ... |
| GitHub | `<repo/example>` | mature implementation | ... |

**Options matrix**
| Option | Evidence | Pros | Cons / risks | Fit |
|---|---|---|---|---|
| Reuse existing provider | local evidence | least code | may need small extension | best |
| Add new provider | ... | isolated | duplicates state owner | reject |

**Decision**
- Chosen:
- Why:
- Rejected options:
- Reversal cost:
- Follow-up validation:

## Brownfield Impact Audit

**Mode:** brownfield | greenfield | not_applicable
**Audit status:** pending | complete
**Context packet(s):**
- ...

**Canonical values / hardcoded contracts**
| Value or contract | Search evidence | Owners / consumers | Decision |
|---|---|---|---|
| `theme` | `rg -n "theme|Theme" src tests` | `src/theme/*`, settings UI | migrate/add guard/defer |

**Dependency surface map**
| Surface | Reads | Writes | Mirrors / duplicates | Notes |
|---|---|---|---|---|
| UI / API / domain / tests / docs | ... | ... | ... | ... |

**Reuse / refactor-first decision**
| Existing code candidate | Current responsibility | Can be extended/generalized? | Decision |
|---|---|---|---|
| `src/theme/provider.tsx` | owns theme state | yes/no/unknown | reuse/extend/extract/replace/add-new + rationale |

**Visual system / CSS reuse**
| Visual element | Existing CSS/component primitive | Hardcoded styling found? | Decision |
|---|---|---|---|
| button / row / card / modal / badge | `.app-btn`, `.app-card`, etc. | `style=`, `cssText`, inline colors/sizes | reuse class / add variant / extract primitive / forbid inline |

**Design standards compliance**
| Element touched | Existing standard / pattern | States checked | Result |
|---|---|---|---|
| button / row / card / modal / badge | tokens, UI patterns, component inventory | default/hover/focus/disabled/loading/error/responsive | pass/gap + fix |

**Side-effect order**
- Guards before side effects:
- Side effects touched:
- Cache / audit / idempotency notes:

**Duplicate logic / mirrors**
- UI mirrors:
- Tool/agent schemas:
- Docs/examples:

**Test and lint guards**
- Unit / integration tests:
- Static/lint guards:
- Manual smoke:

**Deferred / intentionally not touched**
- ...

**Unknowns requiring human answer**
- ...

## Approved TDD Plan

Pending — filled by `/appmaker:tdd` after plan approval and before first RED test.

## TDD Plan Check

Pending — filled by `/appmaker:tdd` before first RED test. Required result: PASS or WARN with explicit accepted risk; FAIL blocks implementation.

## QA / Smoke Plan

Pending — filled by `/appmaker:tdd` before completion. Must name affected surfaces, manual/browser checks, screenshot requirements for UI, and rollback/refresh checks where relevant.

## Execution Record

**Base ref:** <sha | no_base_ref>
**Dirty at start:** yes/no
**Dirty files at start:**
- ...

**Planned files:**
- ...

**Planned tests:**
- ...

**Actual files:**
- ...

**Tests run:**
- ...

**AC completed:** <n>/<n>

**Drift notes:**
- ...

## Blocked by

None — can start immediately.
```

## Field semantics

| Field | Required | Notes |
|---|---|---|
| `id` | yes | Auto-incremented from existing backlog items (NNN format) |
| `slug` | yes | Kebab-case, ~3-5 words, derived from slice title |
| `status` | yes | `open` initial, transitions: open → in_progress → done; `blocked` if waiting on blocker |
| `labels` | yes | At least one. Multiple OK. |
| `execution_class` | yes | Per constitution rule 6. Default `autonomous`, escalate to `human_required` for non-delegable judgments. |
| `blocked_by` | yes | Empty list `[]` if no blockers. Otherwise list of backlog IDs. Cycle detection mandatory. |
| `traces_to` | yes (if from PRD) | List of PRD pcrit-IDs this slice addresses. Empty for ad-hoc items (e.g. feedback bugs). |
| `feature` | optional | Links to feature folder. Empty for project-level items. |
| `user_stories_covered` | optional | PRD user story numbers (1, 2, 5...). |
| `context_packets` | optional | `appmaker/context/*.md` snapshots used to plan this item. |
| `touches` | optional | Graphify-derived communities/files expected to be touched. Advisory, not scope expansion. |
| `edit_scope` | optional | Guard/freeze boundary. `allow` lists intended write areas; `forbid` lists paths that require explicit user approval or drift notes. |
| `created` | yes | ISO date. |
| `source` | yes | `decompose` (from PRD), `feedback` (from QA), `manual` (user-added). |

## When item moves to done/

After completion (status flips to `done`), move file to `appmaker/backlog/done/<YYYY-MM-DD>-<slug>.md`. Date prefix = completion date. Original ID preserved in front-matter.

## Rules

- **Front-matter mandatory.** All required fields present.
- **`What to build` describes end-to-end behavior.** Not layer-by-layer.
- **Acceptance criteria checkbox list** with inline annotations: `traces_to:` mandatory (links AC → PRD `pcrit-*`); `test:` optional for executable tests (form `<file>::<name>`, e.g. `tests/theme.test.ts::useTheme_returns_theme`) — closes AC ↔ test name drift; `human-review:` optional for manual ACs — must include explicit criterion describing what reviewer checks.
- **Implementation Decisions / Gray Areas comes before planning.** Unresolved gray areas that affect architecture/API/UI behavior must be resolved, deferred with risk, or marked `human_required` before `/appmaker:tdd` starts.
- **Brownfield Impact Audit is mandatory for existing systems.** If `project_mode: brownfield`, the section starts as `pending` during decomposition and must be `complete` before the first RED test. It must show evidence from searches, not only prose. Greenfield work may mark `Mode: greenfield` and `Audit status: not_applicable`.
- **Approved TDD Plan is durable.** `/appmaker:tdd` writes the user-approved plan before first RED test. Review/checklist compare this dry-run intent against `Execution Record` actual files/tests.
- **TDD Plan Check is mandatory.** PASS or accepted WARN before first RED; FAIL means revise plan or escalate.
- **Execution Record captures planned-vs-actual work.** Prefer auto-filled factual fields. Human writes only intent, AC status, and drift explanation. `Base ref` anchors the slice start, dirty fields document pre-existing worktree state, planned fields declare intended files/tests, actual fields record verified outcome, `AC completed` summarizes checkbox progress, and `Drift notes` explains deviations or says `(none)`.
- **Context packet links if used.** Don't paste Graphify output into backlog item.
- **Touches are advisory.** Confirm in code; don't implement graph neighbors unless AC requires it.
- **`Blocked by` explicit.** "None — can start immediately" if no blockers (don't omit section).
