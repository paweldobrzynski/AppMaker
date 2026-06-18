#!/usr/bin/env bash
# Smoke test for v0.2.29 Studio wireframes JSON API (wireframes-json.sh + server.mjs --api).

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WF_SCRIPT="$REPO_ROOT/plugin/appmaker/scripts/wireframes-json.sh"
SERVER="$REPO_ROOT/plugin/appmaker/studio/server.mjs"

echo "=== Studio wireframes API smoke tests ==="

assert_file_exists "wireframes-json.sh present" "$WF_SCRIPT"

# Empty (non-appmaker) dir → empty arrays, exit 0.
TMP_EMPTY=$(setup_temp_dir)
EMPTY_JSON=$(bash "$WF_SCRIPT" --project-dir "$TMP_EMPTY" 2>/tmp/appmaker-wf-empty.err)
RC=$?
assert_exit_zero "wireframes-json exits 0 without appmaker dir" "$RC"
assert_contains "wireframes-json empty wireframes" "$EMPTY_JSON" '"wireframes":[]'
assert_contains "wireframes-json empty recaps" "$EMPTY_JSON" '"recaps":[]'

# Project with a wireframe + a recap.
TMP_PROJECT=$(setup_temp_dir)
mkdir -p "$TMP_PROJECT/appmaker/features/001-demo" "$TMP_PROJECT/appmaker/reviews"

cat > "$TMP_PROJECT/appmaker/features/001-demo/wireframe.md" <<'EOF'
# Wireframe: Demo

## Flow

```mermaid
flowchart LR
  A --> B
```

## Traces

| Region | Illustrates |
|---|---|
| toggle | pcrit-001 |
| save   | pcrit-003 |
EOF

cat > "$TMP_PROJECT/appmaker/reviews/2026-06-18-recap-demo.md" <<'EOF'
# Recap: demo
EOF

WF_JSON=$(bash "$WF_SCRIPT" --project-dir "$TMP_PROJECT" 2>/tmp/appmaker-wf-json.err)
RC=$?
assert_exit_zero "wireframes-json exits 0 in appmaker project" "$RC"
assert_contains "wireframes-json includes feature" "$WF_JSON" '"feature":"001-demo"'
assert_contains "wireframes-json includes path" "$WF_JSON" '"path":"appmaker/features/001-demo/wireframe.md"'
assert_contains "wireframes-json detects mermaid diagram" "$WF_JSON" '"has_diagram":true'
assert_contains "wireframes-json extracts pcrit refs" "$WF_JSON" '"pcrit_refs":["pcrit-001","pcrit-003"]'
assert_contains "wireframes-json lists recap scope" "$WF_JSON" '"scope":"demo"'
assert_contains "wireframes-json lists recap date" "$WF_JSON" '"date":"2026-06-18"'

# Integration: same JSON via server.mjs --api wireframes (when node available).
if command -v node >/dev/null 2>&1; then
  API_JSON=$(node "$SERVER" --api wireframes --project-dir "$TMP_PROJECT" 2>/tmp/appmaker-wf-api.err)
  RC=$?
  assert_exit_zero "server.mjs --api wireframes exits 0" "$RC"
  assert_contains "server.mjs --api wireframes returns feature" "$API_JSON" '"feature":"001-demo"'
else
  echo "  (node not found — skipping server.mjs --api integration check)"
fi

print_summary
