#!/usr/bin/env bash
# Smoke test for v0.2.30 YAGNI / over-engineering lens: reference doc + config dial + gate wiring.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
YAGNI="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/yagni-ladder.md"
CONFIG="$REPO_ROOT/plugin/appmaker/resources/appmaker/config.yaml.template"
REVIEW_CONTRACT="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/review/review-contract.md"
CHECKLIST="$REPO_ROOT/plugin/appmaker/skills/checklist/SKILL.md"
DECOMPOSE="$REPO_ROOT/plugin/appmaker/skills/decompose/SKILL.md"
TDD="$REPO_ROOT/plugin/appmaker/skills/tdd/SKILL.md"

echo "=== YAGNI lens smoke tests ==="

assert_file_exists "yagni-ladder.md present" "$YAGNI"

LADDER=$(cat "$YAGNI")
assert_contains "ladder has does-it-need-to-exist rung" "$LADDER" "Does this need to exist"
assert_contains "ladder reaches for stdlib" "$LADDER" "standard library"
assert_contains "ladder has safety carve-outs" "$LADDER" "When NOT to be lazy"
assert_contains "ladder credits ponytail" "$LADDER" "ponytail"

CFG=$(cat "$CONFIG")
assert_contains "config.yaml.template has build_intensity" "$CFG" "build_intensity:"
assert_contains "build_intensity documents levels" "$CFG" "lite | standard | ultra"

RC_TXT=$(cat "$REVIEW_CONTRACT")
assert_contains "review-contract has YAGNI lens" "$RC_TXT" "Over-engineering (YAGNI)"
assert_contains "review-contract cites yagni-ladder" "$RC_TXT" "yagni-ladder.md"

assert_contains "checklist has Over-engineering row" "$(cat "$CHECKLIST")" "Over-engineering"
assert_contains "decompose cites yagni-ladder" "$(cat "$DECOMPOSE")" "yagni-ladder.md"
assert_contains "tdd cites yagni-ladder" "$(cat "$TDD")" "yagni-ladder.md"

print_summary
