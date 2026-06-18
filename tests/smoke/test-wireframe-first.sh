#!/usr/bin/env bash
# Smoke test for v0.2.29 visual layer: wireframe-first (prd) + visual recap (review) contracts.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PRD_SKILL="$REPO_ROOT/plugin/appmaker/skills/prd/SKILL.md"
REVIEW_SKILL="$REPO_ROOT/plugin/appmaker/skills/review/SKILL.md"
WIREFRAME_TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/templates/wireframe-template.md"

echo "=== wireframe-first / visual recap smoke tests ==="

assert_file_exists "prd/SKILL.md present" "$PRD_SKILL"
assert_file_exists "review/SKILL.md present" "$REVIEW_SKILL"
assert_file_exists "wireframe-template.md present" "$WIREFRAME_TEMPLATE"

PRD=$(cat "$PRD_SKILL")
assert_contains "prd has wireframe-first step" "$PRD" "Wireframe-first"
assert_contains "prd writes wireframe.md" "$PRD" "wireframe.md"
assert_contains "prd wireframe is markdown-native (mermaid)" "$PRD" "mermaid"
assert_contains "prd wireframe includes ASCII" "$PRD" "ASCII"
assert_contains "prd wireframe traces to pcrit" "$PRD" "pcrit-"
assert_contains "prd states wireframe is conditional (UI or API surface)" "$PRD" "UI surface OR an external API surface"

REVIEW=$(cat "$REVIEW_SKILL")
assert_contains "review has visual recap step" "$REVIEW" "Visual recap"
assert_contains "review recap writes recap file" "$REVIEW" "recap-"
assert_contains "review recap is explicitly NOT a gate" "$REVIEW" "NOT a gate"

TEMPLATE=$(cat "$WIREFRAME_TEMPLATE")
assert_contains "template has mermaid block" "$TEMPLATE" '```mermaid'
assert_contains "template has Traces section" "$TEMPLATE" "## Traces"
assert_contains "template states view-of-PRD direction" "$TEMPLATE" "never originate"

print_summary
