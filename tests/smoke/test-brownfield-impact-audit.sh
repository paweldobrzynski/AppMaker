#!/usr/bin/env bash
# Smoke test for the Brownfield Impact Audit gate.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/lib.sh"

TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/templates/backlog-item-template.md"
TDD_SKILL="$REPO_ROOT/plugin/appmaker/skills/tdd/SKILL.md"
BROWNFIELD_REF="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/tdd/brownfield-impact-audit.md"
DECOMPOSE_SKILL="$REPO_ROOT/plugin/appmaker/skills/decompose/SKILL.md"
GRILL_BROWNFIELD="$REPO_ROOT/plugin/appmaker/skills/grill-brownfield/SKILL.md"
CONTEXT_TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/templates/context-packet-template.md"
CONTEXT_SKILL="$REPO_ROOT/plugin/appmaker/skills/context/SKILL.md"
REVIEW_CONTRACT="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/review/review-contract.md"
CHECKLIST_SKILL="$REPO_ROOT/plugin/appmaker/skills/checklist/SKILL.md"

echo "=== Brownfield Impact Audit gate smoke tests ==="

for f in "$TEMPLATE" "$TDD_SKILL" "$BROWNFIELD_REF" "$DECOMPOSE_SKILL" "$GRILL_BROWNFIELD" "$CONTEXT_TEMPLATE" "$CONTEXT_SKILL" "$REVIEW_CONTRACT" "$CHECKLIST_SKILL"; do
  assert_file_exists "required workflow file exists: ${f#$REPO_ROOT/}" "$f"
done

line_no() {
  local pattern="$1" file_path="$2"
  grep -nE "$pattern" "$file_path" | head -1 | cut -d: -f1
}

AC_LINE=$(line_no '^## Acceptance criteria$' "$TEMPLATE")
AUDIT_LINE=$(line_no '^## Brownfield Impact Audit$' "$TEMPLATE")
PLAN_LINE=$(line_no '^## Approved TDD Plan$' "$TEMPLATE")
if [ -n "$AC_LINE" ] && [ -n "$AUDIT_LINE" ] && [ -n "$PLAN_LINE" ] && [ "$AC_LINE" -lt "$AUDIT_LINE" ] && [ "$AUDIT_LINE" -lt "$PLAN_LINE" ]; then
  TEMPLATE_ORDER_OK=yes
else
  TEMPLATE_ORDER_OK=no
fi
assert_eq "template places Brownfield Impact Audit between ACs and TDD plan" "yes" "$TEMPLATE_ORDER_OK"

for phrase in \
  "Canonical values / hardcoded contracts" \
  "Dependency surface map" \
  "Side-effect order" \
  "Duplicate logic / mirrors" \
  "Test and lint guards" \
  "Deferred / intentionally not touched" \
  "Unknowns requiring human answer"
do
  COUNT=$(grep -cF "$phrase" "$TEMPLATE" || true)
  if [ "$COUNT" -gt 0 ]; then PRESENT=yes; else PRESENT=no; fi
  assert_eq "template has audit section: $phrase" "yes" "$PRESENT"
done

CTX_LINE=$(line_no '^### 2\. Read context' "$TDD_SKILL")
AUDIT_STEP_LINE=$(line_no '^### 2b\. Brownfield Impact Audit' "$TDD_SKILL")
PLAN_STEP_LINE=$(line_no '^### 3\. Planning' "$TDD_SKILL")
if [ -n "$CTX_LINE" ] && [ -n "$AUDIT_STEP_LINE" ] && [ -n "$PLAN_STEP_LINE" ] && [ "$CTX_LINE" -lt "$AUDIT_STEP_LINE" ] && [ "$AUDIT_STEP_LINE" -lt "$PLAN_STEP_LINE" ]; then
  TDD_ORDER_OK=yes
else
  TDD_ORDER_OK=no
fi
assert_eq "tdd runs impact audit after context and before planning" "yes" "$TDD_ORDER_OK"

for phrase in \
  "refuse the first RED cycle" \
  "use \`rg\` first" \
  "canonical values / hardcoded contracts" \
  "side-effect order" \
  "TDD cycles cover every non-deferred dependency"
do
  COUNT=$(grep -cF "$phrase" "$TDD_SKILL" || true)
  if [ "$COUNT" -gt 0 ]; then PRESENT=yes; else PRESENT=no; fi
  assert_eq "tdd enforces audit requirement: $phrase" "yes" "$PRESENT"
done

for phrase in \
  "Data model and read/write paths" \
  "API / caller graph" \
  "UI / client mirrors" \
  "Tests / lint / docs / memory" \
  "Backward compatibility / rollout" \
  "exact search query" \
  "owner/consumer/mirror" \
  "Unexplained \"not touched\" is not allowed"
do
  COUNT=$(grep -cF "$phrase" "$BROWNFIELD_REF" || true)
  if [ "$COUNT" -gt 0 ]; then PRESENT=yes; else PRESENT=no; fi
  assert_eq "brownfield reference documents audit detail: $phrase" "yes" "$PRESENT"
done

DECOMP_SEED_COUNT=$(grep -cF "Brownfield Impact Audit seed" "$DECOMPOSE_SKILL" || true)
if [ "$DECOMP_SEED_COUNT" -gt 0 ]; then DECOMP_SEED_PRESENT=yes; else DECOMP_SEED_PRESENT=no; fi
assert_eq "decompose seeds Brownfield Impact Audit" "yes" "$DECOMP_SEED_PRESENT"

DECOMP_PENDING_COUNT=$(grep -cF "Audit status: pending" "$DECOMPOSE_SKILL" || true)
if [ "$DECOMP_PENDING_COUNT" -gt 0 ]; then DECOMP_PENDING_PRESENT=yes; else DECOMP_PENDING_PRESENT=no; fi
assert_eq "decompose writes pending audit for brownfield backlog items" "yes" "$DECOMP_PENDING_PRESENT"

GRILL_SEED_COUNT=$(grep -cF "Build Brownfield Impact Audit seed" "$GRILL_BROWNFIELD" || true)
if [ "$GRILL_SEED_COUNT" -gt 0 ]; then GRILL_SEED_PRESENT=yes; else GRILL_SEED_PRESENT=no; fi
assert_eq "grill-brownfield builds audit seed before questions" "yes" "$GRILL_SEED_PRESENT"

CTX_VALUES_COUNT=$(grep -cF "Canonical Values / Hardcoded Contracts" "$CONTEXT_TEMPLATE" || true)
CTX_SKILL_VALUES_COUNT=$(grep -cF "Canonical Values / Hardcoded Contracts" "$CONTEXT_SKILL" || true)
if [ "$CTX_VALUES_COUNT" -gt 0 ] && [ "$CTX_SKILL_VALUES_COUNT" -gt 0 ]; then CONTEXT_VALUES_PRESENT=yes; else CONTEXT_VALUES_PRESENT=no; fi
assert_eq "context packets capture canonical values and hardcoded contracts" "yes" "$CONTEXT_VALUES_PRESENT"

REVIEW_COUNT=$(grep -cF "Brownfield impact audit coverage" "$REVIEW_CONTRACT" || true)
if [ "$REVIEW_COUNT" -gt 0 ]; then REVIEW_PRESENT=yes; else REVIEW_PRESENT=no; fi
assert_eq "review contract checks Brownfield Impact Audit coverage" "yes" "$REVIEW_PRESENT"

CHECKLIST_COUNT=$(grep -cF "Brownfield Impact Audit" "$CHECKLIST_SKILL" || true)
CHECKLIST_COMPLETE_COUNT=$(grep -cF "Audit status: complete" "$CHECKLIST_SKILL" || true)
if [ "$CHECKLIST_COUNT" -gt 0 ] && [ "$CHECKLIST_COMPLETE_COUNT" -gt 0 ]; then CHECKLIST_PRESENT=yes; else CHECKLIST_PRESENT=no; fi
assert_eq "checklist gates missing or incomplete Brownfield Impact Audit" "yes" "$CHECKLIST_PRESENT"

print_summary
