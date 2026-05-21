#!/usr/bin/env bash
# Smoke test for the Architecture Options Research gate.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/lib.sh"

ARCH_REF="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/architecture-options-research.md"
TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/templates/backlog-item-template.md"
CONTEXT_TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/templates/context-packet-template.md"
CONTEXT_SKILL="$REPO_ROOT/plugin/appmaker/skills/context/SKILL.md"
PRD_SKILL="$REPO_ROOT/plugin/appmaker/skills/prd/SKILL.md"
TDD_SKILL="$REPO_ROOT/plugin/appmaker/skills/tdd/SKILL.md"
DECOMPOSE_SKILL="$REPO_ROOT/plugin/appmaker/skills/decompose/SKILL.md"
GRILL_BROWNFIELD="$REPO_ROOT/plugin/appmaker/skills/grill-brownfield/SKILL.md"
REVIEW_SKILL="$REPO_ROOT/plugin/appmaker/skills/review/SKILL.md"
REVIEW_CONTRACT="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/review/review-contract.md"
CHECKLIST_SKILL="$REPO_ROOT/plugin/appmaker/skills/checklist/SKILL.md"

echo "=== Architecture Options Research gate smoke tests ==="

for f in "$ARCH_REF" "$TEMPLATE" "$CONTEXT_TEMPLATE" "$CONTEXT_SKILL" "$PRD_SKILL" "$TDD_SKILL" "$DECOMPOSE_SKILL" "$GRILL_BROWNFIELD" "$REVIEW_SKILL" "$REVIEW_CONTRACT" "$CHECKLIST_SKILL"; do
  assert_file_exists "required workflow file exists: ${f#$REPO_ROOT/}" "$f"
done

line_no() {
  local pattern="$1" file_path="$2"
  grep -nE "$pattern" "$file_path" | head -1 | cut -d: -f1
}

AC_LINE=$(line_no '^## Acceptance criteria$' "$TEMPLATE")
ARCH_LINE=$(line_no '^## Architecture Options Research$' "$TEMPLATE")
BROWNFIELD_LINE=$(line_no '^## Brownfield Impact Audit$' "$TEMPLATE")
if [ -n "$AC_LINE" ] && [ -n "$ARCH_LINE" ] && [ -n "$BROWNFIELD_LINE" ] && [ "$AC_LINE" -lt "$ARCH_LINE" ] && [ "$ARCH_LINE" -lt "$BROWNFIELD_LINE" ]; then
  TEMPLATE_ORDER_OK=yes
else
  TEMPLATE_ORDER_OK=no
fi
assert_eq "template places architecture research before brownfield audit" "yes" "$TEMPLATE_ORDER_OK"

for phrase in \
  "greenfield often needs it more" \
  "framework/library/vendor choice" \
  "design system or reusable UI primitive taxonomy" \
  "ref_search_documentation" \
  "ref_read_url" \
  "GitHub indexed resources" \
  "Options matrix" \
  "Package / dependency legitimacy" \
  "At least two credible options" \
  "Custom build requires a rationale" \
  "slopsquatting" \
  "failed install"
do
  COUNT=$(grep -cF "$phrase" "$ARCH_REF" || true)
  if [ "$COUNT" -gt 0 ]; then PRESENT=yes; else PRESENT=no; fi
  assert_eq "architecture ref documents: $phrase" "yes" "$PRESENT"
done

for f in "$TEMPLATE" "$CONTEXT_TEMPLATE" "$CONTEXT_SKILL"; do
  COUNT=$(grep -cF "Architecture Options Research" "$f" || true)
  REF_COUNT=$(grep -cF "ref_search_documentation" "$f" || true)
  if [ "$COUNT" -gt 0 ] && [ "$REF_COUNT" -gt 0 ]; then PRESENT=yes; else PRESENT=no; fi
  assert_eq "artifact captures architecture research and Ref evidence: ${f#$REPO_ROOT/}" "yes" "$PRESENT"
done

for f in "$PRD_SKILL" "$TDD_SKILL" "$DECOMPOSE_SKILL" "$GRILL_BROWNFIELD" "$REVIEW_SKILL" "$REVIEW_CONTRACT" "$CHECKLIST_SKILL"; do
  TITLE_COUNT=$(grep -cF "Architecture Options Research" "$f" || true)
  LOWER_COUNT=$(grep -cF "architecture options research" "$f" || true)
  if [ "$TITLE_COUNT" -gt 0 ] || [ "$LOWER_COUNT" -gt 0 ]; then PRESENT=yes; else PRESENT=no; fi
  assert_eq "workflow enforces architecture research: ${f#$REPO_ROOT/}" "yes" "$PRESENT"
done

CHECKLIST_MATRIX_COUNT=$(grep -cF "options matrix" "$CHECKLIST_SKILL" || true)
CHECKLIST_SOURCES_COUNT=$(grep -cF "source evidence" "$CHECKLIST_SKILL" || true)
if [ "$CHECKLIST_MATRIX_COUNT" -gt 0 ] && [ "$CHECKLIST_SOURCES_COUNT" -gt 0 ]; then CHECKLIST_PRESENT=yes; else CHECKLIST_PRESENT=no; fi
assert_eq "checklist fails source-free architecture decisions" "yes" "$CHECKLIST_PRESENT"

print_summary
