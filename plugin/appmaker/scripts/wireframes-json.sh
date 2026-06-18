#!/usr/bin/env bash
# Deterministic JSON snapshot of wireframe + visual-recap artifacts for AppMaker Studio.
# No writes. No jq dependency. Renders ONLY what exists on disk (no separate source of truth).

set -u

usage() {
  cat <<'USAGE'
Usage: wireframes-json.sh [--project-dir DIR]

Scans appmaker/features/*/wireframe.md and appmaker/reviews/*-recap-*.md and prints a
compact JSON snapshot for the Studio "Design / Wireframes" panel. No writes.
USAGE
}

die() {
  echo "wireframes-json: $*" >&2
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

first_heading() {
  awk '/^# / { sub(/^# /, ""); print; exit }' "$1"
}

if [ ! -d appmaker ]; then
  printf '{"wireframes":[],"recaps":[]}\n'
  exit 0
fi

printf '{"wireframes":['
first=1
for wf in appmaker/features/*/wireframe.md; do
  [ -f "$wf" ] || continue
  feature=$(basename "$(dirname "$wf")")
  title=$(first_heading "$wf")
  if grep -q '```mermaid' "$wf" 2>/dev/null; then
    has_diagram=true
  else
    has_diagram=false
  fi
  pcrit=$(grep -oE 'pcrit-[0-9]+' "$wf" 2>/dev/null | sort -u | tr '\n' ' ')

  [ "$first" -eq 1 ] || printf ','
  printf '{"feature":'
  json_string "$feature"
  printf ',"title":'
  json_string "$title"
  printf ',"path":'
  json_string "$wf"
  printf ',"has_diagram":%s' "$has_diagram"
  printf ',"pcrit_refs":'
  json_words_array "$pcrit"
  printf '}'
  first=0
done
printf ']'

printf ',"recaps":['
first=1
for recap in appmaker/reviews/*-recap-*.md; do
  [ -f "$recap" ] || continue
  base=$(basename "$recap" .md)
  # Filename shape: YYYY-MM-DD[-HHMM]-recap-<slug>
  date=$(printf "%s" "$base" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')
  scope=$(printf "%s" "$base" | sed 's/^.*-recap-//')

  [ "$first" -eq 1 ] || printf ','
  printf '{"scope":'
  json_string "$scope"
  printf ',"path":'
  json_string "$recap"
  printf ',"date":'
  json_string "$date"
  printf '}'
  first=0
done
printf ']'

printf '}\n'
