#!/usr/bin/env bash
# Run all AppMaker smoke tests.
# Exit 0 if all pass, 1 if any fail. Per-test exit codes also reported.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -t 1 ]; then
  C_BOLD=$'\033[1m'; C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_RESET=$'\033[0m'
else
  C_BOLD=''; C_RED=''; C_GREEN=''; C_RESET=''
fi

TOTAL_PASS=0
TOTAL_FAIL=0
declare -a FAILED_SUITES

for test in "$SCRIPT_DIR"/test-*.sh; do
  name=$(basename "$test" .sh)
  echo "${C_BOLD}━━━ $name ━━━${C_RESET}"
  bash "$test"
  RC=$?
  if [ "$RC" -eq 0 ]; then
    TOTAL_PASS=$((TOTAL_PASS + 1))
  else
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
    FAILED_SUITES+=("$name")
  fi
  echo ""
done

echo "${C_BOLD}══════════════════════════════════════${C_RESET}"
echo "${C_BOLD}Smoke test summary${C_RESET}"
echo "  Suites passed: ${C_GREEN}$TOTAL_PASS${C_RESET}"
echo "  Suites failed: ${C_RED}$TOTAL_FAIL${C_RESET}"
if [ "$TOTAL_FAIL" -gt 0 ]; then
  for s in "${FAILED_SUITES[@]}"; do echo "    - $s"; done
  exit 1
fi
exit 0
