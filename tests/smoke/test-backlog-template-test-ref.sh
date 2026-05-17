#!/usr/bin/env bash
# Smoke test for v0.2.18 pcrit-002: backlog item template supports inline test: ref per AC.
#
# Codex review criteria (3 enforcements to avoid slice-001-style weak test):
#   1. CONCRETE test: ref example — real file.ext::testname, not placeholder
#      Reason: placeholder <test_file>::<test_name> would pass as docs without
#      proving usable form.
#   2. Example AC WITHOUT test ref — human-review form. Proves field is optional;
#      contract doesn't force fake test refs on manual ACs.
#   3. Field semantics/rules explicit: test: is optional + applies to executable
#      tests; human-review requires criterion.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/templates/backlog-item-template.md"

echo "=== backlog-item-template.md AC test: ref smoke tests ==="

assert_file_exists "backlog-item-template.md present" "$TEMPLATE"

# 1. Concrete test: ref example — matches `test: <path>.<ext>::<name>` form
#    where path is realistic (not <placeholder>) and ext is a known test extension.
CONCRETE_COUNT=$(grep -cE 'test:[[:space:]]+[a-zA-Z][a-zA-Z0-9_./-]*\.(sh|ts|js|py|go|rs|md)::[a-zA-Z_][a-zA-Z0-9_]*' "$TEMPLATE" || true)
[ "$CONCRETE_COUNT" -ge 1 ] && CONCRETE_PRESENT="yes" || CONCRETE_PRESENT="no"
assert_eq "template has CONCRETE test: ref example (file.ext::name, not placeholder)" "yes" "$CONCRETE_PRESENT"

# 2. Example AC without test — human-review form proving field optional
HUMAN_REVIEW_COUNT=$(grep -cE '\(traces_to:[^)]*human-review' "$TEMPLATE" || true)
[ "$HUMAN_REVIEW_COUNT" -ge 1 ] && HUMAN_REVIEW_PRESENT="yes" || HUMAN_REVIEW_PRESENT="no"
assert_eq "template has AC example without test (human-review form)" "yes" "$HUMAN_REVIEW_PRESENT"

# 3a. Field semantics documents test: as optional
TEST_OPTIONAL_DOC=$(grep -cE 'test:.*optional|optional.*\btest:' "$TEMPLATE" || true)
[ "$TEST_OPTIONAL_DOC" -ge 1 ] && TEST_OPTIONAL_PRESENT="yes" || TEST_OPTIONAL_PRESENT="no"
assert_eq "template documents test: field as optional" "yes" "$TEST_OPTIONAL_PRESENT"

# 3b. Field semantics documents human-review requires criterion
HUMAN_CRITERION_DOC=$(grep -cE 'human-review.*criterion|criterion.*human-review' "$TEMPLATE" || true)
[ "$HUMAN_CRITERION_DOC" -ge 1 ] && HUMAN_CRITERION_PRESENT="yes" || HUMAN_CRITERION_PRESENT="no"
assert_eq "template documents human-review requires criterion" "yes" "$HUMAN_CRITERION_PRESENT"

print_summary
