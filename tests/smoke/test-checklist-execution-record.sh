#!/usr/bin/env bash
# Smoke test for v0.2.21 checklist gates around AC test mapping and Execution Record.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CHECKLIST_SKILL="$REPO_ROOT/plugin/appmaker/skills/checklist/SKILL.md"

echo "=== checklist/SKILL.md Execution Record gate smoke tests ==="

assert_file_exists "checklist/SKILL.md present" "$CHECKLIST_SKILL"

AC_MAPPING_COUNT=$(grep -cE 'AC test mapping|test:.*human-review:|human-review:.*test:' "$CHECKLIST_SKILL" || true)
[ "$AC_MAPPING_COUNT" -ge 1 ] && AC_MAPPING_PRESENT="yes" || AC_MAPPING_PRESENT="no"
assert_eq "checklist gates ACs with test or human-review annotation" "yes" "$AC_MAPPING_PRESENT"

for phrase in \
  "missing \`Base ref\` = FAIL" \
  "missing \`Tests run\` = FAIL" \
  "planned-vs-actual differs and \`Drift notes\` is empty = WARN"
do
  COUNT=$(grep -cF "$phrase" "$CHECKLIST_SKILL" || true)
  [ "$COUNT" -ge 1 ] && PRESENT="yes" || PRESENT="no"
  assert_eq "checklist documents gate: ${phrase}" "yes" "$PRESENT"
done

BLOCK_ONLY_COUNT=$(grep -cF "Only invariant breakage should be FAIL" "$CHECKLIST_SKILL" || true)
[ "$BLOCK_ONLY_COUNT" -ge 1 ] && BLOCK_ONLY_PRESENT="yes" || BLOCK_ONLY_PRESENT="no"
assert_eq "checklist states anti-bureaucracy FAIL policy" "yes" "$BLOCK_ONLY_PRESENT"

RIGOR_COUNT=$(grep -cF "rigor_level" "$CHECKLIST_SKILL" || true)
[ "$RIGOR_COUNT" -ge 1 ] && RIGOR_PRESENT="yes" || RIGOR_PRESENT="no"
assert_eq "checklist reads rigor_level before classifying gates" "yes" "$RIGOR_PRESENT"

print_summary
