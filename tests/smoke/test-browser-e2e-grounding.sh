#!/usr/bin/env bash
# Smoke test for v0.2.28 #1: scan-first browser E2E grounding.
# Verifies the browser-e2e supporting ref exists, carries the no-invented-locators
# contract, and is wired into tdd / review-contract / checklist.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RES="$REPO_ROOT/plugin/appmaker/resources/appmaker/skills"
SKILLS="$REPO_ROOT/plugin/appmaker/skills"
DOC="$RES/tdd/browser-e2e.md"

echo "=== browser E2E grounding smoke tests ==="

assert_file_exists "browser-e2e.md supporting ref present" "$DOC"

# Core contract: scan live DOM before generating; never invent locators.
SCAN_FIRST=$(grep -cEi 'scan' "$DOC" || true)
[ "$SCAN_FIRST" -ge 1 ] && SCAN_OK="yes" || SCAN_OK="no"
assert_eq "browser-e2e.md describes scanning the live app" "yes" "$SCAN_OK"

NO_INVENT=$(grep -cEi 'never (invent|guess)|not (a guess|invent)|never write E2E selectors' "$DOC" || true)
[ "$NO_INVENT" -ge 1 ] && NO_INVENT_OK="yes" || NO_INVENT_OK="no"
assert_eq "browser-e2e.md forbids invented selectors" "yes" "$NO_INVENT_OK"

APP_MAP=$(grep -c 'app-map.md' "$DOC" || true)
[ "$APP_MAP" -ge 1 ] && APP_MAP_OK="yes" || APP_MAP_OK="no"
assert_eq "browser-e2e.md defines the app-map artifact" "yes" "$APP_MAP_OK"

REPAIR=$(grep -cEi 'repair|run.{0,3}fail.{0,3}fix|rerun' "$DOC" || true)
[ "$REPAIR" -ge 1 ] && REPAIR_OK="yes" || REPAIR_OK="no"
assert_eq "browser-e2e.md has a bounded repair loop" "yes" "$REPAIR_OK"

# Wiring: tdd planning + review-contract + checklist reference browser-e2e.
TDD_REF=$(grep -c 'browser-e2e.md' "$SKILLS/tdd/SKILL.md" || true)
[ "$TDD_REF" -ge 1 ] && TDD_OK="yes" || TDD_OK="no"
assert_eq "tdd/SKILL.md references browser-e2e.md" "yes" "$TDD_OK"

REVIEW_REF=$(grep -c 'browser-e2e.md' "$RES/review/review-contract.md" || true)
[ "$REVIEW_REF" -ge 1 ] && REVIEW_OK="yes" || REVIEW_OK="no"
assert_eq "review-contract.md gates on browser E2E grounding" "yes" "$REVIEW_OK"

CHECK_REF=$(grep -c 'Browser E2E grounding' "$SKILLS/checklist/SKILL.md" || true)
[ "$CHECK_REF" -ge 1 ] && CHECK_OK="yes" || CHECK_OK="no"
assert_eq "checklist/SKILL.md has Browser E2E grounding check" "yes" "$CHECK_OK"

print_summary
