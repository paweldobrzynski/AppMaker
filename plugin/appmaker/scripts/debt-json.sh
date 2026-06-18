#!/usr/bin/env bash
# Deterministic harvest of `appmaker:debt` shortcut markers into JSON for /appmaker:debt.
# No writes. No jq dependency. Tier-1 grep — collects deliberate shortcuts, never fixes them.
#
# Marker convention (in any code comment):
#   appmaker:debt <ceiling> -> upgrade: <path>     (also accepts the arrow →)
# Example:
#   // appmaker:debt global lock -> upgrade: per-account locks if throughput matters

set -u

usage() {
  cat <<'USAGE'
Usage: debt-json.sh [--project-dir DIR]

Scans project source for `appmaker:debt` markers and prints a compact JSON ledger.
Excludes .git/, node_modules/, and appmaker/ (markers live in source, not artifacts). No writes.
USAGE
}

die() {
  echo "debt-json: $*" >&2
  exit 2
}

PROJECT_DIR="."

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project-dir)
      shift
      [ "$#" -gt 0 ] || die "--project-dir requires a value"
      PROJECT_DIR="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
  shift
done

cd "$PROJECT_DIR" || die "cannot cd to project dir: $PROJECT_DIR"

json_escape() {
  sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g'
}

json_string() {
  printf '"%s"' "$(printf "%s" "$1" | json_escape)"
}

# Trim leading/trailing whitespace.
trim() {
  sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

# Collect matches: "file:line:content". grep -r excludes the dirs that never hold live debt.
MATCHES=$(grep -rn \
  --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=appmaker \
  'appmaker:debt' . 2>/dev/null | LC_ALL=C sort)

printf '{"debts":['
first=1
# Use a here-string so the loop body runs in this shell (counters not needed, but keeps it simple).
while IFS= read -r match; do
  [ -n "$match" ] || continue

  # Split "path:line:content" — path may contain no colon (paths here start with ./).
  file=$(printf "%s" "$match" | cut -d: -f1)
  line=$(printf "%s" "$match" | cut -d: -f2)
  content=$(printf "%s" "$match" | cut -d: -f3-)

  # Everything after the marker token.
  after=$(printf "%s" "$content" | sed 's/.*appmaker:debt//')

  # ceiling = text before the upgrade marker (→ | -> | upgrade:); upgrade = text after `upgrade:`.
  ceiling=$(printf "%s" "$after" | sed -E 's/(→|->|[[:space:]]*upgrade:).*//' | trim)
  if printf "%s" "$after" | grep -qi 'upgrade:'; then
    upgrade=$(printf "%s" "$after" | sed -E 's/.*upgrade:[[:space:]]*//I' | trim)
  else
    upgrade=""
  fi

  if [ -n "$ceiling" ]; then has_ceiling=true; else has_ceiling=false; fi
  if [ -n "$upgrade" ]; then has_upgrade=true; else has_upgrade=false; fi

  [ "$first" -eq 1 ] || printf ','
  printf '{"file":'
  json_string "$file"
  printf ',"line":%s' "${line:-0}"
  printf ',"ceiling":'
  json_string "$ceiling"
  printf ',"upgrade":'
  json_string "$upgrade"
  printf ',"has_ceiling":%s' "$has_ceiling"
  printf ',"has_upgrade":%s' "$has_upgrade"
  printf ',"raw":'
  json_string "$(printf "%s" "$content" | trim)"
  printf '}'
  first=0
done <<EOF
$MATCHES
EOF
printf ']}\n'
