#!/usr/bin/env bash
# Smoke test for selected gstack-inspired lifecycle improvements.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
README="$REPO_ROOT/README.md"
DESIGN="$REPO_ROOT/DESIGN.md"
BACKLOG_TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/templates/backlog-item-template.md"
TDD_SKILL="$REPO_ROOT/plugin/appmaker/skills/tdd/SKILL.md"
STATUS_SKILL="$REPO_ROOT/plugin/appmaker/skills/status/SKILL.md"
QA_SKILL="$REPO_ROOT/plugin/appmaker/skills/qa/SKILL.md"
DESIGN_REVIEW_SKILL="$REPO_ROOT/plugin/appmaker/skills/design-review/SKILL.md"
DIAGNOSE_SKILL="$REPO_ROOT/plugin/appmaker/skills/diagnose/SKILL.md"
REVIEW_SKILL="$REPO_ROOT/plugin/appmaker/skills/review/SKILL.md"
REVIEW_CONTRACT="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/review/review-contract.md"
CHECKLIST_SKILL="$REPO_ROOT/plugin/appmaker/skills/checklist/SKILL.md"

echo "=== gstack-inspired lifecycle smoke tests ==="

for f in "$README" "$DESIGN" "$BACKLOG_TEMPLATE" "$TDD_SKILL" "$STATUS_SKILL" "$QA_SKILL" "$DESIGN_REVIEW_SKILL" "$DIAGNOSE_SKILL" "$REVIEW_SKILL" "$REVIEW_CONTRACT" "$CHECKLIST_SKILL"; do
  assert_file_exists "required workflow file exists: ${f#$REPO_ROOT/}" "$f"
done

README_TEXT=$(cat "$README" 2>/dev/null || true)
DESIGN_TEXT=$(cat "$DESIGN" 2>/dev/null || true)
BACKLOG_TEXT=$(cat "$BACKLOG_TEMPLATE" 2>/dev/null || true)
TDD_TEXT=$(cat "$TDD_SKILL" 2>/dev/null || true)
STATUS_TEXT=$(cat "$STATUS_SKILL" 2>/dev/null || true)
QA_TEXT=$(cat "$QA_SKILL" 2>/dev/null || true)
DESIGN_REVIEW_TEXT=$(cat "$DESIGN_REVIEW_SKILL" 2>/dev/null || true)
DIAGNOSE_TEXT=$(cat "$DIAGNOSE_SKILL" 2>/dev/null || true)
REVIEW_TEXT=$(cat "$REVIEW_SKILL" 2>/dev/null || true)
REVIEW_CONTRACT_TEXT=$(cat "$REVIEW_CONTRACT" 2>/dev/null || true)
CHECKLIST_TEXT=$(cat "$CHECKLIST_SKILL" 2>/dev/null || true)

assert_contains "README references gstack inspiration" "$README_TEXT" "garrytan/gstack"
assert_contains "DESIGN captures gstack adopted patterns" "$DESIGN_TEXT" "Z gstack"

assert_contains "status has Review Readiness Dashboard" "$STATUS_TEXT" "Review Readiness Dashboard"
assert_contains "status dashboard checks QA" "$STATUS_TEXT" "QA / Smoke Plan"
assert_contains "status dashboard checks design review" "$STATUS_TEXT" "Design Review"

assert_contains "backlog template has QA plan handoff" "$BACKLOG_TEXT" "QA / Smoke Plan"
assert_contains "tdd writes QA plan before completion" "$TDD_TEXT" "QA / Smoke Plan"
assert_contains "review consumes QA plan" "$REVIEW_CONTRACT_TEXT" "QA / Smoke Plan"

assert_contains "qa skill is diff-aware" "$QA_TEXT" "git diff"
assert_contains "qa skill writes report" "$QA_TEXT" "appmaker/qa"
assert_contains "qa skill verifies browser screenshots for UI" "$QA_TEXT" "screenshot"

assert_contains "design-review skill checks reusable CSS" "$DESIGN_REVIEW_TEXT" "reusable CSS"
assert_contains "design-review skill forbids hardcoded visuals" "$DESIGN_REVIEW_TEXT" "hardcoded"
assert_contains "design-review skill requires screenshot evidence" "$DESIGN_REVIEW_TEXT" "screenshot"

assert_contains "diagnose forbids fix before root cause" "$DIAGNOSE_TEXT" "no fixes before root cause"
assert_contains "diagnose stops after 3 failed hypotheses" "$DIAGNOSE_TEXT" "3 failed"

assert_contains "review checks doc staleness" "$REVIEW_CONTRACT_TEXT" "Documentation staleness"
assert_contains "checklist checks doc staleness" "$CHECKLIST_TEXT" "Documentation staleness"

assert_contains "backlog template has edit scope" "$BACKLOG_TEXT" "edit_scope"
assert_contains "tdd enforces edit scope" "$TDD_TEXT" "edit_scope"
assert_contains "review checks edit scope drift" "$REVIEW_CONTRACT_TEXT" "edit_scope"

assert_contains "review supports adversarial mode" "$REVIEW_TEXT" "adversarial"
assert_contains "review contract checks adversarial review" "$REVIEW_CONTRACT_TEXT" "Adversarial review"

print_summary
