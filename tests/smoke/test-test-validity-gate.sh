#!/usr/bin/env bash
# Smoke test for v0.2.28 #2: anti-placebo test-validity gate.
# Verifies the test-validity supporting ref exists, carries deterministic markers
# + regression-judgment, and is wired into tdd / review-contract / checklist.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RES="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills"
SKILLS="$REPO_ROOT/plugin/appmaker/skills"
DOC="$RES/tdd/test-validity.md"

echo "=== test-validity gate smoke tests ==="

assert_file_exists "test-validity.md supporting ref present" "$DOC"

# Tier 1 deterministic markers must be enumerated (matched as plain substrings;
# the doc shows them escaped inside an rg regex, e.g. `\.skip\(`).
for marker in '.skip' '.only' 'xit' 'tautology' 'commented'; do
  HIT=$(grep -cF "$marker" "$DOC" || true)
  [ "$HIT" -ge 1 ] && OK="yes" || OK="no"
  assert_eq "test-validity.md lists marker '${marker}'" "yes" "$OK"
done

# Tier 2 judgment: regression catch.
REGRESS=$(grep -cEi 'regression|go red|catch a regression' "$DOC" || true)
[ "$REGRESS" -ge 1 ] && REGRESS_OK="yes" || REGRESS_OK="no"
assert_eq "test-validity.md asks would-it-catch-a-regression" "yes" "$REGRESS_OK"

PLACEBO=$(grep -ci 'placebo' "$DOC" || true)
[ "$PLACEBO" -ge 1 ] && PLACEBO_OK="yes" || PLACEBO_OK="no"
assert_eq "test-validity.md frames placebo tests" "yes" "$PLACEBO_OK"

# Wiring: tdd verification + review-contract + checklist reference test-validity.
TDD_REF=$(grep -c 'test-validity.md' "$SKILLS/tdd/SKILL.md" || true)
[ "$TDD_REF" -ge 1 ] && TDD_OK="yes" || TDD_OK="no"
assert_eq "tdd/SKILL.md references test-validity.md" "yes" "$TDD_OK"

REVIEW_REF=$(grep -c 'test-validity.md' "$RES/review/review-contract.md" || true)
[ "$REVIEW_REF" -ge 1 ] && REVIEW_OK="yes" || REVIEW_OK="no"
assert_eq "review-contract.md gates on test validity" "yes" "$REVIEW_OK"

CHECK_REF=$(grep -c 'Test validity' "$SKILLS/checklist/SKILL.md" || true)
[ "$CHECK_REF" -ge 1 ] && CHECK_OK="yes" || CHECK_OK="no"
assert_eq "checklist/SKILL.md has Test validity check" "yes" "$CHECK_OK"

print_summary
