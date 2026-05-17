#!/usr/bin/env bash
# Smoke test for v0.2.18 pcrit-006: /appmaker:start does not unconditionally route
# to non-existent /appmaker:spike (TODO skill, not yet implemented).
#
# Operator picked Option A (2026-05-17): route prototype intent to /appmaker:grill
# with explicit TODO note about /appmaker:spike status. Test enforces both:
#   1. Honest route — either no `spike` route OR `spike` mention has TODO context
#      (distinguishes `"spike"` keyword in trigger column from `\`spike\`` route
#      in suggestion column; backtick form is the route invocation)
#   2. Grill fallback present (operator's chosen alternative path)

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
START="$REPO_ROOT/plugin/appmaker/skills/start/SKILL.md"

echo "=== /appmaker:start prototype route smoke tests ==="

assert_file_exists "start/SKILL.md present" "$START"

# Extract the prototype row from macro action table
PROTOTYPE_ROW=$(grep -E '^\| \*\*prototype\*\*' "$START" | head -1)

# 1. Honest route: backtick-wrapped `spike` route only acceptable with TODO/unimplemented context.
# Backtick form `\`spike\`` indicates route invocation; quoted "spike" in keyword column is fine.
HAS_SPIKE_ROUTE=$(echo "$PROTOTYPE_ROW" | grep -cE '`spike`' || true)
HAS_TODO=$(echo "$PROTOTYPE_ROW" | grep -ciE 'todo|not yet|not implemented|unimplemented' || true)

if [ "$HAS_SPIKE_ROUTE" -eq 0 ] || [ "$HAS_TODO" -ge 1 ]; then
  HONEST="yes"
else
  HONEST="no"
fi
assert_eq "prototype route honest (no unconditional \`spike\` without TODO context)" "yes" "$HONEST"

# 2. Grill fallback present (operator picked Option A — route to /appmaker:grill)
HAS_GRILL_FALLBACK=$(echo "$PROTOTYPE_ROW" | grep -cE '`grill`' || true)
[ "$HAS_GRILL_FALLBACK" -ge 1 ] && GRILL_OK="yes" || GRILL_OK="no"
assert_eq "prototype route suggests \`grill\` as fallback (Option A)" "yes" "$GRILL_OK"

print_summary
