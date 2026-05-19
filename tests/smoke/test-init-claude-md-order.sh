#!/usr/bin/env bash
# Smoke test: init/SKILL.md describes Forest CLAUDE.md install BEFORE invoking
# init-materialize.sh.
#
# Reason: the materialize script appends the AppMaker pointer block to
# project-root CLAUDE.md (idempotently). Forest's install uses
# `curl ... > CLAUDE.md`, which OVERWRITES the file. If Forest runs AFTER
# materialize, the AppMaker pointer is silently clobbered. Test pins the
# correct order in the skill body.
#
# Anchoring rule: order check uses OPERATIONAL command lines, not metadata
# mentions. Forest install = line with `curl <url> .../forrestchang...`;
# materialize invocation = line with `bash <path>/init-materialize.sh`.
# Meta-text in the description frontmatter or intro paragraph would otherwise
# false-positive the order check.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INIT="$REPO_ROOT/plugin/appmaker/skills/init/SKILL.md"

echo "=== init/SKILL.md CLAUDE.md order smoke tests ==="

assert_file_exists "init/SKILL.md present" "$INIT"

# Presence: Forest's CLAUDE.md is mentioned somewhere in the skill.
FOREST_MENTION=$(grep -cE "Forest('?s)? CLAUDE\.md" "$INIT" || true)
[ "$FOREST_MENTION" -ge 1 ] && FOREST_MENTIONED="yes" || FOREST_MENTIONED="no"
assert_eq "init/SKILL.md mentions Forest's CLAUDE.md" "yes" "$FOREST_MENTIONED"

# Operational line numbers (the actual commands, not prose).
FOREST_CMD_LINE=$(grep -nE 'curl[^`]*https?://[^`]*forrestchang' "$INIT" | head -1 | cut -d: -f1)
MATERIALIZE_CMD_LINE=$(grep -nE 'bash[^`]*init-materialize\.sh' "$INIT" | head -1 | cut -d: -f1)

[ -n "$FOREST_CMD_LINE" ] && FOREST_CMD_PRESENT="yes" || FOREST_CMD_PRESENT="no"
assert_eq "init/SKILL.md contains the Forest install command (curl <url>)" "yes" "$FOREST_CMD_PRESENT"

[ -n "$MATERIALIZE_CMD_LINE" ] && MAT_CMD_PRESENT="yes" || MAT_CMD_PRESENT="no"
assert_eq "init/SKILL.md contains the materialize-script invocation (bash <path>)" "yes" "$MAT_CMD_PRESENT"

if [ -n "$FOREST_CMD_LINE" ] && [ -n "$MATERIALIZE_CMD_LINE" ] && [ "$FOREST_CMD_LINE" -lt "$MATERIALIZE_CMD_LINE" ]; then
  ORDER_OK="yes"
else
  ORDER_OK="no"
fi
assert_eq "Forest install command precedes init-materialize.sh invocation" "yes" "$ORDER_OK"

# Defense-in-depth: no actual `curl <url> > CLAUDE.md` install command should
# appear AFTER the materialize invocation (that would clobber the AppMaker
# pointer the script just appended). Requires `https?://` to distinguish from
# guardrail prose that explains the rule without an executable command.
if [ -n "$MATERIALIZE_CMD_LINE" ]; then
  CURL_AFTER=$(awk -v mat="$MATERIALIZE_CMD_LINE" 'NR>mat && /curl[^`]*https?:\/\/[^`]*> *CLAUDE\.md/ {found=1} END {print (found ? "yes" : "no")}' "$INIT")
else
  CURL_AFTER="no"
fi
assert_eq "no executable 'curl <url> > CLAUDE.md' after materialize invocation (would clobber pointer)" "no" "$CURL_AFTER"

print_summary
