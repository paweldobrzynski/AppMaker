#!/usr/bin/env bash
# Smoke test for deterministic JSON APIs used by future AppMaker UI/control-plane.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
STATUS_SCRIPT="$REPO_ROOT/plugin/appmaker/scripts/status-json.sh"
PHASE_SCRIPT="$REPO_ROOT/plugin/appmaker/scripts/phase-plan.sh"

echo "=== engine JSON API smoke tests ==="

assert_file_exists "status-json.sh present" "$STATUS_SCRIPT"
assert_file_exists "phase-plan.sh present" "$PHASE_SCRIPT"

PHASE_HELP=$(bash "$PHASE_SCRIPT" --help 2>/dev/null || true)
assert_contains "phase-plan help documents json mode" "$PHASE_HELP" "--json"

TMP_EMPTY=$(setup_temp_dir)
EMPTY_JSON=$(bash "$STATUS_SCRIPT" --project-dir "$TMP_EMPTY" 2>/tmp/appmaker-status-empty.err)
RC=$?
assert_exit_zero "status-json exits 0 without appmaker dir" "$RC"
assert_contains "status-json marks non-appmaker dir" "$EMPTY_JSON" '"appmaker":false'

TMP_PROJECT=$(setup_temp_dir)
mkdir -p "$TMP_PROJECT/appmaker/features/001-old-feature" \
  "$TMP_PROJECT/appmaker/features/002-new-feature" \
  "$TMP_PROJECT/appmaker/backlog/done" \
  "$TMP_PROJECT/appmaker/checklists" \
  "$TMP_PROJECT/appmaker/phase-plans"
printf '0.2.25\n' > "$TMP_PROJECT/appmaker/.appmaker-version"

cat > "$TMP_PROJECT/appmaker/backlog/001-open-api.md" <<'EOF'
---
id: 001
status: open
feature: 002-new-feature
---
EOF

cat > "$TMP_PROJECT/appmaker/backlog/002-blocked-ui.md" <<'EOF'
---
id: 002
status: blocked
feature: 002-new-feature
---
EOF

cat > "$TMP_PROJECT/appmaker/backlog/done/003-done-worker.md" <<'EOF'
---
id: 003
status: done
feature: 002-new-feature
---
EOF

cat > "$TMP_PROJECT/appmaker/checklists/2026-05-22-feature-002-new-feature.md" <<'EOF'
---
scope: feature 002-new-feature
status: WARN
created: 2026-05-22
---
EOF

cat > "$TMP_PROJECT/appmaker/phase-plans/2026-05-22-100000-phase-alpha-dry-run.md" <<'EOF'
---
phase_id: phase-alpha
mode: dry-run
status: PASS
created: 2026-05-22T10:00:00Z
---
EOF

STATUS_JSON=$(bash "$STATUS_SCRIPT" --project-dir "$TMP_PROJECT" 2>/tmp/appmaker-status-json.err)
RC=$?
assert_exit_zero "status-json exits 0 in appmaker project" "$RC"
assert_contains "status-json marks appmaker project" "$STATUS_JSON" '"appmaker":true'
assert_contains "status-json includes version" "$STATUS_JSON" '"version":"0.2.25"'
assert_contains "status-json selects newest active feature" "$STATUS_JSON" '"active_feature":"002-new-feature"'
assert_contains "status-json counts feature backlog total" "$STATUS_JSON" '"total":3'
assert_contains "status-json counts done backlog" "$STATUS_JSON" '"done":1'
assert_contains "status-json lists open backlog ids" "$STATUS_JSON" '"open_ids":["001","002"]'
assert_contains "status-json includes checklist status" "$STATUS_JSON" '"checklist":{"status":"WARN"'
assert_contains "status-json includes latest phase id" "$STATUS_JSON" '"phase":{"id":"phase-alpha"'
assert_contains "status-json includes latest phase status" "$STATUS_JSON" '"status":"PASS"'
assert_contains "status-json includes git state" "$STATUS_JSON" '"git":{"dirty":false'

TMP_PHASE=$(setup_temp_dir)
mkdir -p "$TMP_PHASE/appmaker/backlog" "$TMP_PHASE/appmaker/phase-plans"
cat > "$TMP_PHASE/appmaker/config.yaml" <<'EOF'
max_parallel_agents: 3
phase_execution_mode: local
EOF

cat > "$TMP_PHASE/appmaker/backlog/001-auth-service.md" <<'EOF'
---
id: 001
slug: auth-service
status: open
execution_class: autonomous
blocked_by: []
phase_id: phase-alpha
agent_profile: backend-specialist
write_scope:
  - src/auth/
depends_on: []
integration_risk: medium
traces_to: [pcrit-001]
---
EOF

cat > "$TMP_PHASE/appmaker/backlog/002-billing-service.md" <<'EOF'
---
id: 002
slug: billing-service
status: open
execution_class: autonomous
blocked_by: []
phase_id: phase-alpha
agent_profile: backend-specialist
write_scope:
  - src/billing/
depends_on: []
integration_risk: low
traces_to: [pcrit-002]
---
EOF

(
  cd "$TMP_PHASE" || exit 1
  bash "$PHASE_SCRIPT" --json phase-alpha >/tmp/appmaker-phase-json-pass.out
)
RC=$?
PHASE_JSON=$(cat /tmp/appmaker-phase-json-pass.out 2>/dev/null || true)
assert_exit_zero "phase-plan json pass exits 0" "$RC"
assert_contains "phase-plan json includes phase id" "$PHASE_JSON" '"phase_id":"phase-alpha"'
assert_contains "phase-plan json includes PASS status" "$PHASE_JSON" '"status":"PASS"'
assert_contains "phase-plan json includes report path" "$PHASE_JSON" '"report_path":"appmaker/phase-plans/'
assert_contains "phase-plan json includes waves" "$PHASE_JSON" '"waves":['
assert_contains "phase-plan json includes wave item ids" "$PHASE_JSON" '"items":["001","002"]'

TMP_CONFLICT=$(setup_temp_dir)
mkdir -p "$TMP_CONFLICT/appmaker/backlog" "$TMP_CONFLICT/appmaker/phase-plans"
for item in 001 002; do
  cat > "$TMP_CONFLICT/appmaker/backlog/${item}-conflict.md" <<EOF
---
id: ${item}
slug: conflict-${item}
status: open
execution_class: autonomous
blocked_by: []
phase_id: phase-conflict
agent_profile: backend-specialist
write_scope:
  - src/shared/
depends_on: []
integration_risk: medium
traces_to: [pcrit-${item}]
---
EOF
done

(
  cd "$TMP_CONFLICT" || exit 1
  bash "$PHASE_SCRIPT" --json phase-conflict >/tmp/appmaker-phase-json-conflict.out
)
RC=$?
CONFLICT_JSON=$(cat /tmp/appmaker-phase-json-conflict.out 2>/dev/null || true)
assert_eq "phase-plan json conflict exits 1" "1" "$RC"
assert_contains "phase-plan json conflict status FAIL" "$CONFLICT_JSON" '"status":"FAIL"'
assert_contains "phase-plan json includes conflict list" "$CONFLICT_JSON" '"conflicts":['
assert_contains "phase-plan json names scope overlap" "$CONFLICT_JSON" "scope overlap"

print_summary
