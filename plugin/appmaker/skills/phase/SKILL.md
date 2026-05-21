---
description: Plan one execution phase from AppMaker backlog items. Dry-run only in v1: groups independent items into parallel waves, detects write-scope conflicts, and persists a phase execution plan. Execute remains disabled until the dry-run contract is validated.
disable-model-invocation: true
---

Phase planner. GSD-like "do phase" adapted to AppMaker: plan first, evidence on disk, no execution until scope/dependency conflicts are visible.

## When to invoke

- Manual: `/appmaker:phase <phase-id> --dry-run`
- Execute: `/appmaker:phase <phase-id> --execute` is rejected for now. `--execute is TODO` until dry-run plans validate in real projects.
- Suggested after `/appmaker:decompose` when several backlog items share `phase_id`
- AFK-safe: NO — writes plan artifact and may later dispatch subagents; user approval required
- Required state: `appmaker/backlog/*.md` items with phase metadata
- Required input: `phase_id`

## Process

### 1. Read phase items

Find active backlog items where frontmatter has `phase_id: <phase-id>`.

Read each item's:
- `id`, `slug`, `status`, `execution_class`
- `blocked_by` and `depends_on`
- `agent_profile`
- `write_scope`
- `integration_risk`
- `feature`, `traces_to`, `context_packets`

Ignore `status: done` items as executable targets, but allow them to satisfy `blocked_by` / `depends_on`.

### 2. Validate dry-run inputs

FAIL plan if any target item has:
- missing `write_scope`
- empty `agent_profile`
- `execution_class: human_required`
- unresolved `blocked_by`
- unresolved `depends_on`
- missing acceptance criteria or missing `traces_to` where from PRD

WARN plan if:
- `integration_risk: high`
- `write_scope` is broad (`src/**`, project root, `**/*`)
- item has no `context_packets` in brownfield mode

### 3. Detect scope overlap

Compare normalized `write_scope` entries across items.

Treat as scope overlap when:
- two items claim identical paths/globs
- one item claims a parent of another item's path
- both claim broad globs under same subsystem

Any scope overlap blocks parallel execution in the same wave. If conflict cannot be isolated by wave ordering, mark plan `FAIL` and ask user to split ownership or serialize the items.

### 4. Build Parallel Waves

Topologically sort by `blocked_by` + `depends_on`.

Within each wave:
- only include `status: open` items
- no unresolved dependency
- no `write_scope` overlap
- no `human_required` item

Prefer fewer, larger safe waves over aggressive parallelism. Phase dry-run optimizes for non-conflicting ownership, not maximum concurrency.

### 5. Persist Phase Execution Plan

Write a compact report to `appmaker/phase-plans/` even on FAIL:

```bash
mkdir -p appmaker/phase-plans
REPORT_PATH="appmaker/phase-plans/$(date -u +%Y-%m-%d-%H%M)-<phase-id>-dry-run.md"
cat > "$REPORT_PATH" <<'PLAN_EOF'
---
phase_id: <phase-id>
mode: dry-run
status: PASS|WARN|FAIL
created: <ISO timestamp>
---

# Phase Execution Plan

## Items

| Item | Agent | Write Scope | Depends On | Risk | Can Run |
|---|---|---|---|---|---|
| 001-auth-service | backend-specialist | src/auth/, tests/auth/ | [] | medium | yes |

## Parallel Waves

| Wave | Items | Reason |
|---|---|---|
| 1 | 001, 002 | no deps, no scope overlap |
| 2 | 003 | depends_on: 001 |

## Conflicts

| Items | Conflict | Resolution |
|---|---|---|
| 004/005 | scope overlap: src/auth/** | split write_scope or serialize |

## Subagent Task Contract

Each future subagent receives exactly one backlog item, its owned `write_scope`, acceptance criteria, context packets, and the rule: do not edit outside scope; you are not alone in the codebase; do not revert others' edits; report drift instead.

## Execute

Disabled. --execute is TODO.
PLAN_EOF
test -f "$REPORT_PATH" && echo "Phase plan: $REPORT_PATH"
```

### 6. Output handoff

Print:

```text
Phase dry-run: PASS|WARN|FAIL
Plan: appmaker/phase-plans/<file>.md
Waves: <n>
Conflicts: <n>
Execute: disabled (--execute is TODO)
```

## Guardrails

- **Dry-run first.** No subagent execution in v1.
- **Manual only.** `disable-model-invocation: true`; routers emit slash command and stop.
- **One item per future subagent.** No feature-sized vague delegation.
- **Owned write scope mandatory.** Missing `write_scope` = FAIL.
- **No conflicting wave.** scope overlap blocks same-wave execution.
- **Respect blockers.** `blocked_by` and `depends_on` both block execution.
- **No human-required work.** Human-required items stay outside phase automation.
- **Persist every result.** PASS/WARN/FAIL all create `appmaker/phase-plans/` evidence.
- **No silent execute.** `--execute` returns "disabled" until separate implementation.
