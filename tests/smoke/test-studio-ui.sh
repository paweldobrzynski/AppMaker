#!/usr/bin/env bash
# Smoke test for local AppMaker Studio UI/control-plane.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SERVER="$REPO_ROOT/plugin/appmaker/studio/server.mjs"
INDEX="$REPO_ROOT/plugin/appmaker/studio/public/index.html"
STYLES="$REPO_ROOT/plugin/appmaker/studio/public/styles.css"
APP_JS="$REPO_ROOT/plugin/appmaker/studio/public/app.js"
STATUS_SCRIPT="$REPO_ROOT/plugin/appmaker/scripts/status-json.sh"
PHASE_SCRIPT="$REPO_ROOT/plugin/appmaker/scripts/phase-plan.sh"

echo "=== AppMaker Studio UI smoke tests ==="

assert_file_exists "studio server present" "$SERVER"
assert_file_exists "studio index present" "$INDEX"
assert_file_exists "studio styles present" "$STYLES"
assert_file_exists "studio app JS present" "$APP_JS"
assert_file_exists "status-json engine present" "$STATUS_SCRIPT"
assert_file_exists "phase-plan engine present" "$PHASE_SCRIPT"

SERVER_HELP=$(node "$SERVER" --help 2>/dev/null || true)
assert_contains "studio server documents project dir" "$SERVER_HELP" "--project-dir"
assert_contains "studio server documents port" "$SERVER_HELP" "--port"
assert_contains "studio server documents host" "$SERVER_HELP" "--host"

INDEX_BODY=$(cat "$INDEX" 2>/dev/null || true)
assert_contains "studio index names AppMaker Studio" "$INDEX_BODY" "AppMaker Studio"
assert_contains "studio index has status grid hook" "$INDEX_BODY" "data-status-grid"
assert_contains "studio index has phase form" "$INDEX_BODY" "phase-form"
assert_contains "studio index has Phase Orchestrator surface" "$INDEX_BODY" "Phase Orchestrator"
assert_contains "studio index has Evidence surface" "$INDEX_BODY" "Evidence"

STYLE_BODY=$(cat "$STYLES" 2>/dev/null || true)
assert_contains "studio styles define signal color" "$STYLE_BODY" "--signal"
assert_contains "studio styles define state pill" "$STYLE_BODY" ".state-pill"

JS_BODY=$(cat "$APP_JS" 2>/dev/null || true)
assert_contains "studio JS reads status API" "$JS_BODY" "/api/status"
assert_contains "studio JS reads phase API" "$JS_BODY" "/api/phase-plan"
assert_contains "studio JS renders status" "$JS_BODY" "renderStatus"
assert_contains "studio JS renders phase plan" "$JS_BODY" "renderPhasePlan"

TMP_PROJECT=$(setup_temp_dir)
mkdir -p "$TMP_PROJECT/appmaker/features/001-old" \
  "$TMP_PROJECT/appmaker/features/002-studio-ready" \
  "$TMP_PROJECT/appmaker/backlog" \
  "$TMP_PROJECT/appmaker/backlog/done" \
  "$TMP_PROJECT/appmaker/checklists" \
  "$TMP_PROJECT/appmaker/phase-plans"
printf '0.2.26\n' > "$TMP_PROJECT/appmaker/.appmaker-version"

cat > "$TMP_PROJECT/appmaker/backlog/001-api.md" <<'EOF'
---
id: 001
slug: api
status: open
feature: 002-studio-ready
execution_class: autonomous
blocked_by: []
phase_id: phase-alpha
agent_profile: backend-specialist
write_scope:
  - src/api/
depends_on: []
integration_risk: medium
traces_to: [pcrit-001]
---
EOF

cat > "$TMP_PROJECT/appmaker/backlog/002-ui.md" <<'EOF'
---
id: 002
slug: ui
status: open
feature: 002-studio-ready
execution_class: autonomous
blocked_by: []
phase_id: phase-alpha
agent_profile: frontend-specialist
write_scope:
  - src/ui/
depends_on: [001]
integration_risk: medium
traces_to: [pcrit-002]
---
EOF

cat > "$TMP_PROJECT/appmaker/backlog/done/003-done.md" <<'EOF'
---
id: 003
slug: done
status: done
feature: 002-studio-ready
---
EOF

cat > "$TMP_PROJECT/appmaker/checklists/2026-05-22-feature-002-studio-ready.md" <<'EOF'
---
scope: feature 002-studio-ready
status: PASS
created: 2026-05-22
---
EOF

STATUS_JSON=$(node "$SERVER" --project-dir "$TMP_PROJECT" --api status 2>/tmp/appmaker-studio-status.err || true)
assert_contains "studio status API marks appmaker project" "$STATUS_JSON" '"appmaker":true'
assert_contains "studio status API exposes active feature" "$STATUS_JSON" '"active_feature":"002-studio-ready"'
assert_contains "studio status API exposes backlog total" "$STATUS_JSON" '"total":3'
assert_contains "studio status API exposes clean git state" "$STATUS_JSON" '"git":{"dirty":false'

PHASE_JSON=$(node "$SERVER" --project-dir "$TMP_PROJECT" --api phase-plan --phase-id phase-alpha 2>/tmp/appmaker-studio-phase.err || true)
assert_contains "studio phase API includes phase id" "$PHASE_JSON" '"phase_id":"phase-alpha"'
assert_contains "studio phase API includes PASS status" "$PHASE_JSON" '"status":"PASS"'
assert_contains "studio phase API includes wave item" "$PHASE_JSON" '"items":["001"]'

PLAN_PATH=$(ls "$TMP_PROJECT"/appmaker/phase-plans/*phase-alpha-dry-run.md 2>/dev/null | head -1)
assert_file_exists "studio phase API persists evidence plan" "$PLAN_PATH"

node "$SERVER" --project-dir "$TMP_PROJECT" --api phase-plan >/tmp/appmaker-studio-missing.json 2>/tmp/appmaker-studio-missing.err
MISSING_RC=$?
assert_eq "studio phase API rejects missing phase id" "2" "$MISSING_RC"

print_summary
