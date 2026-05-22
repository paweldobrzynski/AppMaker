#!/usr/bin/env bash
# Deterministic dry-run planner for AppMaker phase orchestration.

set -u

usage() {
  cat <<'USAGE'
Usage: phase-plan.sh <phase-id> [--project-dir DIR]

Reads appmaker/backlog/*.md, validates phase ownership metadata, builds safe
parallel waves, and writes appmaker/phase-plans/*-dry-run.md.
USAGE
}

die() {
  echo "phase-plan: $*" >&2
  exit 2
}

PHASE_ID=""
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
    -*)
      die "unknown option: $1"
      ;;
    *)
      [ -z "$PHASE_ID" ] || die "only one phase id is supported"
      PHASE_ID="$1"
      ;;
  esac
  shift
done

[ -n "$PHASE_ID" ] || die "missing <phase-id>"
cd "$PROJECT_DIR" || die "cannot cd to project dir: $PROJECT_DIR"
[ -d appmaker/backlog ] || die "missing appmaker/backlog"

TMP_ROOT=$(mktemp -d -t appmaker-phase-plan-XXXXXX)
trap 'rm -rf "$TMP_ROOT"' EXIT

RECORDS_FILE="$TMP_ROOT/items.tsv"
FAIL_FILE="$TMP_ROOT/failures.txt"
WARN_FILE="$TMP_ROOT/warnings.txt"
CONFLICT_FILE="$TMP_ROOT/conflicts.tsv"
WAVES_FILE="$TMP_ROOT/waves.tsv"

: > "$RECORDS_FILE"
: > "$FAIL_FILE"
: > "$WARN_FILE"
: > "$CONFLICT_FILE"
: > "$WAVES_FILE"

trim_value() {
  sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/^"//; s/"$//; s/^'\''//; s/'\''$//'
}

extract_scalar() {
  local file_name="$1"
  local key_name="$2"
  awk -v key="$key_name" '
    $0 ~ "^" key ":" {
      value=$0
      sub("^" key ":[[:space:]]*", "", value)
      print value
      exit
    }
  ' "$file_name" | trim_value
}

inline_list() {
  local file_name="$1"
  local key_name="$2"
  extract_scalar "$file_name" "$key_name" \
    | sed 's/^\[//; s/\]$//; s/,/ /g; s/[[:space:]]\+/ /g; s/^[[:space:]]*//; s/[[:space:]]*$//'
}

block_list_csv() {
  local file_name="$1"
  local key_name="$2"
  awk -v key="$key_name" '
    $0 ~ "^" key ":" {
      value=$0
      sub("^" key ":[[:space:]]*", "", value)
      if (value != "") {
        print value
        in_list=0
        next
      }
      in_list=1
      next
    }
    in_list && /^[[:space:]]*-[[:space:]]*/ {
      value=$0
      sub(/^[[:space:]]*-[[:space:]]*/, "", value)
      print value
      next
    }
    in_list && /^[A-Za-z_][A-Za-z0-9_]*:/ {
      in_list=0
    }
  ' "$file_name" \
    | sed 's/[[:space:]]*#.*$//; s/^[[:space:]]*//; s/[[:space:]]*$//' \
    | awk 'NF' \
    | paste -sd "," -
}

config_value() {
  local key_name="$1"
  [ -f appmaker/config.yaml ] || return 0
  extract_scalar appmaker/config.yaml "$key_name"
}

list_contains() {
  local value_list="$1"
  local wanted="$2"
  case " $value_list " in
    *" $wanted "*) return 0 ;;
    *) return 1 ;;
  esac
}

word_count() {
  set -- ${1:-}
  echo "$#"
}

join_words() {
  local out=""
  local word
  for word in ${1:-}; do
    if [ -z "$out" ]; then
      out="$word"
    else
      out="$out, $word"
    fi
  done
  printf "%s" "$out"
}

normalize_scope() {
  local scope_value="$1"
  scope_value=$(printf "%s" "$scope_value" | trim_value)
  scope_value=${scope_value#./}
  case "$scope_value" in
    */**) scope_value=${scope_value%/**} ;;
  esac
  scope_value=${scope_value%/}
  printf "%s" "$scope_value"
}

scope_pair_overlaps() {
  local scope_a
  local scope_b
  scope_a=$(normalize_scope "$1")
  scope_b=$(normalize_scope "$2")

  [ -n "$scope_a" ] || return 1
  [ -n "$scope_b" ] || return 1

  case "$scope_a" in "."|"*"|"**"|"**/*") return 0 ;; esac
  case "$scope_b" in "."|"*"|"**"|"**/*") return 0 ;; esac

  [ "$scope_a" = "$scope_b" ] && return 0
  case "$scope_a" in "$scope_b"/*) return 0 ;; esac
  case "$scope_b" in "$scope_a"/*) return 0 ;; esac
  return 1
}

scopes_overlap() {
  local scopes_a="$1"
  local scopes_b="$2"
  local scope_a
  local scope_b

  for scope_a in $(printf "%s" "$scopes_a" | tr ',' ' '); do
    for scope_b in $(printf "%s" "$scopes_b" | tr ',' ' '); do
      if scope_pair_overlaps "$scope_a" "$scope_b"; then
        return 0
      fi
    done
  done
  return 1
}

record_field() {
  local wanted_id="$1"
  local field_number="$2"
  awk -F '|' -v wanted="$wanted_id" -v number="$field_number" '$1 == wanted { print $number; exit }' "$RECORDS_FILE"
}

directly_related() {
  local first_id="$1"
  local second_id="$2"
  local first_deps
  local first_blockers
  local second_deps
  local second_blockers

  first_deps=$(record_field "$first_id" 8)
  first_blockers=$(record_field "$first_id" 9)
  second_deps=$(record_field "$second_id" 8)
  second_blockers=$(record_field "$second_id" 9)

  list_contains "$first_deps $first_blockers" "$second_id" && return 0
  list_contains "$second_deps $second_blockers" "$first_id" && return 0
  return 1
}

deps_ready() {
  local dep_list="$1"
  local assigned_ids="$2"
  local target_ids="$3"
  local done_ids="$4"
  local dep_id

  for dep_id in $dep_list; do
    list_contains "$done_ids" "$dep_id" && continue
    if list_contains "$target_ids" "$dep_id"; then
      list_contains "$assigned_ids" "$dep_id" || return 1
    else
      return 1
    fi
  done
  return 0
}

MAX_PARALLEL=$(config_value max_parallel_agents)
case "$MAX_PARALLEL" in
  ''|*[!0-9]*) MAX_PARALLEL=3 ;;
esac
[ "$MAX_PARALLEL" -gt 0 ] || MAX_PARALLEL=3

PLAN_DIR=$(config_value phase_plan_dir)
[ -n "$PLAN_DIR" ] || PLAN_DIR="appmaker/phase-plans"
EXECUTION_MODE=$(config_value phase_execution_mode)
[ -n "$EXECUTION_MODE" ] || EXECUTION_MODE="local"

DONE_IDS=""
for item_file in appmaker/backlog/*.md appmaker/backlog/done/*.md; do
  [ -f "$item_file" ] || continue
  item_id=$(extract_scalar "$item_file" id)
  item_state=$(extract_scalar "$item_file" status)
  if [ -n "$item_id" ] && [ "$item_state" = "done" ]; then
    DONE_IDS="$DONE_IDS $item_id"
  fi
done

TARGET_IDS=""
for item_file in appmaker/backlog/*.md; do
  [ -f "$item_file" ] || continue
  item_phase=$(extract_scalar "$item_file" phase_id)
  [ "$item_phase" = "$PHASE_ID" ] || continue

  item_id=$(extract_scalar "$item_file" id)
  item_slug=$(extract_scalar "$item_file" slug)
  item_state=$(extract_scalar "$item_file" status)
  item_class=$(extract_scalar "$item_file" execution_class)
  item_agent=$(extract_scalar "$item_file" agent_profile)
  item_scopes=$(block_list_csv "$item_file" write_scope)
  item_deps=$(inline_list "$item_file" depends_on)
  item_blockers=$(inline_list "$item_file" blocked_by)
  item_risk=$(extract_scalar "$item_file" integration_risk)
  item_traces=$(inline_list "$item_file" traces_to)

  [ "$item_state" = "done" ] && continue
  [ -n "$item_id" ] || item_id=$(basename "$item_file" .md | sed 's/-.*$//')
  [ -n "$item_slug" ] || item_slug=$(basename "$item_file" .md | sed 's/^[0-9][0-9]*-//')
  [ -n "$item_state" ] || item_state="open"
  [ -n "$item_risk" ] || item_risk="unknown"

  TARGET_IDS="$TARGET_IDS $item_id"
  printf "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n" \
    "$item_id" "$item_slug" "$item_file" "$item_state" "$item_class" "$item_agent" \
    "$item_scopes" "$item_deps" "$item_blockers" "$item_risk" "$item_traces" >> "$RECORDS_FILE"
done

TARGET_COUNT=$(wc -l < "$RECORDS_FILE" | tr -d ' ')
if [ "$TARGET_COUNT" -eq 0 ]; then
  echo "phase has no active backlog items: $PHASE_ID" >> "$FAIL_FILE"
fi

while IFS='|' read -r item_id item_slug item_file item_state item_class item_agent item_scopes item_deps item_blockers item_risk item_traces; do
  [ -n "$item_id" ] || continue

  [ -n "$item_scopes" ] || echo "$item_id: missing write_scope" >> "$FAIL_FILE"
  [ -n "$item_agent" ] || echo "$item_id: missing agent_profile" >> "$FAIL_FILE"

  if [ -z "$item_traces" ] && ! grep -q 'traces_to:' "$item_file" 2>/dev/null; then
    echo "$item_id: missing traces_to evidence" >> "$FAIL_FILE"
  fi

  if [ "$item_class" = "human_required" ]; then
    echo "$item_id: execution_class human_required" >> "$FAIL_FILE"
  fi

  for dep_id in $item_deps $item_blockers; do
    list_contains "$TARGET_IDS" "$dep_id" && continue
    list_contains "$DONE_IDS" "$dep_id" && continue
    echo "$item_id: unresolved dependency $dep_id" >> "$FAIL_FILE"
  done

  for scope_value in $(printf "%s" "$item_scopes" | tr ',' ' '); do
    normalized_scope=$(normalize_scope "$scope_value")
    case "$normalized_scope" in
      "."|"*"|"**"|"**/*"|"src")
        echo "$item_id: broad write_scope $scope_value" >> "$WARN_FILE"
        ;;
    esac
  done
done < "$RECORDS_FILE"

IDS_SEEN=""
while IFS='|' read -r item_id item_slug item_file item_state item_class item_agent item_scopes item_deps item_blockers item_risk item_traces; do
  [ -n "$item_id" ] || continue
  for other_id in $IDS_SEEN; do
    other_scopes=$(record_field "$other_id" 7)
    if scopes_overlap "$item_scopes" "$other_scopes" && ! directly_related "$item_id" "$other_id"; then
      overlap_note="scope overlap: $other_scopes vs $item_scopes"
      printf "%s, %s|%s|split write_scope or add depends_on\n" "$other_id" "$item_id" "$overlap_note" >> "$CONFLICT_FILE"
      echo "$other_id/$item_id: $overlap_note" >> "$FAIL_FILE"
    fi
  done
  IDS_SEEN="$IDS_SEEN $item_id"
done < "$RECORDS_FILE"

if [ ! -s "$FAIL_FILE" ]; then
  ASSIGNED_IDS=""
  WAVE_NO=1
  LOOP_GUARD=0

  while [ "$(word_count "$ASSIGNED_IDS")" -lt "$TARGET_COUNT" ]; do
    LOOP_GUARD=$((LOOP_GUARD + 1))
    [ "$LOOP_GUARD" -le 100 ] || {
      echo "cycle or planner guard exceeded" >> "$FAIL_FILE"
      break
    }

    WAVE_IDS=""
    WAVE_SCOPES=""

    while IFS='|' read -r item_id item_slug item_file item_state item_class item_agent item_scopes item_deps item_blockers item_risk item_traces; do
      [ -n "$item_id" ] || continue
      list_contains "$ASSIGNED_IDS" "$item_id" && continue

      deps_ready "$item_deps $item_blockers" "$ASSIGNED_IDS" "$TARGET_IDS" "$DONE_IDS" || continue
      [ "$(word_count "$WAVE_IDS")" -lt "$MAX_PARALLEL" ] || continue

      if [ -n "$WAVE_SCOPES" ] && scopes_overlap "$item_scopes" "$WAVE_SCOPES"; then
        continue
      fi

      WAVE_IDS="$WAVE_IDS $item_id"
      if [ -z "$WAVE_SCOPES" ]; then
        WAVE_SCOPES="$item_scopes"
      else
        WAVE_SCOPES="$WAVE_SCOPES,$item_scopes"
      fi
    done < "$RECORDS_FILE"

    if [ -z "$WAVE_IDS" ]; then
      echo "dependency cycle or unsatisfied dependency prevented wave build" >> "$FAIL_FILE"
      break
    fi

    printf "%s|%s|dependency-ready, no scope overlap\n" "$WAVE_NO" "$(join_words "$WAVE_IDS")" >> "$WAVES_FILE"
    ASSIGNED_IDS="$ASSIGNED_IDS $WAVE_IDS"
    WAVE_NO=$((WAVE_NO + 1))
  done
fi

PLAN_STATE="PASS"
if [ -s "$FAIL_FILE" ]; then
  PLAN_STATE="FAIL"
elif [ -s "$WARN_FILE" ]; then
  PLAN_STATE="WARN"
fi

SAFE_PHASE=$(printf "%s" "$PHASE_ID" | sed 's/[^A-Za-z0-9._-]/-/g')
CREATED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
REPORT_PATH="$PLAN_DIR/$(date -u +%Y-%m-%d-%H%M%S)-$SAFE_PHASE-dry-run.md"

mkdir -p "$PLAN_DIR"

{
  echo "---"
  echo "phase_id: $PHASE_ID"
  echo "mode: dry-run"
  echo "status: $PLAN_STATE"
  echo "execution_mode: $EXECUTION_MODE"
  echo "created: $CREATED_AT"
  echo "---"
  echo ""
  echo "# Phase Execution Plan"
  echo ""
  echo "## Items"
  echo "| Item | Agent | Write Scope | Depends On | Risk | Can Run |"
  echo "|---|---|---|---|---|---|"
  if [ "$TARGET_COUNT" -eq 0 ]; then
    echo "| - | - | - | - | - | no |"
  else
    while IFS='|' read -r item_id item_slug item_file item_state item_class item_agent item_scopes item_deps item_blockers item_risk item_traces; do
      can_run="yes"
      [ "$PLAN_STATE" = "FAIL" ] && can_run="blocked"
      [ -n "$item_deps" ] || item_deps="-"
      [ -n "$item_agent" ] || item_agent="-"
      [ -n "$item_scopes" ] || item_scopes="-"
      echo "| $item_id | $item_agent | $item_scopes | $item_deps | $item_risk | $can_run |"
    done < "$RECORDS_FILE"
  fi
  echo ""
  echo "## Parallel Waves"
  echo "| Wave | Items | Reason |"
  echo "|---|---|---|"
  if [ -s "$WAVES_FILE" ]; then
    while IFS='|' read -r wave_no wave_items wave_reason; do
      echo "| $wave_no | $wave_items | $wave_reason |"
    done < "$WAVES_FILE"
  else
    echo "| - | - | blocked by validation |"
  fi
  echo ""
  echo "## Conflicts"
  echo "| Items | Conflict | Resolution |"
  echo "|---|---|---|"
  if [ -s "$CONFLICT_FILE" ]; then
    while IFS='|' read -r conflict_items conflict_note conflict_resolution; do
      echo "| $conflict_items | $conflict_note | $conflict_resolution |"
    done < "$CONFLICT_FILE"
  else
    echo "| - | none | - |"
  fi
  if [ -s "$FAIL_FILE" ]; then
    echo ""
    echo "## Blockers"
    while IFS= read -r fail_line; do
      echo "- $fail_line"
    done < "$FAIL_FILE"
  fi
  if [ -s "$WARN_FILE" ]; then
    echo ""
    echo "## Warnings"
    while IFS= read -r warn_line; do
      echo "- $warn_line"
    done < "$WARN_FILE"
  fi
  echo ""
  echo "## Subagent Task Contract"
  echo "Each future subagent receives one backlog item, owned write_scope, acceptance criteria, context packets, and this rule: do not edit outside write_scope; you are not alone in the codebase; do not revert others' edits; report drift and touched files."
} > "$REPORT_PATH"

echo "Phase plan: $REPORT_PATH"
echo "Status: $PLAN_STATE"

[ "$PLAN_STATE" = "FAIL" ] && exit 1
exit 0
