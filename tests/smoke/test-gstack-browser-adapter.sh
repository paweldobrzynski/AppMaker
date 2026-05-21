#!/usr/bin/env bash
# Smoke test for optional gstack browser runtime adapter.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INIT="$REPO_ROOT/plugin/appmaker/skills/init/SKILL.md"
CONFIG_TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/config.yaml.template"
TOOLING_REF="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/init/tooling-integrations.md"
QA_SKILL="$REPO_ROOT/plugin/appmaker/skills/qa/SKILL.md"
DESIGN_REVIEW="$REPO_ROOT/plugin/appmaker/skills/design-review/SKILL.md"
CHECKLIST="$REPO_ROOT/plugin/appmaker/skills/checklist/SKILL.md"
REVIEW_CONTRACT="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/review/review-contract.md"
README="$REPO_ROOT/README.md"
DESIGN="$REPO_ROOT/DESIGN.md"

echo "=== gstack browser adapter smoke tests ==="

for f in "$INIT" "$CONFIG_TEMPLATE" "$TOOLING_REF" "$QA_SKILL" "$DESIGN_REVIEW" "$CHECKLIST" "$REVIEW_CONTRACT" "$README" "$DESIGN"; do
  assert_file_exists "required workflow file exists: ${f#$REPO_ROOT/}" "$f"
done

INIT_TEXT=$(cat "$INIT" 2>/dev/null || true)
CONFIG_TEXT=$(cat "$CONFIG_TEMPLATE" 2>/dev/null || true)
TOOLING_TEXT=$(cat "$TOOLING_REF" 2>/dev/null || true)
QA_TEXT=$(cat "$QA_SKILL" 2>/dev/null || true)
DESIGN_REVIEW_TEXT=$(cat "$DESIGN_REVIEW" 2>/dev/null || true)
CHECKLIST_TEXT=$(cat "$CHECKLIST" 2>/dev/null || true)
REVIEW_TEXT=$(cat "$REVIEW_CONTRACT" 2>/dev/null || true)
README_TEXT=$(cat "$README" 2>/dev/null || true)
DESIGN_TEXT=$(cat "$DESIGN" 2>/dev/null || true)

assert_contains "config has gstack enabled flag" "$CONFIG_TEXT" "gstack_enabled: false"
assert_contains "config has gstack browse bin path" "$CONFIG_TEXT" "gstack_browse_bin:"
assert_contains "config has UI QA requirement flag" "$CONFIG_TEXT" "gstack_required_for_ui_qa: false"

assert_contains "init asks for gstack browser runtime" "$INIT_TEXT" "Connect gstack browser runtime"
assert_contains "init marks gstack optional but recommended" "$INIT_TEXT" "optional, highly recommended for UI QA/design review"
assert_contains "init configures gstack after materialize" "$INIT_TEXT" "gstack_enabled: true"

assert_contains "tooling guide documents gstack install" "$TOOLING_TEXT" "git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git"
assert_contains "tooling guide documents setup command" "$TOOLING_TEXT" "./setup"
assert_contains "tooling guide documents browse binary" "$TOOLING_TEXT" "browse/dist/browse"
assert_contains "tooling guide documents B status check" "$TOOLING_TEXT" "\$B status"
assert_contains "tooling guide refuses team mode by default" "$TOOLING_TEXT" "Do not run --team by default"

for phrase in "gstack_enabled" "gstack_browse_bin" "\$B status" "\$B goto" "\$B snapshot -i" "\$B screenshot" "\$B responsive" "\$B console --errors" "\$B network"; do
  assert_contains "qa skill uses gstack adapter: $phrase" "$QA_TEXT" "$phrase"
done

for phrase in "gstack_enabled" "\$B screenshot" "\$B responsive" "\$B inspect" "\$B hover"; do
  assert_contains "design-review uses gstack adapter: $phrase" "$DESIGN_REVIEW_TEXT" "$phrase"
done

assert_contains "checklist gates gstack evidence" "$CHECKLIST_TEXT" "gstack browser evidence"
assert_contains "review contract gates gstack evidence" "$REVIEW_TEXT" "gstack browser evidence"
assert_contains "README documents optional gstack browser adapter" "$README_TEXT" "optional gstack browser runtime"
assert_contains "DESIGN documents optional gstack browser adapter" "$DESIGN_TEXT" "optional gstack browser runtime"

print_summary
