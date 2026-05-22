#!/usr/bin/env bash
# Smoke test for /appmaker:phase execute orchestration contract.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PHASE_SKILL="$REPO_ROOT/plugin/appmaker/skills/phase/SKILL.md"
README="$REPO_ROOT/README.md"
DESIGN="$REPO_ROOT/DESIGN.md"

echo "=== /appmaker:phase execute smoke tests ==="

assert_file_exists "phase/SKILL.md present" "$PHASE_SKILL"

PHASE_BODY="$(cat "$PHASE_SKILL" 2>/dev/null || true)"
README_BODY="$(cat "$README" 2>/dev/null || true)"
DESIGN_BODY="$(cat "$DESIGN" 2>/dev/null || true)"

assert_contains "phase supports execute command" "$PHASE_BODY" "/appmaker:phase <phase-id> --execute"
assert_contains "phase execute requires prior dry-run plan" "$PHASE_BODY" "latest PASS/WARN Phase Execution Plan"
assert_contains "phase execute asks for approval" "$PHASE_BODY" "AskUserQuestion"
assert_contains "phase execute invokes Agent tool" "$PHASE_BODY" "Agent("
assert_contains "phase execute runs one subagent per item" "$PHASE_BODY" "one subagent per item"
assert_contains "phase execute runs wave by wave" "$PHASE_BODY" "wave by wave"
assert_contains "phase execute waits for current wave" "$PHASE_BODY" "wait for all subagents in the wave"
assert_contains "phase execute enforces write scope" "$PHASE_BODY" "do not edit outside write_scope"
assert_contains "phase execute tells agents they are not alone" "$PHASE_BODY" "you are not alone in the codebase"
assert_contains "phase execute writes execution report" "$PHASE_BODY" "Phase Execution Report"
assert_contains "phase execute records wave results" "$PHASE_BODY" "Wave Results"
assert_contains "phase execute records integration gate" "$PHASE_BODY" "Integration Gate"
assert_contains "phase execute runs configured verification" "$PHASE_BODY" "test_command"
assert_contains "phase execute stops on subagent failure" "$PHASE_BODY" "subagent FAIL"
assert_contains "phase execute does not use Skill tool handoff" "$PHASE_BODY" "MUST NOT use the Skill tool"
assert_contains "phase execute has repair loop" "$PHASE_BODY" "Repair Loop"
assert_contains "phase execute has review gate" "$PHASE_BODY" "/appmaker:review"
assert_contains "phase execute has QA gate" "$PHASE_BODY" "/appmaker:qa"
assert_contains "phase execute tracks touched files" "$PHASE_BODY" "touched files"
assert_contains "phase execute handles dirty worktree" "$PHASE_BODY" "dirty worktree"
assert_contains "phase execute caps concurrency" "$PHASE_BODY" "max_parallel_agents"
assert_contains "phase execute defines phase states" "$PHASE_BODY" "PLANNED -> RUNNING -> VERIFYING -> REVIEWING -> DONE"

TODO_COUNT=$(grep -c -- "--execute is TODO" "$PHASE_SKILL" || true)
assert_eq "phase execute no longer marked TODO" "0" "$TODO_COUNT"

assert_contains "README documents phase execute" "$README_BODY" "/appmaker:phase <phase-id> --execute"
assert_contains "DESIGN documents phase execute" "$DESIGN_BODY" "Phase execute"

print_summary
