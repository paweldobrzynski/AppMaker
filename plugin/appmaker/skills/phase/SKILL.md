---
description: Plan and execute one AppMaker phase from backlog items. Dry-run calls deterministic phase-plan.sh to build safe waves; execute dispatches one subagent per item wave by wave, integrates results, verifies, repairs once, reviews/QA-gates, and persists phase evidence.
disable-model-invocation: true
---

Phase Orchestrator. GSD-like "do phase" adapted to AppMaker: plan -> dispatch -> integrate -> verify -> repair/review/QA -> evidence. States: `PLANNED -> RUNNING -> VERIFYING -> REVIEWING -> DONE` (or `FAILED`).

## When to invoke

- Manual: `/appmaker:phase <phase-id> --dry-run` (run deterministic `phase-plan.sh` first)
- Manual: `/appmaker:phase <phase-id> --execute`
- Suggested after `/appmaker:decompose` when several backlog items share `phase_id`
- AFK-safe: bounded only; writes code/tests/reports through subagents, requires explicit approval
- Required state: `appmaker/backlog/*.md` items with phase metadata
- Required input: `phase_id`

## Process

### 0. Deterministic dry-run helper

Before model judgment, run the packaged planner from the project root:

```bash
bash <plugin-root>/scripts/phase-plan.sh <phase-id>
```

The helper reads `appmaker/backlog/*.md`, validates phase metadata, detects dependency/scope conflicts, builds `max_parallel_agents` waves, and persists `appmaker/phase-plans/*-<phase-id>-dry-run.md`. Use `--json` for UI/adapters that need machine-readable waves/conflicts. Treat `status: FAIL` as blocking; do not dispatch agents until the plan is PASS or WARN and the user explicitly approves execute.

### 1. Read phase items

Find active backlog items with `phase_id: <phase-id>`. Read `id`, `slug`, `status`, `execution_class`, `blocked_by`, `depends_on`, `agent_profile`, `write_scope`, `integration_risk`, `feature`, `traces_to`, `context_packets`. Read config: `test_command`, `lint_command`, `typecheck_command`, `build_command`, `max_parallel_agents` (default 3), `phase_execution_mode` (`local|worktree|pr`, default `local`), `project_mode`, review/QA settings. Ignore `status: done` as targets, but allow done items to satisfy dependencies.

### 2. Dry-run validation

FAIL plan if target item has missing `write_scope`, missing `agent_profile`, missing AC/PRD `traces_to`, `execution_class: human_required`, unresolved `blocked_by` / `depends_on`, or dirty worktree unrelated to phase item ownership.

WARN plan if `integration_risk: high`, `write_scope` is broad (`src/**`, project root, `**/*`), or brownfield item has no `context_packets`.

### 3. Detect scope overlap

Compare normalized `write_scope` entries. scope overlap = identical paths, parent/child ownership, or broad globs under same subsystem.

Overlap blocks same-wave execution. Unresolvable overlap = FAIL; user must split ownership or serialize.

### 4. Build Parallel Waves

Topologically sort by `blocked_by` + `depends_on`. Cap each wave at `max_parallel_agents`. Prefer safe ownership over concurrency.

Within each wave: status `open`, no unresolved dependency, no `write_scope` overlap, no `human_required` item.

### 5. Persist Phase Execution Plan

Write compact plan to `appmaker/phase-plans/` even on FAIL:

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

## Parallel Waves
| Wave | Items | Reason |
|---|---|---|

## Conflicts
| Items | Conflict | Resolution |
|---|---|---|

## Subagent Task Contract
Each future subagent receives one backlog item, owned `write_scope`, acceptance criteria, context packets, and this rule: do not edit outside write_scope; you are not alone in the codebase; do not revert others' edits; report drift and touched files.
PLAN_EOF
test -f "$REPORT_PATH" && echo "Phase plan: $REPORT_PATH"
```

### 6. Execute preflight

`/appmaker:phase <phase-id> --execute` requires latest PASS/WARN Phase Execution Plan for the same phase, no unresolved conflicts, user approval via AskUserQuestion, clean or attributable dirty worktree, and `max_parallel_agents` applied to every wave.

If missing plan, run dry-run first and stop.

Execution mode contract:

- `local` (default): subagents work in the current workspace with strict `write_scope` and wave-by-wave verification.
- `worktree`: create one per-item git worktree under `phase_worktree_base_dir`; integrate each wave back to the main workspace only after item verification passes.
- `pr`: require `github_cli_enabled: true`, authenticated `gh`, `phase_pr_base_branch`, and clean base. Each item branch/PR is draft by default (`phase_pr_draft: true`); the phase orchestrator reviews and integrates PRs wave by wave. Subagents must not merge their own PRs.

### 7. Dispatch wave by wave

Execute wave by wave. For each wave, start one subagent per item using Agent tool; do not use the Skill tool for side-effect skills. AppMaker phase itself orchestrates; subagents implement directly against the backlog item contract.

Prompt shape:

```text
Agent(
  subagent_type: <agent_profile>,
  description: "Phase <phase-id> item <NNN-slug>",
  prompt: "
    Implement exactly backlog item <path>.
    Owned write_scope: <paths>.
    Acceptance criteria + traces_to: <from backlog>.
    Context packets: <paths>.
    You are not alone in the codebase.
    Do not revert others' edits.
    Do not edit outside write_scope without stopping and reporting drift.
    Fill Execution Record: actual files, tests run, AC completed, drift notes.
    Report touched files and verification result.
  "
)
```

wait for all subagents in the wave. If any subagent FAIL, stop phase unless Repair Loop is allowed.

### 8. Integrate and verify

After each wave: inspect touched files against `write_scope`; run configured `test_command`, `lint_command`, `typecheck_command`, `build_command` when present; run `/appmaker:checklist backlog <id>` for changed items if needed; update execution report with Wave Results and Integration Gate.

Integration Gate PASS requires: no out-of-scope edits without drift note, verification commands pass, AC checkboxes/Execution Record updated, no unresolved conflict.

### 9. Repair Loop

One bounded Repair Loop per failed wave: if verification fails and maps to a wave item, dispatch one repair subagent for that item with same `write_scope`, same "not alone" warning, no broad refactor; rerun verification.

Second failure = phase `FAILED`; user chooses fix manually / override / stop.

### 10. Review + QA gate

When all waves pass integration: run or hand off `/appmaker:review feature <feature>` or `/appmaker:review <ids>` per phase scope; run or hand off `/appmaker:qa` when QA / Smoke Plan or UI/browser surface exists; persist review/QA paths in phase report.

No archive suggestion until review/QA gates are PASS or explicitly overridden.

### 11. Persist Phase Execution Report

Write report at start, append after every wave, finalize at end:

```bash
mkdir -p appmaker/phase-plans
EXEC_PATH="appmaker/phase-plans/$(date -u +%Y-%m-%d-%H%M)-<phase-id>-execute.md"
cat > "$EXEC_PATH" <<'EXEC_EOF'
---
phase_id: <phase-id>
mode: execute
status: RUNNING
started: <ISO timestamp>
---

# Phase Execution Report

## Wave Results
| Wave | Items | Agents | Outcome | touched files |
|---|---|---|---|---|

## Integration Gate
| Check | Result | Evidence |
|---|---|---|

## Repair Loop
| Wave | Item | Action | Result |
|---|---|---|---|

## Review / QA
| Gate | Result | Artifact |
|---|---|---|

## Stop
(filled at end)
EXEC_EOF
test -f "$EXEC_PATH" && echo "Phase execution report: $EXEC_PATH"
```

Finalize status: `DONE` or `FAILED`.

## Guardrails

- **Dry-run before execute.** Execute requires latest PASS/WARN plan.
- **Manual approval.** AskUserQuestion before dispatch.
- **MUST NOT use the Skill tool** for side-effect slash skills from inside phase.
- **One subagent per item.** No vague feature-sized delegation.
- **Bounded concurrency.** Respect `max_parallel_agents`.
- **Owned scope.** do not edit outside write_scope.
- **Shared workspace.** Every agent is told: you are not alone in the codebase.
- **Stop on subagent FAIL** unless bounded Repair Loop applies.
- **Verify before next wave.** No stacking broken waves.
- **Review/QA before done.** Phase is not done until review/QA gates pass or user overrides.
- **Persist every state.** Plan + execution report are audit trail.
