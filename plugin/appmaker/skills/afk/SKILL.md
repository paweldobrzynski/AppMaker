---
description: Controlled autonomous execution loop for AppMaker backlog items. Runs only explicit autonomous slices with checklist/review gates, cost/iteration caps, and human stop points.
disable-model-invocation: true
---

AFK runner. Layer 4. Conservative loop over `execution_class: autonomous` backlog items only.

## When to invoke

- Manual: `/appmaker:afk [--max N] [--dry-run] [--feature <NNN-slug>] [--driver=loop|goal]`
- Suggested after decomposition has PASS/WARN checklist and autonomous slices
- AFK-safe: yes only within caps; writes code/tests/reports
- Required state: `appmaker/config.yaml`, backlog items, clean enough git status
- Required input: explicit user approval

**Driver flag (v0.2.12):**

- `--driver=loop` (default) — AppMaker custom bounded loop. Iterates over backlog items, applies checklist + tdd + review per item. Stops on first FAIL. Explicit AppMaker control flow.
- `--driver=goal` — delegates execution to Claude Code's built-in `/goal` (persistent outcome-based execution). AppMaker formats the goal completion condition; `/goal` drives the loop autonomously. Better for genuinely long-running autonomous work where Agent View monitoring is preferred over per-item stop-and-check.

Pick `--driver=loop` when: AppMaker-specific gate ordering matters (e.g., always run checklist BEFORE tdd, always run review AFTER), bounded predictable iteration count, prefer per-iteration audit trail.

Pick `--driver=goal` when: want Claude Code-native autonomous execution, Agent View dashboard for multi-session monitoring, `/goal`-aware tooling already in use, longer-running work where one user-defined outcome > N AppMaker iterations.

## Process

### 1. Preflight

Read:
- `appmaker/config.yaml`
- open backlog items
- latest checklist reports
- git status

Stop unless:
- `afk_enabled: true` OR user explicitly confirms this run
- `afk_max_iterations` set
- `afk_cost_cap_usd` set
- target items are `execution_class: autonomous`
- blockers are done
- no checklist FAIL for target feature/item

### 2. Select queue

Pick dependency order:
1. no unresolved `blocked_by`
2. `status: open`
3. `execution_class: autonomous`
4. feature filter if provided

Dry-run prints queue only.

### 3. Branch on --driver

**`--driver=loop` (default):** continue to per-item loop below (step 3a).
**`--driver=goal` (v0.2.12):** format `/goal` command + invoke + monitor (step 3b). Skip 3a.

#### 3a. Per-item loop (default)

For each item:
1. Run `/appmaker:checklist backlog <NNN>`.
2. If FAIL -> skip item, report.
3. Run `/appmaker:tdd <NNN>`.
4. Run configured tests/lint/typecheck from `appmaker/config.yaml`.
5. Run `/appmaker:review <NNN>`.
6. If review FAIL -> stop loop.
7. Commit only if user explicitly enabled commit behavior in config (future; default no commit).
8. Update AFK report.

#### 3b. `/goal`-driven mode (v0.2.12)

Format Claude Code `/goal` command with AppMaker completion condition:

```
/goal "Complete autonomous slices [LIST] until ALL conditions:
  - Each slice: checklist PASS, tdd done (status: done in backlog), review PASS
  - No FAIL status on any artifact
  - Cost stays under $<afk_cost_cap_usd>
  - Iteration count under <afk_max_iterations>
STOP IMMEDIATELY on:
  - Any checklist/tdd/review FAIL
  - human_required item encountered
  - Cost/iteration cap reached
  - User interrupt"
```

`/goal` drives the autonomous execution; Claude Code handles the loop, retry logic, multi-turn persistence. AppMaker monitors via:
- AFK report stub written at start (same compact contract as `--driver=loop`)
- Periodic state read: which slices done? Which open? Latest review status?
- Updates `## Iterations` section as state changes

**Benefits over `--driver=loop`:**
- Multi-session observability via `cloud agents` / Agent View
- Mobile monitoring (Pawel can check progress from phone)
- Native Claude Code stop conditions (vs AppMaker custom checks)
- Better integration with future Claude Code autonomous features

**Caveats:**
- `/goal` is a Claude Code 2026 feature — verify availability before use
- Less explicit control flow — `/goal` decides task ordering within its constraint
- AppMaker gates expressed AS goal conditions, not as imperative steps

### 4. Stop conditions

Stop immediately on:
- checklist FAIL
- test/lint/typecheck failure not resolved in current item
- review FAIL
- cost/iteration cap
- `human_required` item
- dirty unrelated git changes that cannot be attributed to current item
- user interrupt

### 5. Report — **MANDATORY persistence (compact contract)**

Follow the **Compact report contract** in `appmaker/skills/output-style.md`. AFK report = one frontmatter block + one iterations table + one stop reason line. No prose, no nested headings per iteration.

**Claude MUST persist via Bash tool** — even when AFK aborts immediately (preflight FAIL, dry-run, 0 items). Past sessions showed 6 AFK invocations with 0 reports. Silent failure = no audit trail.

**Write stub report at START** (immediately after preflight, before per-item loop):

```bash
mkdir -p appmaker/afk
REPORT_PATH="appmaker/afk/$(date -u +%Y-%m-%d-%H%M)-run.md"
cat > "$REPORT_PATH" <<'STUB_EOF'
---
mode: full           # or "dry-run"
status: IN_PROGRESS  # → COMPLETED | ABORTED at end
started: <ISO timestamp>
max_iterations: <N>
cost_cap_usd: <N>
target: <NNN-slug or "all open autonomous">
---

# AFK Run — <date HHMM>

**Queue:** 003, 004, 007  ← dependency-order list, 1 line

## Iterations

| # | Item | Checklist | TDD | Tests | Review | Outcome |
|---|---|---|---|---|---|---|
| 1 | 003 | PASS | done | 12/12 | PASS | done |

(table grows per iteration; blank cells for in-progress)

## Stop
(filled at end — "completed all" OR "<reason>: <evidence>")
STUB_EOF
test -f "$REPORT_PATH" && echo "✓ AFK report: $REPORT_PATH"
```

**Update per iteration:** append a row to the Iterations table (use `cat >>` with a single markdown line — do NOT rewrite the whole file).

**Finalize at end:**
- Flip `status: IN_PROGRESS` → `COMPLETED` / `ABORTED`
- Fill `## Stop` with 1 line (e.g. `completed all 3 items` OR `aborted: review FAIL on item 004 (constitution rule 3)`)

**Dry-run:** still writes report with `mode: dry-run` and `## Stop` = `dry-run — no work executed`.

**Forbidden:**
- Per-iteration headings like `### Iteration 1 — item 003`. Use the table row.
- Separate `## Completed` / `## Skipped` / `## Next Human Decision` sections — the table's Outcome column + `## Stop` line cover this.
- Prose narration of what AFK did. The table IS the narration.

## Guardrails

- **Never run without explicit approval.**
- **Autonomous items only.**
- **Checklist before TDD. Review after TDD.**
- **Stop on first FAIL.**
- **No silent commits.** Commit behavior requires explicit config.
- **Respect cost/iteration caps.**
- **Don't touch `human_required` items.**
- **Don't continue with unrelated dirty git changes.**
