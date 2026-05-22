#!/usr/bin/env bash
# Smoke test for deterministic phase runtime helpers.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$REPO_ROOT/plugin/appmaker/scripts/phase-plan.sh"
PHASE_SKILL="$REPO_ROOT/plugin/appmaker/skills/phase/SKILL.md"
CHECKLIST_SKILL="$REPO_ROOT/plugin/appmaker/skills/checklist/SKILL.md"
STATUS_SKILL="$REPO_ROOT/plugin/appmaker/skills/status/SKILL.md"
CONFIG_TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/config.yaml.template"

echo "=== phase runtime helper smoke tests ==="

assert_file_exists "phase-plan.sh present" "$SCRIPT"

assert_contains "phase skill calls deterministic planner" "$(cat "$PHASE_SKILL" 2>/dev/null || true)" "phase-plan.sh"
assert_contains "checklist has phase scope" "$(cat "$CHECKLIST_SKILL" 2>/dev/null || true)" "/appmaker:checklist phase <phase-id>"
assert_contains "status shows phase visibility" "$(cat "$STATUS_SKILL" 2>/dev/null || true)" "Phase Orchestrator"
assert_contains "config has phase PR mode" "$(cat "$CONFIG_TEMPLATE" 2>/dev/null || true)" "phase_execution_mode:"

TMP_PROJECT=$(setup_temp_dir)
mkdir -p "$TMP_PROJECT/appmaker/backlog" "$TMP_PROJECT/appmaker/phase-plans"
cat > "$TMP_PROJECT/appmaker/config.yaml" <<'EOF'
max_parallel_agents: 3
EOF

cat > "$TMP_PROJECT/appmaker/backlog/001-auth-service.md" <<'EOF'
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

## Acceptance criteria
- [ ] auth works (traces_to: pcrit-001, test: tests/auth.test.ts::auth_works)
EOF

cat > "$TMP_PROJECT/appmaker/backlog/002-billing-service.md" <<'EOF'
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

## Acceptance criteria
- [ ] billing works (traces_to: pcrit-002, test: tests/billing.test.ts::billing_works)
EOF

cat > "$TMP_PROJECT/appmaker/backlog/003-login-ui.md" <<'EOF'
---
id: 003
slug: login-ui
status: open
execution_class: autonomous
blocked_by: []
phase_id: phase-alpha
agent_profile: frontend-specialist
write_scope:
  - src/login/
depends_on: [001]
integration_risk: medium
traces_to: [pcrit-003]
---

## Acceptance criteria
- [ ] login renders (traces_to: pcrit-003, test: tests/login.test.ts::login_renders)
EOF

(
  cd "$TMP_PROJECT" || exit 1
  bash "$SCRIPT" phase-alpha >/tmp/appmaker-phase-plan-pass.out
)
RC=$?
assert_exit_zero "phase-plan pass fixture exits 0" "$RC"
PLAN_PATH=$(ls "$TMP_PROJECT"/appmaker/phase-plans/*phase-alpha-dry-run.md 2>/dev/null | head -1)
assert_file_exists "phase plan persisted" "$PLAN_PATH"
PLAN_BODY="$(cat "$PLAN_PATH" 2>/dev/null || true)"
assert_contains "phase plan status PASS" "$PLAN_BODY" "status: PASS"
assert_contains "phase plan wave 1 has independent items" "$PLAN_BODY" "| 1 | 001, 002 |"
assert_contains "phase plan wave 2 has dependent item" "$PLAN_BODY" "| 2 | 003 |"

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

## Acceptance criteria
- [ ] conflict ${item} (traces_to: pcrit-${item}, test: tests/x.test.ts::x_${item})
EOF
done

(
  cd "$TMP_CONFLICT" || exit 1
  bash "$SCRIPT" phase-conflict >/tmp/appmaker-phase-plan-conflict.out
)
RC=$?
assert_eq "phase-plan conflict fixture exits 1" "1" "$RC"
CONFLICT_PLAN=$(ls "$TMP_CONFLICT"/appmaker/phase-plans/*phase-conflict-dry-run.md 2>/dev/null | head -1)
assert_file_exists "conflict plan persisted" "$CONFLICT_PLAN"
CONFLICT_BODY="$(cat "$CONFLICT_PLAN" 2>/dev/null || true)"
assert_contains "conflict plan status FAIL" "$CONFLICT_BODY" "status: FAIL"
assert_contains "conflict plan names scope overlap" "$CONFLICT_BODY" "scope overlap"

print_summary
