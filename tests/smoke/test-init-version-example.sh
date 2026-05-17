#!/usr/bin/env bash
# Smoke test for v0.2.18 pcrit-005: init/SKILL.md output/example blocks use
# placeholders instead of stale hardcoded version literals.
#
# Codex scoping correction: init/SKILL.md contains MANY legitimate historical
# version references — bash comments `# (v0.2.11 ...)`, sentences `as of v0.2.11`,
# decision labels. A global `[0-9]+\.[0-9]+\.[0-9]+` ban would false-fail.
#
# Scoping rule: drift = bare version at end-of-line after arrow (`→ X.Y.Z$`)
# or `plugin vX.Y.Z$`. Historical = inline `v0.2.11` with surrounding prose,
# comment markers (#), or paren-wrapping `(v0.2.11 ...)`. End-of-line bare
# version is unique to example/output blocks shown to user.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INIT="$REPO_ROOT/plugin/appmaker/skills/init/SKILL.md"

echo "=== init/SKILL.md version example placeholder smoke tests ==="

assert_file_exists "init/SKILL.md present" "$INIT"

# 1. No hardcoded Upgrade: X.Y.Z → A.B.C pattern (drift in example block)
UPGRADE_HARDCODED=$(grep -cE 'Upgrade:[[:space:]]+[0-9]+\.[0-9]+\.[0-9]+[[:space:]]+→[[:space:]]+[0-9]+\.[0-9]+\.[0-9]+' "$INIT" || true)
[ "$UPGRADE_HARDCODED" -eq 0 ] && NO_UPGRADE_HARD="yes" || NO_UPGRADE_HARD="no"
assert_eq "init/SKILL.md does NOT have 'Upgrade: X.Y.Z → A.B.C' hardcoded pattern" "yes" "$NO_UPGRADE_HARD"

# 2. Upgrade: example present with placeholder form (<previous>/<current> OR ${OLD_VERSION}/${PLUGIN_VERSION})
UPGRADE_PLACEHOLDER=$(grep -cE 'Upgrade:[[:space:]]+(<[a-z]+>[[:space:]]+→[[:space:]]+<[a-z]+>|\$\{OLD_VERSION\}[[:space:]]+→[[:space:]]+\$\{PLUGIN_VERSION\})' "$INIT" || true)
[ "$UPGRADE_PLACEHOLDER" -ge 1 ] && UPGRADE_PH="yes" || UPGRADE_PH="no"
assert_eq "init/SKILL.md has 'Upgrade:' with placeholder form (<previous>/<current> or shell-style)" "yes" "$UPGRADE_PH"

# 3. No bare "→ X.Y.Z" at end-of-line (catches version-marker example lines)
# This pattern is specific to drift form; historical refs use prose or comments.
ARROW_VERSION_EOL=$(grep -cE '→[[:space:]]+[0-9]+\.[0-9]+\.[0-9]+[[:space:]]*$' "$INIT" || true)
[ "$ARROW_VERSION_EOL" -eq 0 ] && NO_ARROW_EOL="yes" || NO_ARROW_EOL="no"
assert_eq "init/SKILL.md does NOT have '→ X.Y.Z' at end-of-line (example block drift)" "yes" "$NO_ARROW_EOL"

# 4. No bare "plugin vX.Y.Z" at end-of-line (catches "Resources materialized from plugin vN" line)
# Historical comments use "(v0.2.11 ...)" or "v0.2.11+" — never end-of-line bare.
PLUGIN_VERSION_EOL=$(grep -cE 'plugin v[0-9]+\.[0-9]+\.[0-9]+[[:space:]]*$' "$INIT" || true)
[ "$PLUGIN_VERSION_EOL" -eq 0 ] && NO_PLUGIN_EOL="yes" || NO_PLUGIN_EOL="no"
assert_eq "init/SKILL.md does NOT have 'plugin vX.Y.Z' at end-of-line (output drift)" "yes" "$NO_PLUGIN_EOL"

print_summary
