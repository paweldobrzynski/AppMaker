#!/usr/bin/env bash
# Smoke test for v0.2.18 pcrit-001: PRD template has explicit ## Criticisms section.
# Asserts prd/SKILL.md template body contains:
#   1. ^## Criticisms heading (line-anchored, not in prose)
#   2. At least one pcrit-NNN reference (numbered criterion ID convention)
#
# Method correction 2026-05-17: PRD is upstream source of intent. ## Criticisms
# is where the canonical pcrit-* numbered list lives — anchor point for downstream
# traces_to references in decomposition + backlog items.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PRD_SKILL="$REPO_ROOT/plugin/appmaker/skills/prd/SKILL.md"

echo "=== PRD ## Criticisms section smoke tests ==="

assert_file_exists "prd/SKILL.md present" "$PRD_SKILL"

# Heading exists (line-start ## Criticisms)
HEADING_COUNT=$(grep -cE '^## Criticisms( |$)' "$PRD_SKILL" || true)
[ "$HEADING_COUNT" -ge 1 ] && HEADING_PRESENT="yes" || HEADING_PRESENT="no"
assert_eq "prd/SKILL.md has ## Criticisms heading" "yes" "$HEADING_PRESENT"

# At least one pcrit-NNN list item — markdown bullet + bold + 3-digit canonical ID.
# Stricter than initial: requires actual list item, not prose mention. AC says
# "## Criticisms heading with at least 1 EXAMPLE pcrit-NNN ITEM" — item = list bullet.
# Initial regex matched any `pcrit-[0-9N]+` anywhere in file (false-positive on prose).
PCRIT_ITEM_COUNT=$(grep -cE '^- \*\*pcrit-[0-9]{3}:\*\*' "$PRD_SKILL" || true)
[ "$PCRIT_ITEM_COUNT" -ge 1 ] && PCRIT_ITEM_PRESENT="yes" || PCRIT_ITEM_PRESENT="no"
assert_eq "prd/SKILL.md has pcrit-NNN list item" "yes" "$PCRIT_ITEM_PRESENT"

print_summary
