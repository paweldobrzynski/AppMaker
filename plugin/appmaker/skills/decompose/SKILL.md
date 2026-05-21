---
description: Break PRD into vertical-slice backlog items (tracer bullets). Each slice cuts ALL layers end-to-end. Adopts Matt Pocock to-issues 1:1 plus AppMaker extensions execution_class, traces_to per AC, YAML front-matter, cycle detection, local backlog default. Use when PRD is ready and user wants to plan implementation work.
disable-model-invocation: true
---

Break PRD into independently-grabbable backlog items using **vertical slices** (Matt Pocock tracer bullets). Adopts `to-issues` (canonical, MIT) plus AppMaker extensions.

Templates referenced: `appmaker/templates/backlog-item-template.md` and `appmaker/templates/decomposition-template.md`.

## When to invoke

- Manual: `/appmaker:decompose` (latest PRD) or `/appmaker:decompose <folder>`
- Auto: by `start` on feature workflow continuation post-PRD
- AFK-safe: NO — slice approval requires human review; writes backlog items (side effect)
- Required state: `prd.md` present in feature folder
- Required input: feature folder path (auto-detected if latest PRD obvious)

## Process

### 0. Pre-flight: read memory wiki (MANDATORY)

Decomposition slices benefit from knowing past architectural touch maps + known integration gotchas + already-shipped features. Read BEFORE drafting slice table.

```bash
# Pre-flight wiki cat — respects wiki_preflight_mode config flag (v0.2.12)
WIKI_MODE=$(grep '^wiki_preflight_mode:' appmaker/config.yaml 2>/dev/null | awk '{print $2}')
WIKI_MODE="${WIKI_MODE:-auto}"
if [ "$WIKI_MODE" != "never" ]; then
  for page in architecture feature-index integration-gotchas; do
    f="appmaker/memory/wiki/${page}.md"
    # Skip missing or header-only files (≤5 lines = seed stub, not real content yet) — saves tokens on fresh projects
    if [ -f "$f" ] && [ "$(wc -l < "$f")" -gt 5 ]; then
      echo "─── $f ───" && cat "$f"
    fi
  done
fi
```

Cite as `per wiki/integration-gotchas.md: <known issue>` when slice scope or `human_required` classification is influenced. If `feature-index.md` shows prior slicing patterns for similar work (e.g., "tracer-first → rules → recompute" elsewhere), favor consistency. Don't blindly copy past structure if PRD shape differs — flag the divergence in decomposition.md `Notes`.

### 1. Locate feature folder + read PRD

If invoked without arg, find latest `appmaker/features/<NNN-slug>/` with `prd.md` and no existing `decomposition.md`. Confirm via AskUserQuestion.

### 2. Read context (parallel reads OK)

- `appmaker/features/<NNN>/prd.md` — primary input
- `appmaker/features/<NNN>/spike-output/` if exists (snippets for prototype exception)
- `appmaker/glossary.md` — canonical terms
- `appmaker/constitution.md` — rules
- `appmaker/memory/index.md` + relevant wiki pages — prior architecture/testing/domain lessons
- `appmaker/templates/backlog-item-template.md` + `appmaker/templates/decomposition-template.md` — output formats
- Context packet(s) referenced by PRD. If missing and brownfield context matters, run `/appmaker:context "<feature topic>"`.

### 3. Draft vertical slices (tracer bullets)

Each slice MUST:
- **Cut ALL layers end-to-end** (schema, API, UI, tests) — NOT horizontal
- **Be demoable or verifiable on its own**
- **Be thin** — many thin > few thick

Per slice, classify `execution_class`:
- `human_required` — needs human interaction (architectural decision, design review, money/legal/security/identity per constitution rule 6)
- `autonomous` — can be implemented and merged without human gate
- `conditional` — depends on runtime check (rare)

**Prefer `autonomous`** unless constitution rule 6 applies.

Per slice, identify:
- **Title** (uses glossary terms)
- **execution_class**
- **blocked_by** (other slice IDs)
- **traces_to** (PRD pcrit-id list)
- **user_stories_covered** (from PRD)
- **touches** (Graphify communities + files from context packet, if relevant)
- **context_packets** (packet paths that informed slice)
- **Brownfield Impact Audit seed** when `project_mode: brownfield`: reuse/refactor-first candidates, starting canonical values, likely hardcoded contracts, known UI mirrors, side-effect surfaces, and the first `rg` queries TDD must run. This is a seed, not final evidence; `/appmaker:tdd` completes it before RED.

### 4. Quiz user

Present breakdown as numbered list. Use AskUserQuestion:
- Granularity right?
- Dependencies correct?
- Slices to merge or split?
- `execution_class` markers correct?
- Every PRD criterion covered by ≥1 slice?

Iterate until user approves.

### 5. Cycle detection

Build directed graph of `blocked_by`. Run topological sort. If cycle → refuse to write, surface cycle to user.

### 6. Write backlog items + decomposition overview

For each approved slice, write `appmaker/backlog/NNN-<slug>.md` (using `appmaker/templates/backlog-item-template.md`).

Plus write `appmaker/features/<NNN>/decomposition.md` (using `appmaker/templates/decomposition-template.md`).

Publish in **dependency order** (blockers first).

For brownfield projects, every backlog item must contain `## Brownfield Impact Audit` with `Mode: brownfield` and `Audit status: pending` unless the slice is truly greenfield-only. Seed the section with known context packet evidence and starting searches so TDD cannot begin from a blank page.

### 7. Glossary update (two-tier, v0.2.11)

**Tier 1 — Deterministic stub extraction:**
```bash
bash appmaker/hooks/glossary-extract.sh "appmaker/features/<NNN>/decomposition.md"
```
Verifiable bash that appends candidate-term stubs to glossary. Idempotent.

**Tier 2 — Semantic review:** if conversation context can resolve stubs, suggest `/appmaker:glossary`. Otherwise stubs remain for user's explicit invocation. Best-effort, NOT deterministic.

### 8. Output summary

```
✓ Decomposition: appmaker/features/003-add-dark-mode/decomposition.md
✓ Backlog items: 4 created (IDs 008-011)
  - 008-theme-context-setup (autonomous)
  - 009-toggle-component (autonomous, blocked_by: 008)
  - 010-storage-persistence (autonomous, blocked_by: 008)
  - 011-system-pref-detection (human_required, blocked_by: 008)
✓ Cycle check: PASS
✓ Coverage: 12/12 PRD criteria mapped (no orphans)
✓ Context packets: 1 linked
✓ Glossary: +2 terms

Suggested next: /appmaker:tdd 008  (or autonomous via /appmaker:afk if Layer 4)
```

## Guardrails

- **Tracer bullet, not horizontal slice.** UI-only or DB-only = wrong.
- **Many thin > few thick.**
- **`execution_class` per slice mandatory.** Default `autonomous` unless constitution rule 6.
- **`traces_to` per AC mandatory.** Every AC traces to PRD criterion. No orphans.
- **Graph context is advisory.** Use context packets to avoid missing touched areas, but don't turn graph neighbors into scope without PRD/AC support.
- **Brownfield audit is not advisory.** Context packets and `touches` seed the audit; TDD must complete it before RED, and review/checklist verify coverage.
- **Memory wiki is advisory.** Use durable lessons to shape slices; don't create scope not present in PRD.
- **Cycle detection mandatory.** Refuse if cycle.
- **Quiz user before writing.** Iterate until approved.
- **Local default for output.** Optional `/appmaker:sync-github` adapter.
- **Use glossary terms.**
- **Don't accept horizontal slices.**
- **Don't auto-mark all slices `autonomous`.** Be conservative.
- **Don't write without user approval.**
- **Don't auto-invoke `/appmaker:tdd` next.**
