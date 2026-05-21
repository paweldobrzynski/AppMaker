#!/usr/bin/env bash
# Smoke test for side-effect skill invocation boundary.
# Skills with disable-model-invocation:true cannot be called through the Skill
# tool. Orchestrators must hand off an exact slash command instead of trying to
# invoke them internally.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/lib.sh"

NEXT_SKILL="$REPO_ROOT/plugin/appmaker/skills/next/SKILL.md"
START_SKILL="$REPO_ROOT/plugin/appmaker/skills/start/SKILL.md"
TDD_SKILL="$REPO_ROOT/plugin/appmaker/skills/tdd/SKILL.md"
README="$REPO_ROOT/README.md"

echo "=== side-effect invocation boundary smoke tests ==="

assert_file_exists "next/SKILL.md present" "$NEXT_SKILL"
assert_file_exists "start/SKILL.md present" "$START_SKILL"
assert_file_exists "tdd/SKILL.md present" "$TDD_SKILL"

NEXT_BODY="$(cat "$NEXT_SKILL")"
START_BODY="$(cat "$START_SKILL")"
TDD_BODY="$(cat "$TDD_SKILL")"
README_BODY="$(cat "$README")"

NEXT_FORBIDDEN=$(grep -ciE 'invoke(s|d)? .*via (the )?Skill tool|Skill\(skill:' "$NEXT_SKILL" || true)
if [ "$NEXT_FORBIDDEN" -eq 0 ]; then
  NEXT_CLEAN="yes"
else
  NEXT_CLEAN="no"
fi
assert_eq "next does not claim it can Skill-tool disabled skills" "yes" "$NEXT_CLEAN"

assert_contains "next documents slash-command handoff" "$NEXT_BODY" "emit the exact slash command"
assert_contains "next forbids Skill tool for side-effect skills" "$NEXT_BODY" "MUST NOT use the Skill tool"
assert_contains "start documents disabled-skill handoff" "$START_BODY" "show the exact slash command"
assert_contains "tdd refuses missing backlog item" "$TDD_BODY" "If no backlog item exists"
assert_contains "tdd names Skill-tool failure mode" "$TDD_BODY" "cannot be used with the Skill tool"
assert_contains "README documents invocation boundary" "$README_BODY" "side-effect skills are manual slash-command handoffs"

print_summary
