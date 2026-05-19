#!/usr/bin/env bash
# Smoke test for persisted Approved TDD Plan contract in backlog items.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/templates/backlog-item-template.md"
REVIEW="$REPO_ROOT/plugin/appmaker/skills/review/SKILL.md"
CHECKLIST="$REPO_ROOT/plugin/appmaker/skills/checklist/SKILL.md"

echo "=== backlog Approved TDD Plan smoke tests ==="

assert_file_exists "backlog template present" "$TEMPLATE"

PLAN_LINE=$(grep -n '^## Approved TDD Plan' "$TEMPLATE" | head -1 | cut -d: -f1)
EXEC_LINE=$(grep -n '^## Execution Record' "$TEMPLATE" | head -1 | cut -d: -f1)
if [ -n "$PLAN_LINE" ] && [ -n "$EXEC_LINE" ] && [ "$PLAN_LINE" -lt "$EXEC_LINE" ]; then
  PLAN_ORDER_OK="yes"
else
  PLAN_ORDER_OK="no"
fi
assert_eq "Approved TDD Plan appears before Execution Record" "yes" "$PLAN_ORDER_OK"

TEMPLATE_SEM=$(grep -cF "Review/checklist compare this dry-run intent" "$TEMPLATE" || true)
[ "$TEMPLATE_SEM" -ge 1 ] && TEMPLATE_SEM_OK="yes" || TEMPLATE_SEM_OK="no"
assert_eq "template documents plan-vs-actual semantics" "yes" "$TEMPLATE_SEM_OK"

REVIEW_PLAN=$(grep -cF "Plan-vs-actual drift" "$REVIEW" || true)
[ "$REVIEW_PLAN" -ge 1 ] && REVIEW_PLAN_OK="yes" || REVIEW_PLAN_OK="no"
assert_eq "review checks plan-vs-actual drift" "yes" "$REVIEW_PLAN_OK"

CHECKLIST_PLAN=$(grep -cF "Approved TDD plan" "$CHECKLIST" || true)
[ "$CHECKLIST_PLAN" -ge 1 ] && CHECKLIST_PLAN_OK="yes" || CHECKLIST_PLAN_OK="no"
assert_eq "checklist includes Approved TDD plan check" "yes" "$CHECKLIST_PLAN_OK"

print_summary
