#!/usr/bin/env bash
# Deterministic JSON status snapshot for AppMaker UI/control-plane adapters.

set -u

usage() {
  cat <<'USAGE'
Usage: status-json.sh [--project-dir DIR]

Reads AppMaker project artifacts and prints a compact JSON status snapshot.
No writes. No jq dependency.
USAGE
}

die() {
  echo "status-json: $*" >&2
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

json_words_array() {
  local words="$1"
  local first=1
  local word
  printf '['
  for word in $words; do
    [ "$first" -eq 1 ] || printf ','
    json_string "$word"
    first=0
  done
  printf ']'
}

trim_value() {
  sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/^"//; s/"$//; s/^'\''//; s/'\''$//'
}

extract_scalar() {
  local file_name="$1"
  local key_name="$2"
  [ -f "$file_name" ] || return 0
  awk -v key="$key_name" '
    $0 ~ "^" key ":" {
      value=$0
      sub("^" key ":[[:space:]]*", "", value)
      print value
      exit
    }
  ' "$file_name" | trim_value
}

if [ ! -d appmaker ]; then
  printf '{"appmaker":false}\n'
  exit 0
fi

VERSION=$(cat appmaker/.appmaker-version 2>/dev/null || echo "")

ACTIVE_FEATURE=""
for feature_dir in $(ls -1d appmaker/features/*/ 2>/dev/null | sort -r); do
  [ -d "$feature_dir" ] || continue
  feature_name=$(basename "$feature_dir")
  [ "$feature_name" = "archive" ] && continue
  ACTIVE_FEATURE="$feature_name"
  break
done

TOTAL=0
DONE_COUNT=0
OPEN_IDS=""

if [ -n "$ACTIVE_FEATURE" ]; then
  for backlog_file in appmaker/backlog/*.md appmaker/backlog/done/*.md; do
    [ -f "$backlog_file" ] || continue
    item_feature=$(extract_scalar "$backlog_file" feature)
    [ "$item_feature" = "$ACTIVE_FEATURE" ] || continue

    TOTAL=$((TOTAL + 1))
    item_status=$(extract_scalar "$backlog_file" status)
    item_id=$(extract_scalar "$backlog_file" id)
    [ -n "$item_id" ] || item_id=$(basename "$backlog_file" .md | sed 's/-.*$//')

    if [ "$item_status" = "done" ]; then
      DONE_COUNT=$((DONE_COUNT + 1))
    else
      OPEN_IDS="$OPEN_IDS $item_id"
    fi
  done
fi

CHECKLIST_FILE=""
CHECKLIST_STATUS=""
if [ -n "$ACTIVE_FEATURE" ]; then
  CHECKLIST_FILE=$(ls -t appmaker/checklists/*"$ACTIVE_FEATURE"*.md 2>/dev/null | head -1)
  if [ -n "$CHECKLIST_FILE" ]; then
    CHECKLIST_STATUS=$(extract_scalar "$CHECKLIST_FILE" status)
  fi
fi

PHASE_FILE=$(ls -t appmaker/phase-plans/*-execute.md appmaker/phase-plans/*-dry-run.md 2>/dev/null | head -1)
PHASE_ID=""
PHASE_MODE=""
PHASE_STATUS=""
if [ -n "$PHASE_FILE" ]; then
  PHASE_ID=$(extract_scalar "$PHASE_FILE" phase_id)
  PHASE_MODE=$(extract_scalar "$PHASE_FILE" mode)
  PHASE_STATUS=$(extract_scalar "$PHASE_FILE" status)
fi

GIT_DIRTY=false
GIT_CHANGED_COUNT=0
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  GIT_CHANGED_COUNT=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
  if [ "$GIT_CHANGED_COUNT" -gt 0 ]; then
    GIT_DIRTY=true
  fi
fi

printf '{"appmaker":true'
printf ',"version":'
json_string "$VERSION"
printf ',"active_feature":'
json_string "$ACTIVE_FEATURE"
printf ',"backlog":{"total":%s,"done":%s,"open_ids":' "$TOTAL" "$DONE_COUNT"
json_words_array "$OPEN_IDS"
printf '}'
printf ',"checklist":{"status":'
json_string "$CHECKLIST_STATUS"
printf ',"file":'
json_string "$CHECKLIST_FILE"
printf '}'
printf ',"phase":{"id":'
json_string "$PHASE_ID"
printf ',"mode":'
json_string "$PHASE_MODE"
printf ',"status":'
json_string "$PHASE_STATUS"
printf ',"file":'
json_string "$PHASE_FILE"
printf '}'
printf ',"git":{"dirty":%s,"changed_count":%s}' "$GIT_DIRTY" "$GIT_CHANGED_COUNT"
printf '}\n'
