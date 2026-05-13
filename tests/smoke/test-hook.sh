#!/usr/bin/env bash
# Smoke test for session-start hook.
# Verifies: silent in non-AppMaker dir; correct output across no-feature/active-feature/done-counted scenarios.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

PLUGIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)/plugin/appmaker"
HOOK="$PLUGIN_DIR/hooks/session-start.sh"

[ -x "$HOOK" ] || { echo "❌ hook not executable: $HOOK"; exit 2; }

echo "=== session-start hook smoke tests ==="

# Scenario 1: non-AppMaker dir → silent exit 0
T=$(setup_temp_dir)
OUT=$(cd "$T" && bash "$HOOK" 2>&1)
RC=$?
assert_eq "non-AppMaker dir: exit 0"    "0"  "$RC"
assert_eq "non-AppMaker dir: no output" ""   "$OUT"
rm -rf "$T"

# Scenario 2: appmaker/ exists, no features
T=$(setup_temp_dir)
mkdir -p "$T/appmaker"
echo "0.2.11" > "$T/appmaker/.appmaker-version"
OUT=$(cd "$T" && bash "$HOOK" 2>&1)
assert_contains "no-feature: version" "$OUT" "v0.2.11"
assert_contains "no-feature: text"    "$OUT" "no active feature"
rm -rf "$T"

# Scenario 3: 3 features, expect newest (003) picked
T=$(setup_temp_dir)
mkdir -p "$T/appmaker/features/001-old" "$T/appmaker/features/002-mid" "$T/appmaker/features/003-newest" "$T/appmaker/features/archive"
mkdir -p "$T/appmaker/backlog"
echo "0.2.11" > "$T/appmaker/.appmaker-version"
OUT=$(cd "$T" && bash "$HOOK" 2>&1)
assert_contains "newest-pick: shows 003-newest" "$OUT" "003-newest"
[[ "$OUT" != *"001-old"* ]] && PICKED_RIGHT="yes" || PICKED_RIGHT="no"
assert_eq "newest-pick: does NOT show 001-old" "yes" "$PICKED_RIGHT"
rm -rf "$T"

# Scenario 4: slice counting includes backlog/done/ (v0.2.9 fix)
T=$(setup_temp_dir)
mkdir -p "$T/appmaker/features/001-test"
mkdir -p "$T/appmaker/backlog/done"
echo "0.2.11" > "$T/appmaker/.appmaker-version"
# 2 slices open in backlog/, 3 done in backlog/done/
for n in 001 002; do
  printf 'feature: 001-test\nstatus: open\n' > "$T/appmaker/backlog/${n}-x.md"
done
for n in 003 004 005; do
  printf 'feature: 001-test\nstatus: done\n' > "$T/appmaker/backlog/done/${n}-x.md"
done
OUT=$(cd "$T" && bash "$HOOK" 2>&1)
assert_contains "done-counting: shows 3/5" "$OUT" "3/5"
rm -rf "$T"

print_summary
