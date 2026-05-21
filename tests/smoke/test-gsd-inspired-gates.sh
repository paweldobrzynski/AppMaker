#!/usr/bin/env bash
# Smoke test for selected GSD-inspired AppMaker guardrails.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PLAN_CHECK="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/tdd/plan-check.md"
CONTEXT_BUDGET="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/context-budget.md"
ARCH_REF="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/architecture-options-research.md"
BACKLOG_TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/templates/backlog-item-template.md"
TDD_SKILL="$REPO_ROOT/plugin/appmaker/skills/tdd/SKILL.md"
REVIEW_CONTRACT="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/review/review-contract.md"
CHECKLIST_SKILL="$REPO_ROOT/plugin/appmaker/skills/checklist/SKILL.md"

echo "=== GSD-inspired guardrails smoke tests ==="

for f in "$PLAN_CHECK" "$CONTEXT_BUDGET" "$ARCH_REF" "$BACKLOG_TEMPLATE" "$TDD_SKILL" "$REVIEW_CONTRACT" "$CHECKLIST_SKILL"; do
  assert_file_exists "required workflow file exists: ${f#$REPO_ROOT/}" "$f"
done

PLAN_TEXT=$(cat "$PLAN_CHECK" 2>/dev/null || true)
CONTEXT_TEXT=$(cat "$CONTEXT_BUDGET" 2>/dev/null || true)
ARCH_TEXT=$(cat "$ARCH_REF" 2>/dev/null || true)
BACKLOG_TEXT=$(cat "$BACKLOG_TEMPLATE" 2>/dev/null || true)
TDD_TEXT=$(cat "$TDD_SKILL" 2>/dev/null || true)
REVIEW_TEXT=$(cat "$REVIEW_CONTRACT" 2>/dev/null || true)
CHECKLIST_TEXT=$(cat "$CHECKLIST_SKILL" 2>/dev/null || true)

assert_contains "plan-check has bounded revision gate" "$PLAN_TEXT" "Bounded revision"
assert_contains "plan-check requires AC coverage" "$PLAN_TEXT" "AC coverage"
assert_contains "plan-check requires dependency audit coverage" "$PLAN_TEXT" "dependency audit"
assert_contains "plan-check has escalation path" "$PLAN_TEXT" "escalate"
assert_contains "tdd invokes TDD Plan Check before first RED" "$TDD_TEXT" "TDD Plan Check"

assert_contains "architecture research includes package legitimacy" "$ARCH_TEXT" "Package / dependency legitimacy"
assert_contains "architecture research blocks slopsquatting" "$ARCH_TEXT" "slopsquatting"
assert_contains "architecture research forbids failed-install substitution" "$ARCH_TEXT" "failed install"
assert_contains "checklist gates package legitimacy evidence" "$CHECKLIST_TEXT" "Package legitimacy"

assert_contains "context budget ref documents MCP schema cost" "$CONTEXT_TEXT" "MCP schema cost"
assert_contains "context budget ref documents context degradation" "$CONTEXT_TEXT" "Context degradation"
assert_contains "context budget ref requires pre-flight MCP audit" "$CONTEXT_TEXT" "Pre-flight MCP audit"
assert_contains "checklist checks context budget for large work" "$CHECKLIST_TEXT" "Context budget / MCP audit"

assert_contains "review contract uses exists/substantive/wired/functional" "$REVIEW_TEXT" "exists / substantive / wired / functional"
assert_contains "checklist uses exists/substantive/wired/functional" "$CHECKLIST_TEXT" "exists / substantive / wired / functional"

assert_contains "backlog captures gray areas before planning" "$BACKLOG_TEXT" "Implementation Decisions / Gray Areas"
assert_contains "backlog tracks unresolved gray areas" "$BACKLOG_TEXT" "Unresolved gray area"
assert_contains "tdd refuses unresolved gray areas before planning" "$TDD_TEXT" "unresolved gray areas"

print_summary
