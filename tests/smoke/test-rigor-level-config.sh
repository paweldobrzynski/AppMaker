#!/usr/bin/env bash
# Smoke test for v0.2.21 anti-bureaucracy config: rigor_level.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/config.yaml.template"

echo "=== config.yaml.template rigor_level smoke tests ==="

assert_file_exists "config.yaml.template present" "$CONFIG_TEMPLATE"

RIGOR_LINE=$(grep '^rigor_level:' "$CONFIG_TEMPLATE" || true)
assert_contains "rigor_level defaults to standard" "$RIGOR_LINE" "rigor_level: standard"
assert_contains "rigor_level documents enum values" "$RIGOR_LINE" "light | standard | strict"

for label in "light" "standard" "strict"; do
  COUNT=$(grep -cE "#[[:space:]]+${label}[[:space:]]+—" "$CONFIG_TEMPLATE" || true)
  [ "$COUNT" -ge 1 ] && PRESENT="yes" || PRESENT="no"
  assert_eq "rigor_level documents ${label} mode" "yes" "$PRESENT"
done

print_summary
