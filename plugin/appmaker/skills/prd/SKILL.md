---
description: Synthesize PRD from existing conversation context (interview-result.md + optional spike output). Adopts Matt Pocock to-prd 1:1 plus AppMaker extensions Understanding section (7 subsections), Clarifications block, verifiability discipline per decision, prd ↔ spike integration. Use when feature interview is complete and user wants to synthesize PRD.
disable-model-invocation: true
---

Synthesize PRD. **Do NOT interview** — synthesize what's already in conversation context + interview-result.md. Adopts Matt Pocock `to-prd` (canonical, MIT) plus AppMaker extensions.

**Output style:** Follow `appmaker/skills/output-style.md`. PRD-specific: Understanding uses `###` per-subsection headings (7 subsections), Implementation Decisions as **table** (Decision | Verification | Traces), Testing Decisions as **bullets**, User Stories as **numbered list**. No prose walls. No ASCII separators.

## When to invoke

- Manual: `/appmaker:prd` (latest interview) or `/appmaker:prd <folder>`
- Auto: by `start` on feature workflow continuation post-interview
- AFK-safe: NO — module sketch confirmation requires human review; writes PRD artifact (side effect)
- Required state: `interview-result.md` with `readiness: ready` OR `readiness: ready_with_override` (source can be `interview` OR `grill-brownfield` — v0.2.14)
- Required input: feature folder path (auto-detected if latest non-PRD'd feature obvious)

**Input source paths (v0.2.14):**
- Greenfield: `/appmaker:interview` writes `interview-result.md` with `source: interview, readiness: ready`
- Brownfield (direct): `/appmaker:grill-brownfield` step 5 writes `interview-result.md` with `source: grill-brownfield, readiness: ready_with_override` (override_reason documents that brownfield grilling covered interview dimensions)
- Brownfield (wrapped): `/appmaker:interview` internally invokes `grill-brownfield` then structures output — same artifact shape

PRD does NOT branch on source — same synthesis logic regardless. The source field is metadata for audit trail.

## Process

### 0. Pre-flight: read memory wiki (MANDATORY)

PRD synthesis must respect existing architectural decisions + domain invariants. Read these BEFORE drafting Understanding section.

```bash
# Pre-flight wiki cat — respects wiki_preflight_mode config flag (v0.2.12)
WIKI_MODE=$(grep '^wiki_preflight_mode:' appmaker/config.yaml 2>/dev/null | awk '{print $2}')
WIKI_MODE="${WIKI_MODE:-auto}"
if [ "$WIKI_MODE" != "never" ]; then
  for page in architecture domain-model; do
    f="appmaker/memory/wiki/${page}.md"
    # Skip missing or header-only files (≤5 lines = seed stub, not real content yet) — saves tokens on fresh projects
    if [ -f "$f" ] && [ "$(wc -l < "$f")" -gt 5 ]; then
      echo "─── $f ───" && cat "$f"
    fi
  done
fi
```

Cite as `per wiki/architecture.md: <decision>` in the PRD's Implementation Decisions section when a wiki entry directly drives a decision. If the wiki contradicts what the user proposed in interview, raise via AskUserQuestion before drafting — don't silently override either source.

Note: this supersedes the prior "lazy-read only pages related to feature" guidance — read these two pages ALWAYS, additional pages as relevant.

### 1. Locate feature folder

If user invoked without arg, find latest `appmaker/features/<NNN-slug>/` with `interview-result.md` and no existing `prd.md`. Confirm via AskUserQuestion.

If `interview-result.md` readiness is `needs_more_input` or `reject` — refuse, suggest `/appmaker:interview` continuation or `/appmaker:clarify`.

### 2. Read context (parallel reads OK)

- `appmaker/features/<NNN>/interview-result.md` — primary input
- `appmaker/features/<NNN>/spike-output/` if exists (snippets for prototype exception)
- `appmaker/glossary.md` — use canonical terms
- `appmaker/constitution.md` — respect 10 bounded rules
- `appmaker/memory/index.md` + relevant `appmaker/memory/wiki/*.md` — durable project knowledge, lazy-read only pages related to feature
- Codebase context via `/appmaker:context` (Graphify if available, else file reads). Save packet path in PRD.

### 3. Sketch major modules

Identify modules to build/modify. Look for **deep modules** — encapsulate functionality behind simple, testable, rarely-changing interfaces.

Output sketch as table:
```
| Module | Type | Interface (1-line) | Test scope |
|---|---|---|---|
| AuthMiddleware | new | extracts tenant from JWT | yes |
| ThemeContext | new | provides theme + setter via React context | yes |
| StorageAdapter | modify | add localStorage tier | no (integration) |
```

Confirm via AskUserQuestion: do modules match expectations? Which want tests?

### 4. Write PRD using template

Save to `appmaker/features/<NNN>/prd.md`:

```markdown
---
feature: add-dark-mode
folder: 003-add-dark-mode
created: 2026-05-11
last_updated_by: prd
readiness: inherited
---

# PRD: Add Dark Mode

## Understanding (7 subsections — AppMaker extension)

### Users / buyers / operators
[Who uses, who pays, who operates this.]

### Domain invariants
[Things that must always be true.]

### Identity model
[How identity flows through feature.]

### Trust boundaries
[Where untrusted input crosses into trusted execution.]

### Non-delegable judgments
[Decisions that MUST stay human. Identity/money/irreversible/security.]

### Verifiable success criteria
[Each = auto-check OR human-review-with-criteria. No vague goals.]

### Failure modes / unacceptable outcomes
[What we explicitly want to NOT happen.]

## Clarifications (auto-populated by /appmaker:clarify if invoked)

## Criticisms

Numbered criticisms — each = one tight MUST/MUST NOT statement. Stable `pcrit-NNN` IDs anchor downstream `traces_to` (decomposition + backlog).

Per criterion: verification mechanism explicit — `auto-check` (scripted) OR `human-review-with-criteria` (documented rule).

- **pcrit-001:** <one-line criterion>. Verification: `auto-check` via `<assertion>`.
- **pcrit-002:** <one-line criterion>. Verification: `human-review-with-criteria: <rule>`.

## Problem Statement

## Solution

## User Stories

LONG numbered list. Format: "As an <actor>, I want <feature>, so that <benefit>"

## Implementation Decisions

For each decision, mark **verification**: `auto-check` OR `human-review-with-criteria`.

Capture gray areas explicitly: API shape, data ownership, UI states, error handling, external services, and dependency choices. Unresolved gray areas must become PRD questions or `human_required` slice notes; don't let them silently become TDD assumptions.

For high-impact architectural choices, complete `Architecture Options Research`: read `appmaker/skills/architecture-options-research.md` and finish an options matrix before finalizing the decision. Use local context first, then Ref (`ref_search_documentation` + `ref_read_url`) for official docs/private indexed docs/GitHub resources, with targeted web fallback only when Ref lacks coverage.

**Do NOT include file paths or code snippets** — they age fast.

**Exception (per Matt Pocock canonical to-prd):** if `/appmaker:spike` produced a snippet (state machine, reducer, schema, type shape) encoding a decision more precisely than prose, inline within the relevant decision and note "from prototype". Trim to decision-rich parts only.

## Testing Decisions
- **What makes a good test:** behavior, not implementation. Constitution rule "Real boundaries in integration tests".
- **Modules being tested:**
- **Prior art:**

## Existing System Context

Context packet(s):
- `appmaker/context/2026-05-11-auth-tenancy.md`

Affected communities/modules:
- [Only include if Graphify/context packet identified them.]

Key constraints:
- [Brownfield constraints from context packet. Keep concise.]

## Out of Scope

## Further Notes
```

### 5. Glossary update (two-tier, v0.2.11)

**Tier 1 — Deterministic stub extraction** (mandatory, verifiable bash):

```bash
bash appmaker/hooks/glossary-extract.sh "appmaker/features/<NNN>/prd.md"
```

Scans the just-written PRD for bold-uppercase candidate domain terms, appends stubs for new ones to `appmaker/glossary.md`. Idempotent (skips existing entries). Output: `✓ glossary-extract: N candidate term(s) appended as stubs`.

**Tier 2 — Semantic review** (best-effort, agent-driven, NOT deterministic):

If extraction surfaced stubs AND the current conversation has enough context to define them, suggest `/appmaker:glossary` to resolve stubs. Otherwise leave stubs for user's explicit invocation later.

Honest framing: extraction is deterministic, definition is not. Stubs are a verifiable artifact; resolved entries depend on agent reasoning + user confirmation.

### 6. Output summary

```
✓ PRD: appmaker/features/003-add-dark-mode/prd.md
✓ Modules sketched: 3
✓ Tests planned: 2 modules
✓ Glossary: +3 terms
✓ Clarifications: 0 (run /appmaker:clarify if ambiguous areas remain)
✓ Readiness: inherited from interview (ready)

Suggested next: /appmaker:decompose
Optional: /appmaker:checklist (cross-artifact consistency check pre-decompose)
```

## Guardrails

- **No interview.** Synthesize from interview-result.md + conversation. If gaps, abort.
- **Use glossary terms.** Don't invent synonyms.
- **Module sketch first, confirm with user.** Don't write PRD with unconfirmed modules.
- **Verification per Implementation Decision mandatory.** Each marked `auto-check` or `human-review-with-criteria`.
- **Architecture options research mandatory for high-impact decisions.** No source-free library/framework/vendor/storage/auth/design-system choice.
- **Context packet reference mandatory for brownfield.** If codebase context used, link packet path under Existing System Context.
- **Use memory wiki lazily.** Read relevant pages; do not dump whole memory into PRD.
- **Understanding section mandatory.** All 7 subsections present (even if "N/A").
- **Prototype exception only for snippets that encode decisions precisely.** Not working demos.
- **Local default for output.** `appmaker/features/<NNN>/prd.md`. Optional `/appmaker:sync-github` adapter.
- **Don't auto-publish to GitHub.**
- **Don't auto-invoke `/appmaker:decompose` next.** PRD ends, user reviews, user decides.
