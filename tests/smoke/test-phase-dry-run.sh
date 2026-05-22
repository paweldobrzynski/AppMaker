#!/usr/bin/env bash
# Smoke test for /appmaker:phase dry-run orchestration contract.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PHASE_SKILL="$REPO_ROOT/plugin/appmaker/skills/phase/SKILL.md"
BACKLOG_TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/templates/backlog-item-template.md"
README="$REPO_ROOT/README.md"
DESIGN="$REPO_ROOT/DESIGN.md"

echo "=== /appmaker:phase dry-run smoke tests ==="

assert_file_exists "phase/SKILL.md present" "$PHASE_SKILL"
assert_file_exists "backlog item template present" "$BACKLOG_TEMPLATE"

PHASE_BODY="$(cat "$PHASE_SKILL" 2>/dev/null || true)"
BACKLOG_BODY="$(cat "$BACKLOG_TEMPLATE" 2>/dev/null || true)"
README_BODY="$(cat "$README" 2>/dev/null || true)"
DESIGN_BODY="$(cat "$DESIGN" 2>/dev/null || true)"

assert_contains "phase skill is manual side-effect handoff" "$PHASE_BODY" "disable-model-invocation: true"
assert_contains "phase supports dry-run command" "$PHASE_BODY" "/appmaker:phase <phase-id> --dry-run"
assert_contains "phase supports execute command after dry-run" "$PHASE_BODY" "/appmaker:phase <phase-id> --execute"
assert_contains "phase dry-run writes a persisted plan" "$PHASE_BODY" "appmaker/phase-plans/"
assert_contains "phase requires write scope before planning waves" "$PHASE_BODY" "write_scope"
assert_contains "phase detects write scope overlap conflicts" "$PHASE_BODY" "scope overlap"
assert_contains "phase computes parallel waves" "$PHASE_BODY" "Parallel Waves"
assert_contains "phase keeps subagent execution bounded to backlog item" "$PHASE_BODY" "Subagent Task Contract"
assert_contains "phase forbids executing blocked items" "$PHASE_BODY" "blocked_by"

for field in phase_id parallel_group agent_profile write_scope depends_on integration_risk; do
  assert_contains "backlog template has phase field: $field" "$BACKLOG_BODY" "$field"
done

assert_contains "backlog rules require write_scope for phase dry-run" "$BACKLOG_BODY" "Phase dry-run requires \`write_scope\`"
assert_contains "backlog rules document depends_on vs blocked_by" "$BACKLOG_BODY" "\`depends_on\`"
assert_contains "README documents phase command" "$README_BODY" "/appmaker:phase <phase-id> --dry-run"
assert_contains "DESIGN documents phase dry-run" "$DESIGN_BODY" "Phase dry-run"

print_summary
