#!/usr/bin/env bash
# Smoke test for v0.2.19 pcrit-001: backlog template has ## Execution Record.
# The section is capture-only MVP: one cohesive block with structured fields.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/templates/backlog-item-template.md"

echo "=== backlog-item-template.md Execution Record smoke tests ==="

assert_file_exists "backlog-item-template.md present" "$TEMPLATE"

AC_LINE=$(grep -nE '^## Acceptance criteria$' "$TEMPLATE" | head -1 | cut -d: -f1)
EXEC_LINE=$(grep -nE '^## Execution Record$' "$TEMPLATE" | head -1 | cut -d: -f1)
BLOCKED_LINE=$(grep -nE '^## Blocked by$' "$TEMPLATE" | head -1 | cut -d: -f1)

if [ -n "$AC_LINE" ] && [ -n "$EXEC_LINE" ] && [ -n "$BLOCKED_LINE" ] &&
   [ "$AC_LINE" -lt "$EXEC_LINE" ] && [ "$EXEC_LINE" -lt "$BLOCKED_LINE" ]; then
  ORDER_OK="yes"
else
  ORDER_OK="no"
fi
assert_eq "Execution Record sits between Acceptance criteria and Blocked by" "yes" "$ORDER_OK"

for label in \
  "Base ref" \
  "Dirty at start" \
  "Dirty files at start" \
  "Planned files" \
  "Planned tests" \
  "Actual files" \
  "Tests run" \
  "AC completed" \
  "Drift notes"
do
  COUNT=$(grep -cE "^\*\*${label}:\*\*" "$TEMPLATE" || true)
  [ "$COUNT" -ge 1 ] && PRESENT="yes" || PRESENT="no"
  assert_eq "Execution Record field present: ${label}" "yes" "$PRESENT"
done

DOC_COUNT=$(grep -cE 'Execution Record.*Base ref|Base ref.*Execution Record' "$TEMPLATE" || true)
[ "$DOC_COUNT" -ge 1 ] && DOC_PRESENT="yes" || DOC_PRESENT="no"
assert_eq "template documents Execution Record semantics" "yes" "$DOC_PRESENT"

print_summary
