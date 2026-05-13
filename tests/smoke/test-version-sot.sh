#!/usr/bin/env bash
# Smoke test for v0.2.11 version single-source-of-truth.
# Verifies: plugin.json version is readable via jq; marketplace.json matches.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PLUGIN_MANIFEST="$REPO_ROOT/plugin/appmaker/.claude-plugin/plugin.json"
MARKETPLACE="$REPO_ROOT/.claude-plugin/marketplace.json"

echo "=== version SoT smoke tests ==="

[ -f "$PLUGIN_MANIFEST" ] || { echo "❌ plugin.json missing"; exit 2; }
[ -f "$MARKETPLACE" ]      || { echo "❌ marketplace.json missing"; exit 2; }
command -v jq >/dev/null   || { echo "❌ jq required for these tests"; exit 2; }

PLUGIN_VERSION=$(jq -r '.version' "$PLUGIN_MANIFEST")
MARKETPLACE_VERSION=$(jq -r '.metadata.version' "$MARKETPLACE")

assert_eq "plugin.json + marketplace.json versions match" "$PLUGIN_VERSION" "$MARKETPLACE_VERSION"
assert_contains "version is semver-ish" "$PLUGIN_VERSION" "."

# config.yaml.template uses ${VERSION} placeholder, not hardcoded number
TEMPLATE="$REPO_ROOT/plugin/appmaker/resources/appmaker/config.yaml.template"
TEMPLATE_LINE=$(grep '^resource_version:' "$TEMPLATE")
assert_contains "config.yaml.template uses placeholder" "$TEMPLATE_LINE" '${VERSION}'

# init/SKILL.md no longer has "Plugin version is hardcoded in this skill: \`X.Y.Z\`"
INIT_SKILL="$REPO_ROOT/plugin/appmaker/skills/init/SKILL.md"
HARDCODED_NOTE=$(grep -c "hardcoded in this skill: \`[0-9]" "$INIT_SKILL" || true)
assert_eq "init/SKILL.md no longer claims hardcoded version" "0" "$HARDCODED_NOTE"

# init/SKILL.md reads plugin.json via jq
JQ_REFERENCE=$(grep -c "jq -r '.version'" "$INIT_SKILL" || true)
[ "$JQ_REFERENCE" -ge "1" ] && JQ_PRESENT="yes" || JQ_PRESENT="no"
assert_eq "init/SKILL.md reads plugin.json via jq" "yes" "$JQ_PRESENT"

print_summary
