#!/usr/bin/env bash
# Shared assertion helpers for AppMaker smoke tests.

# Colors
if [ -t 1 ]; then
  C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RESET=$'\033[0m'
else
  C_RED=''; C_GREEN=''; C_YELLOW=''; C_RESET=''
fi

PASS_COUNT=0
FAIL_COUNT=0
FAILURES=()

assert_eq() {
  local name="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "${C_GREEN}✓${C_RESET} $name"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "${C_RED}✗${C_RESET} $name"
    echo "    expected: $expected"
    echo "    actual:   $actual"
    FAILURES+=("$name")
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

assert_contains() {
  local name="$1" haystack="$2" needle="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "${C_GREEN}✓${C_RESET} $name"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "${C_RED}✗${C_RESET} $name"
    echo "    expected to contain: $needle"
    echo "    actual: $haystack"
    FAILURES+=("$name")
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

assert_file_exists() {
  local name="$1" path="$2"
  if [ -f "$path" ]; then
    echo "${C_GREEN}✓${C_RESET} $name"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "${C_RED}✗${C_RESET} $name (file missing: $path)"
    FAILURES+=("$name")
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

assert_exit_zero() {
  local name="$1" actual="$2"
  if [ "$actual" = "0" ]; then
    echo "${C_GREEN}✓${C_RESET} $name"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "${C_RED}✗${C_RESET} $name (exit code: $actual)"
    FAILURES+=("$name")
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

print_summary() {
  echo ""
  echo "──────────────────────────────────────"
  if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "${C_GREEN}All $PASS_COUNT tests passed${C_RESET}"
    return 0
  else
    echo "${C_YELLOW}$PASS_COUNT passed / ${C_RED}$FAIL_COUNT failed${C_RESET}"
    for f in "${FAILURES[@]}"; do echo "  - $f"; done
    return 1
  fi
}

# Setup temp dir for a test; auto-cleanup on EXIT.
setup_temp_dir() {
  local TMPDIR
  TMPDIR=$(mktemp -d -t appmaker-smoke-XXXXXX)
  echo "$TMPDIR"
}
