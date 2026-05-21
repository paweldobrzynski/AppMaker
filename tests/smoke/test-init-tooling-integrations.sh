#!/usr/bin/env bash
# Smoke test for optional-but-recommended GitHub/Ref setup in /appmaker:init.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INIT="$REPO_ROOT/plugin/appmaker/skills/init/SKILL.md"
CONFIG_TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/config.yaml.template"
TOOLING_REF="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/init/tooling-integrations.md"

echo "=== init tooling integrations smoke tests ==="

assert_file_exists "init/SKILL.md present" "$INIT"
assert_file_exists "config.yaml.template present" "$CONFIG_TEMPLATE"
assert_file_exists "tooling-integrations.md present" "$TOOLING_REF"

INIT_TEXT=$(cat "$INIT")
CONFIG_TEXT=$(cat "$CONFIG_TEMPLATE")
TOOLING_TEXT=$(cat "$TOOLING_REF")

assert_contains "init asks for GitHub CLI connection" "$INIT_TEXT" "Connect GitHub CLI"
assert_contains "init marks GitHub optional but recommended" "$INIT_TEXT" "highly recommended but optional"
assert_contains "init asks for Ref Tools MCP connection" "$INIT_TEXT" "Connect Ref Tools MCP"
assert_contains "init asks for gstack browser runtime" "$INIT_TEXT" "Connect gstack browser runtime"
assert_contains "init verifies gh auth status" "$INIT_TEXT" "gh auth status --hostname github.com"
assert_contains "init references user-level Codex Ref config" "$INIT_TEXT" "~/.codex/config.toml"
assert_contains "init forbids project token storage" "$INIT_TEXT" "never store Ref API keys in the project"

assert_contains "config has GitHub capability flag" "$CONFIG_TEXT" "github_cli_enabled: false"
assert_contains "config has Ref capability flag" "$CONFIG_TEXT" "ref_tools_enabled: false"
assert_contains "config has Ref MCP server name" "$CONFIG_TEXT" "ref_tools_mcp_server: ref"
assert_contains "config has gstack capability flag" "$CONFIG_TEXT" "gstack_enabled: false"
assert_contains "config has gstack browse path" "$CONFIG_TEXT" "gstack_browse_bin:"

assert_contains "tooling guide says optional but highly recommended" "$TOOLING_TEXT" "optional but highly recommended"
assert_contains "tooling guide documents gh auth login" "$TOOLING_TEXT" "gh auth login"
assert_contains "tooling guide documents Ref API endpoint" "$TOOLING_TEXT" "https://api.ref.tools/mcp"
assert_contains "tooling guide documents ref_search support purpose" "$TOOLING_TEXT" "Architecture Options Research"
assert_contains "tooling guide documents gstack browser runtime" "$TOOLING_TEXT" "gstack Browser Runtime"
assert_contains "tooling guide documents gstack browse status" "$TOOLING_TEXT" '$B status'
assert_contains "tooling guide forbids storing GitHub tokens" "$TOOLING_TEXT" "Never store GitHub tokens"

print_summary
