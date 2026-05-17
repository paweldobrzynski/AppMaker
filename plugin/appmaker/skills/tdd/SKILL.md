---
description: Test-driven development with red-green-refactor loop, applied per backlog item. Adopts Matt Pocock tdd skill (canonical, MIT) plus AppMaker extensions glossary auto-update, traces_to per AC test, constitution rule references, AC checkbox tracking. Use when implementing a specific backlog item.
disable-model-invocation: true
---

Test-driven dev per slice. Adopts Matt Pocock `tdd` (canonical) plus AppMaker extensions.

Supporting reference files (Matt Pocock 1:1, MIT) live in project tree:
- `appmaker/skills/tdd/deep-modules.md` — deep vs shallow module pattern
- `appmaker/skills/tdd/interface-design.md` — testable interface design
- `appmaker/skills/tdd/mocking.md` — when to mock, when not to
- `appmaker/skills/tdd/refactoring.md` — refactor candidates
- `appmaker/skills/tdd/tests.md` — good vs bad test examples

## When to invoke

- Manual: `/appmaker:tdd <backlog-id>` (e.g., `/appmaker:tdd 008`)
- Auto: by `start` on implementation phase, or by Layer 4 AFK runner (autonomous slices only)
- AFK-safe: yes (for `execution_class: autonomous`), NO (for `human_required` — needs user confirmation per AC)
- Required state: `appmaker/backlog/NNN-slug.md` exists with status `open`, blockers done
- Required input: backlog item ID

## Philosophy (Matt Pocock 1:1)

Tests verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't.

**Good tests** are integration-style. **Bad tests** are coupled to implementation.

See `appmaker/skills/tdd/tests.md` and `appmaker/skills/tdd/mocking.md`.

## Anti-Pattern: Horizontal Slices (Matt Pocock 1:1)

**DO NOT write all tests first, then all implementation.** Vertical: ONE test → ONE implementation → repeat.

```
WRONG: test1, test2, test3 → impl1, impl2, impl3
RIGHT: test1→impl1, test2→impl2, test3→impl3
```

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

Load `appmaker/backlog/NNN-slug.md`:
- Read `What to build`
- Read `Acceptance criteria` (each has `traces_to: pcrit-id`)
- Check `execution_class`: if `human_required`, ask user per AC
- Check `blocked_by`: if non-empty, refuse start until blockers `status: done`

### 2. Read context (parallel reads OK)

- `appmaker/glossary.md` — canonical terms
- `appmaker/constitution.md` — rule 3 (real boundaries), rule 7 (promote green)
- `appmaker/features/<NNN>/prd.md` — user-facing behavior context
- `appmaker/memory/wiki/testing.md` + `integration-gotchas.md` when relevant
- `appmaker/skills/tdd/*.md` — supporting reference on demand
- Context packet paths from backlog item `context_packets`. If absent/stale and codebase context needed, run `/appmaker:context "<backlog topic>"`.

### 3. Planning

Matt Pocock checklist + AppMaker addition:

- [ ] Confirm interface changes with user via AskUserQuestion
- [ ] Confirm which behaviors to test
- [ ] Identify deep modules (see `appmaker/skills/tdd/deep-modules.md`)
- [ ] Design interfaces for testability (see `appmaker/skills/tdd/interface-design.md`)
- [ ] List behaviors to test
- [ ] **AppMaker:** each behavior maps to AC `traces_to: pcrit-id`. Cover all backlog ACs.
- [ ] **AppMaker:** use context packet key files/communities to choose starting files.
- [ ] Get user approval

### 3a. Plan output format

**See `appmaker/skills/output-style.md` for global style.** TDD-specific:

- **≥ 4 cycles** → use **markdown table** (compact, scannable).
- **≤ 3 cycles** → use **per-cycle `### Tn` headings** (more reading space for complex cases).
- **Never:** ASCII separators (`────`), `#:` prefix, stacked RED/GREEN/Traces lines.

#### Table template (4+ cycles)

```markdown
## TDD Plan: <slice-id-slug>

**Interface:** `functionName(args) → returnType`
**Module:** `path/to/module.js` — pure logic per constitution rule 3
**Backlog:** `appmaker/backlog/NNN-slug.md`

| # | Type | RED (failing test) | GREEN (minimal impl) | Traces |
|---|---|---|---|---|
| T1 | tracer | `fn({k:'v'}) === 'Low'` | Create module, terminal short-circuit | SC1 |
| T2 | rule | All 4 terminal statuses → `'Low'` | Covered by T1 | SC1 |
| T3 | edge | `fn(null)` no throw, returns `null` | Add `data = data \|\| {}` | ID4 |

**Integration steps** (manual verification only — NOT TDD):
- Wire into `<caller path>`
- Verify happy path on real `<sample>` record
```

Column rules:
- `#` — `T1`, `T2`, ... (T = test/cycle).
- `Type` — `tracer` / `rule` / `edge` / `regression` / `integration-prep`.
- `RED` — single-line executable-looking pseudo-code.
- `GREEN` — single-line "what changes". "Covered by Tn" is valid.
- `Traces` — AC IDs (canonical `pcrit-NNN` OR project format like `SC1`/`ID4`).

#### Heading template (≤ 3 cycles)

```markdown
## TDD Plan: <slice-id-slug>

**Interface:** `functionName(args) → returnType`
**Backlog:** `appmaker/backlog/NNN-slug.md`

### T1 — Tracer bullet

- **RED:** `fn({k: 'v'}) === 'expected'`
- **GREEN:** Create module, minimal early return
- **Traces:** SC1
- **Note:** establishes module shape; subsequent cycles extend.

### T2 — Rule for X

- **RED:** [single-line failing test]
- **GREEN:** [what changes]
- **Traces:** SC2, ID3
```

### 3b. Execution Record — initial fields (v0.2.19)

After the user approves the TDD plan, and BEFORE the first RED test, materialize
the initial `## Execution Record` fields in the backlog item. Preserve the
existing approval gate; this step only writes the approved plan to disk.

Required capture:
```bash
BASE_REF=$(git rev-parse HEAD 2>/dev/null || echo no_base_ref)
DIRTY_STATUS=$(git status --short 2>/dev/null || true)
```

Write/update these fields:
- **Base ref:** `$BASE_REF`
- **Dirty at start:** `yes` if `DIRTY_STATUS` non-empty, otherwise `no`
- **Dirty files at start:** paths from `git status --short`
- **Planned files:** from the approved TDD plan
- **Planned tests:** from the approved TDD plan

Dirty worktree behavior: capture + WARN, never refuse. The warning exists so
reviewers can separate pre-existing edits from slice drift later.

### 4. Tracer Bullet (Matt 1:1)

ONE test → minimal code to pass. Proves path works end-to-end.

### 5. Incremental Loop (Matt 1:1 + AppMaker AC tracking)

For each behavior:
```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

**AppMaker addition:** per cycle, mark AC checkbox in backlog item:
```diff
- - [ ] `useTheme()` returns ... (traces_to: pcrit-001)
+ - [x] `useTheme()` returns ... (traces_to: pcrit-001)
```

### 6. Refactor (Matt 1:1)

After all ACs ✓, see `appmaker/skills/tdd/refactoring.md`. **Never refactor while RED.**

### 7. Verification (AppMaker — constitution rule 7)

Before marking `done`:
- All ACs ✓
- All tests pass
- Lint clean
- Type check clean
- Constitution rule 3: integration tests use real boundaries (not mocks)

If any fail → fix or escalate.

### 8. Glossary update (two-tier, v0.2.11)

**Tier 1 — Deterministic stub extraction:**
```bash
# Run on the backlog item that just got TDD-completed (captures any new domain terms in test names / what-to-build)
bash appmaker/hooks/glossary-extract.sh "appmaker/backlog/<NNN>-<slug>.md"
```
Verifiable bash. Idempotent.

**Tier 2 — Semantic review:** If extraction surfaced new stubs AND TDD conversation has definitions, MAY invoke `/appmaker:glossary` via Skill tool. Otherwise leave stubs for explicit review. Best-effort, NOT deterministic.

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
- **Drift notes:** `- (none)` unless files/tests/AC differed from the approved plan

Update front-matter: `status: done`, append `completed: <ISO date>`. Move file: `appmaker/backlog/NNN.md` → `appmaker/backlog/done/<YYYY-MM-DD>-NNN.md`.

```
✓ Backlog item 008: DONE
✓ Tests: 4/4 pass
✓ Lint + types: clean
✓ ACs: 4/4 ✓
✓ Glossary: +1 term

Suggested next: /appmaker:tdd 009  (or /appmaker:review)
```

## Checklist Per Cycle (Matt 1:1)

```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Code is minimal for this test
[ ] No speculative features added
```

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
