#!/usr/bin/env bash
# Smoke test for v0.2.18 pcrit-003, pcrit-004, pcrit-007, pcrit-008: doc drift batch.
#
# Codex review criteria (scoped regexes, not global bans):
#   - Layout block drift uses `←` arrow form: `← 22 dirs (...)`. Target this,
#     not raw "19 dirs" or "18 dirs" strings (those appear in historical changelogs).
#   - Stale `.appmaker-version` example uses `(current: "...")` form. Target this,
#     not raw "0.2.X" version strings (those appear as historical decision labels).
#   - README skill count narrative: bare "15 written." line is the drift marker;
#     replacement asserts explicit total via "22 written:" form.
#
# Historical references preserved (NOT a drift):
#   - DESIGN.md:296 v0.2.11 changelog narrative mentions "0.2.0"/"0.2.9"/"18 dirs"
#     as part of decision history, not as layout/example. Stays.
#   - `v0.2.X:` decision labels throughout DESIGN.md. Stay.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
README="$REPO_ROOT/README.md"
DESIGN="$REPO_ROOT/DESIGN.md"

echo "=== doc drift smoke tests ==="

assert_file_exists "README.md present" "$README"
assert_file_exists "DESIGN.md present" "$DESIGN"

# --- README layout (pcrit-003) ---

README_22=$(grep -cE '← 24 dirs \(19 core \+ afk \+ status \+ token-audit \+ next \+ phase\)' "$README" || true)
[ "$README_22" -ge 1 ] && README_22_OK="yes" || README_22_OK="no"
assert_eq "README layout shows ← 24 dirs (19 core + afk + status + token-audit + next + phase)" "yes" "$README_22_OK"

README_18=$(grep -cE '← 18 dirs' "$README" || true)
[ "$README_18" -eq 0 ] && README_18_GONE="yes" || README_18_GONE="no"
assert_eq "README does NOT have ← 18 dirs (layout drift)" "yes" "$README_18_GONE"

# --- README narrative (pcrit-008) ---

README_BARE=$(grep -cE '^15 written\.$' "$README" || true)
[ "$README_BARE" -eq 0 ] && README_BARE_GONE="yes" || README_BARE_GONE="no"
assert_eq "README narrative no longer bare '15 written.' (incomplete count)" "yes" "$README_BARE_GONE"

README_TOTAL=$(grep -cE '^24 written:' "$README" || true)
[ "$README_TOTAL" -ge 1 ] && README_TOTAL_OK="yes" || README_TOTAL_OK="no"
assert_eq "README narrative explicit '24 written:' total" "yes" "$README_TOTAL_OK"

# --- DESIGN layout (pcrit-004) ---

DESIGN_22=$(grep -cE '← 24 dirs \(19 core \+ afk \+ status \+ token-audit \+ next \+ phase\)' "$DESIGN" || true)
[ "$DESIGN_22" -ge 1 ] && DESIGN_22_OK="yes" || DESIGN_22_OK="no"
assert_eq "DESIGN layout shows ← 24 dirs (19 core + afk + status + token-audit + next + phase)" "yes" "$DESIGN_22_OK"

DESIGN_18=$(grep -cE '← 18 dirs' "$DESIGN" || true)
[ "$DESIGN_18" -eq 0 ] && DESIGN_18_GONE="yes" || DESIGN_18_GONE="no"
assert_eq "DESIGN does NOT have ← 18 dirs (layout drift, historical narrative preserved)" "yes" "$DESIGN_18_GONE"

# --- DESIGN .appmaker-version layout example (pcrit-007) ---

DESIGN_STALE=$(grep -cE '\(current:\s*"0\.2\.[0-9]+"\)' "$DESIGN" || true)
[ "$DESIGN_STALE" -eq 0 ] && DESIGN_STALE_GONE="yes" || DESIGN_STALE_GONE="no"
assert_eq "DESIGN .appmaker-version layout uses placeholder, not stale literal" "yes" "$DESIGN_STALE_GONE"

print_summary
