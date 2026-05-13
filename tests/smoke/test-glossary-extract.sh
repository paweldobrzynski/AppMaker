#!/usr/bin/env bash
# Smoke test for glossary-extract.sh (v0.2.11 deterministic stub extraction).
# Verifies: idempotent stub append, existing terms skipped, bad input rejected.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

PLUGIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)/plugin/appmaker"
EXTRACT="$PLUGIN_DIR/hooks/glossary-extract.sh"

[ -x "$EXTRACT" ] || { echo "❌ extract not executable: $EXTRACT"; exit 2; }

echo "=== glossary-extract smoke tests ==="

# Scenario 1: missing arg → rejection (exit 1)
OUT=$(bash "$EXTRACT" 2>&1)
RC=$?
assert_eq "missing arg: exit 1" "1" "$RC"
assert_contains "missing arg: usage msg" "$OUT" "usage"

# Scenario 2: input file doesn't exist → exit 1
OUT=$(bash "$EXTRACT" /tmp/nonexistent-xxxxx.md 2>&1)
RC=$?
assert_eq "missing file: exit 1" "1" "$RC"

# Scenario 3: glossary missing → graceful skip (exit 0, no panic)
T=$(setup_temp_dir)
mkdir -p "$T/appmaker"
echo "**Test Term**" > "$T/artifact.md"
OUT=$(cd "$T" && bash "$EXTRACT" artifact.md 2>&1)
RC=$?
assert_eq "no glossary: exit 0" "0" "$RC"
assert_contains "no glossary: msg" "$OUT" "missing"
rm -rf "$T"

# Scenario 4: extracts new term, skips existing
T=$(setup_temp_dir)
mkdir -p "$T/appmaker"
cat > "$T/appmaker/glossary.md" <<'EOF'
---
term_count: 1
---

## Existing Term
**Definition:** Pre-existing.
EOF
cat > "$T/artifact.md" <<'EOF'
**Existing Term** is in glossary, skip.
**New Domain Term** should be added.
**lowercase phrase** skip (starts lowercase).
**X** too short.
EOF
OUT=$(cd "$T" && bash "$EXTRACT" artifact.md 2>&1)
RC=$?
assert_eq "extract: exit 0" "0" "$RC"
assert_contains "extract: 1 candidate appended" "$OUT" "1 candidate"
GLOSSARY_AFTER=$(cat "$T/appmaker/glossary.md")
assert_contains "extract: New Domain Term added" "$GLOSSARY_AFTER" "## New Domain Term"
[[ "$GLOSSARY_AFTER" == *"## Existing Term"* ]] && KEPT="yes" || KEPT="no"
assert_eq "extract: existing entry preserved" "yes" "$KEPT"
# Re-run should be idempotent
OUT2=$(cd "$T" && bash "$EXTRACT" artifact.md 2>&1)
assert_contains "idempotent: 2nd run no new" "$OUT2" "already in glossary"
rm -rf "$T"

print_summary
