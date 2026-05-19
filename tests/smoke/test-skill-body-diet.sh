#!/usr/bin/env bash
# Smoke test for high-load skill body diet: keep main orchestrators under 200 lines.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== skill body diet smoke tests ==="

for skill in init tdd review status; do
  FILE="$REPO_ROOT/plugin/appmaker/skills/${skill}/SKILL.md"
  assert_file_exists "${skill}/SKILL.md present" "$FILE"
  LINES=$(wc -l < "$FILE" | tr -d ' ')
  if [ "$LINES" -lt 200 ]; then
    OK="yes"
  else
    OK="no"
  fi
  assert_eq "${skill}/SKILL.md is under 200 lines (${LINES})" "yes" "$OK"
done

print_summary
