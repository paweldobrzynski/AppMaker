#!/usr/bin/env bash
# Smoke test for v0.2.30 debt ledger: debt-json.sh harvest + /appmaker:debt + gate wiring.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEBT_SCRIPT="$REPO_ROOT/plugin/appmaker/scripts/debt-json.sh"
DEBT_SKILL="$REPO_ROOT/plugin/appmaker/skills/debt/SKILL.md"
REVIEW_CONTRACT="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills/review/review-contract.md"
CHECKLIST="$REPO_ROOT/plugin/appmaker/skills/checklist/SKILL.md"

echo "=== debt ledger smoke tests ==="

assert_file_exists "debt-json.sh present" "$DEBT_SCRIPT"
assert_file_exists "debt/SKILL.md present" "$DEBT_SKILL"

# Empty (non-marker) dir → empty array, exit 0.
TMP_EMPTY=$(setup_temp_dir)
EMPTY_JSON=$(bash "$DEBT_SCRIPT" --project-dir "$TMP_EMPTY" 2>/tmp/appmaker-debt-empty.err)
RC=$?
assert_exit_zero "debt-json exits 0 without markers" "$RC"
assert_contains "debt-json empty debts" "$EMPTY_JSON" '"debts":[]'

# Project with a full marker, a bare marker, and one inside appmaker/ (must be excluded).
TMP_PROJECT=$(setup_temp_dir)
mkdir -p "$TMP_PROJECT/src" "$TMP_PROJECT/appmaker/features"
printf 'function lock(){ // appmaker:debt global lock -> upgrade: per-account locks if needed\n}\n' > "$TMP_PROJECT/src/lock.js"
printf 'def scan(): # appmaker:debt naive scan\n    pass\n' > "$TMP_PROJECT/src/scan.py"
printf '<!-- appmaker:debt artifact-marker-should-be-ignored -> upgrade: nope -->\n' > "$TMP_PROJECT/appmaker/features/note.md"

DEBT_JSON=$(bash "$DEBT_SCRIPT" --project-dir "$TMP_PROJECT" 2>/tmp/appmaker-debt-json.err)
RC=$?
assert_exit_zero "debt-json exits 0 with markers" "$RC"
assert_contains "debt-json captures source file" "$DEBT_JSON" '"file":"./src/lock.js"'
assert_contains "debt-json parses ceiling" "$DEBT_JSON" '"ceiling":"global lock"'
assert_contains "debt-json parses upgrade path" "$DEBT_JSON" '"upgrade":"per-account locks if needed"'
assert_contains "debt-json full marker has_upgrade true" "$DEBT_JSON" '"has_upgrade":true'
assert_contains "debt-json bare marker has_upgrade false" "$DEBT_JSON" '"has_upgrade":false'
# appmaker/ excluded — the artifact marker must NOT appear.
if [[ "$DEBT_JSON" == *"artifact-marker-should-be-ignored"* ]]; then
  echo "${C_RED}✗${C_RESET} debt-json excludes appmaker/ dir"
  FAILURES+=("debt-json excludes appmaker/ dir"); FAIL_COUNT=$((FAIL_COUNT + 1))
else
  echo "${C_GREEN}✓${C_RESET} debt-json excludes appmaker/ dir"; PASS_COUNT=$((PASS_COUNT + 1))
fi
assert_contains "debt-json emits valid-looking JSON" "$DEBT_JSON" '{"debts":['

# Skill + gate wiring.
SKILL=$(cat "$DEBT_SKILL")
assert_contains "debt skill documents marker convention" "$SKILL" 'appmaker:debt'
assert_contains "debt skill writes a ledger" "$SKILL" 'appmaker/debt/'
assert_contains "debt skill is disable-model-invocation" "$SKILL" 'disable-model-invocation: true'

assert_contains "review-contract gates debt markers" "$(cat "$REVIEW_CONTRACT")" 'Debt marker'
assert_contains "checklist gates debt marker hygiene" "$(cat "$CHECKLIST")" 'Debt marker hygiene'

print_summary
