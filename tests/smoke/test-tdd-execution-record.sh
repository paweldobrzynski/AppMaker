#!/usr/bin/env bash
# Smoke test for v0.2.19 pcrit-002: /appmaker:tdd materializes Execution Record.
# Scope is structural: ordering + required capture commands/fields, not drift automation.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TDD_SKILL="$REPO_ROOT/plugin/appmaker/skills/tdd/SKILL.md"

echo "=== tdd/SKILL.md Execution Record smoke tests ==="

assert_file_exists "tdd/SKILL.md present" "$TDD_SKILL"

line_no() {
  grep -nE "$1" "$TDD_SKILL" | head -1 | cut -d: -f1
}

PLANNING_LINE=$(line_no '^### 3\. Planning$')
INITIAL_LINE=$(line_no '^### 3b\. Execution Record')
TRACER_LINE=$(line_no '^### 4\. Tracer Bullet')

if [ -n "$PLANNING_LINE" ] && [ -n "$INITIAL_LINE" ] && [ -n "$TRACER_LINE" ] &&
   [ "$PLANNING_LINE" -lt "$INITIAL_LINE" ] && [ "$INITIAL_LINE" -lt "$TRACER_LINE" ]; then
  INITIAL_ORDER_OK="yes"
else
  INITIAL_ORDER_OK="no"
fi
assert_eq "initial Execution Record is after planning and before tracer RED" "yes" "$INITIAL_ORDER_OK"

MARK_DONE_LINE=$(line_no '^### 9\. Mark done')
FINAL_LINE=$(line_no '^### 9a\. Execution Record')
MOVE_LINE=$(line_no 'Move file:')

if [ -n "$MARK_DONE_LINE" ] && [ -n "$FINAL_LINE" ] && [ -n "$MOVE_LINE" ] &&
   [ "$MARK_DONE_LINE" -lt "$FINAL_LINE" ] && [ "$FINAL_LINE" -lt "$MOVE_LINE" ]; then
  FINAL_ORDER_OK="yes"
else
  FINAL_ORDER_OK="no"
fi
assert_eq "final Execution Record is in step 9 before move to done" "yes" "$FINAL_ORDER_OK"

BASE_REF_COUNT=$(grep -cF 'git rev-parse HEAD 2>/dev/null || echo no_base_ref' "$TDD_SKILL" || true)
[ "$BASE_REF_COUNT" -ge 1 ] && BASE_REF_PRESENT="yes" || BASE_REF_PRESENT="no"
assert_eq "base_ref capture uses git rev-parse HEAD with no_base_ref fallback" "yes" "$BASE_REF_PRESENT"

DIRTY_COUNT=$(grep -cF 'git status --short' "$TDD_SKILL" || true)
[ "$DIRTY_COUNT" -ge 1 ] && DIRTY_PRESENT="yes" || DIRTY_PRESENT="no"
assert_eq "dirty worktree detection uses git status --short" "yes" "$DIRTY_PRESENT"

DIRTY_WARN_COUNT=$(grep -cE 'Dirty.*WARN|WARN.*dirty|dirty.*WARN' "$TDD_SKILL" || true)
[ "$DIRTY_WARN_COUNT" -ge 1 ] && DIRTY_WARN_PRESENT="yes" || DIRTY_WARN_PRESENT="no"
assert_eq "dirty worktree behavior is capture + WARN" "yes" "$DIRTY_WARN_PRESENT"

for label in "Actual files" "Tests run" "AC completed" "Drift notes"; do
  COUNT=$(grep -cF "$label" "$TDD_SKILL" || true)
  [ "$COUNT" -ge 1 ] && PRESENT="yes" || PRESENT="no"
  assert_eq "final Execution Record field documented: ${label}" "yes" "$PRESENT"
done

# v0.2.20 patch: step 9a must re-read Base ref from backlog item, not assume
# $BASE_REF shell variable persists across separate Bash tool calls between
# step 3b (Phase A) and step 9a (Phase B). Real Claude Code usage runs these
# in different shell contexts.
READS_BASE_REF=$(grep -ciE 'read.*\*?\*?Base ref\*?\*?.*(back )?from.*backlog|backlog.*\*\*Base ref\*\*' "$TDD_SKILL" || true)
[ "$READS_BASE_REF" -ge 1 ] && READS_BACK="yes" || READS_BACK="no"
assert_eq "step 9a re-reads Base ref from backlog item (not shell variable persistence)" "yes" "$READS_BACK"

print_summary
