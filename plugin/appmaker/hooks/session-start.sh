#!/usr/bin/env bash
# AppMaker session-start hook
# Prints 1-line status summary when an AppMaker project is opened.
# Silent exit if no appmaker/ folder. Never blocks session (errors → silent exit 0).

set +e

[ -d appmaker ] || exit 0

VERSION="$(cat appmaker/.appmaker-version 2>/dev/null || echo '?')"

# Find newest non-archived feature folder.
# Sort numerically descending — feature names are zero-padded NNN-slug, so reverse
# alphabetic == reverse numeric. Picks highest-numbered (= most recently allocated).
FEATURE=""
if [ -d appmaker/features ]; then
  for d in $(ls -1d appmaker/features/*/ 2>/dev/null | sort -r); do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    [ "$name" = "archive" ] && continue
    FEATURE="$name"
    break
  done
fi

if [ -z "$FEATURE" ]; then
  echo "▸ AppMaker v$VERSION │ no active feature │ /appmaker:start to begin"
  exit 0
fi

# Count slices linked to active feature — must check BOTH active backlog AND
# backlog/done/ (tdd moves completed items there). Without done/, post-TDD
# status shows 0/N.
TOTAL=0
DONE=0
if [ -d appmaker/backlog ]; then
  for f in appmaker/backlog/*.md appmaker/backlog/done/*.md; do
    [ -f "$f" ] || continue
    if grep -q "^feature: $FEATURE" "$f" 2>/dev/null; then
      TOTAL=$((TOTAL + 1))
      grep -q "^status: done" "$f" 2>/dev/null && DONE=$((DONE + 1))
    fi
  done
fi

# Latest checklist status for this feature
CHECK_STATUS=""
if [ -d appmaker/checklists ]; then
  LATEST_CHECK=$(ls -t appmaker/checklists/*"$FEATURE"*.md 2>/dev/null | head -1)
  if [ -n "$LATEST_CHECK" ]; then
    CHECK_STATUS=$(grep -m1 '^status:' "$LATEST_CHECK" 2>/dev/null | awk '{print $2}')
  fi
fi

PROGRESS=""
if [ "$TOTAL" -gt 0 ]; then
  PROGRESS=" ($DONE/$TOTAL slices done)"
fi

CHECK_PART=""
if [ -n "$CHECK_STATUS" ]; then
  CHECK_PART=" │ checklist: $CHECK_STATUS"
fi

echo "▸ AppMaker v$VERSION │ feature $FEATURE$PROGRESS$CHECK_PART │ /appmaker:status for detail"
exit 0
