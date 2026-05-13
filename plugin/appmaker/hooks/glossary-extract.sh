#!/usr/bin/env bash
# AppMaker glossary auto-stub extractor (v0.2.11)
#
# Deterministic post-step for parent skills (prd, decompose, tdd, grill):
# scans a generated artifact for bold-uppercase candidate terms, compares against
# current glossary, appends stubs for new ones. Definitions are NOT auto-generated
# — stubs are flagged for explicit user review via /appmaker:glossary.
#
# Why this exists (v0.2.11): replaces the prior "agent auto-invokes glossary" trust
# pattern with a deterministic bash extraction. Wording in parent skills said
# "auto-maintained byproduct" but mechanism was best-effort agent instruction. This
# closes that gap: the extraction step is verifiable bash; the SEMANTIC update
# (definitions, false-positive pruning) is still explicit /appmaker:glossary.
#
# Usage: bash appmaker/hooks/glossary-extract.sh <artifact-path>
# Exit: 0 on success or no candidates; 1 on missing args / unreadable input.

set +e

if [ $# -lt 1 ] || [ ! -f "$1" ]; then
  echo "❌ glossary-extract: usage: bash $0 <artifact-path>" >&2
  exit 1
fi

ARTIFACT="$1"
GLOSSARY="appmaker/glossary.md"

# Refuse if no glossary yet (init should have created it; abort cleanly)
if [ ! -f "$GLOSSARY" ]; then
  echo "ⓘ glossary-extract: appmaker/glossary.md missing — skipping (run /appmaker:init first)" >&2
  exit 0
fi

# Extract candidate terms: bold-wrapped, starts uppercase, 3-40 chars.
# Pattern intentionally conservative — better miss than false-positive.
CANDIDATES=$(grep -oE '\*\*[A-Z][A-Za-z][A-Za-z0-9 -]{1,38}\*\*' "$ARTIFACT" 2>/dev/null \
  | sed 's/\*\*//g' | sort -u)

if [ -z "$CANDIDATES" ]; then
  echo "ⓘ glossary-extract: no candidate terms found in $ARTIFACT"
  exit 0
fi

NEW_COUNT=0
while IFS= read -r term; do
  [ -z "$term" ] && continue
  # Skip if already a heading in glossary (case-insensitive match on "## <term>")
  if ! grep -qiE "^## ${term}\$|^## ${term} " "$GLOSSARY" 2>/dev/null; then
    cat >> "$GLOSSARY" <<GLOSSARY_STUB

## $term
**Status:** stub (auto-flagged from \`$ARTIFACT\`)
**Definition:** (needs user input — run \`/appmaker:glossary\` to review/define/reject)
GLOSSARY_STUB
    NEW_COUNT=$((NEW_COUNT + 1))
  fi
done <<< "$CANDIDATES"

if [ "$NEW_COUNT" -gt 0 ]; then
  echo "✓ glossary-extract: $NEW_COUNT candidate term(s) appended as stubs to $GLOSSARY"
  echo "  Review with: /appmaker:glossary"
else
  echo "ⓘ glossary-extract: all candidates already in glossary"
fi
exit 0
