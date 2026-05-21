#!/usr/bin/env bash
# Smoke test for init-materialize.sh runtime behavior on a fresh project.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$REPO_ROOT/plugin/appmaker/scripts/init-materialize.sh"
PLUGIN_MANIFEST="$REPO_ROOT/plugin/appmaker/.claude-plugin/plugin.json"

echo "=== init-materialize.sh fresh project smoke tests ==="

assert_file_exists "init-materialize.sh present" "$SCRIPT"

TMP_PROJECT=$(setup_temp_dir)
(
  cd "$TMP_PROJECT" || exit 1
  bash "$SCRIPT" >/tmp/appmaker-init-materialize.out 2>/tmp/appmaker-init-materialize.err
)
RC=$?
assert_exit_zero "init-materialize.sh exits 0 in empty project" "$RC"

PROJECT_VERSION=$(cat "$TMP_PROJECT/appmaker/.appmaker-version" 2>/dev/null || true)
if command -v jq >/dev/null 2>&1; then
  PLUGIN_VERSION=$(jq -r '.version' "$PLUGIN_MANIFEST")
else
  PLUGIN_VERSION=$(grep -m1 '"version"' "$PLUGIN_MANIFEST" | sed -E 's/.*"version"[^"]*"([^"]+)".*/\1/')
fi

assert_file_exists "config.yaml materialized" "$TMP_PROJECT/appmaker/config.yaml"
assert_file_exists "constitution.md materialized" "$TMP_PROJECT/appmaker/constitution.md"
assert_file_exists ".appmaker-version materialized" "$TMP_PROJECT/appmaker/.appmaker-version"
assert_file_exists "session-start hook materialized" "$TMP_PROJECT/appmaker/hooks/session-start.sh"
assert_file_exists "glossary-extract hook materialized" "$TMP_PROJECT/appmaker/hooks/glossary-extract.sh"
assert_file_exists "CLAUDE.md materialized" "$TMP_PROJECT/CLAUDE.md"
assert_file_exists ".claude/settings.json materialized" "$TMP_PROJECT/.claude/settings.json"
assert_file_exists "review contract materialized" "$TMP_PROJECT/appmaker/skills/review/review-contract.md"
assert_file_exists "status telemetry guide materialized" "$TMP_PROJECT/appmaker/skills/status/telemetry-refinement.md"
assert_file_exists "init tooling integrations guide materialized" "$TMP_PROJECT/appmaker/skills/init/tooling-integrations.md"
assert_file_exists "TDD plan check materialized" "$TMP_PROJECT/appmaker/skills/tdd/plan-check.md"
assert_file_exists "context budget guide materialized" "$TMP_PROJECT/appmaker/skills/context-budget.md"

assert_eq "version marker matches plugin.json" "$PLUGIN_VERSION" "$PROJECT_VERSION"

RULE_COUNT=$(grep -cE '^[0-9]+\. \*\*' "$TMP_PROJECT/appmaker/constitution.md" || true)
assert_eq "constitution seed has exactly 10 rules" "10" "$RULE_COUNT"

POINTER=$(cat "$TMP_PROJECT/CLAUDE.md")
assert_contains "CLAUDE.md pointer includes AppMaker header" "$POINTER" "## AppMaker"
assert_contains "CLAUDE.md pointer includes constitution" "$POINTER" "appmaker/constitution.md"

SETTINGS=$(cat "$TMP_PROJECT/.claude/settings.json")
assert_contains "settings wires session-start hook" "$SETTINGS" "bash appmaker/hooks/session-start.sh"

CONFIG=$(cat "$TMP_PROJECT/appmaker/config.yaml")
assert_contains "config includes github_cli_enabled flag" "$CONFIG" "github_cli_enabled: false"
assert_contains "config includes ref_tools_enabled flag" "$CONFIG" "ref_tools_enabled: false"
assert_contains "config includes ref MCP server name" "$CONFIG" "ref_tools_mcp_server: ref"
assert_contains "config includes gstack_enabled flag" "$CONFIG" "gstack_enabled: false"
assert_contains "config includes gstack browse path" "$CONFIG" "gstack_browse_bin:"

print_summary
