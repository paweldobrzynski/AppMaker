---
description: Test-driven development with red-green-refactor loop, applied per backlog item. Adopts Matt Pocock tdd skill (canonical, MIT) plus AppMaker extensions glossary auto-update, traces_to per AC test, constitution rule references, AC checkbox tracking. Use when implementing a specific backlog item.
disable-model-invocation: true
---

Test-driven dev per slice. Adopts Matt Pocock `tdd` (canonical) plus AppMaker extensions.

Supporting refs: `appmaker/skills/tdd/*`, `appmaker/skills/architecture-options-research.md`, `appmaker/skills/context-budget.md`.

## When to invoke

- Manual slash command only: `/appmaker:tdd <backlog-id>` (e.g., `/appmaker:tdd 008`)
- Suggested by `start`/`next`, or by Layer 4 AFK runner (autonomous slices only)
- AFK-safe: yes (for `execution_class: autonomous`), NO (for `human_required` — needs user confirmation per AC)
- Required state: `appmaker/backlog/NNN-slug.md` exists with status `open`, blockers done
- Required input: backlog item ID

Invocation boundary: this skill has `disable-model-invocation: true`, so it cannot be used with the Skill tool. If another skill reaches TDD, it must emit the exact slash command; do not continue with inline "manual TDD" after a Skill-tool failure.

## Philosophy (Matt Pocock 1:1)

Tests verify behavior through public interfaces, not implementation details. Good tests are integration-style; bad tests are coupled to implementation. See `appmaker/skills/tdd/tests.md` and `appmaker/skills/tdd/mocking.md`.

## Anti-Pattern: Horizontal Slices (Matt Pocock 1:1)

**DO NOT write all tests first, then all implementation.** Vertical: ONE test → ONE implementation → repeat. (`test1→impl1, test2→impl2, ...`, NOT `test1,test2,test3 → impl1,impl2,impl3`.)

## Process

### 0. Pre-flight: read memory wiki (MANDATORY)

TDD must respect known test patterns + integration gotchas from prior features. Read BEFORE drafting RED-GREEN plan.

```bash
# Pre-flight wiki cat — respects wiki_preflight_mode config flag (v0.2.12)
WIKI_MODE=$(grep '^wiki_preflight_mode:' appmaker/config.yaml 2>/dev/null | awk '{print $2}')
WIKI_MODE="${WIKI_MODE:-auto}"
if [ "$WIKI_MODE" != "never" ]; then
  for page in testing integration-gotchas; do
    f="appmaker/memory/wiki/${page}.md"
    # Skip missing or header-only files (≤5 lines = seed stub, not real content yet) — saves tokens on fresh projects
    if [ -f "$f" ] && [ "$(wc -l < "$f")" -gt 5 ]; then
      echo "─── $f ───" && cat "$f"
    fi
  done
fi
```

Cite as `per wiki/testing.md: <pattern>` in the TDD plan when a test seam/loop pattern matches. If `integration-gotchas.md` lists a known issue that this slice could re-trigger, add a corresponding RED test cycle to guard against regression. Note: this supersedes prior "when relevant" wording — read these pages on every TDD invocation.

### 1. Read backlog item

Load `appmaker/backlog/NNN-slug.md`. If no backlog item exists, refuse TDD and tell the user to run `/appmaker:decompose` (standard/strict) or create a light backlog item first. Do not infer a slice directly from `interview-result.md`.

Read backlog fields: `What to build`, `Acceptance criteria`, `Implementation Decisions / Gray Areas`, `execution_class`, `blocked_by`, and `edit_scope`. If blockers remain, refuse. If unresolved gray areas affect architecture/API/UI behavior, pause until resolved, deferred with risk, or `human_required`.

### 2. Read context (parallel reads OK)

- `appmaker/glossary.md` — canonical terms
- `appmaker/constitution.md` — rule 3 (real boundaries), rule 7 (promote green)
- `appmaker/features/<NNN>/prd.md` — user-facing behavior context
- `appmaker/memory/wiki/testing.md` + `integration-gotchas.md`
- `appmaker/skills/tdd/*.md` — supporting reference on demand
- Context packet paths from backlog item `context_packets`. If absent/stale and codebase context needed, run `/appmaker:context "<backlog topic>"`.
- For large/agent-heavy/MCP-heavy work, read `appmaker/skills/context-budget.md` and run the Pre-flight MCP audit before adding more context.

### 2a. Architecture Options Research (MANDATORY for high-impact choices)

If the slice makes a high-impact architecture/library/vendor/storage/auth/design-system decision, read `appmaker/skills/architecture-options-research.md` and complete `## Architecture Options Research` before planning and RED. Applies to greenfield and brownfield; greenfield often needs it more.

### 2b. Brownfield Impact Audit (MANDATORY for brownfield)

Read `appmaker/skills/tdd/brownfield-impact-audit.md`. If `project_mode: brownfield`, or the item touches existing production code, complete `## Brownfield Impact Audit` before the TDD plan and before the first RED test.

The audit must use `rg` first and cover reuse / refactor-first decisions, visual system / CSS reuse, design standards compliance, canonical values / hardcoded contracts, data read/write paths, API / caller graph, UI / client mirrors, side-effect order, tests / lint / docs / memory, and backward compatibility / rollout. If the section is missing, add it from `appmaker/templates/backlog-item-template.md`. If it remains `pending`, refuse the first RED cycle.

Every discovered dependency must be added to the TDD plan/tests or listed under `Deferred / intentionally not touched` with a concrete reason and risk.

### 3. Planning

Matt Pocock checklist + AppMaker addition:

- [ ] Confirm interface changes with user via AskUserQuestion
- [ ] **AppMaker:** verify `Architecture Options Research` is complete when required.
- [ ] Confirm which behaviors to test
- [ ] Identify deep modules (see `appmaker/skills/tdd/deep-modules.md`)
- [ ] Design interfaces for testability (see `appmaker/skills/tdd/interface-design.md`)
- [ ] List behaviors to test
- [ ] **AppMaker:** each behavior maps to AC `traces_to: pcrit-id`. Cover all backlog ACs.
- [ ] **AppMaker:** use context packet key files/communities, respect `edit_scope`, and prefer reuse/extend/extract/replace over add-new.
- [ ] **AppMaker:** UI changes use reusable CSS/component primitives; no new hardcoded visual styling without documented exception.
- [ ] **AppMaker:** every touched visual element follows existing design standards for tokens, states, accessibility, and responsive behavior.
- [ ] **AppMaker:** TDD cycles cover every non-deferred dependency from the Brownfield Impact Audit.
- [ ] **AppMaker:** draft `QA / Smoke Plan` for affected surfaces, including browser/screenshot checks for UI. UI/browser ACs needing an end-to-end flow use scan-first E2E per `appmaker/skills/tdd/browser-e2e.md` (scan live DOM -> ground locators, never invent them).
- [ ] **AppMaker:** run `TDD Plan Check` from `appmaker/skills/tdd/plan-check.md`; revise until PASS/WARN, escalate after 2 failed revisions.
- [ ] Get user approval

### 3a. Plan output format

See `appmaker/skills/tdd/plan-format.md` for the full output spec (table vs heading template, column rules). TL;DR:

- Global style: `appmaker/skills/output-style.md`.
- **≥ 4 cycles** → markdown table.
- **≤ 3 cycles** → per-cycle `### Tn` headings.
- **Never:** ASCII separators (`────`), `#:` prefix, stacked RED/GREEN/Traces lines.

### 3b. Execution Record — initial fields (v0.2.19)

After plan approval and BEFORE first RED, materialize `## Approved TDD Plan`
plus initial `## Execution Record` fields. Preserve the approval gate.
Anti-bureaucracy rule: auto-fill factual Execution Record fields wherever a shell command can prove the value. Human-written fields are for intent, AC status, and drift explanation — not for transcribing git facts.

Required capture:
```bash
BASE_REF=$(git rev-parse HEAD 2>/dev/null || echo no_base_ref)
DIRTY_STATUS=$(git status --short 2>/dev/null || true)
```

Write/update these fields:
- **Approved TDD Plan:** exact plan approved by user (table or headings from step 3a)
- **Base ref:** `$BASE_REF`
- **Dirty at start:** `yes` if `DIRTY_STATUS` non-empty, otherwise `no`
- **Dirty files at start:** paths from `git status --short`
- **Planned files:** from the approved TDD plan
- **Planned tests:** from the approved TDD plan
- **QA / Smoke Plan:** manual/browser checks needed after implementation

Dirty worktree behavior: capture + WARN, never refuse. The warning lets reviewers separate pre-existing edits from slice drift later.

### 4. Tracer Bullet (Matt 1:1)

ONE test → minimal code to pass. Proves path works end-to-end.

### 5. Incremental Loop (Matt 1:1 + AppMaker AC tracking)

For each behavior:
```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

**AppMaker addition:** per cycle, flip the matching AC checkbox in the backlog item (`- [ ]` → `- [x]`, preserving `traces_to: pcrit-NNN`).

### 6. Refactor (Matt 1:1)

After all ACs ✓, see `appmaker/skills/tdd/refactoring.md`. **Never refactor while RED.**

### 7. Verification (AppMaker — constitution rule 7)

Before marking `done`:
- All ACs ✓
- All tests pass; no placebo tests guarding ACs — run `appmaker/skills/tdd/test-validity.md` Tier 1 sweep (no skipped/tautology/commented/no-assert tests)
- Lint clean
- Type check clean
- Constitution rule 3: integration tests use real boundaries (not mocks)

If any fail → fix or escalate.

### 8. Glossary update (two-tier, v0.2.11)

- **Tier 1 (deterministic, idempotent):** `bash appmaker/hooks/glossary-extract.sh "appmaker/backlog/<NNN>-<slug>.md"` — captures new domain terms from test names / what-to-build.
- **Tier 2 (semantic, best-effort):** if Tier 1 surfaced new stubs AND TDD conversation has definitions, suggest `/appmaker:glossary`. Otherwise leave stubs for explicit review.

### 9. Mark done + suggest next

### 9a. Execution Record — final fields (v0.2.19)

Before moving the backlog item to `done/`, fill the final `## Execution Record`
fields:
- **Actual files:** Read **Base ref:** back from the backlog item's `## Execution Record` section (do NOT rely on `$BASE_REF` shell variable from step 3b — separate Bash tool calls between Phase A and Phase B don't share shell state). Then:
  - If Base ref is a SHA: `git diff --name-only "$BASE_REF"..HEAD` for committed delta plus `git diff --name-only` for working-tree delta.
  - If Base ref is `no_base_ref`: only `git diff --name-only` working-tree delta (no committed history to compare).
  - Subtract `Dirty files at start` (also read back from backlog) so pre-existing work isn't mislabeled as slice drift.
- **Tests run:** command(s) run + pass/fail summary
- **AC completed:** checked AC count / total AC count
- **Drift notes:** `- (none)` unless files/tests/AC differed from the approved plan. Drift notes are human-written only when planned files/tests/AC differ; otherwise keep the field mechanical.

Update front-matter: `status: done`, append `completed: <ISO date>`. Move file: `appmaker/backlog/NNN.md` → `appmaker/backlog/done/<YYYY-MM-DD>-NNN.md`. Output summary: backlog id + DONE, tests pass/fail, lint+types status, AC count, glossary delta, suggested next (`/appmaker:tdd <next>` or `/appmaker:review`).

## Checklist Per Cycle (Matt 1:1)

Use `appmaker/skills/tdd/tests.md`: public behavior, minimal code, no speculative features.

## Guardrails

- **One backlog item at a time.**
- **Honor `blocked_by`.**
- **Update AC checkboxes per cycle.**
- **Constitution rule 3 mandatory** — real boundaries in integration tests.
- **Constitution rule 7 mandatory** — don't mark `done` with failing CI.
- **Honor `execution_class`** — `human_required` needs user per AC.
- **Use context packets before broad search.** Avoid rediscovering graph context; refresh packet only if stale or wrong.
- **Use testing memory.** Prior fast loops/gotchas should influence test seam selection.
- **Don't horizontal slice.**
- **Don't refactor while RED.**
- **Don't skip verification step 7.**
- **Don't mock real boundaries in integration tests.**
- **Don't work on blocked items.**
- **Don't auto-invoke `/appmaker:review` next.**
